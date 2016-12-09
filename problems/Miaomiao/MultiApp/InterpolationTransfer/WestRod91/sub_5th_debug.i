[Mesh]
  type = GeneratedMesh
  dim = 2

  nx = 25
  ny = 50

  xmin = 0.002
  xmax = 0.01261566794

  ymin = 0
  ymax = 15e-3
  uniform_refine = 2
  #elem_type = QUAD9
#  displacements = 'disp_x disp_y'
  distribution = serial
[]

[Problem]
  # Specify coordinate system type
  coord_type = RZ
[]

[Variables]
  active =  'crud_temperature crud_pressure'	

  [./crud_temperature]
    order =  FIRST
    family =  LAGRANGE
    initial_condition = 618.0
  [../] 

  [./crud_pressure]
    order =  FIRST
    family =  LAGRANGE
    initial_condition = 15500.0
  [../]
[]

[AuxVariables]
  active =  'H+ Li+ OH- H3BO3 disp_x             disp_y             thickness_change 
             Unity              FluidVelocity      
             PecletNumber       Phase              nodal_Psat_h2o 
             conductivity       LiBO2(s)           nodal_porosity
             nodal_tortuosity   ECofLiBO2          nodal_Tsat_h2o mass_flux VaporTemp  CapillaryPressure  HeatCond  tryingheatcond'

  [./Li+]
    order =  FIRST
    family =  LAGRANGE
    initial_condition = 0.0
   [../]

  [./OH-]
    order =  FIRST
    family =  LAGRANGE
    initial_condition = 0.0
  [../]

  [./H+]
    order =  FIRST
    family =  LAGRANGE
    initial_condition = 0.0
  [../]

  [./H3BO3]
    order =  FIRST
    family =  LAGRANGE
    initial_condition = 0.0
  [../]


  [./tryingheatcond]
  [../]

  [./HeatCond]
    order = CONSTANT
    family = MONOMIAL
  [../]
 

  [./CapillaryPressure]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./disp_x]
    #initial_condition = 0.0
  [../]
  [./disp_y]
    #initial_condition = -0.005
  [../]
  [./thickness_change]
  [../]

  [./Unity]
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

  [./Phase]
# nodal if defined as following
    order = CONSTANT
    family = MONOMIAL
    initial_condition=0.0
  [../]

  [./nodal_Psat_h2o]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 15600.
  [../]

  [./nodal_Tsat_h2o]
    order = FIRST
    family = LAGRANGE
    initial_condition = 617.937
  [../]


  [./conductivity]
    order =  CONSTANT
    family =  MONOMIAL
  [../]

  [./LiBO2(s)]
    order =  FIRST
    family =  LAGRANGE
  [../]

  [./nodal_porosity]
    order =  FIRST
    family =  LAGRANGE
    initial_condition = 0.5
  [../]

  [./nodal_tortuosity]
    order = FIRST
    family = MONOMIAL
    initial_condition = 1.5
  [../]

  [./ECofLiBO2]
    order =  FIRST
    family =  LAGRANGE
  [../]

  [./mass_flux]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./VaporTemp]
    order = CONSTANT
    family = MONOMIAL
  [../]


[]

[Kernels]
 active = 'ThermalDiffusion    ThermalAdvection

           PressureDarcy'

# crud_temperature
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

# crud_pressure
  [./PressureDarcy]
    # This Kernel uses "permeability" from the active material
    type = PressureDarcy
    variable = crud_pressure
    porosity = nodal_porosity
    #HBO2 = crud_concentration_HBO2
  [../]

[]

[AuxKernels]

  [./H3BO3]
    type = ConstantAux
    variable = H3BO3
    value = 0.0
  [../]

  [./H+]
    type = ConstantAux
    variable = H+
    value = 0.0
  [../]

  [./OH-]
    type = ConstantAux
    variable = OH-
    value = 0.0
  [../]

  [./Li+]
    type = ConstantAux
    variable = Li+
    value = 0.0
  [../]

  [./HeatCond]
    type = ConstantAux
    variable = HeatCond
    value = 1.025527e+06
  [../]

  [./crud_thickness_interpolation]
#    type = CoupledDirectionalMeshHeightInterpolation
#    variable = disp_y
#    direction = y
#    execute_on = initial
#    coupled_var = thickness_change

   variable = disp_y
   type = ConstantAux
   execute_on = timestep_begin
   value = 0.0
  [../]

  [./thickness_change]
    type = FunctionAux
    variable = thickness_change
    function = y_displacement
    execute_on = initial
  [../]

  [./unity]
    type = ConstantAux
    variable = Unity
    value = 1.0
  [../]

  [./CapillaryPressure]
    type = CapillaryPressureAux
    variable = CapillaryPressure
  [../]

#saturation pressure
  [./Psat_h2o]
    type = WaterSaturationPressureAux
    variable = nodal_Psat_h2o
    temperature = crud_temperature
    capillary = CapillaryPressure
    concentration = 'H+ Li+ LiBO2(s) H3BO3 OH-'
  [../]

  [./Tsat_h2o]
    type = WaterSaturationTemperatureAux
    variable = nodal_Tsat_h2o
    concentration = 'H+ Li+ LiBO2(s) H3BO3 OH-'
  [../]

#tortuosity
  [./tortuosity]
    type = TortuosityAux
    variable = nodal_tortuosity
    porosity = nodal_porosity
  [../]

#phase variable
  [./phase]
    type = PhaseAux
    variable = Phase
    psat = nodal_Psat_h2o
    pressure = crud_pressure
    deltaP = 1.
    Shift=100.0
  [../]

