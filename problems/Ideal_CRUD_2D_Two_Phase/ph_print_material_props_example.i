  # This example shows the new way to "print" out all EOS fluid properties to the 
  # output file.  It is the same problem as is used in pressure_enthalpy_example.i
  # but with all properties included.
[Mesh]
  file = simple_3d_May_2012.e
[]

[Variables]
  [./pressure]
    order = FIRST
    family = LAGRANGE
    initial_condition = 2e6
  [../]
  [./enthalpy]
    order = FIRST
    family = LAGRANGE
    initial_condition = 850000
  [../]
[]

[AuxVariables]
  # AuxVariable temperature is required here for pressure-enthalpy based problems.
  # It is used for computing grad_T in the EnthalpyTimeDerivative Kernel. Gradients
  # cannot be computed for material properties, so this is the only fluid property 
  # that must remain an auxkernel.
  [./temperature]
    order = FIRST
    family = LAGRANGE
  [../]
  #------------------------------------------------------------------------------
  # Velocity uses its own type of auxkernel because it is a vector with componants
  [./v_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./v_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./v_z]
    order = CONSTANT
    family = MONOMIAL
  [../]
  #------------------------------------------------------------------------------
  # All fluid properties bellow are calculated as material properties internally, but 
  # in order to 'print' them in the output file they need to be fed through an elemental 
  # auxkernel called MaterialRealAux.  If you do not wish to see these properties in the 
  # output file, all of these auxveriables and respective auxkernels can be removed from
  # the input file.
  [./density]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./density_water]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./density_steam]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./viscosity_water]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./viscosity_steam]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./enthalpy_water]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./enthalpy_steam]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./saturation_water]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./ddensitydH_P]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./ddensitydp_H]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./denthalpy_steamdH_P]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./denthalpy_waterdH_P]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./denthalpy_waterdP_H]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./denthalpy_steamdP_H]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dTdP_H]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dswdH]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dTdH_P]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
# Bellow are the respective flow and energy kernels for pressure-enthalpy
# problems
  # Pressure Kernels
  [./p_td]
    type = MassFluxTimeDerivative
    variable = pressure
    enthalpy = enthalpy
  [../]
  [./p_wmfp]
    type = WaterMassFluxPressure
    variable = pressure
    enthalpy = enthalpy
  [../]
  [./p_wsfp]
    type = SteamMassFluxPressure
    variable = pressure
    enthalpy = enthalpy
  [../]
  # ------------------------------
  # Enthalpy/Temperature Kernels
  [./t_td]
    type = EnthalpyTimeDerivative
    variable = enthalpy
    temperature = temperature
    pressure = pressure
  [../]
  [./t_d]
    type = EnthalpyDiffusion
    variable = enthalpy
    pressure = pressure
    temperature = temperature
  [../]
  [./t_cw]
    type = EnthalpyConvectionWater
    variable = enthalpy
    pressure = pressure
  [../]
  [./t_cs]
    type = EnthalpyConvectionSteam
    variable = enthalpy
    pressure = pressure
  [../]
[]

[AuxKernels]
  [./temperature]
    type = FalconCoupledTemperatureAux
    variable = temperature
    pressure = pressure
    enthalpy = enthalpy
    water_steam_properties = water_steam_properties
  [../]
  # -----------------------------------------------
  [./vx]
    type = FalconVelocityAux
    vector = darcy_flux_water
    variable = v_x
    index = 0
  [../]
  [./vy]
    type = FalconVelocityAux
    vector = darcy_flux_water
    variable = v_y
    index = 1
  [../]
  [./vz]
    type = FalconVelocityAux
    vector = darcy_flux_water
    variable = v_z
    index = 2
  [../]
  # -----------------------------------------------
  [./density]
    type = MaterialRealAux
    variable = density
    property = density
  [../]
  [./density_water]
    type = MaterialRealAux
    variable = density_water
    property = density_water
  [../]
  [./density_steam]
    type = MaterialRealAux
    variable = density_steam
    property = density_steam
  [../]
  [./viscosity_water]
    type = MaterialRealAux
    variable = viscosity_water
    property = viscosity_water
  [../]
  [./viscosity_steam]
    type = MaterialRealAux
    variable = viscosity_steam
    property = viscosity_steam
  [../]
  [./enthalpy_water]
    type = MaterialRealAux
    variable = enthalpy_water
    property = enthalpy_water
  [../]
  [./enthalpy_steam]
    type = MaterialRealAux
    variable = enthalpy_steam
    property = enthalpy_steam
  [../]
  [./ddensitydH_P]
    type = MaterialRealAux
    variable = ddensitydH_P
    property = ddensitydH_P
  [../]
  [./ddensitydp_H]
    type = MaterialRealAux
    variable = ddensitydp_H
    property = ddensitydp_H
  [../]
  [./denthalpy_steamdH_P]
    type = MaterialRealAux
    variable = denthalpy_steamdH_P
    property = denthalpy_steamdH_P
  [../]
  [./denthalpy_waterdH_P]
    type = MaterialRealAux
    variable = denthalpy_waterdH_P
    property = denthalpy_waterdH_P
  [../]
  [./denthalpy_steamdP_H]
    type = MaterialRealAux
    variable = denthalpy_steamdP_H
    property = denthalpy_steamdP_H
  [../]
  [./denthalpy_waterdP_H]
    type = MaterialRealAux
    variable = denthalpy_waterdP_H
    property = denthalpy_waterdP_H
  [../]
  [./dTdP_H]
    type = MaterialRealAux
    variable = dTdP_H
    property = dTdP_H
  [../]
  [./saturation_water]
    type = MaterialRealAux
    variable = saturation_water
    property = saturation_water
  [../]
  [./dswdH]
    type = MaterialRealAux
    variable = dswdH
    property = dswdH
  [../]
  [./dTdH_P]
    type = MaterialRealAux
    variable = dTdH_P
    property = dTdH_P
  [../]
[]

[BCs]
  [./left_p]
    type = DirichletBC
    variable = pressure
    boundary = 1
    value = 2e6
  [../]
  [./left_t]
    type = DirichletBC
    variable = enthalpy
    value = 850000
    boundary = 1
  [../]
  [./right_p]
    type = DirichletBC
    variable = pressure
    boundary = 2
    value = 1999900
  [../]
  [./right_t]
    type = DirichletBC
    variable = enthalpy
    value = 800000
    boundary = 2
  [../]
[]

[Materials]
  [./matrix]
    type = FalconGeothermal
    block = 1
    pressure = pressure
    enthalpy = enthalpy
    water_steam_properties = water_steam_properties
    gravity = 0.0
    gx = 0.0
    gy = 0.0
    gz = 0.0
    material_porosity = 0.3
    permeability = 1e-15
    density_rock = 2500
    thermal_conductivity = 2.5
    specific_heat_water = 4186
    specific_heat_rock = 920
  [../]
[]

[UserObjects]
  [./water_steam_properties]
    type = WaterSteamEOS
  [../]
[]

[Executioner]
  type = Transient
  dt = 10000
  num_steps = 150

  #Preconditioned JFNK (default)
  solve_type = 'PJFNK'


[]

[Output]
  file_base = out_ph_print_material_props_example
  output_initial = true
  interval = 1
  exodus = true
[]

