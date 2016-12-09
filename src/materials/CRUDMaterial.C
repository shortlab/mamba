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

#include "CRUDMaterial.h"

template<>
InputParameters validParams<CRUDMaterial>()
{
  InputParameters params = validParams<Material>();

  params.addParam<Real>("dimensionality", 2, "Fractal dimensionality (1,2,3) of the CRUD");
  params.addParam<Real>("pore_size_min_baseline", 1e-7, "This is minimum pore size in the CRUD, acquired from TEM foils");
  params.addParam<Real>("pore_size_avg_baseline", 3e-7, "This is minimum pore size in the CRUD, acquired from TEM foils");
  params.addParam<Real>("pore_size_max_baseline", 5e-7, "This is minimum pore size in the CRUD, acquired from TEM foils");
  params.addParam<Real>("cell_inner_radius", 2e-6, "This is the inner raduis of our unit crud cell");
  params.addParam<Real>("cell_outer_radius", 12.5e-6, "This is the outer radius of our unit crud cell, calculated from chimney density on a piece of crud area");
  params.addParam<Real>("CladHeatFluxIn", 1e6, "This is the heat flux coming from the clad, in MW/m2");
  params.addParam<Real>("ConvectionCoefficient", 1.2e5, "This is the convection coefficient at the interface between crud and coolant");

// These parameters are used in diffusivity calculations

  params.addParam<Real>("WaterViscosityAt298K", 0.008, "This is the viscosity of water at 298K in Pa-s");
  params.addParam<Real>("DiffusivityOfMonoborateAt298K", 1e-9, "This is aqueous diffusivity of the monoborate ion at 298K in 1/m2");
  params.addParam<Real>("DiffusivityOfLithiumAt298K", 1e-9, "This is aqueous diffusivity of the lithium ion at 298K in 1/m2");
  params.addParam<Real>("DiffusivityOfHydrogenAt298K", 1e-9, "This is aqueous diffusivity of the hydrogen ion at 298K in 1/m2");
  params.addParam<Real>("DiffusivityOfHydroxideAt298K", 1e-9, "This is aqueous diffusivity of the Hydroxide ion at 298K in 1/m2");
// This parameter is the scaling factor, or the number to multiply by to scale from meters to something

  params.addParam<Real>("ScalingFactor", 1, "The scaling factor to use throughout the simulation");
  params.addParam<Real>("CRUDThickness", 1, "The unscaled thickness of the CRUD");

  // Thermal conductivities of various phases, assumed constant (for now)
  params.addParam<Real>("k_HBO2_baseline", 1, "Thermal conductivity of orthoboric acid");
  params.addParam<Real>("k_Li2B4O7_baseline", 1, "Thermal conductivity of lithium tetraborate");
  params.addParam<Real>("k_Ni2FeBO5_baseline", 1, "Thermal conductivity of bonaccordite");

  // Series character fraction of the thermal conductance network
  params.addParam<Real>("k_series_character", 0.5, "Series-like nature of the thermal conductance network (0-1)");

  // Volume fractions of various phases, assumed constant (for now)
  params.addParam<Real>("vf_Ni_baseline", 1, "Volume fraction of nicvfel");
  params.addParam<Real>("vf_NiO_baseline", 1, "Volume fraction of nicvfel oxide");
  params.addParam<Real>("vf_Fe3O4_baseline", 1, "Volume fraction of magnetite");
  params.addParam<Real>("vf_NiFe2O4_baseline", 1, "Volume fraction of trevorite");
  params.addParam<Real>("vf_ZrO2_baseline", 1, "Volume fraction of zirconia");
  params.addParam<Real>("vf_HBO2_baseline", 1, "Volume fraction of orthoboric acid");
  params.addParam<Real>("vf_Li2B4O7_baseline", 1, "Volume fraction of lithium tetraborate");
  params.addParam<Real>("vf_Ni2FeBO5_baseline", 1, "Volume fraction of bonaccordite");

  // Get any debugging properties required for variable output

  params.addRequiredParam<Real>("debug_materials", "A boolean to determine whether to output key materials properties");
  params.addParam<Real>("case", 0, "A parameter used to determined whether vapor, liquid, or 2 phase: 0, liquid;1, vapor; 2, 2 phase");

  // Many material properties scale with temperature

  params.addRequiredCoupledVar("tortuosity", "This is the fractalline tortuosity of the CRUD, for scaling diffusiv");
  params.addRequiredCoupledVar("temperature", "Temperature of the CRUD for viscosity calculation (water temperature)");
  params.addRequiredCoupledVar("pressure", "Pressure of the CRUD for thermal condictivity calculation (water pressure)");
//  params.addRequiredCoupledVar("concentration", "BO3 concentration of the CRUD");
  params.addRequiredCoupledVar("porosity", "porosity of the CRUD for material calculations");
//  params.addRequiredCoupledVar("HBO2", "HBO2 in the CRUD for material calculations");
  params.addCoupledVar("phase", 0, "Saturation pressure given temperature");
  params.addCoupledVar("psat", 0, "Saturation pressure given temperature");
  params.addCoupledVar("Tsat",618.0,"Saturation temperature given pressure");

  return params;
}

