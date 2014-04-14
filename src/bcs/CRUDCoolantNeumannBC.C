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

// This file implements heat transfer from the hotter CRUD fluid
// out to the coolant. It makes no assumptions about the boundary
// layer. Proper coupling between MAMBA-BDM and CFD will result in
// the CFD code computing the temperature and heat transfer coefficient
// in the boundary layer, and feeding that to MAMBA-MACRO, which will
// in turn be fed to MAMBA-BDM.

#include "CRUDCoolantNeumannBC.h"

template<>
InputParameters validParams<CRUDCoolantNeumannBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredParam<Real>("T_coolant", "The temperature of the bulk coolant");
  params.addRequiredParam<Real>("h_convection_coolant", "The heat transfer coefficient of the bulk coolant");

  return params;
}

CRUDCoolantNeumannBC::CRUDCoolantNeumannBC(const std::string & name, InputParameters parameters)
 :IntegratedBC(name, parameters),
  _T_coolant(getParam<Real>("T_coolant")),
  _h_convection_coolant(getParam<Real>("h_convection_coolant"))
{}

Real
CRUDCoolantNeumannBC::computeQpResidual()
{
  return _h_convection_coolant * _test[_i][_qp] * (_u[_qp] - _T_coolant);
}
