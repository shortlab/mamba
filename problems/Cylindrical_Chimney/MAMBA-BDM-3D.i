[Mesh]
   file = tests/crud_test/chimney_3d.e
#   uniform_refine = 2
[]

[Variables]
  [./crud_temperature]
    order = FIRST
    family = LAGRANGE
    initial_condition = 600
 [../]

  [./crud_pressure]
    order = FIRST
    family = LAGRANGE
# If scaling from m -> mm, give this in kPa
    initial_condition = 15000
  [../]

  [./crud_concentration_BO3]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1.2e-3
  [../]
[]

[AuxVariables]
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

  [./nodal_Tsat_h2o]
    order = FIRST
    family = LAGRANGE
    initial_condition = 618
  [../]

  [./DiffusivityOfMonoborateAux]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./DiffusivityOfLithium]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./WaterThermalConductivity]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.4
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

  [./permeability]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./FluidVelocity-X]
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
active = 'ThermalDiffusion PressureDarcy AdvectionForConcentration_BO3 DiffusionForConcentration_BO3'
  [./ThermalDiffusion]
    # This Kernel uses "k_cond" from the active material
    type = ThermalDiffusion
    variable = crud_temperature
  [../]

  [./TemperatureTimeDerivative]
    type = CoefTimeDerivative
    variable = crud_temperature
    Coefficient = 1e2
    time_periods = p1
  [../]

  [./PressureTimeDerivative]
    type = CoefTimeDerivative
    variable = crud_pressure
    Coefficient = 1
    time_periods = p1
  [../]

  [./ConcentrationTimeDerivative]
    type = CoefTimeDerivative
    variable = crud_concentration_BO3
    Coefficient = 1
    time_periods = p1
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
    diffusivity = DiffusivityOfMonoborate
    pressure = crud_pressure
    porosity = nodal_porosity
  [../]

  [./DiffusionForConcentration_BO3]
    type = DiffusionForConcentration
    variable = crud_concentration_BO3
    diffusivity = DiffusivityOfMonoborate
    pressure = crud_pressure
    porosity = nodal_porosity
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
    skeleton = 0.5
    HBO2 = crud_concentration_HBO2
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
    matpro = permeability
  [../]

  [./Tsat_h2o]
    type = WaterSaturationTemperatureAux
    variable = nodal_Tsat_h2o
    total_concentration = crud_concentration_BO3
  [../]

  [./D_BO3]
    # This auxilliary kernel outputs the aqueous diffusivity of the monoborate ion
    type = MaterialRealAux
    variable = DiffusivityOfMonoborateAux
    matpro = DiffusivityOfMonoborate
  [../]

  [./D_Li]
    # This auxilliary kernel outputs the aqueous diffusivity of the lithium ion
    type = MaterialRealAux
    variable = DiffusivityOfLithium
    matpro = DiffusivityOfLithium
  [../]

  [./k_cond_h2o]
    type = MaterialRealAux
    variable = WaterThermalConductivity
    matpro = WaterThermalConductivity
  [../]

  [./k_liquid]
    type = MaterialRealAux
    variable = k_liquid
    matpro = k_liquid
  [../]

  [./k_solid]
    type = MaterialRealAux
    variable = k_solid
    matpro = k_solid
  [../]

  [./k_CRUD_eff]
    type = MaterialRealAux
    variable = k_CRUD_eff
    matpro = k_cond
  [../]

  [./rho_h2o]
    type = MaterialRealAux
    variable = WaterDensity
    matpro = WaterDensity
  [../]

  [./mu_h2o]
    type = MaterialRealAux
    variable = WaterViscosity
    matpro = WaterViscosity
  [../]

  [./h_fg_h2o]
    type = MaterialRealAux
    variable = WaterVaporizationEnthalpy
    matpro = WaterVaporizationEnthalpy
  [../]

  [./FluidVelocity-X_h2o]
    type = FluidVelocityAux
    variable = FluidVelocity-X
    pressure = crud_pressure
    porosity = nodal_porosity
  [../]

  [./BO3_Solubility]
    type = BO3_SolubilityAux
    variable = crud_BO3_solubility
    temperature = crud_temperature
    Conc_BO3 = crud_concentration_BO3
    Conc_HBO2 = crud_concentration_HBO2
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
    boundary = 4
  [../]

  [./chimney_crud_temperature]
#    type = DirichletBC
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
    T_coolant = 600
# Give this in SI, even though it doesn't need scaling
    h_convection_coolant = 1.2e4
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
    value = 15000
  [../]

  [./coolant_crud_concentration_BO3]
    type = DirichletBC
    variable = crud_concentration_BO3
    boundary = 2
# This boundary condition requires a concentration of monoborate ion in mole fraction
    value = 1.2e-3
#    value = 3.724e-4
# This number is 1200ppmW converted to mole fraction
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
    block = 1

# Give the material properties in SI, then apply whatever scaling factor you want.

    k_cond_baseline = 0.85
    dimensionality = 3
    permeability_baseline = 3e-14
    pore_size_min_baseline = 2.7e-7
    pore_size_avg_baseline = 3.95e-7
    pore_size_max_baseline = 5.2e-7
    CladHeatFluxIn = 1.5e6

    WaterViscosityAt298K = 8.4e-4
    DiffusivityOfMonoborateAt298K = 1.03e-9
    DiffusivityOfLithiumAt298K = 1.07e-9

# Scale everything to millimeters
    ScalingFactor = 0.001

# Densities in kg/m^3
    DensityHBO2 = 2490

# Thermal conductivities in W/mK

    k_Ni_baseline = 87.864
    k_NiO_baseline = 12.97
    k_Fe3O4_baseline = 5.021
    k_NiFe2O4_baseline = 8.0    # dummy value
    k_ZrO2_baseline = 1.829
    k_HBO2_baseline = 0.5       # dummy value
    k_Li2B4O7_baseline = 0.5    # dummy value
    k_Ni2FeBO5_baseline = 0.5   # dummy value

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
    concentration = crud_concentration_BO3
    porosity = nodal_porosity
    HBO2 = crud_concentration_HBO2
  [../]
[]

[Problem]
  coord_type = RZ
[]

[Executioner]
  type = Steady
#  type = Transient
#  dt = 1e-4

  #Preconditioned JFNK (default)
  solve_type = 'PJFNK'



  l_max_its = 30
  l_tol = 1e-5
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
#  petsc_options_iname = '-pc_type'
#  petsc_options_value = 'lu'

  time_periods       = 'p1'
  time_period_starts = '0'
  time_period_ends   = '10e-4'

  [./Adaptivity]
    steps = 2
    refine_fraction = 0.5
    coarsen_fraction = 0.05
    max_h_level = 4
    error_estimator = KellyErrorEstimator
    print_changed_info = true
    weight_names = 'crud_temperature crud_pressure crud_concentration_BO3'
    weight_values = '1.0 1.0 1.0'
  [../]

[]

[Outputs]
  linear_residuals = true
#  elemental_as_nodal = true
#  output_initial = true
  file_base = out-3D
  interval = 1
#  xda = true
  exodus = true
  perf_log = true
[]

