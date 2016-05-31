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

#ifndef CRUDCHIMNEYCONCENTRATIONMIXEDBC_H
#define CRUDCHIMNEYCONCENTRATIONMIXEDBC_H

//Forward Declarations
class CRUDChimneyConcentrationMixedBC;

template<>
InputParameters validParams<CRUDChimneyConcentrationMixedBC>();

/**
 * Implements a simple constant Neumann BC where grad(u)=alpha * v on the boundary.
 * Uses the term produced from integrating the diffusion operator by parts.
 */
class CRUDChimneyConcentrationMixedBC : public IntegratedBC
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  CRUDChimneyConcentrationMixedBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();

private:

  const MaterialProperty<Real> & _permeability;
  const MaterialProperty<Real> & _mu_h2o;
  const VariableGradient & _grad_P;
  const VariableValue & _porosity;

// This is an abstracted way to get different diffusivities into this kernel

  std::string _prop_name;

  const MaterialProperty<Real> & _D_species;
};

#endif //CRUDCHIMNEYCONCENTRATIONMIXEDBC_H
