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

#ifndef WATERSATURATIONPRESSURE_H
#define WATERSATURATIONPRESSURE_H

#include "AuxKernel.h"


//Forward Declarations
class WaterSaturationPressureAux;

template<>
InputParameters validParams<WaterSaturationPressureAux>();

/**
 * Coupled auxiliary value
 */
class WaterSaturationPressureAux : public AuxKernel
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  WaterSaturationPressureAux(const InputParameters & parameters);

protected:
  virtual Real computeValue();
  VariableValue & _capillary;
  MaterialProperty<Real> & _rho_h2o;
  VariableValue & _crud_temperature;
  std::vector<VariableValue *> _vals;

};

#endif //WATERSATURATIONTEMPERATURE_H
