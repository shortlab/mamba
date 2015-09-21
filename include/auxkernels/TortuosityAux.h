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

#ifndef TORTUOSITYAUX_H
#define TORTUOSITYAUX_H

#include "AuxKernel.h"


//Forward Declarations
class TortuosityAux;

template<>
InputParameters validParams<TortuosityAux>();

/**
 * Coupled auxiliary value
 */
class TortuosityAux : public AuxKernel
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  TortuosityAux(const InputParameters & parameters);

protected:
  virtual Real computeValue();

  VariableValue & _porosity;

};

#endif //TORTUOSITYAUX_H
