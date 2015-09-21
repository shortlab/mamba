#{crud_thickness_microns = 25.000000}
#{chimney_radius_microns = 2.000000}
#{chimney_density_m = 2e9}
#{coolant_boric_acid_mole_frac = 0.001200}
#{coolant_temperature_K = 600.000000}
#{skeletal_porosity = 0.500000}
#{clad_heat_flux_W_m2 = 1000000.000000}
#{h_conv_crud_coolant_W_m2s = 12000.000000}

#{system_pressure_Pa =            15500000}
#{volume_fraction_Ni =             0}
#{volume_fraction_NiO =            0.15}
#{volume_fraction_Fe3O4 =          0.1}
#{volume_fraction_trevorite =      0.75}
#{volume_fraction_zirconia =       0}
#{scaling_factor =                 0.001}

[Mesh]
  type = GeneratedMesh
  dim = 2
  uniform_refine = 2

  nx = 5
  ny = {crud_thickness_microns / 2}

  xmin = {chimney_radius_microns * scaling_factor}
  xmax = {(1 / (sqrt(3.14159 * chimney_density_m))) / scaling_factor}

  ymin = 0.0
  ymax = {crud_thickness_microns * 1e-6 / scaling_factor}
[]

[Variables]
  [./crud_temperature]
    order = FIRST
    family = LAGRANGE
    initial_condition = {coolant_temperature_K}
 [../]

  [./crud_pressure]
    order = FIRST
    family = LAGRANGE
    initial_condition = {system_pressure_Pa * scaling_factor}
  [../]

  [./crud_concentration_BO3]
    order = FIRST
    family = LAGRANGE
    initial_condition = {coolant_boric_acid_mole_frac}
  [../]
[]

[AuxVariables]
  [./nodal_porosity]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = {skeletal_porosity}
  [../]

  [./nodal_tortuosity]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 1.5
  [../]

  [./nodal_Tsat_h2o]
    order = FIRST
    family = LAGRANGE
    initial_condition = 618
  [../]

  [./nodal_superheat]
    order = FIRST
    family = LAGRANGE
  [../]

  [./DiffusivityOfMonoborateAux]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./DiffusivityOfLithium]
    order = CONSTANT
    family = MONOMIAL
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

  [./crud_BO3_solubility]
    order = FIRST
    family = LAGRANGE
  [../]

  [./crud_concentration_HBO2]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Kernels]

active = 'ThermalDiffusion ThermalAdvection PressureDarcy AdvectionForConcentration_BO3 DiffusionForConcentration_BO3'

  [./ThermalDiffusion]
    # This Kernel uses "k_cond" from the active material
    type = ThermalDiffusion
    variable = crud_temperature
  [../]

  [./ThermalAdvection]
    # This Kernel uses "k_cond" from the active material
    type = AdvectionForHeat
    variable = crud_temperature
    pressure = crud_pressure
    porosity = nodal_porosity
  [../]

  [./PressureDarcy]
    # This Kernel uses "permeability" from the active material
    type = PressureDarcy
    variable = crud_pressure
    porosity = nodal_porosity
    HBO2 = crud_concentration_HBO2
  [../]

  [./AdvectionForConcentration_BO3]
    # This Kernel uses "permeability" from the active material, takes a diffusivity (material property) for an aqueous phase, and needs pressure
    type = AdvectionForConcentration
    variable = crud_concentration_BO3
    pressure = crud_pressure
    porosity = nodal_porosity
  [../]

  [./DiffusionForConcentration_BO3]
    type = DiffusionForConcentration
    variable = crud_concentration_BO3
    diffusivity = DiffusivityOfMonoborate
  [../]

  [./Sinks_BO3]
    type = BoricAcidSinks
    variable = crud_concentration_BO3
    Conc_HBO2 = crud_concentration_HBO2
  [../]
[]

