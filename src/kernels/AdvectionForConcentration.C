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

// This file implements the advection component of a generalized
// advection-diffusion-reaction-precipitation relation. It takes
// in the pressure field, the CRUD permeability, the CRUD porosity,
// and the CRUD fluid viscosity, which should be common to all
// concentration fields.

#include "AdvectionForConcentration.h"

template<>
InputParameters validParams<AdvectionForConcentration>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar("pressure",
                               "The pressure of the fluid in the CRUD for the advection-diffusion balance");
  params.addRequiredCoupledVar("porosity",
                               "The porosity of the CRUD for the advection-diffusion balance");
  return params;
}

AdvectionForConcentration::AdvectionForConcentration(const InputParameters & parameters)
    :Kernel(parameters),
     _grad_P(coupledGradient("pressure")),
     _permeability(getMaterialProperty<Real>("permeability")),
     _mu_h2o(getMaterialProperty<Real>("WaterViscosity")),
     _porosity(coupledValue("porosity"))
{}

Real
AdvectionForConcentration::computeQpResidual()
{
//  if (_porosity[_qp] > 0.05)
  return -_test[_i][_qp]
    * (_permeability[_qp] / (_mu_h2o[_qp] * _porosity[_qp]))
    * _grad_P[_qp]
    * _grad_u[_qp];
//  else
//    return 0;
}

Real
AdvectionForConcentration::computeQpJacobian()
{
//  if (_porosity[_qp] > 0.05)
  return -_test[_i][_qp]
    * ((_permeability[_qp] / (_mu_h2o[_qp] * _porosity[_qp])) * _grad_P[_qp]* _grad_phi[_j][_qp]);
//  else
//    return 0;
}
