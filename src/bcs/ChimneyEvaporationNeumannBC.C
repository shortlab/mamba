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

// This file sets a Neumann (gradient-based) boundary condition in
// the pressure distribution. It takes the gradient of the temperature,
// which when scaled with relevant physical parameters, tells you
// how fast heat must be leaving the surface.
//
// It makes the assumption that any heat that leaves the chimney
// is a result of wick boiling, AND that the water/vapor interface
// lies at the CRUD/chimney boundary.
//
// It therefore requires the thermal conductivity, the density of
// water, and the enthalpy of vaporization of water (all computed
// as material properties).
//
// This may have to be modified for precipitation, to assume that
// no heat leaves areas where the fluid pores are clogged. That's
// why the commented-out (1 - HBO2) factor is there, to kill any
// heat flux in the event of HBO2 (or other) precipitation.
//
// Also, (_grad_T[_qp] * _normals[_qp]) is a useful way to get
// the temperature gradient at the boundary, NO MATTER where the
// boundary is, what shape, etc. This makes it mesh- and geometry-
// agnostic, which itself makes the code much more useful.

#include "ChimneyEvaporationNeumannBC.h"

template<>
InputParameters validParams<ChimneyEvaporationNeumannBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredCoupledVar("temperature", "The temperature of the fluid in the CRUD for chimney BC calculation");
  params.addRequiredCoupledVar("HBO2", "The HBO2 in the CRUD for chimney BC calculation");
  params.addRequiredCoupledVar("porosity", "the porosity of CRUD");
  params.addCoupledVar("VaporHeatCond",0, "heat from vapor part");
  return params;
}

ChimneyEvaporationNeumannBC::ChimneyEvaporationNeumannBC(const std::string & name, InputParameters parameters)
 :IntegratedBC(name, parameters),
   _k_cond(getMaterialProperty<Real>("k_cond")),
   _HBO2(coupledValue("HBO2")),
   _porosity(coupledValue("porosity")),
   _rho_h2o(getMaterialProperty<Real>("WaterDensity")),
   _h_fg_h2o(getMaterialProperty<Real>("WaterVaporizationEnthalpy")),
  _grad_T(coupledGradient("temperature")),
  _vaporheatcond(coupledValue("VaporHeatCond"))
{}

Real
ChimneyEvaporationNeumannBC::computeQpResidual()
{
// The (1 - _HBO2[_qp]) multiplier effectively kills the heat flux out the chimney (and therefore stops fluid flow)
// at any locations that precipitation has occurred.

   double vaporheatcond = (_t_step<=1  || _vaporheatcond[_qp]<8.0e5)? 8.0e5: _vaporheatcond[_qp];


    Real wPrecip = -_test[_i][_qp] * (_k_cond[_qp] * (1 - _HBO2[_qp])) / (_rho_h2o[_qp] * _h_fg_h2o[_qp] * _porosity[_qp]) * (_grad_T[_qp] * _normals[_qp]);

// This one doesn't stop flow for precipitation

    Real woPrecip = -_test[_i][_qp]
     / (_rho_h2o[_qp] * _h_fg_h2o[_qp]* _porosity[_qp])
     * ((-vaporheatcond + _grad_T[_qp] * _k_cond[_qp]* _normals[_qp]));
    return woPrecip;

// QUESTION TO ASK: in the case of precipitation, could I force a zero gradient by setting
// the residual equal to grad_P, to force a natural boundary condition at precipitated locations?
// That would mean no flow out those locations, implying a zero fluid velocity towards the chimney there.
}
