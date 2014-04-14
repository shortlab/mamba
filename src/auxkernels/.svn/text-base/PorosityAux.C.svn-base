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

// This file computes the true porosity of the CRUD, by starting
// with the skeletal porosity handed down from MAMBA-MACRO. This
// skeletal porosity is the porosity of the insoluble skeleton of
// iron and nickel oxides.
//
// The porosity then decreases to a smaller value once soluble
// species (such as HBO2) fill up the pores.

#include "PorosityAux.h"

template<>
InputParameters validParams<PorosityAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addParam<Real>("skeleton", 0.5, "Baseline skeletal porosity of the CRUD, handed down from macro-MAMBA");
//  params.addCoupledVar("HBO2", "The local concentration of metaboric acid for porosity calculation");
  return params;
}

PorosityAux::PorosityAux(const std::string & name, InputParameters parameters)
  :AuxKernel(name, parameters),
   _porosity_skeletal(getParam<Real>("skeleton"))
//   _HBO2(coupledValue("HBO2"))

{}

Real
PorosityAux::computeValue()
{
// This one cuts the porosity down in the case of precipitation

//    Real porositywPrecip = (1 - _HBO2[_qp]) * _porosity_skeletal;
    Real porositywPrecip = _porosity_skeletal;
    Real porositywoPrecip = _porosity_skeletal;

    if (porositywPrecip != porositywoPrecip)
    {
//	    std::cout << "PorositywPrecip = " << porositywPrecip << std::endl;
//	    std::cout << "PorositywoPrecip = " << porositywoPrecip << std::endl;
    }

    return porositywoPrecip;

// This one doesn't change porosity for precipitation

//    return _porosity_skeletal;
}
