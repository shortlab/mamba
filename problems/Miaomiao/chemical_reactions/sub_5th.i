#all liquid !!!! original file: Steady_PT_Liquid.i
#[GlobalParams]
#  use_displaced_mesh = true
#[]


[Mesh]
  type = GeneratedMesh
  dim = 2

  nx = 20
  ny = 40

  xmin = 0.002
  xmax = 0.01261566794

  ymin = 0.0
  ymax = 20e-3
  uniform_refine = 2
  #elem_type = QUAD9
#  displacements = 'disp_x disp_y'
#  distribution = serial
[]

[Problem]
  # Specify coordinate system type
  coord_type = RZ
[]

[Variables]
  active =  'crud_temperature crud_pressure H+ Li+ OH- H3BO3'	

  [./crud_temperature]
    order =  FIRST
    family =  LAGRANGE
    initial_condition = 610.0
  [../] 

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
  active =  'disp_x             disp_y             thickness_change 
             Unity              FluidVelocity      
             PecletNumber       Phase              nodal_Psat_h2o 
             conductivity       LiBO2(s)           nodal_porosity
             nodal_tortuosity   ECofLiBO2          nodal_Tsat_h2o mass_flux VaporTemp  CapillaryPressure  HeatCond'


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

           PressureDarcy
           
           Li+_time             Li+_diff            Li+_conv 
	   Li+_precipitate

           OH-_time             OH-_diff            OH-_conv
	   OH-_H3BO3_sub        OH-_H3BO3_diff      OH-_H3BO3_conv
	   OH-_2H3BO3_sub       OH-_2H3BO3_diff     OH-_2H3BO3_conv
	   OH-_H+_sub           OH-_H+_diff         OH-_H+_conv

           H+_time              H+_diff             H+_conv
           H+_OH-_sub           H+_OH-_diff         H+_OH-_conv
	   H+_precipitate

           H3BO3_time           H3BO3_diff          H3BO3_conv
           H3BO3_OH-_sub        H3BO3_OH-_diff      H3BO3_OH-_conv
           2H3BO3_OH-_sub       2H3BO3_OH-_diff     2H3BO3_OH-_conv
           H3BO3_precipitate'

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

  #This time kernel isn't functioning/active, lack storage data
  [./crud_pressure_time]
    type =  CoeffTimeDerivative
    variable =  crud_pressure
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
    start_time = 1.0e-3
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
    lg_kw = EquConstofH3BO3
    sto_u =  1.0 
    sto_v =  1.0
    v =  'H3BO3'
    #start_time = 1.0e-3
  [../]

  [./OH-_H3BO3_diff]
    type =  CoupledDiffusionReactionSub
    variable =  OH-
    weight = 1.0                
    #log_k  = 1.8015
    sto_u =  1.0 
    sto_v =  1.0
    diffusivity = DiffusivityOfHydroxide
    lg_kw = EquConstofH3BO3
    v =  'H3BO3'
    #start_time = 1.0e-3
  [../]

  [./OH-_H3BO3_conv]
    type =  CoupledConvectionReactionSub
    variable =  OH-
    weight =  1.0                
    log_k  = 1.8015
    lg_kw = EquConstofH3BO3
    sto_u =  1.0 
    sto_v =  1.0
    v =  'H3BO3'
    p =  'crud_pressure'
    #start_time = 1.0e-3
  [../]

  [./OH-_2H3BO3_sub]
    type =  CoupledBEEquilibriumSub
    variable =  OH-
    weight = 1.0                
    log_k  = 1.8015
    lg_kw = EquConstofH3BO3_2
    sto_u =  1.0 
    sto_v =  2.0
    v =  'H3BO3'
    #start_time = 1.0e-3
  [../]

  [./OH-_2H3BO3_diff]
    type =  CoupledDiffusionReactionSub
    variable =  OH-
    weight = 1.0                
    #log_k  = 1.8015
    sto_u =  1.0 
    sto_v =  2.0
    diffusivity = DiffusivityOfHydroxide
    lg_kw = EquConstofH3BO3_2
    v =  'H3BO3'
    #start_time = 1.0e-3
  [../]

  [./OH-_2H3BO3_conv]
    type =  CoupledConvectionReactionSub
    variable =  OH-
    weight =  1.0                
    log_k  = 1.8015
    lg_kw = EquConstofH3BO3_2
    sto_u =  1.0 
    sto_v =  2.0
    v =  'H3BO3'
    p =  'crud_pressure'
    #start_time = 1.0e-3
  [../]

  [./OH-_H+_sub]
    type =  CoupledBEEquilibriumSub
    variable =  OH-
    weight = -1.0                
    log_k  = -11.6246
    lg_kw = EquConstofH2O
    sto_u = -1.0 
    sto_v = -1.0
    v = 'H+' 
    #start_time = 1.0e-3
  [../]

  [./OH-_H+_diff]
    type =  CoupledDiffusionReactionSub
    variable =  OH-
    weight = -1.0                
    #log_k  = -11.6246
    sto_u = -1.0 
    sto_v = -1.0
    diffusivity = DiffusivityOfHydroxide
    lg_kw = EquConstofH2O
    v = 'H+'
    #start_time = 1.0e-3
  [../]

  [./OH-_H+_conv]
    type =  CoupledConvectionReactionSub
    variable =  OH-
    weight = -1.0                
    log_k  = -11.6246
    lg_kw = EquConstofH2O
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
    lg_kw = EquConstofH2O
    sto_u = -1.0 
    sto_v = -1.0
    v = 'OH-' 
    #start_time = 1.0e-3
  [../]

  [./H+_OH-_diff]
    type =  CoupledDiffusionReactionSub
    variable =  H+
    weight = -1.0                
    #log_k  = -11.6246
    sto_u = -1.0 
    sto_v = -1.0
    diffusivity = DiffusivityOfHydrogen
    lg_kw = EquConstofH2O
    v = 'OH-'
    #start_time = 1.0e-3
  [../]

  [./H+_OH-_conv]
    type =  CoupledConvectionReactionSub
    variable =  H+
    weight = -1.0                
    log_k  = -11.6246
    lg_kw = EquConstofH2O
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
    start_time = 1.0e-3
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
    lg_kw = EquConstofH3BO3
    sto_u =  1.0 
    sto_v =  1.0
    v =  'OH-'
    #start_time = 1.0e-3
  [../]

  [./H3BO3_OH-_diff]
    type =  CoupledDiffusionReactionSub
    variable =  H3BO3
    weight =  1.0                
    #log_k  =  1.8015
    sto_u =  1.0 
    sto_v =  1.0
    diffusivity = DiffusivityOfMonoborate
    lg_kw = EquConstofH3BO3
    v =  'OH-'
    #start_time = 1.0e-3
  [../]

  [./H3BO3_OH-_conv]
    type =  CoupledConvectionReactionSub
    variable =  H3BO3
    weight =  1.0                
    log_k  =  1.8015
    lg_kw = EquConstofH3BO3
    sto_u =  1.0 
    sto_v =  1.0
    v =  'OH-'
    p =  'crud_pressure'
    #start_time = 1.0e-3
  [../]

  [./2H3BO3_OH-_sub]
    type =  CoupledBEEquilibriumSub
    variable =  H3BO3
    weight =  2.0                
    log_k  =  1.8015
    lg_kw = EquConstofH3BO3_2
    sto_u =  2.0 
    sto_v =  1.0
    v =  'OH-'
    #start_time = 1.0e-3
  [../]

  [./2H3BO3_OH-_diff]
    type =  CoupledDiffusionReactionSub
    variable =  H3BO3
    weight =  2.0                
    #log_k  =  1.8015
    sto_u =  2.0 
    sto_v =  1.0
    diffusivity = DiffusivityOfMonoborate
    lg_kw = EquConstofH3BO3_2
    v =  'OH-'
    #start_time = 1.0e-3
  [../]

  [./2H3BO3_OH-_conv]
    type =  CoupledConvectionReactionSub
    variable =  H3BO3
    weight =  2.0                
    log_k  =  1.8015
    lg_kw = EquConstofH3BO3_2
    sto_u =  2.0 
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
    start_time = 1.0e-3
  [../]

