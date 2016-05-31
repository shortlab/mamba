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

// This file outputs the fluid velocity inside the CRUD fluid
// ***IN THE X-DIRECTION***
//
// It is used to get the maximum fluid speed heading towards the
// boiling chimney.
//
// A later version will output the scalar value of the fluid velocity
// at all locations, and could be used to relax the Darcy flow assumption.
// It is certainly possible that the tiny pores in the CRUD could restrict
// fluid velocity, leading to degraded heat transfer, an increase in
// temperature, and reduced boiling heat flux.
//
// In this case, a higher temperature (and gradient) must be established
// in order to transfer the remaining heat out the top of the CRUD.
//
// ***NOTE***: This idea has NOT been addressed by ANY models yet, and
// could comprise a large 'missing link' between physical understanding
// and fuel performance.

#include "FluidMassFluxAux.h"

template<>
InputParameters validParams<FluidMassFluxAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addRequiredCoupledVar("pressure", "The pressure distribution of the fluid in the CRUD");
  //params.addRequiredCoupledVar("porosity", "The porosity of the CRUD");
  return params;
}

FluidMassFluxAux::FluidMassFluxAux(const InputParameters & parameters)
  :AuxKernel(parameters),
  _permeability(getMaterialProperty<Real>("permeability")),
  _mu_h2o(getMaterialProperty<Real>("WaterViscosity")),
  _rho_h2o(getMaterialProperty<Real>("WaterDensity")),
 // _porosity(coupledValue("porosity")),
  _grad_P(coupledGradient("pressure"))

{}

Real
FluidMassFluxAux::computeValue()
{
//  if (_porosity[_qp] > 0.05)
  return -_permeability[_qp] * _rho_h2o[_qp]* (_grad_P[_qp](1)) / (_mu_h2o[_qp]);
//  else
//    return 0;
}
