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

#include "HeatConductionAux.h"

template<>
InputParameters validParams<HeatConductionAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addRequiredCoupledVar("temperature", "The temperature distribution of the fluid in the CRUD");

  return params;
}

HeatConductionAux::HeatConductionAux(const InputParameters & parameters)
  :AuxKernel(parameters),
  _k_cond(getMaterialProperty<Real>("k_cond")),
//  _mu_h2o(getMaterialProperty<Real>("WaterViscosity")),
//  _porosity(coupledValue("porosity")),
  _grad_T(coupledGradient("temperature"))

{}

Real
HeatConductionAux::computeValue()
{
//  if (_porosity[_qp] > 0.05)
  return -_k_cond[_qp] * (_grad_T[_qp](1));
//  else
//    return 0;
}
