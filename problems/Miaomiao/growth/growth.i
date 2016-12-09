# 50
# 2
# 1000000000
# 0.0012
# 600
# 0.5
# 1000000
# 20000
# 15.5
# 0
# 0
# 1
# 0
# 0.001

[GlobalParams]
  use_displaced_mesh = true
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  uniform_refine = 2
  nx = 5
  ny = 25
  xmin = 0.002
  xmax = 0.0178412487
  ymin = 0.0
  ymax = 0.01
  displacements = 'disp_x disp_y'
[]

[Functions]
  [./growth_func]
    type = ParsedFunction
    value = t
  [../]
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
    initial_condition = 0.0155
  [../]

[]

[AuxVariables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./crud_growth]
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
  [./crud_growth_interpolation]
    type = CoupledDirectionalMeshHeightInterpolation
    variable = disp_y
    direction = y
    execute_on = timestep_begin
    coupled_var = crud_growth
  [../]
  [./growth_aux]
    type = FunctionAux
    variable = crud_growth
    function = growth_func
    execute_on = timestep_begin
  [../]
  [./porosity]
    # This auxilliary kernel takes in various species densities & volume fractions, along with a skeletal porosity, and outputs a total porosity
    type = PorosityAux
    variable = nodal_porosity
    skeleton = 0.5
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
    factor = 1e-06
    offset = 0
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
 
[]


[BCs]
  [./clad_crud_temperature]
    type = CRUDCladNeumannBC
    variable = crud_temperature
    boundary = 0
    #multi_app_q_dot = multi_app_q_dot
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
    T_coolant = 600
    h_convection_coolant = 20000
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
    value = 0.0155
  [../]
  [./coolant_crud_concentration_BO3]
    # This boundary condition requires a concentration of monoborate ion in mole fraction
    type = DirichletBC
    variable = crud_concentration_BO3
    boundary = 2
    value = 0.0012
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
    # Give the material properties in SI, then apply whatever scaling factor you want.
    # Scale everything to millimeters
    # Densities in kg/m^3
    # Thermal conductivities in W/mK
    # (Defined symbolically as the material)
    # (Defined symbolically as the material)
    # (Defined symbolically as the material)
    # (Defined symbolically as the material)
    # Series character of the conductance network (0-1)
    # Volume fractions of solid phases
    type = CRUDMaterial
    block = 0
    dimensionality = 2
    pore_size_min_baseline = 2.7e-7
    pore_size_avg_baseline = 3.95e-7
    pore_size_max_baseline = 5.2e-7
    CladHeatFluxIn = 1000000
    WaterViscosityAt298K = 8.4e-4
    DiffusivityOfMonoborateAt298K = 1.03e-9
    DiffusivityOfLithiumAt298K = 1.07e-9
    ScalingFactor = 0.001
    debug_materials = 0
    crud_thickness = 0.05
    DensityHBO2 = 2490
    k_NiFe2O4_baseline = 10.0 # dummy value
    k_HBO2_baseline = 0.5 # dummy value
    k_Li2B4O7_baseline = 0.5 # dummy value
    k_Ni2FeBO5_baseline = 0.5 # dummy value
    k_series_character = 0.5
    vf_Ni_baseline = 0
    vf_NiO_baseline = 0
    vf_NiFe2O4_baseline = 1
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

[Postprocessors]
  [./peak_clad_temp]
    type = NodalMaxValue
    variable = crud_temperature
  [../]
  [./multi_app_q_dot]
    type = Reporter
  [../]
[]

[Executioner]
  # type = Transient
  # dt = 1e-4
  # petsc_options = '-snes_mf_operator -ksp_monitor'
  # petsc_options_iname = '-pc_type'
  # petsc_options_value = 'lu'
  type = Transient
  num_steps = 10000
  dt = 0.0001

  #Preconditioned JFNK (default)
  solve_type = 'PJFNK'

  l_max_its = 30
  l_tol = 1e-5
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
  # elemental_as_nodal = true
  #
  # xda = true
  file_base = out_2D_50
  exodus = true
  perf_log = true
[]

