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

#include "BoricAcidSinks.h"

template<>
InputParameters validParams<BoricAcidSinks>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar("Conc_HBO2", "The local concentration of solid metaboric acid");
  return params;
}


BoricAcidSinks::BoricAcidSinks(const InputParameters & parameters)
  :Kernel(parameters),
   _Conc_HBO2(coupledValue("Conc_HBO2"))
{}

Real
BoricAcidSinks::computeQpResidual()
{
//  return -_test[_i][_qp] * (_Conc_HBO2[_qp]);               // The residual is the difference between what's not soluble and what exists already
  return 0;
}
