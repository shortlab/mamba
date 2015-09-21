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

#ifndef NODALMAXVALUEFILEIO_H
#define NODALMAXVALUEFILEIO_H

#include "NodalVariablePostprocessor.h"

class MooseVariable;

//Forward Declarations
class NodalMaxValueFileIO;

template<>
InputParameters validParams<NodalMaxValueFileIO>();

class NodalMaxValueFileIO : public NodalVariablePostprocessor
{
public:
  NodalMaxValueFileIO(const InputParameters & parameters);

  virtual void initialize();
  virtual void execute();
  virtual Real getValue();
  virtual void threadJoin(const UserObject & y);

protected:
  Real _value;
};

#endif
