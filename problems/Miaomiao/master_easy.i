#2-phase!!!, original file: Steady_PT_2Phase.i

[Mesh]
  type = GeneratedMesh
  dim = 2


  nx = 25
  ny = 25

  xmin = 0.002
  xmax = 0.01261566794

  ymin = 0.0
  ymax = 0.025
#  elem_type = QUAD9
[]

[Variables]
  [./crud_temperature]
    order = FIRST
    family = LAGRANGE
    initial_condition = 618.5
 [../]

  [./crud_pressure]
    order = FIRST
    family = LAGRANGE
    initial_condition = 15500.
  [../]

[]

[AuxVariables]
  [./H3BO3]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./CapillaryPressure]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./Phase]
# elemental if defined as following
    order = FIRST
    family = LAGRANGE
    initial_condition=0.0
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
  active = 'ThermalDiffusion ThermalAdvection PressureDarcy '

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
  [../]


[]


[AuxKernels]
  [./H3BO3]
    type = ConstantAux
    variable = H3BO3
    value = 0.0
  [../]

  [./CapillaryPressure]
    type = CapillaryPressureAux
    variable = CapillaryPressure
  [../]

  [./phase]
    type = PhaseAux
    variable = Phase
    psat = nodal_Psat_h2o
    pressure = crud_pressure
    deltaP = 1.
    Shift=0.0
  [../]

  [./unity]
    type = ConstantAux
    variable = Unity
    value = 1.0
  [../]

  [./porosity]
    type = ConstantAux
    variable = nodal_porosity
    skeleton = 0.5
  [../]

  [./tortuosity]
    type = TortuosityAux
    variable = nodal_tortuosity
    porosity = nodal_porosity
  [../]

  [./Psat_h2o]
    type = WaterSaturationPressureAux
    variable = nodal_Psat_h2o
    temperature = crud_temperature
    initial_condition = 15500
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




#  [./right_dirichlet]
#    type = OnOffDirichletBC
#    variable = crud_temperature
#    boundary = 'left'
#    var2= Phase
#    value = 618.5
#  [../]

#  [./left_coolant_crud_temperature]
#    type = ConditionLeftTemp
#    variable = crud_temperature
#    boundary = 'left'
#    coef1=618.5
#    constval=618.5
#    TurningPoint=vapor_height
#    HypoTurningPoint=0.020
#    UsingHypo=1
#  [../]


  [./coolant_crud_temp]
    type = DirichletBC
    variable = crud_temperature
    boundary = 'left'
    value = 618.5
  [../]

  [./chimney_crud_pressure]
    type = FunctionDirichletBC
    variable = crud_pressure
    boundary = left
    function = functionpressure
  [../]
#  [./pressure_left]
#    type = ChimneyEvaporationNeumannBC
#    variable = crud_pressure
#    boundary = 3
#    temperature = crud_temperature
#    HBO2 = H3BO3
#  [../]


  [./coolant_crud_pressure]
    type = DirichletBC
    variable = crud_pressure
    boundary = 'top'
    value = 15500.0
  [../]
[]

[Postprocessors]

  [./integral_phase]
    type = ElementIntegralVariablePostprocessor
    variable = Phase
  [../]

  [./vapor_height]
    type=VaporHeight
    integral_all=integral_phase
    area=field_area
    thickness=0.025
  [../]
  [./field_area]
    type = ElementIntegralVariablePostprocessor
    variable = Unity
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
    case=0
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
    phase = Phase
  [../]
[]

[Functions]
  [./functionpressure]
    type = ParsedFunction
    value = '15500.0+100*(0.025-y)'
  [../]
[]

[Executioner]
 type = Steady
  # Preconditioned JFNK (default)
  solve_type = 'PJFNK'

  l_max_its = 50
  nl_max_its = 50
#  l_tol = 1e-5 (default value)
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'

  [./Adaptivity]
    steps = 2
    cycles_per_step = 2
    refine_fraction = 0.5
    coarsen_fraction = 0.05
    max_h_level = 4
    error_estimator = PatchRecoveryErrorEstimator
  [../]

[]

[Outputs]
  file_base = master_easy
  exodus = true
  [./console]
    type = Console
    perf_log = true
    linear_residuals = true
  [../]
[]

