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

#ifndef WATERSIDEFLUXAVERAGE_H
#define WATERSIDEFLUXAVERAGE_H

#include "IntegratedSideFlux.h"

//Forward Declarations
class WaterSideFluxAverage;

template<>
InputParameters validParams<WaterSideFluxAverage>();

class WaterSideFluxAverage : public IntegratedSideFlux
{
public:
  WaterSideFluxAverage(const InputParameters & parameters);
  virtual ~WaterSideFluxAverage(){}

  virtual void initialize();
  virtual void execute();
  virtual Real getValue();
  virtual void threadJoin(const UserObject & y);

protected:
  Real _volume;
};

#endif
