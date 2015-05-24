#ifndef COEFFTIMEDERIVATIVE_H
#define COEFFTIMEDERIVATIVE_H

#include "TimeDerivative.h"

//Forward Declarations
class CoeffTimeDerivative;

template<>
InputParameters validParams<CoeffTimeDerivative>();

class CoeffTimeDerivative : public TimeDerivative
{
public:

  CoeffTimeDerivative(const std::string & name, InputParameters parameters);

protected:
  virtual Real computeQpResidual();

  virtual Real computeQpJacobian();

  MaterialProperty<Real> & _time_coefficient;
};
#endif //COEFTIMEDERIVATIVE
