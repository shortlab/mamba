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

// This file computes the saturation temperature of the fluid in
// the CRUD, based on the concentrations of soluble species in it.
//
// For now, it assumes that all boron-bearing ions in the
// 'total_concentration' count as monoborate ions, what I think
// is a valid assumption.
//
// The relation was adapted from Jeff Deshon's 2004 EPRI report
// on "Guildelines for AOA, Revision 1."

#include "SuperheatTempAux.h"

template<>
InputParameters validParams<SuperheatTempAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addRequiredCoupledVar("temperature", "The temperature of the fluid in the CRUD");
  params.addRequiredCoupledVar("t_sat", "The saturation temperature of the fluid in the CRUD");
  return params;
}

SuperheatTempAux::SuperheatTempAux(const InputParameters & parameters)
  :AuxKernel(parameters),
   _T(coupledValue("temperature")),
   _T_sat(coupledValue("t_sat"))

{}

Real
SuperheatTempAux::computeValue()
{
  return _T[_qp] - _T_sat[_qp];
}
