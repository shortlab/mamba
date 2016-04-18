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

#ifndef MULTIAPPSAMPLEPOSTPROCESSORTRANSFERBASE_H
#define MULTIAPPSAMPLEPOSTPROCESSORTRANSFERBASE_H

#include "MultiAppTransfer.h"

class MooseVariable;
class MultiAppSamplePostprocessorTransferBase;

template<>
InputParameters validParams<MultiAppSamplePostprocessorTransferBase>();

/**
 * Samples a variable's value in the Master domain at the point where the MultiApp is.
 * Copies that value into a postprocessor in the MultiApp.
 */
class MultiAppSamplePostprocessorTransferBase :
  public MultiAppTransfer
{
public:
  MultiAppSamplePostprocessorTransferBase(const std::string & name, InputParameters parameters);
  virtual ~MultiAppSamplePostprocessorTransferBase() {}

  virtual void execute();
  virtual Real getValue(MooseVariable & variable) const;

protected:
  AuxVariableName _postprocessor_name;
  PostprocessorName _from_var_name;
  // The offset to use with the multiapp_postion:
  std::vector<Point> _position_offset;
};

#endif /* MULTIAPPSAMPLEPOSTPROCESSORTRANSFERBASE_H */
