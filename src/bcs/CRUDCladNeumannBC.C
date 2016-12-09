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

// This file is a simple implementation of a forced heat flux
// coming from the cladding. All it does is read the value from
// the input file in MW/m^2.

#include "CRUDCladNeumannBC.h"

template<>
InputParameters validParams<CRUDCladNeumannBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  return params;
}

CRUDCladNeumannBC::CRUDCladNeumannBC(const InputParameters & parameters)
    :IntegratedBC(parameters),
  _q_dot(getMaterialProperty<Real>("CladHeatFlux"))
{}

Real
CRUDCladNeumannBC::computeQpResidual()
{
  return -_test[_i][_qp] * _q_dot[_qp];
}