[AuxKernels]
  [./porosity]
    # This auxilliary kernel takes in various species densities & volume fractions, along with a skeletal porosity, and outputs a total porosity
    type = PorosityAux
    variable = nodal_porosity
    skeleton = {skeletal_porosity}
#    HBO2 = crud_concentration_HBO2
  [../]

  [./tortuosity]
    # This auxilliary kernel takes in the CRUD's total porostiy, and outputs a tortuosity.  A value of one means unimpeded flow/diffusion.
    type = TortuosityAux
    variable = nodal_tortuosity
    porosity = nodal_porosity
  [../]

  [./permeability]
    type = MaterialRealAux
    variable = permeability
    property = permeability
    factor = {scaling_factor ^ 2}
    offset = 0
  [../]

  [./Tsat_h2o]
    type = WaterSaturationTemperatureAux
    variable = nodal_Tsat_h2o
    total_concentration = crud_concentration_BO3
#    initial_condition = 618
  [../]

  [./Superheat]
    type = SuperheatTempAux
    variable = nodal_superheat
    temperature = crud_temperature
    t_sat = nodal_Tsat_h2o
  [../]

  [./D_BO3]
    # This auxilliary kernel outputs the aqueous diffusivity of the monoborate ion
    type = MaterialRealAux
    variable = DiffusivityOfMonoborateAux
    property = DiffusivityOfMonoborate
    factor = {scaling_factor ^ 2}
    offset = 0
  [../]

  [./D_Li]
    # This auxilliary kernel outputs the aqueous diffusivity of the lithium ion
    type = MaterialRealAux
    variable = DiffusivityOfLithium
    property = DiffusivityOfLithium
    factor = {scaling_factor ^ 2}
    offset = 0
  [../]

  [./k_CRUD_eff]
    type = MaterialRealAux
    variable = k_CRUD_eff
    property = k_cond
    factor = {scaling_factor}
    offset = 0
  [../]

  [./k_liquid]
    type = MaterialRealAux
    variable = k_liquid
    property = k_liquid
    factor = {scaling_factor}
    offset = 0
  [../]

  [./k_solid]
    type = MaterialRealAux
    variable = k_solid
    property = k_solid
    factor = {scaling_factor}
    offset = 0
  [../]

  [./rho_h2o]
    type = MaterialRealAux
    variable = WaterDensity
    property = WaterDensity
    factor = {1 / (scaling_factor ^ 3)}
    offset = 0
  [../]

  [./mu_h2o]
    type = MaterialRealAux
    variable = WaterViscosity
    property = WaterViscosity
    factor = {1 / scaling_factor}
    offset = 0
  [../]

  [./h_fg_h2o]
    type = MaterialRealAux
    variable = WaterVaporizationEnthalpy
    property = WaterVaporizationEnthalpy
    factor = {scaling_factor ^ 2}
    offset = 0
  [../]

  [./cp_h2o]
    type = MaterialRealAux
    variable = WaterHeatCapacity
    property = WaterHeatCapacity
    factor = {scaling_factor ^ 2}
    offset = 0
  [../]

  [./FluidVelocity_h2o]
    type = FluidVelocityAux
    variable = FluidVelocity
    pressure = crud_pressure
    porosity = nodal_porosity
  [../]

  [./PecletNumber_h2o]
    type = PecletAux
    variable = PecletNumber
    pressure = crud_pressure
    porosity = nodal_porosity
    tortuosity = nodal_tortuosity
  [../]

  [./BO3_Solubility]
    type = BO3_SolubilityAux
    variable = crud_BO3_solubility
    temperature = crud_temperature
    Conc_BO3 = crud_concentration_BO3
#    Conc_HBO2 = crud_concentration_HBO2
  [../]

  [./Precipitation_HBO2]
    type = Precipitation_HBO2Aux
    variable = crud_concentration_HBO2
    temperature = crud_temperature
    BO3_Solubility = crud_BO3_solubility
    Conc_BO3 = crud_concentration_BO3
  [../]
[]

