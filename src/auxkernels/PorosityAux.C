#include "PorosityAux.h"

template<>
InputParameters validParams<PorosityAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addParam<Real>("init_porosity",0.5,"Initial porosity");

  params.addRequiredParam<std::vector<Real> >("mineral", "Initial mineral concentration");
  params.addRequiredParam<std::vector<Real> >("molecular_weight", "The molecular weight of mineral");
  params.addRequiredParam<std::vector<Real> >("density", "The density of mineral");

  params.addCoupledVar("v", "List of mineral species that could impact porosity");

  return params;
}

PorosityAux::PorosityAux(const std::string & name, InputParameters parameters)
  :AuxKernel(name, parameters),
   _input_initial_porosity(getParam<Real>("init_porosity")),
   _molecular_weight(getParam<std::vector<Real> >("molecular_weight")),
   _mineral_density(getParam<std::vector<Real> >("density")),
   _input_initial_mineral(getParam<std::vector<Real> >("mineral"))
//   _coupled_val1(coupledValueAux("v1"))
{
  int n = coupledComponents("v");
  _vals.resize(n);
  for (unsigned int i=0; i<_vals.size(); ++i)
    _vals[i] = &coupledValue("v", i);
}


Real
PorosityAux::computeValue()
{
//  return (1.0+1.0e-3*_molecular_weight/_mineral_density*_input_initial_mineral)*_input_initial_porosity/(1.0+1.0e-3*_molecular_weight/_mineral_density*_coupled_val1);
  Real _porosity = _input_initial_porosity;
  
  if (_vals.size()) 
    {
      Real _initial_vf = 1.0;
      Real _vf = 1.0;

      for (unsigned int i=0; i<_vals.size(); ++i)
      {
        _initial_vf += 1.0e-3*_input_initial_mineral[i]*_molecular_weight[i]/_mineral_density[i];

        _vf += 1.0e-3*((*_vals[i])[_qp])*_molecular_weight[i]/_mineral_density[i];
        
      }

      _porosity = _initial_vf *_input_initial_porosity/_vf;
    }

  if (_porosity < 1.0e-3)
    _porosity = 1.0e-3;

 // std::cout<<_porosity<<std::endl;
  return _porosity;
    
//  return _input_initial_porosity-_input_initial_porosity*(_coupled_val1-_input_initial_mineral)*_molecular_weight/_mineral_density*1.0e-3;
  
}
