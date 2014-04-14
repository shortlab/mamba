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

#include "IntegratedBC.h"

#ifndef CRUDCLADNEUMANNBC_H
#define CRUDCLADNEUMANNBC_H

//Forward Declarations
class CRUDCladNeumannBC;

template<>
InputParameters validParams<CRUDCladNeumannBC>();

/**
 * Implements a simple constant Neumann BC where grad(u)=alpha * v on the boundary.
 * Uses the term produced from integrating the diffusion operator by parts.
 */
class CRUDCladNeumannBC : public IntegratedBC
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  CRUDCladNeumannBC(const std::string & name, InputParameters parameters);

protected:
  virtual Real computeQpResidual();

private:

  MaterialProperty<Real> & _q_dot;
};

#endif //CRUDCLADNEUMANNBC_H