# conductivity
  [./aux_conductivity]
    type =  ConductivityFieldAux
    variable =  conductivity
    porosity =  nodal_porosity
  #permeability/viscosity/nodal_porosity
  [../]


# porosity
  [./aux_porosity]
    type =  ConstantAux
    variable =  nodal_porosity
    value = 0.5
  [../]

#ECofLiBO2, lgkw
  [./ECofLiBO2]
    type = ECofLiBO2
    variable = ECofLiBO2
    temperature = crud_temperature
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

  [./FluidMassFlux]
    type = FluidMassFluxAux
    variable = mass_flux
    pressure = crud_pressure
  [../]


  [./VaporChimneyTempAvg]
    type = EnergyBalanceAux
    variable = VaporTemp
    SuctionMassFlux = Suction_crud_coolant
    CoolantCrudTempAvg = CoolantCrudTempAvg
    LiquidHeight = liquid_height
    CoolantTemperature = 600.0
    T_sat = nodal_Tsat_h2o
   [../]
  
[]

[BCs]
 active = 'temperature_bottom  temperature_left temperature_up
           pressure_up         pressure_left  pressure_bottom'
#temperature
  [./temperature_bottom]
    type = CoupledTsatDirichletBC
    variable = crud_temperature
    boundary = 0
    Tsat = nodal_Tsat_h2o
  [../]

  [./temperature_up]
    type = CRUDCoolantNeumannBC
    variable = crud_temperature
    boundary = 2
    T_coolant = 608.18
    h_convection_coolant = 4.5209e4 #45000.0
  [../]

  [./temperature_left]
    type = CoupledTsatDirichletBC
    variable = crud_temperature
    boundary = 3
    Tsat = nodal_Tsat_h2o
  [../]

# pressure
  [./pressure_up]
    type =  DirichletBC
    variable =  crud_pressure
    boundary =  2
    value =  15616.62527 
  [../]

  [./pressure_left]
    type = ChimneyEvaporationNeumannBC
    variable = crud_pressure
    boundary = 3
    temperature = crud_temperature
    HBO2 = H3BO3
    porosity = nodal_porosity
  [../]

  [./pressure_bottom]
    type = ChimneyEvaporationNeumannBC
    variable = crud_pressure
    boundary = 0
    temperature = crud_temperature
    HBO2 = H3BO3
    porosity = nodal_porosity
    VaporHeatCond = HeatCond
  [../]
  [./pressure_bottom_2]
    type = DirichletBC
    variable = crud_pressure
    boundary = 0
    value = 15615.
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
    cell_inner_radius = 2.0e-6
    cell_outer_radius = 0.01261566794e-3
    CladHeatFluxIn = 1000000.0
    ConvectionCoefficient = 4.5209e4

    WaterViscosityAt298K = 8.4e-4
    DiffusivityOfMonoborateAt298K = 1.07e-9
    DiffusivityOfLithiumAt298K = 1.029e-9
    DiffusivityOfHydrogenAt298K = 9.311e-9
    DiffusivityOfHydroxideAt298K = 5.273e-9

# Scale everything to millimeters & Kpa
    ScalingFactor = 0.001
    debug_materials = 0
    case=0 #0,all liquid;1,all vapor;2,2 phases
    CRUDThickness = 0.025 #mm

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

    #output_properties = EquConstofH2O
  [../]
[]

[Functions]
  [./y_displacement]
    type = ParsedFunction
    value = y
  [../]
[]

[Postprocessors]

  [./liquid_height]
    type = NodalMaxValue
    variable = thickness_change
  [../]

  [./field_area]
    type = ElementIntegralVariablePostprocessor
    variable = Unity
  [../]

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

  [./Evaporation_Mass_Flux]
    type = WaterSideFluxAverage
    variable = crud_pressure
    boundary = 'top'
  [../]

#water sucked into crud
  [./Suction_crud_coolant]
    type = WaterSideFluxAverage
    variable = crud_pressure
    boundary = 'top'
  [../]

#water evaporation at interface
  [./Evaporation_Mass_Flux_interface]
    type = SideAverageValue
    variable = mass_flux
    boundary = 'bottom'
  [../]

  [./CoolantCrudTempAvg]
    type = SideAverageValue
    variable = crud_temperature
    boundary = 'top'
  [../]
  
  [./VaporTempAvg]
    type = SideAverageValue
    variable = VaporTemp
    boundary = 'bottom'
  [../]
[]

[Executioner]
  type =  Transient
  petsc_options =  '-snes_mf_operator'
  petsc_options_iname =  '-pc_type -pc_hypre_type -ksp_gmres_restart'
  petsc_options_value =  'hypre    boomeramg 51'
  l_max_its =  50
  nl_max_its =  20
#  nl_abs_tol=  1e-6
#  l_abs_tol=  1e-5
  nl_rel_tol =  1e-5
  l_rel_tol =  1e-5
  start_time =  0.0
  end_time = 1.0
  num_steps =  6
  dt = 1.0-1
  dtmin =  0.00000001
  [./Adaptivity]
#    initial_adaptivity = 3
    error_estimator = KellyErrorEstimator
    refine_fraction = 0.85
    coarsen_fraction = 0.05
    max_h_level = 4
  [../]

[]

#[Debug]
#  show_top_residuals             = 1                     
# # show_var_residual_norms        = 1
#[]

[Outputs]
  execute_on = 'timestep_end'
  file_base = sub_5th
  exodus = true
  csv = true
  [./console]
    type = Console
    perf_log = true
    linear_residuals = true
  [../]
[]

