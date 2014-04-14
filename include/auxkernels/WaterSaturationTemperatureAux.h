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

#ifndef WATERSATURATIONTEMPERATURE_H
#define WATERSATURATIONTEMPERATURE_H

#include "AuxKernel.h"


//Forward Declarations
class WaterSaturationTemperatureAux;

template<>
InputParameters validParams<WaterSaturationTemperatureAux>();

/**
 * Coupled auxiliary value
 */
class WaterSaturationTemperatureAux : public AuxKernel
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  WaterSaturationTemperatureAux(const std::string & name, InputParameters parameters);

protected:
  virtual Real computeValue();

  VariableValue & _C;

};

#endif //WATERSATURATIONTEMPERATURE_H
