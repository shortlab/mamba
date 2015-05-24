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

#include "ConductivityFieldAux.h"

template<>
InputParameters validParams<ConductivityFieldAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addRequiredCoupledVar("porosity", "porosity of the CRUD for material calculations");
  return params;
}

ConductivityFieldAux::ConductivityFieldAux(const std::string & name,
                     InputParameters parameters)
    :AuxKernel(name,parameters),
     _porosity(coupledValue("porosity")),
    // _tortuosity(coupledValue("tortuosity")),
    // _grad_P(coupledGradient("pressure")),
     _permeability(getMaterialProperty<Real>("permeability")),
     _mu_h2o(getMaterialProperty<Real>("WaterViscosity"))
//diameter, unit has been changed into mm in CRUDMaterial.C
{}

Real
ConductivityFieldAux::computeValue()
{
  

  
  return  _permeability[_qp]
    / _porosity[_qp]/_mu_h2o[_qp];

    
}
