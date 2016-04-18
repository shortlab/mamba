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

#include "OnOffCoupledTsatDirichletBC.h"

template<>
InputParameters validParams<OnOffCoupledTsatDirichletBC>()
{
  InputParameters params = validParams<CoupledTsatDirichletBC>();
 // params.addRequiredParam<FunctionName>("function", "Forcing function");
  params.addCoupledVar("var2",0,"");
  return params;
}

OnOffCoupledTsatDirichletBC::OnOffCoupledTsatDirichletBC(const std::string & name, InputParameters parameters) :
    CoupledTsatDirichletBC(name, parameters),
_var2(coupledValue("var2"))
{
}

OnOffCoupledTsatDirichletBC::~OnOffCoupledTsatDirichletBC()
{
}

bool
OnOffCoupledTsatDirichletBC::shouldApply()
{
  //return (_t_step == 1) ? true : false;
  //return (_func.value(_t,*_current_node)>0.5)? true : false;
  return ((*_current_node)(1)>_var2[_qp])? true : false;
  //return (_q_point[_qp](1)>0.005)? true:false;
}