[]

[AuxKernels]

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

# LiBO2(s)
  [./aux_LiBO2(s)]
    type =  KineticDisPreConcAux
    variable =  LiBO2(s)
    #log_k= 1.8487 #trying
    lg_kw = ECofLiBO2
    sto_v =   '1.0  1.0  -1.0'
    r_area =   4.61e-4
    ref_kconst =  6.456542e-5
    e_act =  5.25e4
    #0.545 eV-->5.25e4 J/mol
    gas_const =  8.314
    ref_temp =  618.5
    sys_temp =  618.5
    v =  'Li+ H3BO3 H+'
    start_time = 1.0e-3
  [../]

# porosity
  [./aux_porosity]
    type =  PorosityAux
    variable =  nodal_porosity
    init_porosity =  0.50
    mineral =  0.0
    molecular_weight =   49.751
    density =  2.223
    v =  'LiBO2(s)'
    #start_time = 1.0e-3
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
 active = 'temperature_bottom  temperature_up   temperature_left
           pressure_up         pressure_left    pressure_bottom
 	   H+_up	       chimney_crud_concentration_H+
	   Li+_up	  
	   H3BO3_up	       chimney_crud_concentration_H3BO3
	   OH-_up'
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

#    type = DirichletBC
#    variable = crud_pressure
#    boundary = 0
#    value = 15616.42527 
  [../]
#ChimneyEvaporationNeumannBC doesn't work as intended, the pressure distribution is upside down (contrary to what it should be).

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
    boundary = 'bottom left'
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
    boundary = 'bottom left'
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

  [./Suction_crud_coolant]
    type = SideAverageValue
    variable = mass_flux
    boundary = 'top'
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
  petsc_options_iname =  '-pc_type -pc_hypre_type'
  petsc_options_value =  'hypre    boomeramg'
  l_max_its =  50
  nl_max_its =  15
#  nl_abs_tol=  1e-6
#  l_abs_tol=  1e-5
  nl_rel_tol =  1e-5
  l_rel_tol =  1e-5
  start_time =  0.0
  end_time = 1.0
  num_steps =  10
  dt = 1.0e-2
  dtmin =  0.00000001
  [./Adaptivity]
#    initial_adaptivity = 3
    error_estimator = KellyErrorEstimator
    refine_fraction = 0.8
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


