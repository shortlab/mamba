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

#include "LiquidInterfaceVelocity.h"
#include "FEProblem.h"

template<>
InputParameters validParams<LiquidInterfaceVelocity>()
{
  InputParameters params = validParams<GeneralPostprocessor>();

  params.addParam<PostprocessorName>("MinTemp", "The minimum temperature in liquid part");
  params.addParam<PostprocessorName>("MaxTemp", "The maximum temperature in liquid part");
  params.addParam<PostprocessorName>("VaporHeight", "The maximum temperature in liquid part");
  params.addParam<Real>("cell_inner_radius", 2e-6, "meter, This is the inner raduis of our unit crud cell");
  params.addParam<Real>("cell_outer_radius", 12.5e-6, "meter, This is the outer radius of our unit crud cell, calculated from chimney density on a piece of crud area");

  return params;
}

LiquidInterfaceVelocity::LiquidInterfaceVelocity(const InputParameters & parameters) :
    GeneralPostprocessor(parameters),
    _MinTemp(getPostprocessorValue("MinTemp")),
    _MaxTemp(getPostprocessorValue("MaxTemp")),
    _Hv(getPostprocessorValue("VaporHeight")),
    _r_inner(getParam<Real>("cell_inner_radius")),
    _r_outer(getParam<Real>("cell_outer_radius"))
{}

Real
LiquidInterfaceVelocity::getValue()
{
  double Ptemp=15550000;//Pa
  double permeability=2.29489e-15;//m
  double Tsat=618.0685;//K
  double T_l=(Tsat-_MinTemp)/2+_MinTemp;//This temperature is used to calcualte the rho_l
  double T_v=(Tsat-_MaxTemp)/2+_MaxTemp;//This temperature is used to calculate the rho_v
  double mu_v= 11.4 / (1.37e6 - 844 * T_v - std::pow(T_v, 2)); //Pa*s
  double rho_v=0.576
    + Ptemp * (2.483e-5 - 1.41e-12* Ptemp)
    + (Ptemp / T_v) * (-2.616e-2 + 1.016e-9* Ptemp + 7.589/T_v);//kg/m^3
  double rho_l=-4276
    + (53.24 * T_l)
    - (0.1953 * std::pow(T_l, 2))
    + (3.097e-4 * std::pow(T_l, 3))
    - (1.824e-7 * std::pow(T_l, 4));//kg/m^3
  double g=9.8;//m/s^2
  double u_v=permeability*(rho_l-rho_v)/mu_v*g;
  double v_l=(rho_v*u_v*(_Hv*1e-3)*2*libMesh::pi*_r_inner) /
             (rho_l*libMesh::pi*(pow(_r_outer,2)-pow(_r_inner,2)));
  //std::cout<<"rho_v= " << rho_v <<std::endl;
  //std::cout<< "rho_l= "<< rho_l <<std::endl;
  //std::cout<<"mu_v=" << mu_v <<std::endl;
  //std::cout<<"u_v=" <<u_v<<std::endl;
  return  (v_l*1e3);//change to mm/s
}
