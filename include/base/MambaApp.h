#ifndef MAMBAAPP_H
#define MAMBAAPP_H

#include "MooseApp.h"

class MambaApp;

template<>
InputParameters validParams<MambaApp>();

class MambaApp : public MooseApp
{
public:
  MambaApp(InputParameters parameters);
  virtual ~MambaApp();

  static void registerApps();
  static void registerObjects(Factory & factory);
  static void associateSyntax(Syntax & syntax, ActionFactory & action_factory);
};

#endif //MAMBAAPP_H
