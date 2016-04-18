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

#include "EvaporationFunction.h"
#include "MooseTypes.h"


template<>
InputParameters validParams<EvaporationFunction>()
{
    InputParameters params = validParams<Function>();
    params.addRequiredParam<PostprocessorName>("PP", "The name of the postprocessor you are trying to get.");
  params.addParam<Real>("HypoTurningPoint",1,"1: 2phase hypothetical turningpoint 0.020mm;3: subsub.i uses postprocessor to get v_exit");
  params.addParam<Real>("UsingHypo",0,"1: useHypoTurningPoint value ");
  //params.addRequiredCoupledVar("temperature", "The temperature of the fluid in the CRUD for chimney BC calculation");
 // params.addRequiredCoupledVar("HBO2", "The HBO2 in the CRUD for chimney BC calculation");
  //params.addParam<Real>("TurningPoint","The turning point y coordinate of different BC");//unit:millimeter
  params.addRequiredParam<PostprocessorName>("TurningPoint", "insection of vapor and liquid");
  return params;
 
}

EvaporationFunction::EvaporationFunction(const std::string & name, InputParameters parameters) :
      Function(name, parameters),
/*
   _k_cond(getMaterialProperty<Real>("k_cond")),
   _HBO2(coupledValue("HBO2")),
   _rho_h2o(getMaterialProperty<Real>("WaterDensity")),
   _h_fg_h2o(getMaterialProperty<Real>("WaterVaporizationEnthalpy")),
  _grad_T(coupledGradient("temperature")),
*/
  _pp(getPostprocessorValue("PP")),
    _HypoTurningPoint(getParam<Real>("HypoTurningPoint")),
    _UsingHypo(getParam<Real>("UsingHypo")),
 // _turningpoint(getParam<Real>("TurningPoint"))
  _turningpoint(getPostprocessorValue("TurningPoint"))
{}

Real
EvaporationFunction::value(Real /*t*/, const Point & p)
{
    Real val = 0;
    Real y = p(1);
    double turningpoint;
  if (_UsingHypo==1)
   turningpoint=_HypoTurningPoint;
 else
 turningpoint=(_turningpoint>0.010? _turningpoint:0.010);
    if      (y>turningpoint)val=15500.;
    else //val=15500000*0.001+4*2.3e-8*_pp/25e-3/2e-3/2e-3*(25*0.001*0.001*25-y*y);
        val=15500000*0.001+4*2.3e-8*_pp/turningpoint/2e-3/2e-3*(turningpoint*turningpoint-y*y);
/*
    else val=-(_k_cond[_qp])
     / (_rho_h2o[_qp] * _h_fg_h2o[_qp])
     * (_grad_T[_qp] * _normals[_qp]);
*/
    return val; // p(0) == x

}
