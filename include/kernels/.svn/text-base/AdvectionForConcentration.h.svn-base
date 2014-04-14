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

#ifndef ADVECTIONFORCONCENTRATION_H
#define ADVECTIONFORCONCENTRATION_H

#include "Kernel.h"

//Forward Declarations
class AdvectionForConcentration;

/**
 * validParams returns the parameters that this Kernel accepts / needs
 * The actual body of the function MUST be in the .C file.
 */
template<>
InputParameters validParams<AdvectionForConcentration>();

class AdvectionForConcentration : public Kernel
{
public:
  
  AdvectionForConcentration(const std::string & name,
                            InputParameters parameters);
  
protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  
  /**
   * This MooseArray will hold the reference we need to our
   * material property from the Material class
   */
  
  VariableGradient & _grad_P;
  MaterialProperty<Real> & _permeability;
  MaterialProperty<Real> & _mu_h2o;
  VariableValue & _porosity;
};
#endif //ADVECTIONFORCONCENTRATION_H
