// Moose Includes
#include "MambaApp.h"
#include "Moose.h"
#include "MambaApp.h"
#include "Factory.h"
#include "AppFactory.h"
#include "ActionFactory.h"

// First come the kernel header files

#include "ThermalDiffusion.h"
#include "AdvectionForHeat.h"
#include "PressureDarcy.h"
#include "AdvectionForConcentration.h"
#include "DiffusionForConcentration.h"
#include "BoricAcidSinks.h"
#include "ExampleTimeDerivative.h"
//#include "WaterSaturationTemperature.h"

// Next come the auxilliary kernels

#include "TortuosityAux.h"
#include "PorosityAux.h"
#include "WaterSaturationTemperatureAux.h"
#include "SuperheatTempAux.h"
#include "PecletAux.h"
#include "Precipitation_HBO2Aux.h"
#include "BO3_SolubilityAux.h"

// Next come the materials

#include "CRUDMaterial.h"
#include "Knife.h"
#include "Clay.h"

// Next come the boundary conditions

#include "CRUDCladNeumannBC.h"
#include "CRUDCladNeumannBCMultiApp.h"
#include "CRUDCoolantNeumannBC.h"
#include "CoupledTsatDirichletBC.h"
#include "ChimneyEvaporationNeumannBC.h"
#include "CRUDChimneyConcentrationMixedBC.h"

//userobjects
#include "WaterSteamEOS.h"

// Finally, the postprocessors

#include "NodalMaxValueFileIO.h"
#include "AreaAverageBoron.h"

template<>
InputParameters validParams<MambaApp>()
{
  InputParameters params = validParams<MooseApp>();
  return params;
}

MambaApp::MambaApp(const std::string & name, InputParameters parameters) :
    MooseApp(name, parameters)
{
  // Register all the user-created objects for incorporation and use
  Moose::registerObjects(_factory);
  MambaApp::registerObjects(_factory);

  // Associate Parser Syntax
  Moose::associateSyntax(_syntax, _action_factory);
}

void
MambaApp::registerApps()
{
  registerApp(MambaApp);
}

void
MambaApp::registerObjects(Factory & factory)
{
  // First come the kernels

  // Our new advection-diffusion kernel that accepts an auxKernel's aqueous species diffusivity,
  // the permeability material property, and the coupled pressure variable (of which the grad is taken)

  registerKernel(AdvectionForConcentration);
  registerKernel(DiffusionForConcentration);
  registerKernel(BoricAcidSinks);
//  registerAux(WaterSaturationTemperature);

  // Our new Darcy flow kernel that accepts the permeability material property

  registerKernel(PressureDarcy);

  // Our new thermal diffusion kernel that accepts the k_cond (thermal conductivity) material property

  registerKernel(ThermalDiffusion);
  registerKernel(AdvectionForHeat);
  registerKernel(ExampleTimeDerivative);

  // Next come the auxilliary kernels

  registerAux(TortuosityAux);
  registerAux(PorosityAux);
  registerAux(WaterSaturationTemperatureAux);
  registerAux(SuperheatTempAux);
  registerAux(PecletAux);
  registerAux(Precipitation_HBO2Aux);
  registerAux(BO3_SolubilityAux);

  // Next come the materials

  // Register our new CRUD material class so we can use it.

  registerMaterial(CRUDMaterial);
  registerMaterial(Knife);
  registerMaterial(Clay);

  // Next come the boundary conditions

  registerBoundaryCondition(CRUDCladNeumannBC);
  registerBoundaryCondition(CRUDCladNeumannBCMultiApp);
  registerBoundaryCondition(CRUDCoolantNeumannBC);
  registerBoundaryCondition(CoupledTsatDirichletBC);
  registerBoundaryCondition(ChimneyEvaporationNeumannBC);
  registerBoundaryCondition(CRUDChimneyConcentrationMixedBC);

  //userobjects
  registerUserObject(WaterSteamEOS);

  // Finally come the postprocessors
  registerPostprocessor(NodalMaxValueFileIO);
  registerPostprocessor(AreaAverageBoron);
}
