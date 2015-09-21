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

#ifndef ECOFLIBO2_H
#define ECOFLIBO2_H

#include "AuxKernel.h"


//Forward Declarations
class ECofLiBO2;

template<>
InputParameters validParams<ECofLiBO2>();

class ECofLiBO2 : public AuxKernel
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  ECofLiBO2(const InputParameters & parameters);

protected:
  virtual Real computeValue();

  VariableValue & _temperature;
//  VariableValue & _Conc_HBO2;
};

#endif //ECofLiBO2_H
