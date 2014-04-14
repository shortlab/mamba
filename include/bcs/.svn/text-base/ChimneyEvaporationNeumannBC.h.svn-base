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

#ifndef CHIMNEYEVAPORATIONNEUMANNBC_H
#define CHIMNEYEVAPORATIONNEUMANNBC_H

//Forward Declarations
class ChimneyEvaporationNeumannBC;

template<>
InputParameters validParams<ChimneyEvaporationNeumannBC>();

/**
 * Implements a simple constant Neumann BC where grad(u)=alpha * v on the boundary.
 * Uses the term produced from integrating the diffusion operator by parts.
 */
class ChimneyEvaporationNeumannBC : public IntegratedBC
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  ChimneyEvaporationNeumannBC(const std::string & name, InputParameters parameters);

protected:
  virtual Real computeQpResidual();

private:

  MaterialProperty<Real> & _k_cond;
  VariableValue & _HBO2;
  MaterialProperty<Real> & _rho_h2o;
  MaterialProperty<Real> & _h_fg_h2o;
  VariableGradient & _grad_T;
};

#endif //CHIMNEYEVAPORATIONNEUMANNBC_H
