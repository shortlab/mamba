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

#include "BO3_SolubilityAux.h"

// This file calculates the solubility of boric acid in solution, given the
// temperature and initial (non-equilibrium) concentration of BO3 ion.
// The data were calculated using FactSage as functions of [BO3], [Li],
// and temperature. Iron and nickel soluble concentrations were kept at 2.5ppb.
//
// The solubility is given in mole fraction in the fluid.

template<>
InputParameters validParams<BO3_SolubilityAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addRequiredCoupledVar("temperature", "The temperature of the CRUD in Kelvin");
  //params.addParam<Real>("initial_BO3_mole_fraction", 3e-7, "This is minimum pore size in the CRUD, acquired from TEM foils");
  params.addRequiredCoupledVar("Conc_BO3", "The concentration of the borate ion in the CRUD (mole fraction)");
//  params.addRequiredCoupledVar("Conc_HBO2", "The concentration of metaboric acid in the CRUD (mole fraction)");
  return params;
}

BO3_SolubilityAux::BO3_SolubilityAux(const InputParameters & parameters)
  :AuxKernel(parameters),
  _temperature(coupledValue("temperature")),
//  _init_BO3(getParam<Real>("initial_BO3_mole_fraction"))
  _Conc_BO3(coupledValue("Conc_BO3"))
//  _Conc_HBO2(coupledValue("Conc_HBO2"))
{}

Real
BO3_SolubilityAux::computeValue()
{
  double B_tot = _Conc_BO3[_qp];      // This is the total moles of boron present in all forms at this _qp
  double AddTerm = (-12.917 * pow(B_tot, 2)) + (0.349819 * B_tot) - 0.000179077;	// The addative term of the solubility equation
  double MultTerm = (1.89443 * pow(B_tot, 2)) - (0.0603893 * B_tot) + 0.00269831;	// The multiplicative term of the solubility equation
  double T_end = (107425 * pow(B_tot, 2)) - (3498.13 * B_tot) + 819.274;		// The temperature at which BO3 solublility drops to zero

  double soluble_BO3 = AddTerm + MultTerm * log(T_end - _temperature[_qp]);		// This gives the mole fraction of soluble BO3 at this _qp

  return soluble_BO3;
}
