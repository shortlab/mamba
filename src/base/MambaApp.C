#include "MambaApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"

template<>
InputParameters validParams<MambaApp>()
{
  InputParameters params = validParams<MooseApp>();
  return params;
}

MambaApp::MambaApp(const std::string & name, InputParameters parameters) :
    MooseApp(name, parameters)
{
  srand(libMesh::processor_id());
  
  Moose::registerObjects(_factory);
  ModulesApp::registerObjects(_factory);
  MambaApp::registerObjects(_factory);

  Moose::associateSyntax(_syntax, _action_factory);
  ModulesApp::associateSyntax(_syntax, _action_factory);
  MambaApp::associateSyntax(_syntax, _action_factory);
}

MambaApp::~MambaApp()
{
}

void
MambaApp::registerApps()
{
  registerApp(MambaApp);
}

void
MambaApp::registerObjects(Factory & factory)
{
}

void
MambaApp::associateSyntax(Syntax & syntax, ActionFactory & action_factory)
{
}
