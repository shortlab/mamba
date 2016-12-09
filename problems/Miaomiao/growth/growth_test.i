[GlobalParams]
  use_displaced_mesh = true
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  uniform_refine = 2
  nx = 5
  ny = 25
  displacements = 'disp_x disp_y'
[]

[Functions]
  [./growth_func]
    type = ParsedFunction
    value = -0.2
  [../]
[]

[Variables]
  [./u]
    initial_condition=0.
  [../]

[]

[AuxVariables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./crud_growth]
  [../]
[]

[Kernels]
  [./diff]
    type = Diffusion
    variable = u
  [../]
  [./diff_t]
    type = TimeDerivative
    variable = u
  [../]
  
[]

[BCs]
  [./left]
    type = DirichletBC
    variable = u
    boundary = left
    value = 0
  [../]
  [./right]
    type = DirichletBC
    variable = u
    boundary = right
    value = 10
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

[Executioner]
  # type = Transient
  # dt = 1e-4
  # petsc_options = '-snes_mf_operator -ksp_monitor'
  # petsc_options_iname = '-pc_type'
  # petsc_options_value = 'lu'
  type = Transient
  num_steps = 10
  dt = 0.1

  #Preconditioned JFNK (default)
  solve_type = 'PJFNK'

  l_max_its = 30
  l_tol = 1e-5
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
  execute_on = 'timestep_end'
  file_base = growth_test
  exodus = true
  perf_log = true
[]

