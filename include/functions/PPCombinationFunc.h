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

#ifndef PPCOMBINATIONFUNC_H
#define PPCOMBINATIONFUNC_H

#include "Function.h"

class PPCombinationFunc;

template<>
InputParameters validParams<PPCombinationFunc>();

class PPCombinationFunc : public Function
{
public:
  PPCombinationFunc(const InputParameters & parameters);

  virtual Real value(Real t, const Point & p);

protected:
  const PostprocessorValue & _pp1;
  const PostprocessorValue & _pp2;
  Real _coef1;
  Real _coef2;
  Real _const;
};

#endif //PPCOMBINATIONFUNC_H
