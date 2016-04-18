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

#ifndef ONOFFCHIMNEYEVAPORATIONNEUMANNBC_H
#define ONOFFCHIMNEYEVAPORATIONNEUMANNBC_H

#include "ChimneyEvaporationNeumannBC.h"

class OnOffChimneyEvaporationNeumannBC;

template<>
InputParameters validParams<OnOffChimneyEvaporationNeumannBC>();

/**
 *
 */
class OnOffChimneyEvaporationNeumannBC : public ChimneyEvaporationNeumannBC
{
public:
  OnOffChimneyEvaporationNeumannBC(const std::string & name, InputParameters parameters);
  virtual ~OnOffChimneyEvaporationNeumannBC();

  virtual bool shouldApply();

protected:
   VariableValue & _var2;
};

#endif /* OnOffChimneyEvaporationNeumannBC_H */
