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

#include "WaterSideFluxAverage.h"

template<>
InputParameters validParams<WaterSideFluxAverage>()
{
  InputParameters params = validParams<IntegratedSideFlux>();
  return params;
}

WaterSideFluxAverage::WaterSideFluxAverage(const InputParameters & parameters) :
    IntegratedSideFlux(parameters),
    _volume(0)
{}

void
WaterSideFluxAverage::initialize()
{
  SideIntegralVariablePostprocessor::initialize();
  _volume = 0;
}

void
WaterSideFluxAverage::execute()
{
  SideIntegralVariablePostprocessor::execute();
  _volume += _current_side_volume;
}

Real
WaterSideFluxAverage::getValue()
{
  Real integral = SideIntegralVariablePostprocessor::getValue();

  gatherSum(_volume);

  return integral / _volume;
}

void
WaterSideFluxAverage::threadJoin(const UserObject & y)
{
  SideIntegralVariablePostprocessor::threadJoin(y);
  const WaterSideFluxAverage & pps = static_cast<const WaterSideFluxAverage &>(y);
  _volume += pps._volume;
}
