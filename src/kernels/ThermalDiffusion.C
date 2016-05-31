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

#include "ThermalDiffusion.h"

template<>
InputParameters validParams<ThermalDiffusion>()
{
  InputParameters params = validParams<Diffusion>();
  return params;
}


ThermalDiffusion::ThermalDiffusion(const InputParameters & parameters)
  :Diffusion(parameters),
   _k_cond(getMaterialProperty<Real>("k_cond"))
{}

Real
ThermalDiffusion::computeQpResidual()
{
  // We're dereferencing the _k_cond pointer to get to the
  // material properties vector... which gives us one property
  // value per quadrature point.

  // Also... we're reusing the Diffusion Kernel's residual
  // so that we don't have to recode that.
  return _k_cond[_qp] * Diffusion::computeQpResidual();
}

Real
ThermalDiffusion::computeQpJacobian()
{
  return _k_cond[_qp] * Diffusion::computeQpJacobian();
}
