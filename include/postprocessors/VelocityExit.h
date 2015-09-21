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

#ifndef VELOCITYEXIT_H
#define VELOCITYEXIT_H

#include "GeneralPostprocessor.h"

class VelocityExit;

template<>
InputParameters validParams<VelocityExit>();

class VelocityExit : public GeneralPostprocessor
{
public:
  VelocityExit(const InputParameters & parameters);

  virtual void initialize() {}
  virtual void execute() {}
  virtual Real getValue();

protected:

//For thickness and CladHeatFlux, I need constant, not point value
//  MaterialProperty<Real> & _thickness;
//  MaterialProperty<Real> & _q_dot_clad;

//  Real _chimney_outer_radius;
//  MaterialProperty<Real> & _thickness;
//  MaterialProperty<Real> & _q_dot_in;
  Real _thickness;
  Real _HypoTurningPoint;
  Real _UsingHypo;
  Real _q_dot_in;
  Real _chimney_inner_radius;
  Real _chimney_outer_radius;
  Real _coolant_pressure;
  Real _hfgAt15_5MPa;
  Real _rho_gAt15_5MPa;
  Real _T_coolant;
  Real _h_convection_coolant;
  Real _mu_h2o_chimney;
  Real _turningpoint;
 // PostprocessorValue & _turningpoint;

  PostprocessorValue & _pp1;
  
 // VariableValue & _porosity;
};

#endif //VelocityExit_H
