#ifndef MAMBAAPP_H
#define MAMBAAPP_H

#include "MooseApp.h"

class MambaApp;

template<>
InputParameters validParams<MambaApp>();

class MambaApp : public MooseApp
{
public:
  MambaApp(const std::string & name, InputParameters parameters);

  static void registerApps();
  static void registerObjects(Factory & factory);
};

#endif //MAMBAAPP_H
