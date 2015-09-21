[Mesh]
  type = GeneratedMesh
  dim = 2
  uniform_refine = 2

  nx = 5
  ny = 25

  xmin = 0.0025
  xmax = 0.0125

  ymin = 0.0
  ymax = 0.05
[]

[Variables]
  [./crud_temperature]
    order = FIRST
    family = LAGRANGE
    initial_condition = 600
 [../]
[]

[AuxVariables]
  [./Phase]
# elemental if defined as following
    order = FIRST
    family = LAGRANGE
  [../]

  [./FakeTortuosity]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 1.5
  [../]

  [./FakePorosity]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.5
  [../]

  [./FakePressure]
    order = FIRST
    family = LAGRANGE
  [../]

  [./FakeConcentration]
    order = FIRST
    family = LAGRANGE
  [../]

  [./FakeHBO2]
    order = FIRST
    family = LAGRANGE
  [../]

  [./FakeTsat]
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
[]

[Kernels]
active = 'ThermalDiffusion'
  [./ThermalDiffusion]
    # This Kernel uses "k_cond" from the active material
    type = ThermalDiffusion
    variable = crud_temperature
  [../]
[]

[AuxKernels]
  [./D_BO3]
    # This auxilliary kernel outputs the aqueous diffusivity of the monoborate ion
    type = MaterialRealAux
    variable = DiffusivityOfMonoborateAux
    property = DiffusivityOfMonoborate
    factor = 1e-06
    offset = 0
  [../]

  [./D_Li]
    # This auxilliary kernel outputs the aqueous diffusivity of the lithium ion
    type = MaterialRealAux
    variable = DiffusivityOfLithium
    property = DiffusivityOfLithium
    factor = 1e-06
    offset = 0
  [../]

  [./FakeTortuosity]
    # This auxilliary kernel outputs the aqueous diffusivity of the lithium ion
    type = ConstantAux
    variable = FakeTortuosity
    value = 1.5
  [../]

  [./FakePorosity]
    # This auxilliary kernel outputs the aqueous diffusivity of the lithium ion
    type = ConstantAux
    variable = FakePorosity
    value = 0.5
  [../]

  [./FakePressure]
    # This auxilliary kernel outputs the aqueous diffusivity of the lithium ion
    type = ConstantAux
    variable = FakePressure
    value = 15000000
  [../]

  [./FakeConcentration]
    # This auxilliary kernel outputs the aqueous diffusivity of the lithium ion
    type = ConstantAux
    variable = FakeConcentration
    value = 0.0012
  [../]

  [./FakeHBO2]
    # This auxilliary kernel outputs the aqueous diffusivity of the lithium ion
    type = ConstantAux
    variable = FakeHBO2
    value = 0
  [../]

  [./FakeTsat]
    # This auxilliary kernel outputs the aqueous diffusivity of the lithium ion
    type = ConstantAux
    variable = FakeTsat
    value = 618
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
    Tsat = FakeTsat
    HBO2 = FakeHBO2
    BO3 = FakeConcentration
  [../]

  [./coolant_crud_temperature]
    type = CRUDCoolantNeumannBC
    variable = crud_temperature
    boundary = 2
    T_coolant = 600
    h_convection_coolant = 1.2e4
  [../]
[]

[Materials]
  [./material_CRUD]
    type = CRUDMaterial
    block = 0

# Give the material properties in SI, then apply whatever scaling factor you want.

    dimensionality = 2
    CladHeatFluxIn = 1.55e6

    DiffusivityOfMonoborateAt298K = 1.03e-9
    DiffusivityOfLithiumAt298K = 1.07e-9

# Scale everything to millimeters
    ScalingFactor = 0.001
    debug_materials = 0
    crud_thickness = 0.05

# Thermal conductivities in W/mK

#   k_Ni_baseline = XXXXX	# (Defined symbolically as the material)
#   k_NiO_baseline = XXXXX	# (Defined symbolically as the material)
#   k_Fe3O4_baseline = XXXXX	# (Defined symbolically as the material)
    k_NiFe2O4_baseline = 15.0	# dummy value
#   k_ZrO2_baseline = XXXXX	# (Defined symbolically as the material)
    k_HBO2_baseline = 0.5	# dummy value
    k_Li2B4O7_baseline = 0.5	# dummy value
    k_Ni2FeBO5_baseline = 0.5	# dummy value

    # Series character of the conductance network (0-1)
    k_series_character = 0.5

    # Volume fractions of solid phases
    vf_Ni_baseline = 0.02
    vf_NiO_baseline = 0.15
    vf_NiFe2O4_baseline = 0.68
    vf_ZrO2_baseline = 0.05
    vf_HBO2_baseline = 0
    vf_Li2B4O7_baseline = 0
    vf_Ni2FeBO5_baseline = 0

    temperature = crud_temperature
    tortuosity = FakeTortuosity
    pressure = FakePressure
    porosity = FakePorosity
#    concentration = FakeConcentration
    psat = FakeHBO2
    phase = FakeHBO2
  [../]
[]

[Problem]
  coord_type = RZ
[]

[Postprocessors]
  [./Peak_Clad_Temp_(K)]
    type = NodalMaxValue
    variable = crud_temperature
  [../]
[]

[Executioner]
  type = Steady
#  type = Transient
#  dt = 1e-4
#  petsc_options = '-snes_mf_operator -ksp_monitor'

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
[]

[Outputs]
#  elemental_as_nodal = true
#
  file_base = out
  #  xda = true
  exodus = true
  perf_log = true
[]
