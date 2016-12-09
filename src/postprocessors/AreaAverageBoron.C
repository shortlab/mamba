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

#include "AreaAverageBoron.h"
#include "FEProblem.h"

template<>
InputParameters validParams<AreaAverageBoron>()
{
  InputParameters params = validParams<GeneralPostprocessor>();

  params.addRequiredParam<PostprocessorName>("total_boron", "The name of the PP that is computing the total amount of boron deposited.");
  params.addRequiredParam<PostprocessorName>("area", "The name of the PP that is computing the surface area.");

  params.addRequiredParam<bool>("in_meters", "Whether or not to convert the area to meters^2.");

  return params;
}

AreaAverageBoron::AreaAverageBoron(const InputParameters & parameters) :
    GeneralPostprocessor(parameters),
    _total_boron(getPostprocessorValue(getParam<PostprocessorName>("total_boron"))),
    _area(getPostprocessorValue(getParam<PostprocessorName>("area"))),
    _in_meters(getParam<bool>("in_meters"))
{}

Real
AreaAverageBoron::getValue()
{
  Real area = _area;

  if(_in_meters)
    area*=(0.001*0.001);

  return _total_boron / area;
}
