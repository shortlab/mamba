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

#include "NodalMinValue.h"

#include <algorithm>
#include <limits>

template<>
InputParameters validParams<NodalMinValue>()
{
  InputParameters params = validParams<NodalVariablePostprocessor>();
  return params;
}

NodalMinValue::NodalMinValue(const InputParameters & parameters) :
  NodalVariablePostprocessor(parameters),
  _value(std::numeric_limits<Real>::max())
{}

void
NodalMinValue::initialize()
{
  _value = -std::numeric_limits<Real>::max();
}

void
NodalMinValue::execute()
{
  _value = std::max(_value, -_u[_qp]);
}

Real
NodalMinValue::getValue()
{
  gatherMax(_value);
  return -_value;
}

void
NodalMinValue::threadJoin(const UserObject & y)
{
  const NodalMinValue & pps = static_cast<const NodalMinValue &>(y);
  _value = std::min(_value, pps._value);
}
