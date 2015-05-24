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

#include "PostprocessorFunction.h"
#include "MooseTypes.h"

template<>
InputParameters validParams<PostprocessorFunction>()
{
  InputParameters params = validParams<Function>();
  params.addRequiredParam<PostprocessorName>("pp1", "The name of the postprocessor you are trying to get.");
  params.addRequiredParam<PostprocessorName>("pp2", "The name of the postprocessor you are trying to get.");
  params.addParam<Real>("WaterViscosityInChimney",2e-8,"The vapor viscosity in chimney");
  params.addParam<Real>("ChimneyInnerRadius",0.002,"The radius of chimney");
  params.addParam<Real>("CladHeatFluxIn",1e6,"The heat flux from the clad-crud interface");
  params.addParam<Real>("CRUDThickness",0.025,"As the name said");
  params.addParam<Real>("CoolantPressure",15500,"15.5MPa");
  params.addParam<Real>("hfgAt15_5MPa",1.0e3,"As the name said");
  params.addParam<Real>("rho_gAt15_5MPa",1.0e-7,"As the name said");
  params.addParam<Real>("T_coolant",600.0,"The radius of chimney");
  params.addParam<Real>("h_convection_coolant",1.2e5,"Between crud and coolant");
  return params;
}

PostprocessorFunction::PostprocessorFunction(const std::string & name, InputParameters parameters) :
    Function(name, parameters),
//    _thickness(getMaterialProperty<Real>("crud_thickness")),
    _thickness(getParam<Real>("CRUDThickness")),
//    _q_dot_clad(getMaterialProperty<Real>("CladHeatFlux")),
    _q_dot_in(getParam<Real>("CladHeatFluxIn")),
    _chimney_inner_radius(getParam<Real>("ChimneyInnerRadius")),
//    _chimney_outer_radius(getParam<Real>("ChimneyOuterRadius")),
    _coolant_pressure(getParam<Real>("CoolantPressure")),
    _hfgAt15_5MPa(getParam<Real>("hfgAt15_5MPa")),
    _rho_gAt15_5MPa(getParam<Real>("rho_gAt15_5MPa")),
    _T_coolant(getParam<Real>("T_coolant")),
    _h_convection_coolant(getParam<Real>("h_convection_coolant")),
    _mu_h2o_chimney(getParam<Real>("WaterViscosityInChimney")),
    _pp1(getPostprocessorValue("pp1")),
    _pp2(getPostprocessorValue("pp2"))
{
}

Real
PostprocessorFunction::value(Real /*t*/, const Point & p)
{
// All unit need changing into mm  
  double upsideBC_area = _pp2;
  double m_dot = (upsideBC_area * _q_dot_in 
                 - _h_convection_coolant * _pp1 
                 + _h_convection_coolant * _T_coolant * _pp2)
                 / _hfgAt15_5MPa;
  double vo = m_dot / _rho_gAt15_5MPa 
              / (libMesh::pi * std::pow(_chimney_inner_radius, 2)) ;
  double Pressure = _coolant_pressure + 16 * vo * _mu_h2o_chimney * 
            (std::pow(_thickness, 2) - std::pow(p(1), 2)) / 
            std::pow(2 * _chimney_inner_radius, 2) / _thickness;
//p(2)==z
  double alpha = 16 * vo * _mu_h2o_chimney / 
            std::pow(2 * _chimney_inner_radius, 2) / _thickness;
  double C = _coolant_pressure + alpha * std::pow(_thickness, 2);
  std::cout << "alpha= " << alpha << std::endl;   
  std::cout << "C= " << C << std::endl;   
  std::cout << "p(1) = " << p(1) << std::endl;  
  std::cout << "P = " << Pressure << std::endl; 
  return Pressure;
}
