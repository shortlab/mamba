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

#include "PecletAux.h"

template<>
InputParameters validParams<PecletAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addRequiredCoupledVar("porosity", "The porosity of the CRUD for the advection-diffusion balance");
  params.addRequiredCoupledVar("tortuosity", "The tortuosity of the CRUD for the advection-diffusion balance");
  params.addRequiredCoupledVar("pressure",
                               "The pressure of the fluid in the CRUD for the advection-diffusion balance");
  return params;
}

PecletAux::PecletAux(const std::string & name,
                     InputParameters parameters)
    :AuxKernel(name,parameters),
     _porosity(coupledValue("porosity")),
     _tortuosity(coupledValue("tortuosity")),
     _grad_P(coupledGradient("pressure")),
     _k_crud(getMaterialProperty<Real>("k_cond")),
     _permeability(getMaterialProperty<Real>("permeability")),
     _mu_h2o(getMaterialProperty<Real>("WaterViscosity")),
     _rho_h2o(getMaterialProperty<Real>("WaterDensity")),
     _cp_h2o(getMaterialProperty<Real>("WaterHeatCapacity")),
     _d_for_PecletAux(getMaterialProperty<Real>("WaterViscosity"))
{}

Real
PecletAux::computeValue()
{
  
  // The Peclet number is (L*rho*Cp*v/k)
  
  return _rho_h2o[_qp]
    * _tortuosity[_qp]
    * _cp_h2o[_qp]
    * (_permeability[_qp] / (_mu_h2o[_qp] * _porosity[_qp]))  // Here we're using the superficial velocity
    * (std::abs(_grad_P[_qp](0)) + std::abs(_grad_P[_qp](1)) + std::abs(_grad_P[_qp](2)))
    / _k_crud[_qp];
}
