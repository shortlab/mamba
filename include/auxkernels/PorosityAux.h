#ifndef POROSITYAUX_H
#define POROSITYAUX_H

#include "AuxKernel.h"


//Forward Declarations
class PorosityAux;

template<>
InputParameters validParams<PorosityAux>();

/** 
 * Coupled auxiliary value
 */
class PorosityAux : public AuxKernel
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  PorosityAux(const std::string & name, InputParameters parameters);

  virtual ~PorosityAux() {}
  
protected:
  virtual Real computeValue();

  Real _input_initial_porosity;
//  Real _input_initial_mineral;
//  Real _molecular_weight;
//  Real _mineral_density;

  std::vector<Real> _molecular_weight;
  std::vector<Real> _mineral_density;
  std::vector<Real> _input_initial_mineral;
  
//  Real & _coupled_val1;
  std::vector<VariableValue *>  _vals;
};

#endif //POROSITYAUX_H