CRUDMaterial::CRUDMaterial(const InputParameters & parameters)
    :Material(parameters),

     // Get parameters from the input file
     _dimensionality(getParam<Real>("dimensionality")),
     _pore_size_min_baseline(getParam<Real>("pore_size_min_baseline")),
     _pore_size_avg_baseline(getParam<Real>("pore_size_avg_baseline")),
     _pore_size_max_baseline(getParam<Real>("pore_size_max_baseline")),
     _r_inner(getParam<Real>("cell_inner_radius")),
     _r_outer(getParam<Real>("cell_outer_radius")),
     _q_dot_in(getParam<Real>("CladHeatFluxIn")),
     _h_convection(getParam<Real>("ConvectionCoefficient")),

     _mu_298K(getParam<Real>("WaterViscosityAt298K")),
     _D_BO3_298K(getParam<Real>("DiffusivityOfMonoborateAt298K")),
     _D_Li_298K(getParam<Real>("DiffusivityOfLithiumAt298K")),
     _D_H_298K(getParam<Real>("DiffusivityOfHydrogenAt298K")),
     _D_OH_298K(getParam<Real>("DiffusivityOfHydroxideAt298K")),
     // Implement a SCALING factor, so the entire simulation can
     // be scaled from SI (in which it was written) to something
     // else, like millimeters or microns, to help with simulation
     // scaling, convergence, and solve time. This stops "floating
     // point noise" from leaking into the simulation.
     _scaling_factor(getParam<Real>("ScalingFactor")),
     _thickness(getParam<Real>("CRUDThickness")),

     // Get baseline thermal conductivities from the input file
     // in the absence of real correlations or formulas
     _k_HBO2_baseline(getParam<Real>("k_HBO2_baseline")),
     _k_Li2B4O7_baseline(getParam<Real>("k_Li2B4O7_baseline")),
     _k_Ni2FeBO5_baseline(getParam<Real>("k_Ni2FeBO5_baseline")),

     // Get the degree of series-ness of the thermal conductance network
     _k_series_character(getParam<Real>("k_series_character")),

     // Get baseline solid volume fractions from the input file
     // in the absence of real correlations or formulas
     _vf_Ni_baseline(getParam<Real>("vf_Ni_baseline")),
     _vf_NiO_baseline(getParam<Real>("vf_NiO_baseline")),
     _vf_Fe3O4_baseline(getParam<Real>("vf_Fe3O4_baseline")),
     _vf_NiFe2O4_baseline(getParam<Real>("vf_NiFe2O4_baseline")),
     _vf_ZrO2_baseline(getParam<Real>("vf_ZrO2_baseline")),
     _vf_HBO2_baseline(getParam<Real>("vf_HBO2_baseline")),
     _vf_Li2B4O7_baseline(getParam<Real>("vf_Li2B4O7_baseline")),
     _vf_Ni2FeBO5_baseline(getParam<Real>("vf_Ni2FeBO5_baseline")),

     // Read in any debugging flags for parameter output
     _debug_materials(getParam<Real>("debug_materials")),
     _case(getParam<Real>("case")),

     // Declare material properties that kernels can use
     _surfacetension(declareProperty<Real>("SurfaceTension")),
     //_phase(declareProperty<Real>("PhaseFlag")),
     _k_cond(declareProperty<Real>("k_cond")),
     _pore_size_min(declareProperty<Real>("pore_size_min")),
     _pore_size_avg(declareProperty<Real>("pore_size_avg")),
     _pore_size_max(declareProperty<Real>("pore_size_max")),
     _r_inner_cell(declareProperty<Real>("CellInnerRadius")),
     _r_outer_cell(declareProperty<Real>("CellOuterRadius")),
     _h_convection_coeff(declareProperty<Real>("ConvectionCoefficient")),
     _permeability(declareProperty<Real>("permeability")),
     _k_liquid(declareProperty<Real>("k_liquid")),
     _k_solid(declareProperty<Real>("k_solid")),
     _mu_h2o(declareProperty<Real>("WaterViscosity")),
     _rho_h2o(declareProperty<Real>("WaterDensity")),
     _h_fg_h2o(declareProperty<Real>("WaterVaporizationEnthalpy")),
     _h_vapor(declareProperty<Real>("VaporEnthalpy")),
     _cp_liquid(declareProperty<Real>("WaterHeatCapacity")),
     _cp_vapor(declareProperty<Real>("VaporHeatCapacity")),
     _q_dot_clad(declareProperty<Real>("CladHeatFlux")),

     _D_BO3(declareProperty<Real>("DiffusivityOfMonoborate")),
     _D_Li(declareProperty<Real>("DiffusivityOfLithium")),
     _D_H(declareProperty<Real>("DiffusivityOfHydrogen")),
     _D_OH(declareProperty<Real>("DiffusivityOfHydroxide")),

     _lgKw_H2O(declareProperty<Real>("EquConstofH2O")),
     _lgKw_H3BO3(declareProperty<Real>("EquConstofH3BO3")),
     _lgKw_H3BO3_2(declareProperty<Real>("EquConstofH3BO3_2")),
     _lgKw_LiBO2(declareProperty<Real>("EquConstofLiBO2")),

     _t_crud(declareProperty<Real>("crud_thickness")),
     _conductivity(declareProperty<Real>("conductivity")),
     _crud_porosity(declareProperty<Real>("porosity")),
