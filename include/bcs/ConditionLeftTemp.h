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


#ifndef CONDITIONLEFTTEMP_H
#define CONDITIONLEFTTEMP_H

#include "NodalBC.h"
//Forward Declarations
class ConditionLeftTemp;

template<>
InputParameters validParams<ConditionLeftTemp>();

class ConditionLeftTemp : public NodalBC
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  ConditionLeftTemp(const InputParameters & parameters);
  virtual ~ConditionLeftTemp(){}
protected:
  virtual Real computeQpResidual();

private:

  //VariableValue & _coupledvar;
  Real _coef1;
  Real _HypoTurningPoint;
  Real _UsingHypo;
  Real _const;
  PostprocessorValue & _turningpoint;
 // Real _turningpoint;
};

#endif //ConditionLeftTemp_H
