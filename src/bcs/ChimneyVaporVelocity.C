//This boundary condition is calculate vapor velocity coming out from crud to chimney based on mass conservation

//This doesn't work!!! because of coupling postprocessor value!!!

#include "ChimneyVaporVelocity.h"

template<>
InputParameters validParams<ChimneyVaporVelocity>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addParam<PostprocessorName>("MeshHeight", "The vapor thickness");
  params.addParam<PostprocessorName>("AverageMassFlux", "Mass flux from the liquid part calculation");
  return params;
}

ChimneyVaporVelocity::ChimneyVaporVelocity(const InputParameters & parameters)
 :IntegratedBC(parameters),
   _r_inner(getMaterialProperty<Real>("CellInnerRadius")),
   _r_outer(getMaterialProperty<Real>("CellOuterRadius")),
   _h(getPostprocessorValue("MeshHeight")),
   _m_dot(getPostprocessorValue("AverageMassFlux")),
   _rho_h2o(getMaterialProperty<Real>("WaterDensity"))
{}

Real
ChimneyVaporVelocity::computeQpResidual()
{ double _h= (_t_step<=1)? 6e-3: _h;
  double _m_dot = (_t_step <=1 )? 1.0e-7: _m_dot;
  //std::cout<<_t_step<<std::endl;
  double l_v_area_ratio = 1.0/2 * (pow(_r_outer[_qp],2)-pow(_r_inner[_qp],2))
                          /(_r_inner[_qp] * _h);
  double vapor_velocity = _test[_i][_qp] * std::abs(_m_dot) * l_v_area_ratio / _rho_h2o[_qp];//
  return vapor_velocity;
}
