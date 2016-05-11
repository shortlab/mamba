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

#include "ECofLiBO2.h"
//This auxkernel is to calculate the equilibrium constant of
//LiBO_2(s)+H_2O+H^+\rightleftharpoons Li^++B(OH)_3
template<>
InputParameters validParams<ECofLiBO2>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addRequiredCoupledVar("temperature", "The temperature of the CRUD in Kelvin");
  return params;
}

ECofLiBO2::ECofLiBO2(const InputParameters & parameters)
  :AuxKernel(parameters),
  _temperature(coupledValue("temperature"))
{}

Real
ECofLiBO2::computeValue()
{
  return (5.249217 + 1185.683 / _temperature[_qp]);//return lgkw
}