[BCs]
  [./clad_crud_temperature]
    type = CRUDCladNeumannBC
    variable = crud_temperature
    boundary = 0
  [../]

  [./chimney_crud_temperature]
    type = CoupledTsatDirichletBC
    variable = crud_temperature
    boundary = 3
    HBO2 = crud_concentration_HBO2
    BO3 = crud_concentration_BO3
    Tsat = nodal_Tsat_h2o
  [../]

  [./coolant_crud_temperature]
    type = CRUDCoolantNeumannBC
    variable = crud_temperature
    boundary = 2
    T_coolant = {coolant_temperature_K}
    h_convection_coolant = {h_conv_crud_coolant_W_m2s}
  [../]

  [./chimney_crud_pressure]
    type = ChimneyEvaporationNeumannBC
    variable = crud_pressure
    boundary = 3
    temperature = crud_temperature
    HBO2 = crud_concentration_HBO2
  [../]

  [./coolant_crud_pressure]
    type = DirichletBC
    variable = crud_pressure
    boundary = 2
    value = {system_pressure_Pa * scaling_factor}
  [../]

  [./coolant_crud_concentration_BO3]
    type = DirichletBC
    variable = crud_concentration_BO3
    boundary = 2
# This boundary condition requires a concentration of monoborate ion in mole fraction
    value = {coolant_boric_acid_mole_frac}
  [../]

  [./chimney_crud_concentration_BO3]
    type = CRUDChimneyConcentrationMixedBC
    variable = crud_concentration_BO3
    boundary = 3
    pressure = crud_pressure
    porosity = nodal_porosity
    diffusivity = DiffusivityOfMonoborate
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
    CladHeatFluxIn = {clad_heat_flux_W_m2}

    WaterViscosityAt298K = 8.4e-4
    DiffusivityOfMonoborateAt298K = 1.03e-9
    DiffusivityOfLithiumAt298K = 1.07e-9

# Scale everything to millimeters
    ScalingFactor = {scaling_factor}
    debug_materials = 0
    crud_thickness = {crud_thickness_microns * 1e-6 / scaling_factor}

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
    vf_Ni_baseline = {volume_fraction_Ni}
    vf_NiO_baseline = {volume_fraction_NiO}
    vf_Fe3O4_baseline = {volume_fraction_Fe3O4}
    vf_NiFe2O4_baseline = {volume_fraction_trevorite}
    vf_ZrO2_baseline = {volume_fraction_zirconia}
    vf_HBO2_baseline = 0
    vf_Li2B4O7_baseline = 0
    vf_Ni2FeBO5_baseline = 0

    tortuosity = nodal_tortuosity
    temperature = crud_temperature
    pressure = crud_pressure
    concentration = crud_concentration_BO3
    porosity = nodal_porosity
    HBO2 = crud_concentration_HBO2
  [../]
[]

[Problem]
  coord_type = RZ
[]

[Postprocessors]
  [./Peak_Clad_Temp_(K)]
    type = NodalMaxValueFileIO
    variable = crud_temperature
  [../]
[]

[Executioner]
  type = Steady
#  type = Transient
#  dt = 1e-4

  #Preconditioned JFNK (default)
  solve_type = 'PJFNK'

#  petsc_options = '-snes_mf_operator'
  l_max_its = 30
  l_tol = 1e-5
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
#  petsc_options_iname = '-pc_type'
#  petsc_options_value = 'lu'

  [./Adaptivity]
    steps = 2
#    cycles_per_step = 2
    refine_fraction = 0.5
    coarsen_fraction = 0.05
    max_h_level = 4
    error_estimator = PatchRecoveryErrorEstimator
#    print_changed_info = true
    weight_names = 'crud_temperature crud_pressure crud_concentration_BO3'
    weight_values = '1.0 1.0 1.0'
  [../]
[]

[Outputs]
#  elemental_as_nodal = true
#
  file_base = out_2D_{crud_thickness_microns}
  #  xda = true
  exodus = true
  perf_log = true
[]

