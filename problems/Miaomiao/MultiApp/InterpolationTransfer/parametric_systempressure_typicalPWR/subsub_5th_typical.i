#TODO: KineticDisPreConcAux.C use unit mol/L, however, as 1kg is about 1L for water, for now I didn't change by a factor, this edition considers 4 reactions, adding 2H3BO3+OH-  -->>B2(OH)7-
#This is all vapor part
[Mesh]
  type = GeneratedMesh
  dim = 2

  nx = 40
  ny = 80

  xmin = 0.002
  xmax = 0.01261566794

  ymin = 0.0
  ymax = 6.3e-3
  #uniform_refine = 2
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
    initial_condition = 620.0
  [../] 

  [./crud_pressure]
    order =  FIRST
    family =  LAGRANGE
    initial_condition = 15550.0
  [../]


[]

[AuxVariables]
  active =  ' H+ Li+ OH- H3BO3 disp_x 
             Unity                Phase          nodal_Psat_h2o 
             conductivity         LiBO2(s)       nodal_porosity
             nodal_tortuosity     ECofLiBO2      nodal_Tsat_h2o
             CapillaryPressure  y_coord  HeatCond Tsat_interface_vapor' 

  [./Tsat_interface_vapor]
  [../]

  [./disp_x]
  [../]

  [./HeatCond]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 1.0e5
  [../]

  [./y_coord]
  [../]

  [./CapillaryPressure]
    order = CONSTANT
    family = MONOMIAL
  [../]

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

  [./Unity]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./Phase]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./nodal_Psat_h2o]
    order = CONSTANT
    family = MONOMIAL
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
    initial_condition = 0.6
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
[]

[Kernels]
 active = 'ThermalDiffusion    ThermalAdvection      PressureDarcy'
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
  active =  'H+ Li+ OH- H3BO3  pesu_number
             Psat_h2o        Tsat_h2o           tortuosity          
             phase           aux_conductivity    
             aux_porosity    ECofLiBO2          unity
             CapillaryPressure  y_coord HeatCond'

  [./pesu_number]
   variable = disp_x
   type = ConstantAux
   value = -7.285713e-07
  [../]

  [./HeatCond]
    type = HeatConductionAux
    variable = HeatCond
    temperature = crud_temperature
  [../]

  [./y_coord]
    type = FunctionAux
    variable = y_coord
    function = y_dimension
  [../]

  [./CapillaryPressure]
    type = CapillaryPressureAux
    variable = CapillaryPressure
  [../]

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

  [./unity]
    type = ConstantAux
    variable = Unity
    value = 1.0
  [../]

#saturation pressure
  [./Psat_h2o]
    type = WaterSaturationPressureAux
    variable = nodal_Psat_h2o
    temperature = crud_temperature
    capillary = CapillaryPressure
    concentration = 'H+ Li+ H3BO3 OH-'
  [../]

  [./Tsat_h2o]
    type = WaterSaturationTemperatureAux
    variable = nodal_Tsat_h2o
    concentration = 'H+ Li+ H3BO3 OH-'
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
    variable = nodal_porosity
    type =  ConstantAux
    value = 0.6 ###
  [../]

#ECofLiBO2, lgkw
  [./ECofLiBO2]
    type = ECofLiBO2
    variable = ECofLiBO2
    temperature = crud_temperature
  [../]
[]

[Functions]
  [./y_dimension]
    type = ParsedFunction
    value = y
  [../]

  [./functionpressure]
    type = ParsedFunction
    value = -20+(0.006-y)*2e3#'15550.0-25*(0.020-y)'
  [../]

  [./functiontemperature]
    type = PiecewiseLinear
    x = '0.0 0.0012'
    y = '6.18e2 618.0'
    axis = 1
  [../]

  [./interfacetemperature]
    type = ParsedFunction
    value = a
    vals = Avg_Tsat_interface
    vars = a
  [../]

  [./interfacepressure]
    type = ParsedFunction
    value = 15510.0+b ####
    vals = CapillaryPressure
    vars = b
  [../]
