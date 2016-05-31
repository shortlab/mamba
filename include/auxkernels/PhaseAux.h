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

#ifndef PHASEAUX_H
#define PHASEAUX_H

#include "AuxKernel.h"

//Forward Declarations
class PhaseAux;

/**
 * validParams returns the parameters that this Kernel accepts / needs
 * The actual body of the function MUST be in the .C file.
 */
template<>
InputParameters validParams<PhaseAux>();

class PhaseAux : public AuxKernel
{
public:

  PhaseAux(const InputParameters & parameters);

protected:
  virtual Real computeValue();

  /**
   * This MooseArray will hold the reference we need to our
   * material property from the Material class
   */
private:

  const VariableValue & _psat;
  const VariableValue & _P;
  Real _deltaP;
  Real _shift;

};
#endif //PHASEAUX_H
