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

#ifndef KNIFE_H
#define KNIFE_H

#include "Material.h"

//Forward Declarations
class Knife;

template<>
InputParameters validParams<Knife>();

class Knife : public Material
{
public:
  Knife(const std::string & name,
                  InputParameters parameters);

protected:
//  virtual void initQpStatefulProperties();
  virtual void computeQpProperties();

private:

  /**
   * Holds a value from the input file.
   */
  MaterialProperty<Real> & _k_cond;

  VariableValue & _T;
};

#endif //KNIFE_H
