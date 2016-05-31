/****************************************************************/
/*             DO NOT MODIFY OR REMOVE THIS HEADER              */
/*          FALCON - Fracturing And Liquid CONvection           */
/*                                                              */
/*       (c) pending 2012 Battelle Energy Alliance, LLC         */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#ifndef FALCONVELOCITYAUX_H
#define FALCONVELOCITYAUX_H

#include "AuxKernel.h"


//Forward Declarations
class FalconVelocityAux;

template<>
InputParameters validParams<FalconVelocityAux>();

/**
 * Coupled auxiliary value
 */
class FalconVelocityAux : public AuxKernel
{
public:

  /**
   * Factory constructor, takes parameters so that all
   * derived classes can be built using the same
   * constructor.
   */
  FalconVelocityAux(const InputParameters & parameters);

  virtual ~FalconVelocityAux() {}

protected:
  virtual Real computeValue();

  const MaterialProperty<RealGradient> & _darcy_flux_water;
  const MaterialProperty<RealGradient> & _darcy_flux_steam;
  int _i;

};

#endif //FALCONVELOCITYAUX_H
