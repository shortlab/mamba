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

#ifndef MULTIAPPSAMPLEPOSTPROCESSORTRANSFERFLUX_H
#define MULTIAPPSAMPLEPOSTPROCESSORTRANSFERFLUX_H

#include "MultiAppSamplePostprocessorTransferBase.h"

class MultiAppSamplePostprocessorTransferFlux;

template<>
InputParameters validParams<MultiAppSamplePostprocessorTransferFlux>();

/**
 * Samples a variable's value in the Master domain at the point where the MultiApp is.
 * Copies that value into a postprocessor in the MultiApp.
 */
class MultiAppSamplePostprocessorTransferFlux :
  public MultiAppSamplePostprocessorTransferBase
{
public:
  MultiAppSamplePostprocessorTransferFlux(const InputParameters & parameters);
  virtual ~MultiAppSamplePostprocessorTransferFlux() {}

  virtual void execute();
  virtual Real getValue(MooseVariable & variable) const;

protected:

  // The normal to use with the gradient:
  std::vector<Point> _normal;

  // Hard-coded material property:
  Real _mat_prop;
};

#endif /* MULTIAPPSAMPLEPOSTPROCESSORTRANSFERFLUX_H */
