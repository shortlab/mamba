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

#ifndef HEATCONDUCTIONAUX_H
#define HEATCONDUCTIONAUX_H

#include "AuxKernel.h"


//Forward Declarations
class HeatConductionAux;

template<>
InputParameters validParams<HeatConductionAux>();

/**
 * Coupled auxiliary value
 */
class HeatConductionAux : public AuxKernel
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  HeatConductionAux(const std::string & name, InputParameters parameters);

protected:
  virtual Real computeValue();

  MaterialProperty<Real> & _k_cond;
  //MaterialProperty<Real> & _mu_h2o;
  //VariableValue & _porosity;
  VariableGradient & _grad_T;

};

#endif //HeatConductionAux_H