//   _Tsat_h2o(declareProperty<Real>("WaterSaturationTemperature")),

     _tortuosity(coupledValue("tortuosity")),
     _T(coupledValue("temperature")),
     _P(coupledValue("pressure")),
//     _C(coupledValue("concentration")),
     _porosity(coupledValue("porosity")),
     _phase(coupledValue("phase")),
     _psat(coupledValue("psat")),
     _Tsat(coupledValue("Tsat"))
//    _HBO2(coupledValue("HBO2"))
{
// First, scale the baseline diffusivities with the scaling factor.
// _mu_h2o[_qp] has already been scaled above.
//
// ***NOTE***: These values MUST be scaled during the constructor!
// Doing so in the computation section will continually apply the
// scaling factor, shrinking it over and over again.
//
// Any value read directly from the input file that needs to be scaled must
// be scaled in the constructor to only happen once.

  _D_BO3_298K /= std::pow(_scaling_factor, 2);	// Scale inverse twice for m^2 (m^2/s)
  _D_Li_298K /= std::pow(_scaling_factor, 2);	// Scale inverse twice for m^2 (m^2/s)

  _D_H_298K /= std::pow(_scaling_factor, 2);	// Scale inverse twice for m^2 (m^2/s)
  _D_OH_298K /= std::pow(_scaling_factor, 2);	// Scale inverse twice for m^2 (m^2/s)
// Next, scale the baseline viscosity of water at room temperature.

  _mu_298K *= _scaling_factor;                  // Scale once for 1/m
}

