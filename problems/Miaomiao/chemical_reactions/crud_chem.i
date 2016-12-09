#TODO: KineticDisPreConcAux.C use unit mol/L, however, as 1kg is about 1L for water, for now I didn't change by a factor
[Mesh]
  type = GeneratedMesh
  dim = 2

  nx = 80
  ny = 160

  xmin = 0.002
  xmax = 0.01261566794

  ymin = 0.0
  ymax = 0.025
  refine = 4
[]

[Variables]
  active =  'crud_pressure H+ Li+ OH- H3BO3'	

  [./crud_pressure]
    order =  FIRST
    family =  LAGRANGE
    initial_condition = 15500.0
  [../]

  [./Li+]
    order =  FIRST
    family =  LAGRANGE
    initial_condition = 0.00028571
   [../]

  [./OH-]
    order =  FIRST
    family =  LAGRANGE
    initial_condition = 1.0e-4
  [../]

  [./H+]
    order =  FIRST
    family =  LAGRANGE
    initial_condition = 1.0e-7
  [../]

  [./H3BO3]
    order =  FIRST
    family =  LAGRANGE
    initial_condition = 0.1111
   [../]

[]

[AuxVariables]
  active =  'crud_temperature      Phase          nodal_Psat_h2o 
             conductivity         LiBO2(s)       nodal_porosity
             nodal_tortuosity'

  [./crud_temperature]
    order =  FIRST
    family =  LAGRANGE
    initial_condition = 600.0
  [../]  

  [./Phase]
# elemental if defined as following
    order = FIRST
    family = LAGRANGE
    initial_condition=0.0
  [../]

  [./nodal_Psat_h2o]
    order = FIRST
    family = LAGRANGE
    initial_condition = 15500.
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
    initial_condition = 0.45
  [../]

  [./nodal_tortuosity]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 1.5
  [../]

[]

[Kernels]
 active = '                     crud_pressure_diff
           
           Li+_time            Li+_diff           Li+_conv 
	   Li+_precipitate

           OH-_time             OH-_diff            OH-_conv
	   OH-_H3BO3_sub        OH-_H3BO3_diff      OH-_H3BO3_conv
	   OH-_H+_sub           OH-_H+_diff         OH-_H+_conv

           H+_time              H+_diff             H+_conv
           H+_OH-_sub           H+_OH-_diff         H+_OH-_conv
	   H+_precipitate

           H3BO3_time          H3BO3_diff          H3BO3_conv
           H3BO3_OH-_sub        H3BO3_OH-_diff      H3BO3_OH-_conv
           H3BO3_precipitate'

# crud_pressure
  #This time kernel isn't functioning/active, lack storage data
  [./crud_pressure_time]
    type =  CoeffTimeDerivative
    variable =  crud_pressure
  [../]

  [./crud_pressure_diff]
    type =  DiffusionForConcentration
    variable =  crud_pressure
    diffusivity = conductivity
  [../]

# Li+
  [./Li+_time]
    type =  PrimaryTimeDerivative
    variable =  Li+
  [../]

  [./Li+_diff]
    type =  DiffusionForConcentration
    variable =  Li+
    diffusivity = DiffusivityOfLithium
  [../]

  [./Li+_conv]
    type =  PrimaryConvection
    variable =  Li+
    p =  'crud_pressure'
  [../]

  [./Li+_precipitate]
    type =  CoupledBEKinetic
    variable =  Li+
    weight =  1.0
    v =  'LiBO2(s)'
    #start_time = 1.0e-3
  [../]

# OH-
  [./OH-_time]
    type =  PrimaryTimeDerivative
    variable =  OH-
  [../]

  [./OH-_diff]
    type =  DiffusionForConcentration
    variable =  OH-
    diffusivity = DiffusivityOfHydroxide
  [../]

  [./OH-_conv]
    type =  PrimaryConvection
    variable =  OH-
    p =  'crud_pressure'
  [../]

  [./OH-_H3BO3_sub]
    type =  CoupledBEEquilibriumSub
    variable =  OH-
    weight = 1.0                
    log_k  = 1.8015
    sto_u =  1.0 
    sto_v =  1.0
    v =  'H3BO3'
    #start_time = 1.0e-3
  [../]

  [./OH-_H3BO3_diff]
    type =  CoupledDiffusionReactionSub
    variable =  OH-
    weight = 1.0                
    log_k  = 1.8015
    sto_u =  1.0 
    sto_v =  1.0
    diffusivity = DiffusivityOfHydroxide
    v =  'H3BO3'
    #start_time = 1.0e-3
  [../]

  [./OH-_H3BO3_conv]
    type =  CoupledConvectionReactionSub
    variable =  OH-
    weight =  1.0                
    log_k  = 1.8015
    sto_u =  1.0 
    sto_v =  1.0
    v =  'H3BO3'
    p =  'crud_pressure'
    #start_time = 1.0e-3
  [../]

  [./OH-_H+_sub]
    type =  CoupledBEEquilibriumSub
    variable =  OH-
    weight = -1.0                
    log_k  = -11.6246
    sto_u = -1.0 
    sto_v = -1.0
    v = 'H+' 
    #start_time = 1.0e-3
  [../]

  [./OH-_H+_diff]
    type =  CoupledDiffusionReactionSub
    variable =  OH-
    weight = -1.0                
    log_k  = -11.6246
    sto_u = -1.0 
    sto_v = -1.0
    diffusivity = DiffusivityOfHydroxide
    v = 'H+'
    #start_time = 1.0e-3
  [../]

  [./OH-_H+_conv]
    type =  CoupledConvectionReactionSub
    variable =  OH-
    weight = -1.0                
    log_k  = -11.6246
    sto_u = -1.0 
    sto_v = -1.0
    v = 'H+' 
    p =  'crud_pressure'
    #start_time = 1.0e-3
  [../]

