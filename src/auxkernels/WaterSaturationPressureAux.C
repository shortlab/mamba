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

#include "WaterSaturationPressureAux.h"

template<>
InputParameters validParams<WaterSaturationPressureAux>()
{
  InputParameters params = validParams<AuxKernel>();
params.addRequiredCoupledVar("temperature", "The ionic concentration in the CRUD for temperature chimney BC calculation");
  params.addRequiredCoupledVar("capillary", "Capillary pressure leading to vapor pressure lowering");
  params.addCoupledVar("concentration", "The list of ions whose molal concentration would be used in the CRUD for temperature chimney BC calculation");
  return params;
}

WaterSaturationPressureAux::WaterSaturationPressureAux(const std::string & name, InputParameters parameters)
  :AuxKernel(name, parameters),
   _capillary(coupledValue("capillary")),
   _rho_h2o(getMaterialProperty<Real>("WaterDensity")),
   _crud_temperature(coupledValue("temperature"))
{
  int n = coupledComponents("concentration");
  _vals.resize(n);
  for (unsigned int i=0; i<_vals.size(); ++i)
    _vals[i] = & coupledValue("concentration", i);
}
// International Equations for the Satruration Properties of Ordinary Water... 1990 Wagner and Pruss
Real
WaterSaturationPressureAux::computeValue()
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
// In order to use the water diagram, introduce a temperature correction because of different solutes.
  double R=8.3144621e6;//change to mm
  double _T_correction = 199.01*(1-a_w)
                     -952.74*std::pow((1-a_w),2)
                     +26013.91*std::pow((1-a_w),3)
                     -262916.0*std::pow((1-a_w),4)
                     +997166.1*std::pow((1-a_w),5);//K

  double a1 = -7.85951783;
  double a2 =  1.84408259;
  double a3 = -11.7866497;
  double a4 =  22.6807411;
  double a5 = -15.9618719;
  double a6 =  1.80122502;
  double Tc =  647.096;//K
  double pc =  22064;//KPa
  double crud_temperature=_crud_temperature[_qp];//superheat
  double tau = 1 - (crud_temperature) / Tc;//-_T_correction
  if (tau<0.0)
     tau=0.0;
  double psat = a_w * //vapor pressure lowering because of solutes.
                pc * exp(Tc / (crud_temperature) * (a1*tau + a2*std::pow(tau,1.5) + a3*std::pow(tau,3.0) + a4*std::pow(tau,3.5) + a5*std::pow(tau,4.0) + a6*std::pow(tau,7.5))) * //pure water saturation pressure
                exp(-_capillary[_qp]/(_rho_h2o[_qp]*R*(crud_temperature)));//vapor pressure lowering in porous media
  return (psat);//KPa,related with millimeter.
}