//void
//CRUDMaterial::initQpStatefulProperties()
//{
//  _k_cond[_qp] = _k_cond_baseline / _scaling_factor;
//}

void
CRUDMaterial::computeQpProperties()
{
/**************************************************************/
  // The following model calculates the thermal conductivity of the CRUD by using
  // a method of parallel resistances, depending on the volume fractions of the
  // CRUD's constituents. It calculates the thermal conductivity of water on the fly,
  // and takes in constants (for now) for solid species.
  // From Gierszewski, Mikic & Todreas (PFC-RR-80-12)

//  if (_HBO2[_qp] < 0.5)
  _crud_porosity[_qp] = _porosity[_qp];
  _h_convection_coeff[_qp] = _h_convection;

  double Ptemp = (isParamValid("pressure") ? _P[_qp] : 15500) / _scaling_factor;
//unit: Pa
//The following constants are to calculate surface tension
  double BB = 235.8e-3;//N/m, No need to change unit
  double T_c = 647.15;//K
  double bb = -0.625;
  double mu = 1.256;
  double T_diff=T_c - _T[_qp];
  if (T_diff<0)
    T_diff=0;
  _surfacetension[_qp] = BB * std::pow((T_diff)/T_c, mu) *
                         (1 + bb * (T_diff) / T_c);

  //_phase[_qp] = 1.0 / (exp((_P[_qp] - _psat[_qp])/_deltaP)+1);
//!!!!!Now we don't use this condition, instead combine liquid and vapor properties.

//  if (_P[_qp] >= _psat[_qp])



  if (_case==0)  // It means the liquid state!!!
  // From Gierszewski, Mikic & Todreas (PFC-RR-80-12)
  {

  _mu_h2o[_qp] =
      25.3
    / (-8.58e4 + (91.0 * _T[_qp]) + std::pow(_T[_qp], 2));

  // From Gierszewski, Mikic & Todreas (PFC-RR-80-12)

  _rho_h2o[_qp] =
      -4276
    + (53.24 * _T[_qp])
    - (0.1953 * std::pow(_T[_qp], 2))
    + (3.097e-4 * std::pow(_T[_qp], 3))
    - (1.824e-7 * std::pow(_T[_qp], 4));

  // Define the heat capacity of the liquid,
  // for Peclet number determination and heat advection
  // From Gierszewski, Mikic & Todreas (PFC-RR-80-12)

  _cp_liquid[_qp] =
      4028.0
    + (128.8 / (1 - (_T[_qp] / 650)))
    + (4.674 / (std::pow((1 - (_T[_qp] / 650)), 2)));


  _k_liquid[_qp] =
      0.686
    + (7.3e-10) * (Ptemp)
    - ((5.87e-6) * std::pow((_T[_qp] - 415), 2));


  }

  if (_case==1) //It means in vapor state, still use liquid as the name for convenience
  {

   _mu_h2o[_qp] =
   11.4 / (1.37e6 - 844 * _T[_qp] - std::pow(_T[_qp], 2));

   _rho_h2o[_qp] =
      0.576
    + Ptemp * (2.483e-5 - 1.41e-12* Ptemp)
    + (Ptemp / _T[_qp]) * (-2.616e-2 + 1.016e-9* Ptemp + 7.589/ _T[_qp]);

  _cp_liquid[_qp] =
      2709.0
    + (Ptemp / _T[_qp]) * (-8.594e-1- 2.378e-7* Ptemp + 1.062e-3 * _T[_qp] + 1.686e-4* Ptemp / _T[_qp])
    - 277.2 * std::pow(_T[_qp],2) / Ptemp;

  _k_liquid[_qp] =
      -7.21e-3 + Ptemp * (8.309e-8 + 2.818e-15 * Ptemp)
     + _T[_qp] * (6.74e-5 + 3.895e-8 * _T[_qp])
     + _T[_qp] * Ptemp * (-2.854e-10-4.067e-18*Ptemp+2.417e-13 * _T[_qp]);

 //   _phase[_qp] = 1;

  }



  if (_case==2) //This means 2 phase!!!
  {
   //combined properties
    double _mu_h2o_l =
      25.3
    / (-8.58e4 + (91.0 * _T[_qp]) + std::pow(_T[_qp], 2));
    double _rho_h2o_l =
      -4276
    + (53.24 * _T[_qp])
    - (0.1953 * std::pow(_T[_qp], 2))
    + (3.097e-4 * std::pow(_T[_qp], 3))
    - (1.824e-7 * std::pow(_T[_qp], 4));
    double _cp_liquid_l =
      4028.0
    + (128.8 / (1 - (_T[_qp] / 650)))
    + (4.674 / (std::pow((1 - (_T[_qp] / 650)), 2)));
    double _k_liquid_l =
      0.686
    + (7.3e-10) * (Ptemp)
    - ((5.87e-6) * std::pow((_T[_qp] - 415), 2));

   double _mu_h2o_v =
   11.4 / (1.37e6 - 844 * _T[_qp] - std::pow(_T[_qp], 2));

   double _rho_h2o_v =
      -0.576
    + Ptemp * (2.483e-5 - 1.41e-12* Ptemp)
    + (Ptemp / _T[_qp]) * (-2.616e-2 + 1.016e-9* Ptemp + 7.589/ _T[_qp]);

  double _cp_liquid_v =
      2709.0
    + (Ptemp / _T[_qp]) * (-8.594e-1- 2.378e-7* Ptemp + 1.062e-3 * _T[_qp] + 1.686e-4* Ptemp / _T[_qp])
    - 277.2 * std::pow(_T[_qp],2) / Ptemp;

  double _k_liquid_v =
      -7.21e-3 + Ptemp * (8.309e-8 + 2.818e-15 * Ptemp)
     + _T[_qp] * (6.74e-5 + 3.895e-8 * _T[_qp])
     + _T[_qp] * Ptemp * (-2.854e-10-4.067e-18*Ptemp+2.417e-13 * _T[_qp]);

   _mu_h2o[_qp]=_mu_h2o_l*(1.0-_phase[_qp])+_phase[_qp]*_mu_h2o_v;
   _rho_h2o[_qp]=_rho_h2o_l*(1.0-_phase[_qp])+_rho_h2o_v*_phase[_qp];
   _cp_liquid[_qp]=_cp_liquid_l*(1.0-_phase[_qp])+_cp_liquid_v*_phase[_qp];
   _k_liquid[_qp]=_k_liquid_l*(1.0-_phase[_qp])+_k_liquid_v*_phase[_qp];

}

   _cp_vapor[_qp] =
      2709.0
    + (Ptemp / _T[_qp]) * (-8.594e-1- 2.378e-7* Ptemp + 1.062e-3 * _T[_qp] + 1.686e-4* Ptemp / _T[_qp])
    - 277.2 * std::pow(_T[_qp],2) / Ptemp;//vapor specific heat capacity

//Begin to calculate vapor enthalpy(REF:Steam and Gas Tables with Computer Equations)
double B11=2.04121E3;
double B12=-4.040021E1;
double B13=-4.8095E-1;
double B21=1.610693;
double B22=5.472051E-2;
double B23=7.517537E-4;
double B31=3.383117e-4;
double B32=-1.975736e-5;
double B33=-2.87409e-7;
double B41=1.70782e3;
double B42=-1.699419e1;
double B43=6.2746295e-2;
double B44=-1.0284259e-4;
double B45=6.456198e-8;
double MM=4.5e1;
double P_MPa=_P[_qp] * _scaling_factor;
  //Nested: Begin to calculate saturation temperature
  double AAA=-0.387592e3;
  double BBB=-0.125875e5;
  double CCC=-0.152578e2;
  double TS=AAA+BBB/(std::log(P_MPa)+CCC);//K
  //end to calculate saturation temperature
double A0=B11+B12*P_MPa+B13*pow(P_MPa,2);
double A1=B21+B22*P_MPa+B23*pow(P_MPa,2);
double A2=B31+B32*P_MPa+B33*pow(P_MPa,2);
double A3=B41+B42*TS+B43*pow(TS,2)+B44*pow(TS,3)+B45*pow(TS,4);
  _h_vapor[_qp]=
    A0+A1*_T[_qp]+A2*pow(_T[_qp],2)-A3*exp((TS-_T[_qp])/MM); //vapor enthalpy kJ/kg
//end to calculate vapor enthalpy

  _h_vapor[_qp] /= std::pow(_scaling_factor, 3);  // Scale inverse three times for k* m^2 (kJ/kg = 1e3 kg*m/s^2 * m * 1/kg)

  _h_fg_h2o[_qp] =
      -1249010
    + 604714
    * std::log(657.482 - _T[_qp]);
  _h_fg_h2o[_qp] /= std::pow(_scaling_factor, 2);	// Scale inverse twice for m^2 (J/kg = kg*m/s^2 * m * 1/kg)

  _rho_h2o[_qp] *= std::pow(_scaling_factor, 3);     // Scale thrice for 1/m^3
  _cp_liquid[_qp] /= std::pow(_scaling_factor, 2);	// Scale inverse twice for m^2 (J/kg-K = kg*m/s^2 * m * 1/kg-K)
  _cp_vapor[_qp] /= std::pow(_scaling_factor, 2);	// Scale inverse twice for m^2 (J/kg-K = kg*m/s^2 * m * 1/kg-K)
  _mu_h2o[_qp] *= _scaling_factor;	// Scale once for 1/m
  _k_liquid[_qp] = _k_liquid[_qp] / _scaling_factor;
  // Scale inverse once for m (W/mK = kg*m/s^2 * m/s * 1/mK = kg*m/s^3-K)



  // Find the thermal conductivity of the solid phase,
  // by taking a volume average of its constituents

  // First, find thermal conductivities of phases that have actual
  // temperature-dependent functional forms.

  Real _k_Ni =
       703.56
     - (83.297 * log(_T[_qp] + 1518.17));	// From Watanabe, 1993
  Real _k_NiO =
       (-5.602e-9) * std::pow(_T[_qp], 3)
     + (2.435e-5) * std::pow(_T[_qp], 2)
     - 0.03543 * _T[_qp]
     + 21.658;					// From Kingery et al., 1954
  Real _k_Fe3O4 = 4.23 - (_T[_qp] * 1.37e-3);	// From Molgaard and Smeltzer, J. Appl. Phys., 1971
  Real _k_ZrO2 = (3.791e-4) * _T[_qp] + 1.748;	// From Kingery et al., 1954
  Real _k_NiFe2O4 = 1 / (-0.02751 + 0.00044 * _T[_qp]);	// From NEW experiment by Nelson, Stanek, Short!!!

  // Next, average the solid phases' thermal conductivities with their volume fractions

  _k_solid[_qp] =
      (_vf_Ni_baseline * _k_Ni)
    + (_vf_NiO_baseline * _k_NiO)
    + (_vf_Fe3O4_baseline * _k_Fe3O4)
    + (_vf_NiFe2O4_baseline * _k_NiFe2O4)
    + (_vf_ZrO2_baseline * _k_ZrO2);

  _k_solid[_qp] = _k_solid[_qp] / _scaling_factor;
  // Scale inverse once for m (W/mK = kg*m/s^2 * m/s * 1/mK = kg*m/s^3-K)

  // ***TODO*** Add boric acid concentration's contribution to water thermal conductivity

  // Find the thermal conductivity of the overall CRUD, assuming a mix of
  // parallel and series resistance character to the whole matrix.

  // Start by defining the fractal dimensions

  _t_crud[_qp] = _thickness ;//direct millimeters from inputfile

  _pore_size_min[_qp] = _pore_size_min_baseline / _scaling_factor;	// Scale inverse once for m
  _pore_size_avg[_qp] = _pore_size_avg_baseline / _scaling_factor;      // Scale inverse once for m
  _pore_size_max[_qp] = _pore_size_max_baseline / _scaling_factor;      // Scale inverse once for m
  _r_inner_cell[_qp] = _r_inner / _scaling_factor;
  _r_outer_cell[_qp] = _r_outer / _scaling_factor;

  Real Df =
      _dimensionality
    - ((std::log(_porosity[_qp])) / (std::log(_pore_size_min[_qp] / _pore_size_max[_qp])));

  Real Lg =
      (_pore_size_max[_qp] / _pore_size_min[_qp])
    * sqrt((libMesh::pi / 4) * (Df / (2 - Df)) * ((1 - _porosity[_qp]) / _porosity[_qp]));

  Real Dt = 1 + (std::log((isParamValid("tortuosity") ? _tortuosity[_qp] : 1.5)) / std::log(Lg));


  // The series part comes first.

  Real _k_series =
    1 / (
      (_porosity[_qp] / _k_liquid[_qp])
      + ((1 - _porosity[_qp]) / _k_solid[_qp])
      );

  // Then use the parallel part from Shi et al., 2008

/*
  Real _k_parallel =
    (
      (
        (2 - Df)
        * _porosity[_qp]
        * std::pow(_pore_size_max[_qp], 2)
        * (1 - std::pow((_pore_size_min[_qp] / _pore_size_max[_qp]), 2)
          )
        )
      /
      (
        (Dt - Df + 1)
        * (1 - std::pow((_pore_size_min[_qp] / _pore_size_max[_qp]), 2)
          )
        )
      )
    * _k_liquid[_qp]
    + ((1 - _porosity[_qp]) * _k_solid[_qp]);//*/

  Real _k_parallel =
      (2-Df) * _porosity[_qp]
    * pow(_pore_size_max[_qp], Dt-1)
    * (1 - pow((_pore_size_min[_qp] / _pore_size_max[_qp]),(Dt-Df+1)))
    * _k_liquid[_qp]
    / pow(_t_crud[_qp],Dt-1) / (Dt-Df+1)
    / (1 - pow((_pore_size_min[_qp] / _pore_size_max[_qp]),(2-Df)))
    +  ((1 - _porosity[_qp]) * _k_solid[_qp]);

  _k_cond[_qp] =
    1 / (
      (_k_series_character / _k_series)
      + ((1 - _k_series_character) / _k_parallel)
      );

  // Because the component liquid and solid thermal conductivities were scaled,
  // no addition scaling is required.

/**************************************************************/

  // The following material model calculates the fractalline permeability
  // of the CRUD from Df, Dt, e, and l_max. It doesn't need to be scaled,
  // since the _pore_size_max has already been scaled. That puts it in the right units.

  Real plusDt = (1 + Dt) / 2;
  Real minusDt = (1 - Dt) / 2;

  _permeability[_qp] =
      ((pow((libMesh::pi * Df), minusDt) * std::pow((4 * (2 - Df)), plusDt)) / (128 * (3 + Dt - Df)))
    * std::pow((_porosity[_qp] / (1 - _porosity[_qp])), plusDt)
    * std::pow(_pore_size_max[_qp], 2);

/***********************************************************/


  _q_dot_clad[_qp] = _q_dot_in;	// No scaling factor needed: W/m^2 = (kg*m/s^2)*(m/s)*(1/m^2) = kg/s^3

  // These are aqueous diffusivities, all scaled with temperature.
  // Now scale the diffusivities using the Einstein-something relation
  // between diffusivity, viscosity, and temperature

  _D_BO3[_qp] =
      (_D_BO3_298K / _tortuosity[_qp])
    * _mu_298K * _T[_qp] / (_mu_h2o[_qp] * 298.15);

  _D_Li[_qp] =
      (_D_Li_298K / _tortuosity[_qp])
    * _mu_298K * _T[_qp] / (_mu_h2o[_qp] * 298.15);

  _D_H[_qp] =
      (_D_H_298K / _tortuosity[_qp])
    * _mu_298K * _T[_qp] / (_mu_h2o[_qp] * 298.15);

  _D_OH[_qp] =
      (_D_OH_298K / _tortuosity[_qp])
    * _mu_298K * _T[_qp] / (_mu_h2o[_qp] * 298.15);

// *******************************************************/
// The following is equilibrium constant (lgKw) for reactions:
// H20--->>H+  + OH-
  _lgKw_H2O[_qp] = -4.098 -3245.2/ _T[_qp] +
     2.2362e5 / std::pow(_T[_qp],2)-3.984e7 / std::pow(_T[_qp],3)
     + (13.957 -1262.3/_T[_qp]+8.5641e5/std::pow(_T[_qp],2)) *
     log10(_rho_h2o[_qp] * 1e6);//based on molality

// B(OH)3 + OH- --->> B(OH)4-
  _lgKw_H3BO3[_qp] = 1573.21/ _T[_qp] +28.8397
     +0.011748*_T[_qp]-13.2258 * log10(_T[_qp]);

// 2B(OH)3 + OH- --->> B2(OH)7-
  _lgKw_H3BO3_2[_qp] = 2756.1/_T[_qp]-18.966+5.835*log10(_T[_qp]);

// LiBO2(s) + H2O + H+ --->> Li+ + B(OH)3
  _lgKw_LiBO2[_qp] = 5.249217 + 1185.683 / _T[_qp];


// *******************************************************/

  //conductivity of solution
  _conductivity[_qp] = _permeability[_qp]
    / _porosity[_qp]/_mu_h2o[_qp];     //scaled to mm

  // Output any material properties requested by the debugger

  if (_debug_materials == 1)
  {
    std::cout << "T = " << _T[_qp] << std::endl;
    std::cout << "Psat = " << _psat[_qp] << std::endl;
    std::cout << "D_BO3_298K = " << _D_BO3_298K << std::endl;
    std::cout << "D_Li_298K = " << _D_Li_298K << std::endl;
    std::cout << "mu_298K = " << _mu_298K << std::endl;
    std::cout << "kNi = " << _k_Ni << std::endl;
    std::cout << "kNiO = " << _k_NiO << std::endl;
    std::cout << "kFe3O4 = " << _k_Fe3O4 << std::endl;
    std::cout << "kZrO2 = " << _k_ZrO2 << std::endl;
    std::cout << "k_solid = " << _k_solid[_qp] << std::endl;
    std::cout << "k_liquid = " << _k_liquid[_qp] << std::endl;
    std::cout << "k_series = " << _k_series << std::endl;
    std::cout << "k_parallel = " << _k_parallel << std::endl;
    std::cout << "k_series_character = " << _k_series_character << std::endl;
    std::cout << "k = " << _k_cond[_qp] << std::endl;
    std::cout << "Df = " << Df << std::endl;
    std::cout << "e = " << _porosity[_qp] << std::endl;
    std::cout << "tau = " << _tortuosity[_qp] << std::endl;
    std::cout << "Lg = " << Lg << std::endl;
    std::cout << "Dt = " << Dt << std::endl;
    std::cout << "+Dt = " << plusDt << std::endl;
    std::cout << "-Dt = " << minusDt << std::endl;
    std::cout << "perm = " << _permeability[_qp] << std::endl;
    std::cout << "mu_h2o = " << _mu_h2o[_qp] << std::endl;
    std::cout << "rho_h2o = " << _rho_h2o[_qp] << std::endl;
    std::cout << "h_fg = " << _h_fg_h2o[_qp] << std::endl;
    std::cout << "Qclad = " << _q_dot_clad[_qp] << std::endl;
    std::cout << "D_BO3 = " << _D_BO3[_qp] << std::endl;
    std::cout << "D_Li = " << _D_Li[_qp] << std::endl << std::endl;
  }

// *******************************************************

  // End the function

}
