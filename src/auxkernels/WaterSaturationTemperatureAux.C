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

// This file computes the saturation temperature of the fluid in
// the CRUD, based on the concentrations of soluble species in it.
//
// For now, it assumes that all boron-bearing ions in the
// 'total_concentration' count as monoborate ions, what I think
// is a valid assumption.
//
// The relation was adapted from Jeff Deshon's 2004 EPRI report
// on "Guildelines for AOA, Revision 1."

#include "WaterSaturationTemperatureAux.h"

template<>
InputParameters validParams<WaterSaturationTemperatureAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addCoupledVar("concentration", "The list of ions whose molal concentration would be used in the CRUD for temperature chimney BC calculation");
  params.addCoupledVar("pressure", 15500,"pressure field");
  return params;
}

WaterSaturationTemperatureAux::WaterSaturationTemperatureAux(const InputParameters & parameters)
  :AuxKernel(parameters),
  _p(coupledValue("pressure"))
{
  int n = coupledComponents("concentration");
  _vals.resize(n);
  for (unsigned int i=0; i<_vals.size(); ++i)
    _vals[i] = & coupledValue("concentration", i);
}

Real
WaterSaturationTemperatureAux::computeValue()
{
  Real a_w = 1.0;
  Real m_c = 0.0;
  Real m_w = 55.509;//mol/kg for water
  if (_vals.size())
  {
    for (unsigned int i=0; i<_vals.size(); ++i)
      m_c += (*_vals[i])[_qp];
    a_w = m_w/(m_w+m_c);
  }
  
  Real A=-0.387592e3;
  Real B=-0.125875e5;
  Real C=-0.152578e2;
  double Ptemp = (isParamValid("pressure") ? _p[_qp] : 15500) /1000;//change to MPa
  Real Tsat_pureh2o=A+B/(std::log(Ptemp)+C);//From Steam and Gas Tables with Computer Equations

  double _Tsat_h2o = Tsat_pureh2o+199.01*(1-a_w)
                     -952.74*std::pow((1-a_w),2)
                     +26013.91*std::pow((1-a_w),3)
                     -262916.0*std::pow((1-a_w),4)
                     +997166.1*std::pow((1-a_w),5);//K
  return _Tsat_h2o;
}
