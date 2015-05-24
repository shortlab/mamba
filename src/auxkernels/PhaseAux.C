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

// This file implements the advection component of a generalized
// advection-diffusion-reaction-precipitation relation. It takes
// in the pressure field, the CRUD permeability, the CRUD porosity,
// and the CRUD fluid viscosity, which should be common to all
// Heat fields.

#include "PhaseAux.h"

template<>
InputParameters validParams<PhaseAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addParam<Real>("deltaP", 1, "A parameter used to determined the inclination of Phase curve");
  params.addRequiredCoupledVar("psat", "Saturation pressure given temperature");
  params.addRequiredCoupledVar("pressure", "Pressure of the CRUD for thermal condictivity calculation (water pressure)");
  params.addParam<Real>("Shift",0.0,"to describe superheated liquid");
  return params;
}

PhaseAux::PhaseAux(const std::string & name,
                     InputParameters parameters)
    :AuxKernel(name,parameters),
     _psat(coupledValue("psat")),
     _P(coupledValue("pressure")),
    // _tortuosity(coupledValue("tortuosity")),
     _deltaP(getParam<Real>("deltaP")),
     _shift(getParam<Real>("Shift"))
    // _phase(getMaterialProperty<Real>("PhaseFlag"))
{}

Real
PhaseAux::computeValue()
{
  
  //return _phase[_qp];
  if ((_P[_qp] - (_psat[_qp]-_shift))/_deltaP >= 10)
     return 0;
  else if ((_P[_qp] - (_psat[_qp]-_shift))/_deltaP <= -10)
     return 1;
  else
  return  1.0 / (exp((_P[_qp] - (_psat[_qp]-_shift))/_deltaP)+1);
    
}
