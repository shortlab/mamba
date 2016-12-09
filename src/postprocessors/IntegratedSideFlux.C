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

#include "IntegratedSideFlux.h"

template<>
InputParameters validParams<IntegratedSideFlux>()
{
  InputParameters params = validParams<SideIntegralVariablePostprocessor>();
//  params.addRequiredCoupledVar("porosity", "The porosity of the CRUD");
  return params;
}

IntegratedSideFlux::IntegratedSideFlux(const InputParameters & parameters) :
    SideIntegralVariablePostprocessor(parameters),
    _permeability(getMaterialProperty<Real>("permeability")),
    _mu_h2o(getMaterialProperty<Real>("WaterViscosity")),
    _rho_h2o(getMaterialProperty<Real>("WaterDensity"))
//    _porosity(coupledValue("porosity"))
{}

Real
IntegratedSideFlux::computeQpIntegral()
{
  return -_rho_h2o[_qp]*_permeability[_qp]*_grad_u[_qp]*_normals[_qp]/_mu_h2o[_qp];
}
