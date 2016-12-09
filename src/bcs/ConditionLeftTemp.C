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

#include "ConditionLeftTemp.h"

template<>
InputParameters validParams<ConditionLeftTemp>()
{
  InputParameters params = validParams<NodalBC>();

  //params.addRequiredCoupledVar("anotherVar", "Coupled variable");
  params.addParam<Real>("coef1", 1.0, "multiplied by var1");
  params.addParam<Real>("constval", 0.0, "added");
  params.addRequiredParam<PostprocessorName>("TurningPoint", "insection of vapor and liquid");
  params.addParam<Real>("HypoTurningPoint",1,"1: 2phase hypothetical turningpoint 0.020mm;3: subsub.i uses postprocessor to get v_exit");
  params.addParam<Real>("UsingHypo",0,"1: useHypoTurningPoint value ");
 // params.addParam<Real>("TurningPoint",0.0125,"");
  return params;
}

ConditionLeftTemp::ConditionLeftTemp(const InputParameters & parameters)
 :NodalBC(parameters),
   //_coupledvar(coupledValue("anotherVar")),
   _coef1(getParam<Real>("coef1")),
    _HypoTurningPoint(getParam<Real>("HypoTurningPoint")),
    _UsingHypo(getParam<Real>("UsingHypo")),
  // _pp(getPostprocessorValue("PP")),
   _const(getParam<Real>("constval")),
   _turningpoint(getPostprocessorValue("TurningPoint"))
 //  _turningpoint(getParam<Real>("TurningPoint"))
{}

Real
ConditionLeftTemp::computeQpResidual()
{
  Real y = (*_current_node)(1);
  double turningpoint;
  if (_UsingHypo==1)
   turningpoint=_HypoTurningPoint;
 else
 turningpoint=(_turningpoint>0.010? _turningpoint:0.010);
  if (y<turningpoint)
  //return _u[_qp]-(_coef1*_coupledvar[_qp]*(_coef2-y)+ _const);
  //  return _u[_qp]-(((_const-_pp)/_turningpoint)*y+ _pp);
  return _u[_qp]-(((_const-_coef1)/turningpoint)*y+ _coef1);
  else
    return _u[_qp]-_const;

//    return (_u[_qp] - 620);
}
