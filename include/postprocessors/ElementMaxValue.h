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

#ifndef ELEMENTMAXVALUE_H
#define ELEMENTMAXVALUE_H

#include "ElementIntegralVariablePostprocessor.h"

//Forward Declarations
class ElementMaxValue;

template<>
InputParameters validParams<ElementMaxValue>();

/**
 * This postprocessor returns the maximum value of the specified variable.
 */
class ElementMaxValue : public ElementIntegralVariablePostprocessor
{
public:
  ElementMaxValue(const InputParameters & parameters);

  virtual void initialize();
  virtual Real computeValue();
  virtual void execute();
  virtual Real getValue();

  //virtual void threadJoin(const UserObject & y);

protected:
  Real _value;
  unsigned int _node_id;
};

#endif
