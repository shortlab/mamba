//This file is used to apply boundary condition at vapor region chimney. Energy conservation

#include "ChimneyEnthalpyFlow.h"

template<>
InputParameters validParams<ChimneyEnthalpyFlow>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredCoupledVar("pressure", "The pressure of the fluid in the CRUD for chimney BC calculation");
  return params;
}

ChimneyEnthalpyFlow::ChimneyEnthalpyFlow(const InputParameters & parameters)
    :IntegratedBC(parameters),
   _rho_g(getMaterialProperty<Real>("WaterDensity")),
   _h_g(getMaterialProperty<Real>("VaporEnthalpy")),
   _kappa(getMaterialProperty<Real>("permeability")),
   _mu_g(getMaterialProperty<Real>("WaterViscosity")),
  _grad_P(coupledGradient("pressure"))
{}

Real
ChimneyEnthalpyFlow::computeQpResidual()
{

    Real residual = -_test[_i][_qp] *
         _rho_g[_qp] * _h_g[_qp] * _kappa[_qp] / _mu_g[_qp]
         * _grad_P[_qp] * _normals[_qp];

    return residual;
}
