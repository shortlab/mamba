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

#ifndef ADVECTIONFORHEAT_H
#define ADVECTIONFORHEAT_H

#include "Kernel.h"

//Forward Declarations
class AdvectionForHeat;

/**
 * validParams returns the parameters that this Kernel accepts / needs
 * The actual body of the function MUST be in the .C file.
 */
template<>
InputParameters validParams<AdvectionForHeat>();

class AdvectionForHeat : public Kernel
{
public:

  AdvectionForHeat(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();

  /**
   * This MooseArray will hold the reference we need to our
   * material property from the Material class
   */

  const VariableValue & _porosity;
  const VariableValue & _tortuosity;
  const VariableGradient & _grad_P;
  const MaterialProperty<Real> & _permeability;
  const MaterialProperty<Real> & _mu_h2o;
  const MaterialProperty<Real> & _rho_h2o;
  const MaterialProperty<Real> & _cp_h2o;
};
#endif //ADVECTIONFORHEAT_H
