#include "InterfaceVaporPressureAux.h"

template<>
InputParameters validParams<InterfaceVaporPressureAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addRequiredCoupledVar("CapillaryPressure", "Capillary pressure field");
  params.addRequiredCoupledVar("LiquidPressure", "pressure field for liquid part");  
  return params;
}

InterfaceVaporPressureAux::InterfaceVaporPressureAux(const std::string & name,
                     InputParameters parameters)
    :AuxKernel(name,parameters),
     _pc(coupledValue("CapillaryPressure")),
     _pl(coupledValue("LiquidPressure"))
{}

Real
InterfaceVaporPressureAux::computeValue()
{
  

  
  return _pc[_qp] + _pl[_qp];

    
}
