$ Aprepro (Revision: 2.23) Tue Dec 31 11:01:41 2013
#25
#2
#2000000000
#0.0012
#600
#0.5
#1000000
#12000
#2.3e-08 #mm

#0.0125 #mm
#    CoolantPressure = 15500.0
#9.662e+11 #mm
#1.0192e-07 #mm

#15500000
#0
#0.15
#0.1
#0.75
#0
#0.001

[Mesh]
  type = GeneratedMesh
  dim = 2
  uniform_refine = 4

  nx = 5
  ny = 25

  xmin = 0.002
  xmax = 0.01261566794

  ymin = 0.0
  ymax = 0.025
  elem_type = QUAD4
[]

[Variables]
  [./crud_temperature]
    order = FIRST
    family = LAGRANGE
    initial_condition = 600.
 [../]

  [./crud_pressure]
    order = FIRST
    family = LAGRANGE
    initial_condition = 15500.
  [../]

[]

[AuxVariables]
  [./CapillaryPressure]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./Phase]
    order = FIRST
    family = LAGRANGE
  [../]

  [./Unity]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./nodal_porosity]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.5
  [../]

  [./nodal_tortuosity]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 1.5
  [../]

  [./nodal_Psat_h2o]
    order = FIRST
    family = LAGRANGE
    initial_condition = 15500.
  [../]

  [./k_liquid]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./k_solid]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./k_CRUD_eff]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./WaterDensity]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./WaterViscosity]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./WaterVaporizationEnthalpy]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./WaterHeatCapacity]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./permeability]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./FluidVelocity]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./PecletNumber]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  active = 'ThermalDiffusion ThermalAdvection PressureDarcy'

  [./ThermalDiffusion]
    type = ThermalDiffusion
    variable = crud_temperature
  [../]

  [./ThermalAdvection]
    type = AdvectionForHeat
    variable = crud_temperature
    porosity = nodal_porosity
    tortuosity = nodal_tortuosity
    pressure = crud_pressure
    
  [../]

  [./PressureDarcy]
    # This Kernel uses "permeability" from the active material
    type = PressureDarcy
    variable = crud_pressure
    porosity = nodal_porosity
#    HBO2 = crud_concentration_HBO2
  [../]

[]


[DiracKernels]
  [./front_source]
    value = 50
    front_uo = tdf
    variable = crud_pressure
#    PressureJump = CapillaryPressure
    type = FrontSource
  [../]
[]


[AuxKernels]
  [./CapillaryPressure]
    type = CapillaryPressureAux
    variable = CapillaryPressure
  [../]

  [./phase]
    type = PhaseAux
    variable = Phase
    psat = nodal_Psat_h2o
    pressure = crud_pressure
    deltaP = 20.0
  [../]

  [./unity]
    type = ConstantAux
    variable = Unity
    value = 1.0
  [../]

  [./porosity]
    type = PorosityAux
    variable = nodal_porosity
    skeleton = 0.5
#    HBO2 = crud_concentration_HBO2
  [../]

  [./tortuosity]
    type = TortuosityAux
    variable = nodal_tortuosity
    porosity = nodal_porosity
  [../]

  [./permeability]
    type = MaterialRealAux
    variable = permeability
    property = permeability
# return factor*property+offset
    factor = 1e-06
    offset = 0
  [../]

  [./Psat_h2o]
    type = WaterSaturationPressureAux
    variable = nodal_Psat_h2o
    temperature = crud_temperature
    initial_condition = 15500
  [../]

  [./k_CRUD_eff]
    type = MaterialRealAux
    variable = k_CRUD_eff
    property = k_cond
    factor = 0.001
    offset = 0
  [../]

  [./k_liquid]
    type = MaterialRealAux
    variable = k_liquid
    property = k_liquid
    factor = 0.001
    offset = 0
  [../]

  [./k_solid]
    type = MaterialRealAux
    variable = k_solid
    property = k_solid
    factor = 0.001
    offset = 0
  [../]

  [./rho_h2o]
    type = MaterialRealAux
    variable = WaterDensity
    property = WaterDensity
    factor = 1000000000
    offset = 0
  [../]

  [./mu_h2o]
    type = MaterialRealAux
    variable = WaterViscosity
    property = WaterViscosity
    factor = 1000
    offset = 0
  [../]

  [./h_fg_h2o]
    type = MaterialRealAux
    variable = WaterVaporizationEnthalpy
    property = WaterVaporizationEnthalpy
    factor = 1e-06
    offset = 0
  [../]

  [./cp_h2o]
    type = MaterialRealAux
    variable = WaterHeatCapacity
    property = WaterHeatCapacity
    factor = 1e-06
    offset = 0
  [../]

  [./FluidVelocity_h2o]
    type = FluidVelocityAux
# This is to calculate the x-direction velocity
    variable = FluidVelocity
    pressure = crud_pressure
    porosity = nodal_porosity
  [../]

  [./PecletNumber_h2o]
    type = PecletAux
    variable = PecletNumber
    pressure = crud_pressure
  [../]
[]

[BCs]

  [./clad_crud_temperature]
    type = CRUDCladNeumannBC
    variable = crud_temperature
    boundary = 'bottom'
  [../]

  [./top_coolant_crud_temperature]
    type = CRUDCoolantNeumannBC
    variable = crud_temperature
    boundary = 'top'
    T_coolant = 600.0
    h_convection_coolant = 12000.0
  [../]

###
  [./left_coolant_crud_temperature]
    type = DirichletBC
    variable = crud_temperature
    boundary = 'left'
    value = 616.0
  [../]
####

