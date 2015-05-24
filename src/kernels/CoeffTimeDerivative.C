#include "CoeffTimeDerivative.h"

#include "Material.h"

template<>
InputParameters validParams<CoeffTimeDerivative>()
{
  InputParameters params = validParams<TimeDerivative>();
  return params;
}

CoeffTimeDerivative::CoeffTimeDerivative(const std::string & name, InputParameters parameters)
  :TimeDerivative(name,parameters),
  _time_coefficient(getMaterialProperty<Real>("porosity"))
{
}

Real
CoeffTimeDerivative::computeQpResidual()
{
  return _time_coefficient[_qp]*TimeDerivative::computeQpResidual();
}

Real
CoeffTimeDerivative::computeQpJacobian()
{
  return _time_coefficient[_qp]*TimeDerivative::computeQpJacobian();
}
