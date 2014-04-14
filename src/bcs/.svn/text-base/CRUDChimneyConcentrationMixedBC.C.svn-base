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

// This file implements a "no flux" boundary condition at the
// CRUD/chimney interface. It basically says that advection of
// species must equal diffusion at this interface, since fluid
// advection is pushing the solutes towards the boiling chimney,
// but diffusion works against the gradient created.
//
// This boundary condition will therefore have to incorporate
// chemical changes once they are modeled. I don't quite know
// how to do that yet, but it may be as simple as adding source
// and sink terms to this BC (and the concentration field) for
// each chemical reaction.
//
// (_permeability[_qp] / (_mu_h2o[_qp] * _porosity[_qp])) * (_grad_P[_qp] * _normals[_qp])
// gives the fluid velocity at the boundary due to advection,
// since v=(permeability/viscosity*porosity)*grad_P

#include "CRUDChimneyConcentrationMixedBC.h"

template<>
InputParameters validParams<CRUDChimneyConcentrationMixedBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredCoupledVar("pressure", "The pressure of the fluid in the CRUD for concentration BC calculation");
  params.addRequiredCoupledVar("porosity", "The porosity of the CRUD for concentration BC calculation");
  params.addRequiredParam<std::string>("diffusivity","The real material property (here is it a diffusivity) to use in this boundary condition");
  return params;
}

CRUDChimneyConcentrationMixedBC::CRUDChimneyConcentrationMixedBC(const std::string & name, InputParameters parameters)
 :IntegratedBC(name, parameters),
  _permeability(getMaterialProperty<Real>("permeability")),
  _mu_h2o(getMaterialProperty<Real>("WaterViscosity")),
  _grad_P(coupledGradient("pressure")),
  _porosity(coupledValue("porosity")),
  _prop_name(getParam<std::string>("diffusivity")),
  _D_species(getMaterialProperty<Real>(_prop_name))
{}

Real
CRUDChimneyConcentrationMixedBC::computeQpResidual()
{
//  if (_porosity[_qp] > 0.05)
    return _test[_i][_qp] * (_permeability[_qp] / (_mu_h2o[_qp] * _porosity[_qp])) * (_grad_P[_qp] * _normals[_qp]) * (_u[_qp]);
//  else
//    return 1e-3;
}
