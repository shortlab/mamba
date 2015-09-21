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

// This file computes the tortuosity from the true porosity (soluble
// + insoluble) of the CRUD. It uses the relation from Eq. ___ from
// Boming Chen's Appl. Mech. Rev. (2008).
//
// The tortuosity is used to calculate the fractal parameters of the
// CRUD, and ultimately the permeability to Darcy flow in the
// pressure field.
//
// The tortuosity is also used to scale diffusivities down, since it
// takes longer for ions to diffuse through twisty passages (along
// larger effective path lengths) than wide open fluid. Diffusivities
// are divided by the tortuosity to get the effective diffusivities.

#include "TortuosityAux.h"

template<>
InputParameters validParams<TortuosityAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addRequiredCoupledVar("porosity", "Local porosity of the CRUD)");
  return params;
}

TortuosityAux::TortuosityAux(const InputParameters & parameters)
  :AuxKernel(parameters),
   _porosity(coupledValue("porosity"))

{}

Real
TortuosityAux::computeValue()
{
  double tau;

  double A = sqrt(1 - _porosity[_qp]);

  tau = 0.5 * (1 + (0.5 * A) + A * ((sqrt(pow(((1 / A) - 1), 2) + 0.25)) / (1 - A)));

  return tau;
}
