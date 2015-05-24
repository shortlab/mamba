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

#include "VelocityExit.h"

template<>
InputParameters validParams<VelocityExit>()
{
  InputParameters params = validParams<GeneralPostprocessor>();
  params.addRequiredParam<PostprocessorName>("pp1", "The name of the postprocessor you are trying to get.");
  params.addParam<Real>("HypoTurningPoint",1,"1: 2phase hypothetical turningpoint 0.020mm;3: subsub.i uses postprocessor to get v_exit");
  params.addParam<Real>("UsingHypo",0,"1: useHypoTurningPoint value ");
//  params.addRequiredCoupledVar("porosity", "porosity of the CRUD for material calculations");
  params.addParam<Real>("WaterViscosityInChimney",2e-8,"The vapor viscosity in chimney");
  params.addParam<Real>("ChimneyInnerRadius",0.002,"The radius of chimney");
  params.addParam<Real>("ChimneyOuterRadius",0.0125,"The radius of chimney");
  params.addParam<Real>("CladHeatFluxIn",1e6,"The heat flux from the clad-crud interface");
  params.addParam<Real>("CRUDThickness",0.025,"As the name said");
  params.addParam<Real>("CoolantPressure",15500,"15.5MPa");
  params.addParam<Real>("hfgAt15_5MPa",1.0e3,"As the name said");
  params.addParam<Real>("rho_gAt15_5MPa",1.0e-7,"As the name said");
  params.addParam<Real>("T_coolant",600.0,"The radius of chimney");
  params.addParam<Real>("h_convection_coolant",1.2e5,"Between crud and coolant");
  params.addParam<Real>("TurningPoint",0.02,"Between crud and coolant");
//  params.addRequiredParam<PostprocessorName>("TurningPoint", "insection of vapor and liquid");
  return params;
}

VelocityExit::VelocityExit(const std::string & name, InputParameters parameters) :
    GeneralPostprocessor(name, parameters),
//    _thickness(getMaterialProperty<Real>("crud_thickness")),
    _thickness(getParam<Real>("CRUDThickness")),
    _HypoTurningPoint(getParam<Real>("HypoTurningPoint")),
    _UsingHypo(getParam<Real>("UsingHypo")),
//    _q_dot_in(getMaterialProperty<Real>("CladHeatFlux")),
    _q_dot_in(getParam<Real>("CladHeatFluxIn")),
    _chimney_inner_radius(getParam<Real>("ChimneyInnerRadius")),
    _chimney_outer_radius(getParam<Real>("ChimneyOuterRadius")),
    _coolant_pressure(getParam<Real>("CoolantPressure")),
    _hfgAt15_5MPa(getParam<Real>("hfgAt15_5MPa")),
    _rho_gAt15_5MPa(getParam<Real>("rho_gAt15_5MPa")),
    _T_coolant(getParam<Real>("T_coolant")),
    _h_convection_coolant(getParam<Real>("h_convection_coolant")),
    _mu_h2o_chimney(getParam<Real>("WaterViscosityInChimney")),
 //   _turningpoint(getPostprocessorValue("TurningPoint")),
    _turningpoint(getParam<Real>("TurningPoint")),
    _pp1(getPostprocessorValue("pp1"))
   // _porosity(coupledValue("porosity"))
{
}

Real
VelocityExit::getValue()
{
// All unit need changing into mm  
//  double upsideBC_area = _pp2;
  double _porosity=0.5;
  double thickness=_thickness;
  double turningpoint;
  if (_UsingHypo==1)
   turningpoint=_HypoTurningPoint;
 else
 turningpoint=(_turningpoint>0.010? _turningpoint:0.010);
  double upsideBC_area =libMesh::pi*
(std::pow(_chimney_outer_radius, 2) - std::pow(_chimney_inner_radius, 2));
  double m_dot = (upsideBC_area * _q_dot_in * _porosity 
                 - _h_convection_coolant * _pp1 * upsideBC_area * _porosity
                 + _h_convection_coolant * _T_coolant * upsideBC_area * _porosity)/ _hfgAt15_5MPa;//taking porosity into account.
 // std::cout<< m_dot << std::endl;
//Calculate the velocity of vapor coming from the interface inside CRUD
  double vo = m_dot*
              upsideBC_area/(2.0*libMesh::pi*_chimney_inner_radius*(thickness-turningpoint) +upsideBC_area)
              / _rho_gAt15_5MPa / (libMesh::pi * std::pow(_chimney_inner_radius, 2)) ;
  return vo;
}
