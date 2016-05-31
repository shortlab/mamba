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

#ifndef FLUIDMASSFLUXAUX_H
#define FLUIDMASSFLUXAUX_H

#include "AuxKernel.h"


//Forward Declarations
class FluidMassFluxAux;

template<>
InputParameters validParams<FluidMassFluxAux>();

/**
 * Coupled auxiliary value
 */
class FluidMassFluxAux : public AuxKernel
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  FluidMassFluxAux(const InputParameters & parameters);

protected:
  virtual Real computeValue();

  const MaterialProperty<Real> & _permeability;
  const MaterialProperty<Real> & _mu_h2o;
  const MaterialProperty<Real> & _rho_h2o;
 // VariableValue & _porosity;
  const VariableGradient & _grad_P;

};

#endif //FLUIDMassFluxAUX_H
