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
// Heat fields.

#include "AdvectionForHeat.h"

template<>
InputParameters validParams<AdvectionForHeat>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar("porosity", "The porosity of the CRUD for the advection-diffusion balance");
  params.addRequiredCoupledVar("tortuosity", "The tortuosity of the CRUD for the advection-diffusion balance");
  params.addRequiredCoupledVar("pressure", "The pressure of the fluid in the CRUD for the advection-diffusion balance");
  return params;
}

AdvectionForHeat::AdvectionForHeat(const InputParameters & parameters)
    :Kernel(parameters),
     _porosity(coupledValue("porosity")),
     _tortuosity(coupledValue("tortuosity")),
     _grad_P(coupledGradient("pressure")),
     _permeability(getMaterialProperty<Real>("permeability")),
     _mu_h2o(getMaterialProperty<Real>("WaterViscosity")),
     _rho_h2o(getMaterialProperty<Real>("WaterDensity")),
     _cp_h2o(getMaterialProperty<Real>("WaterHeatCapacity"))
{}

Real
AdvectionForHeat::computeQpResidual()
{
  return _test[_i][_qp]
    * _rho_h2o[_qp]
    * _cp_h2o[_qp]
    * _tortuosity[_qp]
    * (_permeability[_qp] / (_mu_h2o[_qp] * _porosity[_qp]))
    * _grad_P[_qp]
    * _grad_u[_qp];
}

Real
AdvectionForHeat::computeQpJacobian()
{
  return _test[_i][_qp]
    * _rho_h2o[_qp]
    * _cp_h2o[_qp]
    * _tortuosity[_qp]
    * (_permeability[_qp] / (_mu_h2o[_qp] * _porosity[_qp]))
    * _grad_P[_qp]
    * _grad_phi[_j][_qp];
}
