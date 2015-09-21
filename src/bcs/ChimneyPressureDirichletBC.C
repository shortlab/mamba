#include "ChimneyPressureDirichletBC.h"
//#include "Function.h"

template<>
InputParameters validParams<ChimneyPressureDirichletBC>()
{
  InputParameters params = validParams<NodalBC>();
 // params.addParam<Real>("value", 0.0, "The value the variable should have on the boundary");
 // params.addRequiredParam<FunctionName>("function", "The forcing function.");
  params.addRequiredParam<PostprocessorName>("PP", "The name of the postprocessor you are trying to get.");
  return params;
}

ChimneyPressureDirichletBC::ChimneyPressureDirichletBC(const InputParameters & parameters) :
    NodalBC(parameters),
    //_func(getFunction("function")),
    _pp(getPostprocessorValue("PP"))
{
}

Real
ChimneyPressureDirichletBC::computeQpResidual()
{
  Real y = (*_current_node)(1);
  Real r=_u[_qp]-(15500000*0.001+4*2.3e-8*_pp/25e-3/2e-3/2e-3*(25*0.001*0.001*25-y*y));
  return r;
}

