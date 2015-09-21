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

#ifndef PRESSUREDARCY_H
#define PRESSUREDARCY_H

#include "Diffusion.h"

//Forward Declarations
class PressureDarcy;

/**
 * validParams returns the parameters that this Kernel accepts / needs
 * The actual body of the function MUST be in the .C file.
 */
template<>
InputParameters validParams<PressureDarcy>();

class PressureDarcy : public Diffusion
{
public:

  PressureDarcy(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();

  /**
   * This MooseArray will hold the reference we need to our
   * material property from the Material class
   */
  MaterialProperty<Real> & _permeability;
  MaterialProperty<Real> & _mu_h2o;
  VariableValue & _porosity;
//  VariableValue & _HBO2;
};
#endif //PRESSUREDARCY_H
