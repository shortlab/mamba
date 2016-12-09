[Mesh]
  type = FileMesh
  uniform_refine = 2
  file = Knife-Quench.e
[]

[Variables]
  [./temperature]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1500
 [../]
[]

[AuxVariables]
[]

[Kernels]
active = 'EulerKnife EulerClay ThermalDiffusion'

## Here the time_coefficient must be the density times the heat capacity of the material

  [./EulerKnife]
    type = ExampleTimeDerivative
    variable = temperature
    block = 'Knife'
## Specific heat capacity: 461 J/kg-C
## Density: 7870 kg/m^3
    time_coefficient = 3628070
  [../]

  [./EulerClay]
    type = ExampleTimeDerivative
    variable = temperature
    block = 'Clay'
## Specific heat capacity: 1381 J/kg-C
## Density: 1600 kg/m^3
    time_coefficient = 2209600
  [../]

  [./ThermalDiffusion]
    # This Kernel uses "k_cond" from the active material
    type = ThermalDiffusion
    variable = temperature
  [../]
[]

[AuxKernels]
[]

[BCs]
  [./water-cooling]
    type = CRUDCoolantNeumannBC
    variable = temperature
    boundary = 'Water-Facing'
    T_coolant = 300
    h_convection_coolant = 500
  [../]
[]

[Materials]
  [./Knife]
    type = Knife
    block = 'Knife'
    temperature = temperature
  [../]

  [./Clay]
    type = Clay
    block = 'Clay'
    temperature = temperature
  [../]
[]

[Postprocessors]
  [./BladeTip]
    type = PointValue
    variable = temperature
    point = '0 -0.0149 0.121'
  [../]

  [./BladeNearTip]
    type = PointValue
    variable = temperature
    point = '0 -0.012 0.121'
  [../]

  [./BladeCenter]
    type = PointValue
    variable = temperature
    point = '0 0 0.121'
  [../]

  [./BladeSide]
    type = PointValue
    variable = temperature
    point = '0.002 0.01 0.121'
  [../]

  [./BladeBack]
    type = PointValue
    variable = temperature
    point = '0 0.0145 0.121'
  [../]
[]

[Preconditioning]
  active = smp
  [./smp]
    type = SMP
    full = true
  [../]

  [./fdp]
    type = FDP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  num_steps = 1000
  end_time = 120

  [./TimeStepper]
      type                     = DT2
      dt                       = 1e-2                        # The initial time step size.
      e_max                    = 1e7                  # Maximum acceptable error.
      e_tol                    = 1e6                  # Target error tolerance.
      max_increase             = 1.5                       # Maximum ratio that the time step can increase.
  [../]

  solve_type = Newton
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'

  l_max_its = 50
  l_tol = 1e-4
  nl_rel_step_tol = 1e-50
  nl_rel_tol = 1e-4
  nl_abs_tol = 1e-8

#  line_search = none

#  [./Adaptivity]
#    steps = 1
#    refine_fraction = 0.4
#    coarsen_fraction = 0.02
#    max_h_level = 3
#    error_estimator = KellyErrorEstimator
#  [../]
[]

[Outputs]
  file_base = QuenchingResult
  interval = 1
  exodus = true
  csv = true
  [./console]
    type = Console
    perf_log = true
  [../]

[]

