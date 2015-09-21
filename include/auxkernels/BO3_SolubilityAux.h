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

#ifndef BO3_SOLUBILITYAUX_H
#define BO3_SOLUBILITYAUX_H

#include "AuxKernel.h"


//Forward Declarations
class BO3_SolubilityAux;

template<>
InputParameters validParams<BO3_SolubilityAux>();

class BO3_SolubilityAux : public AuxKernel
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  BO3_SolubilityAux(const InputParameters & parameters);

protected:
  virtual Real computeValue();

  VariableValue & _temperature;
  VariableValue & _Conc_BO3;
//  VariableValue & _Conc_HBO2;
};

#endif //BO3_SOLUBILITYAUX_H
