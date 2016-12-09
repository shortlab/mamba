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

#ifndef CLAY_H
#define CLAY_H

#include "Material.h"

//Forward Declarations
class Clay;

template<>
InputParameters validParams<Clay>();

class Clay : public Material
{
public:
  Clay(const std::string & name,
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

#endif //CLAY_H
