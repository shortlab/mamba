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

#ifndef EVAPORATIONFUNCTION_H
#define EVAPORATIONFUNCTION_H

#include "Function.h"

class EvaporationFunction;

template<>
InputParameters validParams<EvaporationFunction>();

class EvaporationFunction : public Function
{
  public:
      EvaporationFunction(const std::string & name, InputParameters parameters);

        virtual Real value(Real t, const Point & p);
private:
/*
  MaterialProperty<Real> & _k_cond;
  //VariableValue & _HBO2;
  MaterialProperty<Real> & _rho_h2o;
  MaterialProperty<Real> & _h_fg_h2o;
  VariableGradient & _grad_T;
*/
  PostprocessorValue & _pp;
//  Real _turningpoint;
  Real _HypoTurningPoint;
  Real _UsingHypo;
  PostprocessorValue & _turningpoint;
};

#endif //EvaporationFunction_H
