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

#include "NodalMaxValueFileIO.h"

#include <algorithm>
#include <limits>
#include <iostream>
#include <fstream>
#include <string>

template<>
InputParameters validParams<NodalMaxValueFileIO>()
{
  InputParameters params = validParams<NodalVariablePostprocessor>();
  return params;
}

NodalMaxValueFileIO::NodalMaxValueFileIO(const std::string & name, InputParameters parameters) :
  NodalVariablePostprocessor(name, parameters)
{}

void
NodalMaxValueFileIO::initialize()
{
  _value = -std::numeric_limits<Real>::max();
}

void
NodalMaxValueFileIO::execute()
{
  _value = std::max(_value, _u[_qp]);
}

Real
NodalMaxValueFileIO::getValue()
{
  gatherMax(_value);
  std::ofstream myfile ("PeakCladTemp.out");
  if (myfile.is_open())
  {
    myfile << "PeakCladTemp = " << _value << std::endl;
    myfile.close();
  }
  else std::cout << "Unable to open file";

  return _value;
}

void
NodalMaxValueFileIO::threadJoin(const UserObject & y)
{
  const NodalMaxValueFileIO & pps = static_cast<const NodalMaxValueFileIO &>(y);
  _value = std::max(_value, pps._value);
}

