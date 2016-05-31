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

#include "LiquidHeight.h"
#include "FEProblem.h"

template<>
InputParameters validParams<LiquidHeight>()
{
  InputParameters params = validParams<GeneralPostprocessor>();

  params.addRequiredParam<PostprocessorName>("minuend", "The name of the PP that is computing the total amount of boron deposited.");

  params.addRequiredParam<Real>("thickness", "unit:mm");

  return params;
}

LiquidHeight::LiquidHeight(const InputParameters & parameters) :
    GeneralPostprocessor(parameters),
    _minuend(getPostprocessorValue("minuend")),
    _thickness(getParam<Real>("thickness"))
    //_in_meters(getParam<bool>("in_meters"))
{}

Real
LiquidHeight::getValue()
{
   //if(_in_meters)
  //  area*=(0.001*0.001);*

  return  (_thickness-_minuend);
}
