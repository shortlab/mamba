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

#ifndef SUPERHEATTEMPAUX_H
#define SUPERHEATTEMPAUX_H

#include "AuxKernel.h"


//Forward Declarations
class SuperheatTempAux;

template<>
InputParameters validParams<SuperheatTempAux>();

/**
 * Coupled auxiliary value
 */
class SuperheatTempAux : public AuxKernel
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  SuperheatTempAux(const std::string & name, InputParameters parameters);

protected:
  virtual Real computeValue();

  VariableValue & _T;
  VariableValue & _T_sat;

};

#endif //SUPERHEATTEMPAUX_H
