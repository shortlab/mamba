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

#ifndef POSTPROCESSORFUNCTION_H
#define POSTPROCESSORFUNCTION_H

#include "Function.h"

class PostprocessorFunction;

template<>
InputParameters validParams<PostprocessorFunction>();

class PostprocessorFunction : public Function
{
public:
  PostprocessorFunction(const InputParameters & parameters);

  virtual Real value(Real t, const Point & p);

protected:
//For thickness and CladHeatFlux, I need constant, not point value
//  MaterialProperty<Real> & _thickness;
//  MaterialProperty<Real> & _q_dot_clad;

//  Real _chimney_outer_radius;
  Real _thickness;
  Real _q_dot_in;
  Real _chimney_inner_radius;
  Real _coolant_pressure;
  Real _hfgAt15_5MPa;
  Real _rho_gAt15_5MPa;
  Real _T_coolant;
  Real _h_convection_coolant;
  Real _mu_h2o_chimney;
//  MaterialProperty<Real> & _mu_h2o;
  const PostprocessorValue & _pp1;
  const PostprocessorValue & _pp2;
};

#endif //POSTPROCESSORFUNCTION_H
