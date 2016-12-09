[Mesh]
  # type = GeneratedMesh
  # dim = 2

  # nx = 5
  # ny = 30

  # xmin = 2.5e-3
  # xmax = 12.5e-3

  # ymin = 0.0
  # ymax = 50e-3

  file = tests/crud_test/chimney_3d.e
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
    initial_condition = 0 
  [../]

  [./crud_concentration_BO3]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1e-4 
  [../]
[]

[AuxVariables]
  [./nodal_porosity]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./nodal_tortuosity]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./nodal_fractal_Df]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./nodal_Tsat_h2o]
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
  [./ThermalDiffusion]
    # This Kernel uses "k_cond" from the active material
    type = ThermalDiffusion
    variable = crud_temperature
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

#  [./Sinks_BO3]
#    type = BoricAcidSinks
#    variable = crud_concentration_BO3
#    Conc_HBO2 = crud_concentration_HBO2
#  [../]
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

  [./fractal_Df]
    type = FractalDfAux
    variable = nodal_fractal_Df
    dimensionality = 3.0
    porosity = nodal_porosity
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

  [./permeability]
    type = MaterialRealAux
    variable = permeability
    matpro = permeability
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
    value = 0
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

    k_cond_baseline = 0.75
    permeability_baseline = 3e-14
    tortuosity = nodal_tortuosity
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

    temperature = crud_temperature
    concentration = crud_concentration_BO3
    porosity = nodal_porosity
    HBO2 = crud_concentration_HBO2
  [../]
[]

[Problem]
#  coord_type = RZ
[]

[Preconditioning]
  active = 'FDP'

  [./FDP]
    type = FDP
    full = true
  [../]
[]

[Executioner]
  type = Steady
#  type = Transient
#  dt = 1e-2
#  num_steps = 5

  #Preconditioned JFNK (default)
  solve_type = 'PJFNK'



  l_max_its = 30
  l_tol = 1e-5
  nl_rel_tol = 1e-6
#  petsc_options_iname = '-pc_type -pc_hypre_type'
#  petsc_options_value = 'hypre boomeramg'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  [./Adaptivity]
    steps = 6
    refine_fraction = 0.5
    coarsen_fraction = 0.38
    max_h_level = 10
    error_estimator = KellyErrorEstimator
    print_changed_info = true
    weight_names = 'crud_temperature crud_pressure crud_concentration_BO3'
    weight_values = '1.0 1.0 1.0'
  [../]

[]

[Outputs]
  execute_on = 'timestep_end'
  linear_residuals = true
  file_base = out
  exodus = true
  perf_log = true
[]

