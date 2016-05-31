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

// This file is a simple implementation of a forced heat flux
// coming from the cladding. All it does is read the value from
// the input file in MW/m^2.

#include "CRUDCladNeumannBCMultiApp.h"

template<>
InputParameters validParams<CRUDCladNeumannBCMultiApp>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredParam<PostprocessorName>("multi_app_q_dot", "The cladding heat flux given from MultiApp");

  return params;
}

CRUDCladNeumannBCMultiApp::CRUDCladNeumannBCMultiApp(const InputParameters & parameters)
 :IntegratedBC(parameters),
  _q_dot_multiapp(getPostprocessorValue("multi_app_q_dot"))
{}

Real
CRUDCladNeumannBCMultiApp::computeQpResidual()
{
  return -_test[_i][_qp] * _q_dot_multiapp;
}
