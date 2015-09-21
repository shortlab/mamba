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

#include "CapillaryPressureAux.h"

template<>
InputParameters validParams<CapillaryPressureAux>()
{
  InputParameters params = validParams<AuxKernel>();
  return params;
}

CapillaryPressureAux::CapillaryPressureAux(const InputParameters & parameters)
    :AuxKernel(parameters),
    // _porosity(coupledValue("porosity")),
    // _tortuosity(coupledValue("tortuosity")),
    // _grad_P(coupledGradient("pressure")),
     _surfacetension(getMaterialProperty<Real>("SurfaceTension")),
     _pore_size_min(getMaterialProperty<Real>("pore_size_min"))
//diameter, unit has been changed into mm in CRUDMaterial.C
{}

Real
CapillaryPressureAux::computeValue()
{
  

  
  return 4 * _surfacetension[_qp]
    / _pore_size_min[_qp];

    
}
