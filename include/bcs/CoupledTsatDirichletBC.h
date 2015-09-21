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

#include "NodalBC.h"

#ifndef COUPLEDTSATDIRICHLETBC_H
#define COUPLEDTSATDIRICHLETBC_H

//Forward Declarations
class CoupledTsatDirichletBC;

template<>
InputParameters validParams<CoupledTsatDirichletBC>();

class CoupledTsatDirichletBC : public NodalBC
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  CoupledTsatDirichletBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();

private:

  VariableValue & _Tsat_h2o;
//  VariableValue & _HBO2;
//  VariableValue & _C;
};

#endif //COUPLEDTSATDIRICHLETBC_H
