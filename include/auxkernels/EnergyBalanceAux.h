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

#ifndef ENERGYBALANCEAUX_H
#define ENERGYBALANCEAUX_H
#include "AuxKernel.h"

//Forward Declarations
class EnergyBalanceAux;

template<>
InputParameters validParams<EnergyBalanceAux>();

/**
 * Coupled auxiliary value
 */
class EnergyBalanceAux : public AuxKernel
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  EnergyBalanceAux(const std::string & name, InputParameters parameters);

protected:
  virtual Real computeValue();

  PostprocessorValue & _G;
  PostprocessorValue & _T_avg;
  PostprocessorValue & _h_liquid;
  MaterialProperty<Real> & _r_inner;
  MaterialProperty<Real> & _r_outer;
  MaterialProperty<Real> & _h_fg_h2o;
  MaterialProperty<Real> & _c_pv;
  MaterialProperty<Real> & _c_pl;
  MaterialProperty<Real> & _h_convection;
  MaterialProperty<Real> & _q_dot;
  VariableValue & _T_sat;
  Real _T_coolant;
  Real _coef1;
  Real _coef2;
  Real _const;
};

#endif //EnergyBalanceAUX_H
