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

#ifndef INTEGRATEDSIDEFLUX_H
#define INTEGRATEDSIDEFLUX_H

#include "SideIntegralVariablePostprocessor.h"
#include "MaterialPropertyInterface.h"

//Forward Declarations
class IntegratedSideFlux;

template<>
InputParameters validParams<IntegratedSideFlux>();

/**
 * This postprocessor computes a side integral of the mass flux.
 */
class IntegratedSideFlux : public SideIntegralVariablePostprocessor
{
public:
  IntegratedSideFlux(const InputParameters & parameters);

protected:
  virtual Real computeQpIntegral();

  const MaterialProperty<Real> & _permeability;
  const MaterialProperty<Real> & _mu_h2o;
  const MaterialProperty<Real> & _rho_h2o;
//  VariableValue & _porosity;
};

#endif // INTEGRATEDSIDEFLUX_H
