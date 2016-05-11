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

#ifndef PRECIPITATION_HBO2AUX_H
#define PRECIPITATION_HBO2AUX_H

#include "AuxKernel.h"


//Forward Declarations
class Precipitation_HBO2Aux;

template<>
InputParameters validParams<Precipitation_HBO2Aux>();

class Precipitation_HBO2Aux : public AuxKernel
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  Precipitation_HBO2Aux(const InputParameters & parameters);

protected:
  virtual Real computeValue();

  const VariableValue & _temperature;
  const VariableValue & _BO3_Solubility;
  const VariableValue & _Conc_BO3;

};

#endif //PRECIPITATION_HBO2AUX_H
