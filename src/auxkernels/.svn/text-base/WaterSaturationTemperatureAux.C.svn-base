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

#include "WaterSaturationTemperatureAux.h"

template<>
InputParameters validParams<WaterSaturationTemperatureAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addRequiredCoupledVar("total_concentration", "The ionic concentration in the CRUD for temperature chimney BC calculation");
  return params;
}

WaterSaturationTemperatureAux::WaterSaturationTemperatureAux(const std::string & name, InputParameters parameters)
  :AuxKernel(name, parameters),
   _C(coupledValue("total_concentration"))

{}

Real
WaterSaturationTemperatureAux::computeValue()
{
  double C = _C[_qp];
  double _Tsat_h2o = (11453.3 * pow(C, 3)) - (249.862 * pow(C, 2)) + (274.056 * C) + 618.068;

  return _Tsat_h2o;
}
