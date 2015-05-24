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

#include "PPCombinationFunc.h"
#include "MooseTypes.h"
template<>
InputParameters validParams<PPCombinationFunc>()
{
  InputParameters params = validParams<Function>();
  params.addRequiredParam<PostprocessorName>("pp1", "The name of the postprocessor you are trying to get.");
 params.addRequiredParam<PostprocessorName>("pp2", "The name of the postprocessor you are trying to get.");
  params.addParam<Real>("coef1", 1.0, "multiplied by var1");
  params.addParam<Real>("coef2", 1.0, "multiplied by var2");
  params.addParam<Real>("constval", 0.0, "to avoid 0.0 value for this");
  return params;
}

PPCombinationFunc::PPCombinationFunc(const std::string & name, InputParameters parameters) :
    Function(name, parameters),
    _pp1(getPostprocessorValue("pp1")),
    _pp2(getPostprocessorValue("pp2")),
   _coef1(getParam<Real>("coef1")),
   _coef2(getParam<Real>("coef2")),
   _const(getParam<Real>("constval"))
{
}

Real
PPCombinationFunc::value(Real t, const Point & p)
{
  return (_pp1-_pp2)*(_coef1-p(1))/_coef1+_pp2;//(_pp1+_coef1>_const)? (_pp1+_coef1):_const;
 // return _coef1*_pp1*p(1) + _coef2*_pp2*p(1) +_pp2+ _const;
}
