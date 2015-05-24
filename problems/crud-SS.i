[Mesh]
  type = FileMesh
  file = problems/Real_CRUD_Extruded/CRUD-Hole_remeshed.e
  #type = GeneratedMesh
  #dim = 2

  #nx = 25
  #ny = 50

  #xmin = 0.002
  #xmax = 0.01261566794

  #ymin = 0.0
  #ymax = 0.020
  #uniform_refine = 2
   # distribution = serial
[]

[MeshModifiers]
  [./extrude]
    type = MeshExtruder
    num_layers = 10
    extrusion_vector = '0 0 7e-2'
  #  height = 7e-2
  #  extrusion_axis = 2 # Z
    bottom_sideset = '2'
    top_sideset = '3'
  [../]
[]

# "An RZ coordinate system was requested for subdomain 1 which contains 3D elements."
#[Problem]
  # Specify coordinate system type
  #coord_type = RZ
#[]

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
  active =  ' H+ Li+ OH- H3BO3
             Unity                Phase          nodal_Psat_h2o 
             conductivity         LiBO2(s)       nodal_porosity
             nodal_tortuosity     ECofLiBO2      nodal_Tsat_h2o' 


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
    order = FIRST
    family = LAGRANGE
  [../]

  [./nodal_Psat_h2o]
    order = FIRST
    family = LAGRANGE
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
  active =  'H+ Li+ OH- H3BO3
             Psat_h2o        Tsat_h2o           tortuosity          
             phase           aux_conductivity    
             aux_porosity    ECofLiBO2          unity'
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
    value = 0.5
  [../]

#ECofLiBO2, lgkw
  [./ECofLiBO2]
    type = ECofLiBO2
    variable = ECofLiBO2
    temperature = crud_temperature
  [../]
[]

[Functions]
  [./functionpressure]
    type = ParsedFunction
    value = '15550.0-13*(0.020-y)'
  [../]

  [./functiontemperature]
    type = ParsedFunction
    value = '618.0+(628.0 - 618.0)*(0.020-y)/0.020'
  [../]
[]

[BCs]
#temperature
  [./temperature_crud_clad]
    type = CRUDCladNeumannBC
    variable = crud_temperature
    #boundary = 'bottom'
    boundary = 2
  [../]

#  [./chimney_crud_temperature]
#    type = FunctionDirichletBC
#    variable = crud_temperature
#    boundary = 'left'
#    function = functiontemperature
#  [../]

  [./temperature_crud_coolant]
    type = CoupledTsatDirichletBC
    variable = crud_temperature
    #boundary = 'top'
    boundary = 3
    Tsat = nodal_Tsat_h2o
  [../]

# pressure
  [./pressure_crud_coolant]
    type =  DirichletBC
    variable =  crud_pressure
    #boundary =  'top'
    boundary = 3
    value =  15550.
  [../]

  [./pressure_crud_chimney]
    type = FunctionDirichletBC
    variable = crud_pressure
    #boundary = 'left'
    boundary = 1 	# not sure if this is the right boundary...
    function = functionpressure
  [../]
[]

[Postprocessors]
  [./Evaporation_Mass_Rate_crud_chimney]
    type = IntegratedSideFlux
    variable = crud_pressure
    #boundary = 'left'
    boundary = 1	# not sure if this is the right boundary
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
    thickness=0.025
  [../]
[]

[Materials]
  [./material_CRUD]
    type = CRUDMaterial
    block = 1

# Give the material properties in SI, then apply whatever scaling factor you want.

    dimensionality = 2
    pore_size_min_baseline = 2.5e-7
    pore_size_avg_baseline = 3.75e-7
    pore_size_max_baseline = 5.0e-7
    CladHeatFluxIn = 1.0e6

    WaterViscosityAt298K = 8.4e-4
    DiffusivityOfMonoborateAt298K = 1.07e-9
    DiffusivityOfLithiumAt298K = 1.029e-9
    DiffusivityOfHydrogenAt298K = 9.311e-9
    DiffusivityOfHydroxideAt298K = 5.273e-9

# Scale everything to millimeters & Kpa
    ScalingFactor = 0.001
    debug_materials = 0
    case=0 #0,all liquid;1,all vapor;2,2 phases
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

    #output_properties = EquConstofH2O
  [../]
[]

[Executioner]
  #type =  Transient
  type = Steady
  
  petsc_options =  '-snes_mf_operator'
  petsc_options_iname =  '-pc_type -pc_hypre_type'
  petsc_options_value =  'hypre    boomeramg'
  l_max_its =  50
  nl_max_its =  5
#  nl_abs_tol=  1e-6
#  l_abs_tol=  1e-5
  nl_rel_tol =  1e-5
  l_rel_tol =  1e-5
  start_time =  0.0
  end_time = 1.0
  num_steps =  4
  dt = 1.0e-3
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
  file_base = 3D_CRUD_flake_SS
  exodus = true
  interval=1
  csv = true
  [./console]
    type = Console
    perf_log = true
    linear_residuals = true
  [../]
[]