[]

[BCs]

  active = 'temperature_bottom temperature_top_node temperautre_enthalpyflow
            pressure_up chimney_crud_pressure_3'
#temperature
  [./temperature_bottom]
    type = CRUDCladNeumannBC
    variable = crud_temperature
    boundary = 'bottom'
  [../]

  [./temperautre_enthalpyflow]
    type = ChimneyEnthalpyFlow
    variable = crud_temperature
    boundary = 'left'
    pressure = crud_pressure
  [../]

#This comes from liquid part (average value)
  [./temperature_top_avg]
    type = FunctionDirichletBC
    variable = crud_temperature
    boundary = 'top'
    function = interfacetemperature
  [../]

#This comes from liquid part (interpolation value)
  [./temperature_top_node]
    type = CoupledTsatDirichletBC
    variable = crud_temperature
    boundary = 'top'
    Tsat = Tsat_interface_vapor
  [../]

# pressure
  [./pressure_up]
    type =  FunctionDirichletBC
    variable =  crud_pressure
    boundary =  'top'
    function =  interfacepressure
  [../]
  
  [./chimney_crud_pressure_3]
    type = ChimneyVaporVelocity
    variable = crud_pressure
    boundary = 'left'
    MeshHeight = mesh_height
    AverageMassFlux = liquid_mass_flux
  [../]

[]

[Postprocessors]
  [./InterfacePositionRight]
    type = SideAverageValue
    variable = Phase
    boundary = 'right'
  [../] 

  [./InterfacePositionLeft]
    type = SideAverageValue
    variable = Phase
    boundary = 'left'
  [../]

  [./pesu_liquid_mass_flux]
    type = NodalMaxValue
    variable = disp_x
    execute_on = timestep_begin
  [../]

  [./Avg_Tsat_interface]
    type = Receiver
  [../]

  [./CapillaryPressure]
    type = Receiver
  [../]

#rho*v
  [./liquid_mass_flux]
    type = Receiver
  [../]

  [./heat_cond]
    type = SideAverageValue
    variable = HeatCond
    boundary = 'top'
  [../]

  [./mesh_height]
    type = NodalMaxValue
    variable = y_coord
    execute_on = timestep
  [../]

  [./Evaporation_Mass_Rate]
    type = IntegratedSideFlux
    variable = crud_pressure
    boundary = 'left'
  [../]

  [./Peak_Clad_Temp]
    type = NodalMaxValue
    variable = crud_temperature
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
    thickness= 6e-3
  [../]

#for testing purpose
  [./test_interface_temperature]
    type = SideAverageValue
    variable = crud_temperature
    boundary = 'top'
  [../]

  [./clad_avg_temperature]
    type = SideAverageValue
    variable = crud_temperature
    boundary = 'bottom'
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
    case=1 #0,all liquid;1,all vapor;2,2 phases
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

    #output_properties = CladHeatFluxIn
  [../]
[]

[Executioner]
  type =  Transient
  petsc_options =  '-snes_mf_operator'
  petsc_options_iname =  '-pc_type -pc_hypre_type -ksp_gmres_restart'
  petsc_options_value =  'hypre    boomeramg  51'
  l_max_its =  50
  nl_max_its =  15
  nl_abs_tol=  1e-6
  l_abs_tol=  1e-6
  nl_rel_tol =  1e-6
  l_rel_tol =  1e-6
  start_time =  0.0
  end_time = 10.0
  num_steps =  40
  dt = 5e-1
  dtmin =  0.00000001


[]

#[Debug]
#  show_top_residuals             = 1                     
# # show_var_residual_norms        = 1
#[]

[Outputs]
  execute_on = 'timestep_end'
  file_base = subsub_5th_typical
  exodus = true
  csv = true
  [./console]
    type = Console
    perf_log = true
    linear_residuals = true
  [../]
[]
