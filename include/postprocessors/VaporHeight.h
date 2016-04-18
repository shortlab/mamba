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

#ifndef VAPORHEIGHT_H
#define VAPORHEIGHT_H

#include "GeneralPostprocessor.h"

//Forward Declarations
class VaporHeight;

template<>
InputParameters validParams<VaporHeight>();

class VaporHeight : public GeneralPostprocessor
{
public:
  VaporHeight(const std::string & name, InputParameters parameters);

  virtual void initialize() {}
  virtual void execute() {}

  /**
   * This will return the current time step size.
   */
  virtual Real getValue();

protected:
  PostprocessorValue & _integral;
  PostprocessorValue & _area;
  Real _thickness;
};

#endif //VaporHeight_H
