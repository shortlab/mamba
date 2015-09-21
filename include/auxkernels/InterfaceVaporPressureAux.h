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

#ifndef INTERFACEVAPORPRESSUREAUX_H
#define INTERFACEVAPORPRESSUREAUX_H

#include "AuxKernel.h"

//Forward Declarations
class InterfaceVaporPressureAux;

/**
 * validParams returns the parameters that this Kernel accepts / needs
 * The actual body of the function MUST be in the .C file.
 */
template<>
InputParameters validParams<InterfaceVaporPressureAux>();

class InterfaceVaporPressureAux : public AuxKernel
{
public:
  
  InterfaceVaporPressureAux(const InputParameters & parameters);
  
protected:
  virtual Real computeValue();
  
  /**
   * This MooseArray will hold the reference we need to our
   * material property from the Material class
   */
  
  VariableValue & _pc;
  VariableValue & _pl;


};
#endif //InterfaceVaporPressureAux_H
