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
  OnOffCoupledTsatDirichletBC(const InputParameters & parameters);
  virtual ~OnOffCoupledTsatDirichletBC();

  virtual bool shouldApply();

protected:
   const VariableValue & _var2;
};

#endif /* OnOffCoupledTsatDirichletBC_H */