#  [./chimney_crud_pressure]
#    type = FunctionDirichletBC
#    variable = crud_pressure
#    boundary = left
#    function = postprocessor_function
##    temperature = crud_temperature
##    HBO2 = crud_concentration_HBO2
#  [../]

  [./chimney_crud_pressure]
    type = FunctionDirichletBC
    variable = crud_pressure
    boundary = left
    function = bc_func
  [../]

  [./coolant_crud_pressure]
    type = DirichletBC
    variable = crud_pressure
    boundary = 'top'
    value = 15500.0
  [../]
[]

[UserObjects]
  [./tdf]
    type = TrackDiracFront
    var = Phase
    execute_on = timestep
  [../]
[]

[Materials]
  [./material_CRUD]
    type = CRUDMaterial
    block = 0

# Give the material properties in SI, then apply whatever scaling factor you want.

    dimensionality = 2
    pore_size_min_baseline = 2.5e-7
    pore_size_avg_baseline = 3.75e-7
    pore_size_max_baseline = 5.0e-7
    CladHeatFluxIn = 1000000.0

    WaterViscosityAt298K = 8.4e-4
    DiffusivityOfMonoborateAt298K = 1.03e-9
    DiffusivityOfLithiumAt298K = 1.07e-9

# Scale everything to millimeters & Kpa
    ScalingFactor = 0.001
    debug_materials = 0

    CRUDThickness = 0.025

# Densities in kg/m^3
#    DensityHBO2 = 2490

# Thermal conductivities in W/mK

#   k_Ni_baseline = XXXXX	# (Defined symbolically as the material)
#   k_NiO_baseline = XXXXX	# (Defined symbolically as the material)
#   k_Fe3O4_baseline = XXXXX	# (Defined symbolically as the material)
    k_NiFe2O4_baseline = 8.0	# dummy value
#   k_ZrO2_baseline = XXXXX	# (Defined symbolically as the material)
    k_HBO2_baseline = 0.5	# dummy value
    k_Li2B4O7_baseline = 0.5	# dummy value
    k_Ni2FeBO5_baseline = 0.5	# dummy value
    # Series character of the conductance network (0-1)
    k_series_character = 0.5

    # Volume fractions of solid phases
    vf_Ni_baseline = 0
    vf_NiO_baseline = 0.15
    vf_Fe3O4_baseline = 0.1
    vf_NiFe2O4_baseline = 0.75
    vf_ZrO2_baseline = 0
    vf_HBO2_baseline = 0
    vf_Li2B4O7_baseline = 0
    vf_Ni2FeBO5_baseline = 0

    tortuosity = nodal_tortuosity
    temperature = crud_temperature
    pressure = crud_pressure
#    concentration = crud_concentration_BO3
    porosity = nodal_porosity
#    HBO2 = crud_concentration_HBO2
    psat = nodal_Psat_h2o
  [../]
[]

[Functions]
  active = 'bc_func'

  [./postprocessor_function]
    type = PostprocessorFunction
    pp1 = up_bc_avg #top side temperature average value
    pp2 = up_bc_area
    WaterViscosityInChimney = 2.3e-8 #mm
    ChimneyInnerRadius = 0.002 #mm
#    ChimneyOuterRadius = 0.0125 #mm
    CladHeatFluxIn = 1000000.0
    CRUDThickness = 0.025 #mm
    CoolantPressure = 15500.0
    hfgAt15_5MPa = 966.2e9 #mm
    rho_gAt15_5MPa = 101.92e-9 #mm
    T_coolant = 600.0
    h_convection_coolant = 12000.0
  [../]

  [./bc_func]
    type = ParsedFunction
    value = 15500000*0.001+4*2.3e-8*alpha/25e-3/2e-3/2e-3*(25*0.001*0.001*25-y*y)
    vars = 'alpha'
    vals = V_exit
  [../]
[]


[Postprocessors]
  [./Peak_Clad_Temp_(K)]
    type = NodalMaxValueFileIO
    variable = crud_temperature
  [../]

  [./up_bc]
    type = SideIntegralVariablePostprocessor
    boundary = 'top'
    variable = crud_temperature
  [../]

  
  [./up_bc_avg]
    type = SideAverageValue
    boundary = 'top'
    variable = crud_temperature
  [../]

  [./up_bc_area]
    type = SideIntegralVariablePostprocessor
    boundary = 'top'
    variable = Unity
  [../]

  [./V_exit]
#mm/s
    type = VelocityExit
    pp1 = up_bc #Postprocessor value
    pp2 = up_bc_area
    WaterViscosityInChimney = 2.3e-8 #mm
    ChimneyInnerRadius = 0.002 #mm
    ChimneyOuterRadius = 0.0125 #mm
    CladHeatFluxIn = 1000000.0
    CRUDThickness = 0.025 #mm
    CoolantPressure = 15500.0
    hfgAt15_5MPa = 966.2e9 #mm
    rho_gAt15_5MPa = 101.92e-9 #mm
    T_coolant = 600.0
    h_convection_coolant = 12000.0
  [../]
[]

[Executioner]


  type = Transient

  num_steps = 40

  [./TimeStepper]
    type = DT2
    dt = 1e-6
    e_max = 3e-1
    e_tol = 1e-1
  [../]


#  petsc_options = '-snes_mf_operator'

  # Preconditioned JFNK (default)
  solve_type = 'PJFNK'

  l_max_its = 10
  nl_max_its = 60
  l_tol = 1e-5
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Adaptivity]
    steps = 2
#    cycles_per_step = 2
    refine_fraction = 0.5
    coarsen_fraction = 0.05
    max_h_level = 4
    error_estimator = PatchRecoveryErrorEstimator
[]

[Outputs]
  elemental_as_nodal = true
  file_base = out_2D_transi
  #  xda = true
  exodus = true
  perf_log = true
[]

