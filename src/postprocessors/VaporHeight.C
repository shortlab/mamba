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

#include "VaporHeight.h"
#include "FEProblem.h"

template<>
InputParameters validParams<VaporHeight>()
{
  InputParameters params = validParams<GeneralPostprocessor>();
  
  params.addRequiredParam<PostprocessorName>("integral_all", "The name of the PP that is computing the total amount of boron deposited.");
  params.addRequiredParam<PostprocessorName>("area", "The name of the PP that is computing the surface area.");

  params.addRequiredParam<Real>("thickness", "unit:mm");

  return params;
}

VaporHeight::VaporHeight(const InputParameters & parameters) :
    GeneralPostprocessor(parameters),
    _integral(getPostprocessorValue("integral_all")),
    _area(getPostprocessorValue("area")),
    _thickness(getParam<Real>("thickness"))
    //_in_meters(getParam<bool>("in_meters"))
{}

Real
VaporHeight::getValue()
{
   //if(_in_meters)
  //  area*=(0.001*0.001);* 
  
  return _integral / (_area+1e-8)* _thickness;
}
