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

#ifndef CHIMNEYENTHALPYFLOW_H
#define CHIMNEYENTHALPYFLOW_H

//Forward Declarations
class ChimneyEnthalpyFlow;

template<>
InputParameters validParams<ChimneyEnthalpyFlow>();

/**
 * Implements a simple constant Neumann BC where grad(u)=alpha * v on the boundary.
 * Uses the term produced from integrating the diffusion operator by parts.
 */
class ChimneyEnthalpyFlow : public IntegratedBC
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  ChimneyEnthalpyFlow(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();

private:

  MaterialProperty<Real> & _rho_g;
  MaterialProperty<Real> & _h_g;
  MaterialProperty<Real> & _kappa;
  MaterialProperty<Real> & _mu_g;
  VariableGradient & _grad_P;
};

#endif //ChimneyEnthalpyFlow_H
