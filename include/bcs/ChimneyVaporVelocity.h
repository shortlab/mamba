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

//This boundary condition is calculate vapor velocity coming out from crud to chimney based on mass conservation

#include "IntegratedBC.h"

#ifndef CHIMNEYVAPORVELOCITY_H
#define CHIMNEYVAPORVELOCITY_H

//Forward Declarations
class ChimneyVaporVelocity;

template<>
InputParameters validParams<ChimneyVaporVelocity>();

/**
 * Implements a simple constant Neumann BC where grad(u)=alpha * v on the boundary.
 * Uses the term produced from integrating the diffusion operator by parts.
 */
class ChimneyVaporVelocity : public IntegratedBC
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  ChimneyVaporVelocity(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();

private:

  MaterialProperty<Real> & _r_inner;
  MaterialProperty<Real> & _r_outer;
  PostprocessorValue & _h;
  PostprocessorValue & _m_dot;
  MaterialProperty<Real> & _rho_h2o;
};

#endif //ChimneyVaporVelocity_H
