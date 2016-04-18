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

#include "PressureDarcy.h"

template<>
InputParameters validParams<PressureDarcy>()
{
  InputParameters params = validParams<Diffusion>();
  params.addRequiredCoupledVar("porosity", "The porosity of the CRUD for the pressure field calculation");
//  params.addRequiredCoupledVar("HBO2", "The HBO2 in the CRUD for the pressure field calculation");
  return params;
}


PressureDarcy::PressureDarcy(const std::string & name,
                                   InputParameters parameters)
  :Diffusion(name,parameters),
   _permeability(getMaterialProperty<Real>("permeability")),
   _mu_h2o(getMaterialProperty<Real>("WaterViscosity")),
   _porosity(coupledValue("porosity"))
//   _HBO2(coupledValue("HBO2"))
{}

Real
PressureDarcy::computeQpResidual()
{
    return (_permeability[_qp] / _mu_h2o[_qp] / _porosity[_qp])
           * Diffusion::computeQpResidual();

}

Real
PressureDarcy::computeQpJacobian()
{
    return (_permeability[_qp] / (_mu_h2o[_qp] * _porosity[_qp])) 
           * Diffusion::computeQpJacobian();

//    return (1 - _HBO2[_qp]) * (_permeability[_qp] / _mu_h2o[_qp]) * Diffusion::computeQpJacobian();
}
