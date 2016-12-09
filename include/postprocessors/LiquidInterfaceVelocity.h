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

#ifndef LIQUIDINTERFACEVELOCITY_H
#define LIQUIDINTERFACEVELOCITY_H

#include "GeneralPostprocessor.h"

//Forward Declarations
class LiquidInterfaceVelocity;

template<>
InputParameters validParams<LiquidInterfaceVelocity>();

class LiquidInterfaceVelocity : public GeneralPostprocessor
{
public:
  LiquidInterfaceVelocity(const InputParameters & parameters);

  virtual void initialize() {}
  virtual void execute() {}

  /**
   * This will return the current time step size.
   */
  virtual Real getValue();

protected:
  const PostprocessorValue & _MinTemp;
  const PostprocessorValue & _MaxTemp;
  const PostprocessorValue & _Hv;
  Real _r_inner;
  Real _r_outer;
};

#endif //LiquidInterfaceVelocity_H
