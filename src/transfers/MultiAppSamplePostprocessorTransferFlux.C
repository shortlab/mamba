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

#include "MultiAppSamplePostprocessorTransferFlux.h"

// Moose
#include "MooseTypes.h"
#include "FEProblem.h"

// libMesh
#include "libmesh/meshfree_interpolation.h"
#include "libmesh/system.h"

template<>
InputParameters validParams<MultiAppSamplePostprocessorTransferFlux>()
{
  InputParameters params = validParams<MultiAppSamplePostprocessorTransferBase>();

  params.addRequiredParam<std::vector<Point> >("normal", "The normal to be used with the gradient.");
  params.addRequiredParam<Real>("mat_prop", "The material property to be used to compute the flux.");

  return params;
}

MultiAppSamplePostprocessorTransferFlux::MultiAppSamplePostprocessorTransferFlux(const std::string & name, InputParameters parameters) :
    MultiAppSamplePostprocessorTransferBase(name, parameters),

    _normal(getParam<std::vector<Point> >("normal")),
    _mat_prop(getParam<Real>("mat_prop"))

{
}

void
MultiAppSamplePostprocessorTransferFlux::execute()
{
     MultiAppSamplePostprocessorTransferBase::execute();
}

Real
MultiAppSamplePostprocessorTransferFlux::getValue(MooseVariable & variable) const
{
	return - _mat_prop * variable.gradSln()[0] * _normal[0];
}
