#ifndef ONOFFCOUPLEDTSATDIRICHLETBC_H
#define ONOFFCOUPLEDTSATDIRICHLETBC_H

#include "CoupledTsatDirichletBC.h"

class OnOffCoupledTsatDirichletBC;

template<>
InputParameters validParams<OnOffCoupledTsatDirichletBC>();

/**
 *
 */
class OnOffCoupledTsatDirichletBC : public CoupledTsatDirichletBC
{
public:
  OnOffCoupledTsatDirichletBC(const std::string & name, InputParameters parameters);
  virtual ~OnOffCoupledTsatDirichletBC();

  virtual bool shouldApply();

protected:
   VariableValue & _var2;
};

#endif /* OnOffCoupledTsatDirichletBC_H */

