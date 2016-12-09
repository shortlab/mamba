/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#include "EnergyBalanceAux.h"
//return _coef1*_var1[_qp] + _coef2*_var2[_qp] + _const;


template<>
InputParameters validParams<EnergyBalanceAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addRequiredCoupledVar("T_sat", "Coupled variable");
  params.addRequiredParam<PostprocessorName>("SuctionMassFlux", "The name of the postprocessor you are trying to get.");
  params.addRequiredParam<PostprocessorName>("CoolantCrudTempAvg", "The name of the postprocessor you are trying to get.");
  params.addRequiredParam<PostprocessorName>("LiquidHeight", "The name of the postprocessor you are trying to get.");
  params.addParam<Real>("CoolantTemperature",584.0, "");
 // params.addRequiredCoupledVar("var2", "Subtrahend variable");
  params.addParam<Real>("coef1", 1.0, "multiplied by var1");
  params.addParam<Real>("coef2", 1.0, "multiplied by var2");
  params.addParam<Real>("constval", 0.0, "added");
  return params;
}

EnergyBalanceAux::EnergyBalanceAux(const InputParameters & parameters) :
    AuxKernel(parameters),
    _G(getPostprocessorValue("SuctionMassFlux")),
    _T_avg(getPostprocessorValue("CoolantCrudTempAvg")),
    _h_liquid(getPostprocessorValue("LiquidHeight")),
    _r_inner(getMaterialProperty<Real>("CellInnerRadius")),
    _r_outer(getMaterialProperty<Real>("CellOuterRadius")),
    _h_fg_h2o(getMaterialProperty<Real>("WaterVaporizationEnthalpy")),
    _c_pv(getMaterialProperty<Real>("VaporHeatCapacity")),
    _c_pl(getMaterialProperty<Real>("WaterHeatCapacity")),
    _h_convection(getMaterialProperty<Real>("ConvectionCoefficient")),
    _q_dot(getMaterialProperty<Real>("CladHeatFlux")),
    _T_sat(coupledValue("T_sat")),
     _T_coolant(getParam<Real>("CoolantTemperature")),
    _coef1(getParam<Real>("coef1")),
   _coef2(getParam<Real>("coef2")),
   _const(getParam<Real>("constval"))

{}

Real EnergyBalanceAux::computeValue()
{
  //return _coef1*_var1[_qp] + _coef2*_var2[_qp] + _const;
  double E_source = _q_dot[_qp];//from cladding
  double E_sink1 = _h_convection[_qp] * (_T_avg-_T_coolant); //convection with coolant
  double E_sink2 = _G * _h_fg_h2o[_qp]; //evaporation energy loss
  double E_sink3 = _c_pl[_qp] * _G * (_T_sat[_qp] - _T_avg); // water temperature increase
  //double E_sink4 = vapor temperature increase;
  double G_vapor = (pow(_r_outer[_qp],2)-pow(_r_inner[_qp],2))/
                 (pow(_r_outer[_qp],2)-pow(_r_inner[_qp],2)+_h_liquid*2*_r_inner[_qp]) * _G;
  return ((E_source-E_sink1-E_sink2-E_sink3)/(G_vapor * _c_pv[_qp]) +_T_sat[_qp]);
}
