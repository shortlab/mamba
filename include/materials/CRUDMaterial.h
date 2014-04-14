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

#ifndef CRUDMATERIAL_H
#define CRUDMATERIAL_H

#include "Material.h"

//Forward Declarations
class CRUDMaterial;

template<>
InputParameters validParams<CRUDMaterial>();

class CRUDMaterial : public Material
{
public:
  CRUDMaterial(const std::string & name,
                  InputParameters parameters);

protected:
//  virtual void initQpStatefulProperties();
  virtual void computeQpProperties();

private:

  /**
   * Holds a value from the input file.
   */
  Real _dimensionality;
  Real _pore_size_min_baseline;
  Real _pore_size_avg_baseline;
  Real _pore_size_max_baseline;
  Real _q_dot_in;

  Real _mu_298K;
  Real _D_BO3_298K;
  Real _D_Li_298K;
  Real _scaling_factor;
  Real _t_crud;
  
  // Assumed constant thermal conductivities of solid phases
  Real _k_HBO2_baseline;
  Real _k_Li2B4O7_baseline;
  Real _k_Ni2FeBO5_baseline;  

  // Series character of the thermal conductance network
  Real _k_series_character;
  
  // Volume fractions of solid phases
  Real _vf_Ni_baseline;
  Real _vf_NiO_baseline;
  Real _vf_Fe3O4_baseline;
  Real _vf_NiFe2O4_baseline;
  Real _vf_ZrO2_baseline;
  Real _vf_HBO2_baseline;
  Real _vf_Li2B4O7_baseline;
  Real _vf_Ni2FeBO5_baseline;  


  // Debugging flags
  Real _debug_materials;
  
  /**
   * This is the member reference that will hold the
   * computed values from this material class.
   */
  MaterialProperty<Real> & _k_cond;
  MaterialProperty<Real> & _pore_size_min;
  MaterialProperty<Real> & _pore_size_avg;
  MaterialProperty<Real> & _pore_size_max;
  MaterialProperty<Real> & _permeability;
  MaterialProperty<Real> & _k_liquid;
  MaterialProperty<Real> & _k_solid;
  MaterialProperty<Real> & _mu_h2o;
  MaterialProperty<Real> & _rho_h2o;
  MaterialProperty<Real> & _h_fg_h2o;
  MaterialProperty<Real> & _cp_liquid;
  MaterialProperty<Real> & _q_dot_clad;
  MaterialProperty<Real> & _D_BO3;
  MaterialProperty<Real> & _D_Li;
//  MaterialProperty<Real> & _Tsat_h2o;

  VariableValue & _tortuosity;
  VariableValue & _T;
  VariableValue & _P;
  VariableValue & _C;
  VariableValue & _porosity;
  VariableValue & _HBO2;

};

#endif //CRUDMATERIAL_H