# H+
  [./H+_time]
    type =  PrimaryTimeDerivative
    variable =  H+
  [../]

  [./H+_diff]
    type =  DiffusionForConcentration
    variable =  H+
    diffusivity = DiffusivityOfHydrogen
  [../]

  [./H+_conv]
    type =  PrimaryConvection
    variable =  H+
    p =  'crud_pressure'
  [../]

  [./H+_OH-_sub]
    type =  CoupledBEEquilibriumSub
    variable =  H+
    weight = -1.0                
    log_k  = -11.6246
    sto_u = -1.0 
    sto_v = -1.0
    v = 'OH-' 
    #start_time = 1.0e-3
  [../]

  [./H+_OH-_diff]
    type =  CoupledDiffusionReactionSub
    variable =  H+
    weight = -1.0                
    log_k  = -11.6246
    sto_u = -1.0 
    sto_v = -1.0
    diffusivity = DiffusivityOfHydrogen
    v = 'OH-'
    #start_time = 1.0e-3
  [../]

  [./H+_OH-_conv]
    type =  CoupledConvectionReactionSub
    variable =  H+
    weight = -1.0                
    log_k  = -11.6246
    sto_u = -1.0 
    sto_v = -1.0
    v = 'OH-' 
    p =  'crud_pressure'
    #start_time = 1.0e-3
  [../]

  [./H+_precipitate]
    type =  CoupledBEKinetic
    variable =  H+
    weight =  -1.0 
    v =  'LiBO2(s)'
    #start_time = 1.0e-3
  [../]

# H3BO3
  [./H3BO3_time]
    type =  PrimaryTimeDerivative
    variable =  H3BO3
  [../]

  [./H3BO3_diff]
    type =  DiffusionForConcentration
    variable =  H3BO3
    diffusivity = DiffusivityOfMonoborate
  [../]

  [./H3BO3_conv]
    type =  PrimaryConvection
    variable =  H3BO3
    p =  'crud_pressure'
  [../]

  [./H3BO3_OH-_sub]
    type =  CoupledBEEquilibriumSub
    variable =  H3BO3
    weight =  1.0                
    log_k  =  1.8015
    sto_u =  1.0 
    sto_v =  1.0
    v =  'OH-'
    #start_time = 1.0e-3
  [../]

  [./H3BO3_OH-_diff]
    type =  CoupledDiffusionReactionSub
    variable =  H3BO3
    weight =  1.0                
    log_k  =  1.8015
    sto_u =  1.0 
    sto_v =  1.0
    diffusivity = DiffusivityOfMonoborate
    v =  'OH-'
    #start_time = 1.0e-3
  [../]

  [./H3BO3_OH-_conv]
    type =  CoupledConvectionReactionSub
    variable =  H3BO3
    weight =  1.0                
    log_k  =  1.8015
    sto_u =  1.0 
    sto_v =  1.0
    v =  'OH-'
    p =  'crud_pressure'
    #start_time = 1.0e-3
  [../]

  [./H3BO3_precipitate]
    type =  CoupledBEKinetic
    variable =  H3BO3
    weight =  1.0 
    v =  'LiBO2(s)'
    #start_time = 1.0e-3
  [../]

[]

[AuxKernels]
  active =  'Psat_h2o        tortuosity         temp 
             phase           aux_conductivity   aux_LiBO2(s) 
             aux_porosity'

#saturation pressure
  [./Psat_h2o]
    type = WaterSaturationPressureAux
    variable = nodal_Psat_h2o
    temperature = crud_temperature
  [../]

#tortuosity
  [./tortuosity]
    type = TortuosityAux
    variable = nodal_tortuosity
    porosity = nodal_porosity
  [../]

