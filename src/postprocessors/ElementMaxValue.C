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

#include "ElementMaxValue.h"
#include "MooseMesh.h"
#include "SubProblem.h"
// libMesh
#include "libmesh/boundary_info.h"

template<>
InputParameters validParams<ElementMaxValue>()
{
  InputParameters params = validParams<ElementIntegralVariablePostprocessor>();
  return params;
}

ElementMaxValue::ElementMaxValue(const std::string & name, InputParameters parameters) :
    ElementIntegralVariablePostprocessor(name, parameters),
    _value(-std::numeric_limits<Real>::max())
{
}

void
ElementMaxValue::initialize()
{
  _value = -std::numeric_limits<Real>::max();
}

Real
ElementMaxValue::computeValue()
{
  return _u[_qp];
}

void
ElementMaxValue::execute()
{
  Real val = computeValue();

  if (val > _value)
  {
    _value = val;
    _node_id = _current_elem->id();
    //_node_id = _current_node->id();
  }
}

Real
ElementMaxValue::getValue()
{
  gatherProxyValueMax(_value, _node_id);
  return _node_id;
}
/*
void
ElementMaxValue::threadJoin(const UserObject & y)
{
  const ElementMaxValue & pps = static_cast<const ElementMaxValue &>(y);
  if (pps._value > _value)
  {
    _value = pps._value;
    _node_id = pps._node_id;
  }
}*/
