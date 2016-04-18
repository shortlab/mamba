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

// This file gives a 0/1 "phase field" of whether or not precipitation
// has occurred. It doesn't return exactly '1' because doing so
// would cause some 'divide by zero' errors elsewhere. There are
// a number of conditions in the form (X * (1 - HBO2)), so making
// HBO2 = 0.99999 effectively zeroes out terms in the precipitated
// field without crashing the simulation.

#include "Precipitation_HBO2Aux.h"

template<>
InputParameters validParams<Precipitation_HBO2Aux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addRequiredCoupledVar("temperature", "The temperature of the CRUD in Kelvin");
  params.addRequiredCoupledVar("BO3_Solubility", "The coupled solubility of the borate ion in the CRUD (mole fraction)");
  params.addRequiredCoupledVar("Conc_BO3", "The concentration of the borate ion in the CRUD (mole fraction)");
  return params;
}

Precipitation_HBO2Aux::Precipitation_HBO2Aux(const std::string & name, InputParameters parameters)
  :AuxKernel(name, parameters),
  _temperature(coupledValue("temperature")),
  _BO3_Solubility(coupledValue("BO3_Solubility")),
  _Conc_BO3(coupledValue("Conc_BO3"))
{}

Real
Precipitation_HBO2Aux::computeValue()
{
  if (_Conc_BO3[_qp] <= (_BO3_Solubility[_qp]))
    return 0;
  else
    return 0.99;	// The precipitate is the difference between what's not soluble and what exists already
}