# assume a temperature for now
  [./temp]
    type = ConstantAux
    variable = crud_temperature
    value = 618.5
  [../]

#phase variable
  [./phase]
    type = PhaseAux
    variable = Phase
    psat = nodal_Psat_h2o
    pressure = crud_pressure
    deltaP = 1.
    Shift=0.0
  [../]

# conductivity
  [./aux_conductivity]
    type =  ConductivityFieldAux
    variable =  conductivity
    porosity =  nodal_porosity
  #permeability/viscosity/nodal_porosity
  [../]

# LiBO2(s)
  [./aux_LiBO2(s)]
    type =  KineticDisPreConcAux
    variable =  LiBO2(s)
    log_k  =   7.2254
    sto_v =   '1.0 1.0  -1.0'
    r_area =   4.61e-4
    ref_kconst =  6.456542e-6
    e_act =  5.25e4
    #0.545 eV-->5.25e4 J/mol
    gas_const =  8.314
    ref_temp =  298.15
    sys_temp =  618.5
    v =  'Li+ H3BO3 H+'
    #start_time = 1.0e-3
  [../]

# porosity
  [./aux_porosity]
    type =  PorosityAux
    variable =  nodal_porosity
    init_porosity =  0.45
    mineral =  0.0
    molecular_weight =   49.751
    density =  2.223
    v =  'LiBO2(s)'
    #start_time = 1.0e-3
  [../]

[]

[Functions]
  [./functionpressure]
    type = ParsedFunction
    value = '15500.0+100*(0.025-y)'
  [../]
[]

[BCs]
 active = 'pressure_up    pressure_left
 	   H+_up	  chimney_crud_concentration_H+
	   Li+_up	  
	   H3BO3_up	  chimney_crud_concentration_H3BO3
	   OH-_up'


# pressure
  [./pressure_up]
    type =  DirichletBC
    variable =  crud_pressure
    boundary =  2
    value =  15500.
  [../]

  [./pressure_left]
    type = ChimneyEvaporationNeumannBC
    variable = crud_pressure
    boundary = 3
    temperature = crud_temperature
    HBO2 = H3BO3
  [../]

  [./chimney_crud_pressure]
    type = FunctionDirichletBC
    variable = crud_pressure
    boundary = left
    function = functionpressure
  [../]

# H+
  [./H+_up]
    type =  DirichletBC
    variable =  H+
    boundary =  2
    value =  1.0e-7   #pH=7
  [../]

  [./chimney_crud_concentration_H+]
    type = CRUDChimneyConcentrationMixedBC
    variable = H+
    boundary = 3
    pressure = crud_pressure
    porosity = nodal_porosity
    diffusivity = DiffusivityOfHydrogen
  [../]

# Li+
  [./Li+_up]
    type =  DirichletBC
    variable =  Li+
    boundary =  2
    value =  0.00028571 #mol/kg also 2.0ppm
  [../]

# H3BO3
  [./H3BO3_up]
    type =  DirichletBC
    variable =  H3BO3
    boundary =  2
    value =  0.1111   #mol/kg, also 1200ppm
  [../]

  [./chimney_crud_concentration_H3BO3]
    type = CRUDChimneyConcentrationMixedBC
    variable = H3BO3
    boundary = 3
    pressure = crud_pressure
    porosity = nodal_porosity
    diffusivity = DiffusivityOfMonoborate
  [../]

# OH-
  [./OH-_up]
    type =  DirichletBC
    variable =  OH-
    boundary =  2
    value =  1.0e-4
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
    DiffusivityOfMonoborateAt298K = 1.07e-9
    DiffusivityOfLithiumAt298K = 1.029e-9
    DiffusivityOfHydrogenAt298K = 9.311e-9
    DiffusivityOfHydroxideAt298K = 5.273e-9

# Scale everything to millimeters & Kpa
    ScalingFactor = 0.001
    debug_materials = 0
    case=0 #all liquid
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

[Executioner]
  type =  Transient
  petsc_options =  '-snes_mf_operator'
  petsc_options_iname =  '-pc_type -pc_hypre_type'
  petsc_options_value =  'hypre    boomeramg'
  l_max_its =  50
  l_tol =  1e-2
  nl_max_its =  5
  nl_abs_tol=  1e-6
  l_abs_tol=  1e-5
  nl_rel_tol =  1e-6
  l_rel_tol =  1e-6
  start_time =  0.0
  end_time = 20.0
  num_steps =  2
  dt = 1.0e-4
  dtmin =  0.00000001
  dtmax =  1.0

[]

#[Debug]
#  show_top_residuals             = 1                     
# # show_var_residual_norms        = 1
#[]

[Outputs]
  execute_on = 'timestep_end'
  file_base = crud_chemical
  exodus = true
  [./console]
    type = Console
    perf_log = true
    linear_residuals = true
  [../]
[]
