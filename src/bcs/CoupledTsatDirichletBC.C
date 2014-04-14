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

// This file sets the temperature of the CRUD at the boiling chimney
// to equal the saturation temperature, set by the concentration of
// soluble species in the CRUD fluid.
//
// This makes the ASSUMPTION that all heat transfer at the CRUD/
// chimney is due to wick boiling, and that the CRUD doesn't dry
// out.
//
// This assumption may need to be relaxed if dryout occurs,
// especially if Darcy flow doesn't apply and fluid velocities are
// restricted.
//
// UPDATE NEEDED: I need a way to "turn off" this boundary
// condition in the case of precipitation. What I really want is
// for a Dirichlet boundary condition if no precipitation has
// occurred, and for a natural boundary condition if the pores
// are clogged. This will give the physically significant result of
// rapid heat-up in the event of precipitation, since the boiling
// heat transfer will necessarily move up to the regions that aren't
// clogged.
//
// I forsee a serious positive feedback effect in this scenario,
// especially in the event of an RIA. ***NOTE***: This effect hasn't
// been elucidated yet, and could be a very important transient
// effect to consider.

#include "CoupledTsatDirichletBC.h"

template<>
InputParameters validParams<CoupledTsatDirichletBC>()
{
  InputParameters params = validParams<NodalBC>();

  params.addRequiredCoupledVar("Tsat", "The water saturation temperature in the CRUD for temperature chimney BC calculation");
  params.addRequiredCoupledVar("HBO2", "The HBO2 in the CRUD for temperature chimney BC calculation");
  params.addRequiredCoupledVar("BO3", "The BO3 in the CRUD for temperature chimney BC calculation");
  return params;
}

CoupledTsatDirichletBC::CoupledTsatDirichletBC(const std::string & name, InputParameters parameters)
 :NodalBC(name, parameters),
  _Tsat_h2o(coupledValue("Tsat")),
  _HBO2(coupledValue("HBO2")),
  _C(coupledValue("BO3"))
{}

Real
CoupledTsatDirichletBC::computeQpResidual()
{
//  if (_HBO2[_qp] < 0.05)	// If the pores aren't clogged, fix the temperature at Tsat to assume wick boiling at the chimney
    return (_u[_qp] - _Tsat_h2o[_qp]);
//  else		// If the pores are clogged, apply a natural boundary condition to show no heat transfer out of the clogged pores
//    return (_u[_qp] - 620);
}
