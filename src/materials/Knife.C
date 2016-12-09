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

#include "Knife.h"

template<>
InputParameters validParams<Knife>()
{
  InputParameters params = validParams<Material>();

  params.addRequiredCoupledVar("temperature", "Temperature of the material");

  return params;
}

Knife::Knife(const std::string & name,
                           InputParameters parameters)
    :Material(name, parameters),

     // Declare material properties that kernels can use
     _k_cond(declareProperty<Real>("k_cond")),

     _T(coupledValue("temperature"))
{
}

void
Knife::computeQpProperties()
{
  _k_cond[_qp] = 51;
}
