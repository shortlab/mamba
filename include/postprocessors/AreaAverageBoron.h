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

#ifndef AREAAVERAGEBORON_H
#define AREAAVERAGEBORON_H

#include "GeneralPostprocessor.h"

//Forward Declarations
class AreaAverageBoron;

template<>
InputParameters validParams<AreaAverageBoron>();

class AreaAverageBoron : public GeneralPostprocessor
{
public:
  AreaAverageBoron(const std::string & name, InputParameters parameters);

  virtual void initialize() {}
  virtual void execute() {}

  /**
   * This will return the current time step size.
   */
  virtual Real getValue();

protected:
  const PostprocessorValue & _total_boron;
  const PostprocessorValue & _area;

  bool _in_meters;
};

#endif //AREAAVERAGEBORON_H
