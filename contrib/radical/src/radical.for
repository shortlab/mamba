      program radical

c***********************************************************************
c                              RADICAL
c               RADIation Chemistry Analysis Loop code
c***********************************************************************


c***********************************************************************
c     Version:        RADICAL 1.8.2         April 2012
c     Author:         Michael Short
c***********************************************************************
c
c	-Swapped out the old LSODE with the new double-precision DLSODE.
c      This just required a Find/Replace of LSODE -> DLSODE
c
c***********************************************************************


c***********************************************************************
c     Version:        radical 1.8.1         April 2012
c     Author:         Michael Short
c***********************************************************************
c
c	-Resurrected the code into Intel Visual Fortran 2011 XE
c     -Named the previously unnamed BLOCKDATA in CHEXAL.FOR
c      in order to avoid linker errors (multiply defined __UNNAMED_DATA)
c     -Changed a slash to a comma, one line was previously trying to
c      divide a string by a constant in the output writing routines.
c      This was the bug mentioned by Il-Soon in the last Radical_r3.plg
c
c     *** NOTE *** Make sure to compile in "Release" mode to avoid
c      silly errors! You'll have to run the program from the command
c      line, and don't forget to place the input files in the same
c      directory as the executable.
c
c***********************************************************************


c***********************************************************************
c     Version:        radical 1.8           July 2003
c     Author:         Yasuyuki Otsuka
c***********************************************************************
c
c	See the memorandum about the revision record.
c
c***********************************************************************


c***********************************************************************
c     Version:        radical 1.7           June 2003
c     Author:         Yasuyuki Otsuka
c***********************************************************************
c
c	See the memorandum about the revision record.
c
c***********************************************************************


c***********************************************************************
c  Version: 1.6b25        Wendesday, February 7, 1996 4:00:00 PM

c  radical calculates concentrations of O2, H2, H2O2 and radicals in
c  coolant in a boiling water reactor (BWR) as a function of position 
c  along the flow path.  The code is based on species-balance equations
c  which consider such effects as:

c    Chemical reactions
c    Radiolysis (decomposition of H2O due to gamma and neutron radiation)
c    Convection
c    Mass transfer between liquid and gas (only for O2 and H2)
c    Thermal and surface decomposition of H2O2

c  A loop such as a bwr coolant loop is divided into a number of
c  components which are connencted through a combination of series 
c  and parallel flow paths.  Parameters for each component is
c  input through an input file which contains 3 major items:

c    1. Plant geometry (flow-path length, hydraulic diameter)
c    2. Plant operating condition (thermal-hydraulic data and radiation
c       level)
c    3. Water chemstry data (chemical reaction set, g-values, and
c       initial concentrations)

c  The code starts calculation at the first component and continues 
c  calculation along the flow path.  A component with, for instance,
c  radial gradient of radiation level such as the downcomer, may be 
c  subdivided into a number of parallel sub-components to increase 
c  accuracy of the output.

c  While the code is originally written for BWRs, its flexibility
c  allows the code to be adapted to many other problems, such as
c  PWRs, experimental loops, nuclear waste packages, or chemical
c  kinetics studies. 

c  A sensitivity analysis routine is also included in the code to get 
c  quantitative measure of how much input parameters, such as rate
c  constants and g-values, affect concentration output.  For example
c  the code can evaluate the sensitivity of H2O2 with respect to
c  rate constants, mass transfer coefficient, and g-values at each
c  component. This allows the user, or the experimenter, to concentrate
c  on those parameters that are particularly important.

c***********************************************************************

c  Reference:

c  John Chun;"Modeling of BWR Water Chemistry", SM thesis, Nuclear
c  Engineering, MIT, 1990.

c***********************************************************************

c  Author and Contact: John H. Chun
c                      Nuclear Reactor Laboratory
c                      Massachusetts Institute of Technology
c                      138 Albany St Rm NW13-239
c                      Cambridge, MA 02139-4296
c                      (617) 253-5368 / 7300 fax
c                      e-mail: johnchun@athena.mit.edu

c  Alternate Contact:  Prof. Ronald G. Ballinger
c                      Dept. of Nuclear Engineering and
c                      Materials Science and Engineering
c                      Massachusetts Institute of Technology
c                      77 Mass Ave Rm 24-215
c                      Cambridge, MA 02139
c                      (617) 253-5118 / 258-7437 fax
c                      e-mail: hvymet@mit.edu

c***********************************************************************

c  This code relies on the subroutine 'DLSODE' to solve a system of
c  ordinary differential equations.  DLSODE is a powerful set of
c  routines for solving nonlinear, stiff, first-order ode's which has
c  been developed by Alan Hindmarsh at Lawrence Livermore National
c  Laboratory.  The author gratefully acknowledges the kind assistance
c  Dr. Hindmarsh has provided.

c  Author and Contact  Alan C. Hindmarsh                                      
c                      Mathematics and Statistics Division, L-316               
c                      Lawrence Livermore National Laboratory                   
c                      Livermore, CA 94550.                                     
c  Reference                                                                   
c  Alan C. Hindmarsh,  DLSODE and LSODI, Two New Initial Value                
c  Ordinary Differential Equation Solvers,                                   
c  ACM-SIGNUM Newsletter, Vol. 15, No. 4 (1980), pp. 10-11.                  

c***********************************************************************

c  Modification Notes:

c  v1.0 Note: This is the first published version of radical after a
c  series of debugging and modification of MITIRAD 7.0.
c  MITIRAD 1.0 is a code package developed by Scott Simonson in 1988
c  at MIT as part of his PhD thesis. The code was used to assess
c  the radiation and chemistry effects on radioactive waste packages in
c  underground depository.
c  A major modification and addition to the code was carried out by
c  John Chun to include correct reaction equations and extend it to 
c  calculate multiple-component systems.
c  Routines for sensitivity analysis including adjoint and
c  response evaluator were rewritten and included in this 
c  version of radical.
c  Development stage for v1.0 (in reverse time)

c    0. Birth of radical 1.0 for MicroVax III.
c    1. Born again from MITIRAD version 7.0
c    2. Sensitivity analysis extension to MITIRAD version 6.0
c    3. Multiple-component extension to MITIRAD version 5.0
c    4. Two-phase flow extension (version MITIRAD 5.0)

c  v1.1 Note: This version is a result of transporting VAX Fortran to
c  MacFortran II. Some changes were necessary to run radical 1.0 on the
c  Macintosh using Absoft MacFortran II compiler and this version 1.1
c  reflects these changes.
c  No variable initialization is performed on MacFortran II so this was
c  performed explicitly in the code.
c  Date and Time subroutines are not supported on MacFortran II, so 
c  subroutines on a seperate file 'date.f' have been created.  These
c  subroutines may be machine dependent, so take caution.
c  A 1987 version of DLSODE is used instead of the 1981 version used in 
c  radical 1.0. No obvious differences have been noticed.
c  PlotFile has been modified to a columnar format for easier input
c  into KaleidaGraph.
c  SensFile of v1.0 has been removed completely. Sensitivity results
c  may still be plotted easily from the output file by the cut-&-paste method.
c  To cut a column at a time, use the Option-key select method in MS Word.

c  v1.11 Note: The exponent D in the output and plot file has been changed
c  to E for easier import to KaleidaGraph.  Also page breaks are removed.

c  v1.5 Note: All names, these include variables, constants, parameters
c  and subroutines, have been modified to conform to the Pascal
c  convention, ie, uppercase for the first letter of each word, for better
c  readability of the source code.  All FORTRAN reserved words are now in
c  lowercase.  All this means the code is case sensitive and may be
c  compiled without the folding option.
c  Some names have been chaned to make better sense,
c  eg. NeutCoef -> NeutCoef, GammaCoef -> GammaCoef, VoidCoef -> VoidCoef
c  Some minor bugs have been fixed, eg. the array boundary error for Koef
c  and the gas species in ppb.

c***********************************************************************

c  Compiler Notes:

c  v1.5 has been compiled using MacFORTRAN compiler version 3.2 and will
c  run on any Apple Macintosh computer with a math coprocessor and
c  System 6.0.5 or higher.  Minimum 2 mb RAM and 5 mb harddisk are needed.

c  MacFortran II Compiler v3.2 Notes:

c  Use the following compiler options to preserve VAX compatibilities.
c    -s  :this option preserves static storage of local variables.
c    -N8 :this auto-segmentation option removes memory-size related errors.
c    -f  :this option removes case-sensitivity by folding all characters.
c         Since all names in v1.5 have consistent case, this option
c         may be omitted depending on the platform.

c  MacFortran II Linker Note

c  Use the following linker options to preserve VAX compatibilities.
c    -f  :see above.

c***********************************************************************

c  Program Elements:

c  radical.blk:is used to declare global variables and common blocks
c              in each subroutine.  Instead of writing this in each
c              subroutine, an external file 'radical.blk' is used.
c  InitializeLoop: calls subroutine ReadLoop, SetUp, WriteComp.
c  ReadLoop:   reads reaction information from input file.  
c  FindLine:   positions input pointer at a specific location in the
c              input file.
c  SetUpRx:    sets up reaction matrix for radiolysis calculation.
c  SetUpNode:  sets up loop node information array.
c  WriteLoop:  prints reaction information to output file.
c  CalcLoop:   evaluates radiolysis of the entire assembly of components
c              by advancing a node at a time and calling CalcComp.
c  CalcComp:   evaluates radiolysis of a component by calling 
c              Radiolysis.
c  Push:       pushes node number into stack. Used for recurssive
c              evaluation of multiple parallel-series components.
c  Pull:       pulls node number from stack.
c  SumFlow:    sums volumetric flowrates of all components at node.
c  AverageFlow:averges concentration at node by weighing density and 
c              flowrate.
c  ReadComp:   reads component input parameters.
c  PrepareComp: adjusts input parameters for Radiolysis.
c  WriteComp:  prints component data.
c  Radiolysis: calls concentration which in turn calls DLSODE to 
c              evaluate radiolysis.
c  Concentration:calls DLSODE which in turn calls DifEq and Jacob which
c              evaluates spatial concentration profile.
c  DLSODE:      Livermore Solver of Ordinary Differential Equations
c              -  a set of subroutines provided by Alan Hindmarsh 
c              of LLNL. It solves a set of ordinary
c              differential equations using Gears method suited for
c              stiff nonlinear differential equations.
c  DifEq:        sets up the concentration differential equations
c              to be solved by DLSODE.        
c  Jacob:      contains the jacobian of the differential equations
c              in DifEq.
c  DoseShape:  evaluates dose shape as a function of position.
c  ThermalHydro: evaluates two phase flow parameters.
c  Arrhenius:  adjusts rate constants to temperature changes.
c  WriteConc:  writes concentrations to output files.
c  WriteStat:  writes radiolysis run statistics to output file.
c  Sensitivity:calls Adjoint and Response to evaluate sensitivity.
c  Adjoint:    evaluates adjoint of radiolysis calculations.
c  AdjFro:     d(Adjoint)/dx evaluator for DLSODE.
c  AdjJacob:   jacobian evaluator for adjoint.
c  Interpolate:interpolates radiolysis and adjoint curve outputs.
c  Response:   evaluates response of adjoint.
c  ResFro:     d(Response)/dx evaluator for DLSODE.
c  ResJacob:   jacobian evaluator for Response.
c  WrietSens:  writes sensitivity results to output file.
c  Terminate:  terminates program by closing files.

c  Global Constants:

c  ICO:        dimension of component array.
c  INO:        dimension of node array.
c  IRX:        dimension of reaction array.
c  ISP:        dimension of species array.
c  IST:        dimension of radiolysis and adjoint curve output for 
c              interpolation in AdjFro and ResFro.
c  LIW:        size of DLSODE integer working array.
c  LRW:        size of DLSODE real working array.
c  GasConst:   universal gas constant (kJ/mol-K).

c  Global Variables:

c  AdjCurve:  adjoint profile curve used in interpolation.
c  AdjXXXXX:  variable XXXXX used for adjoint calculation.
c  BTot:      total boron content in coolant (mol/kgH2O). used for pH calc.
c  LiTot:     total lithium content in coolant (mol/kgH2O). used for pH calc
c  SensComp:  flag used for component sensitivity analysis.
c  SurfComp:  flag used for hydrogen peroxide surface decomposition.
c             true(default)=consider surface effect,
c             false=disregard surface effect
c  CompFlowX: flowrate of component for either liquid or gas.
c  CompName:  name of component.
c  CompNode:  component node information array.
c  Conc:      species concentration vector (moles/l).
c  ConcCurve: concentration profile curve used in Interpolation.
c  ConcFinal: final concentration array of a component (moles/l).
c  ConcNode:  averaged concentration at each node.
c  CycleOut:  flag used to control output at each cycle.
c  Debug:     flag to print diagnostic messages to output.
c  DensGas:   density of vapor (g/cc).
c  DensLiq:   density of liquid (g/cc).
c  Diameter:  effective hydraulic diameter of the flow channel (cm).
c  dVFdx:     d(void fraction)/dx.
c  dVGdx:     d(vapor velocity)/dx.
c  dVLdx:     d(liquid velocity)/dx.
c  EA:        activation energy (kj/mole-K).
c  FlowPara:  flow parameter used in Bankoff's equation.
c  FlowRate:  mass flowrate (g/sec).
c  GammaCoef:    coefficient array for gamma dose shape polynomial.
c  GammaAvg: gamma dose rate (rad/s).
c  GConvert:  conversion factor from # species/100 ev to mol/l-rad.
c  GGamma:    gamma g-value (# species/100 ev) for density.
c  GNeut:     neutron g-value (# species/100 ev) for density.
c  IComp:     component number under evaluation.
c  ICycle:    cycle counter.
c  Id1:       reaction array sizing parameter.
c  Id2        reactant array sizing parameter.
c  INn:       n=1 to 3; indicies arrays for chemical reaction evaluation.
c  InFile:    input file name.
c  IP:        product array for chemical reaction set.
c  IR:        reactant array for chemical reaction set.
c  ISens:     sensitivity species number under evaluation.
c  Iter:      iteration performed for curve data points used to 
c             interpolate.
c  Koef:      reaction coefficient; + for product, - for reactant.
c                                   1 for first order, 2 for second order.
c  MaxIter:   total iteration of the concentration and adjoint arrays. 
c  MaxOrdGamma: maximum order of gamma dose shape function polynomial.
c  MaxOrdNeut: maximum order of neutron dose shape function polynomial.
c  MaxOrdVoid: maximum order of void fraction shape function polynomial.
c  NComp:     number of components in the loop.
c  NCycle:    number of cycles to go through the entire loop.
c  NeutCoef:  coefficients for neutron dose shape polynomial.
c  NeutAvg:  neutron dose rate (rad/s).
c  NodeCount: number of beginning and ending components at each node.
c  NodeInfo:  list of beginning and ending components at each node.
c  NodeStart: node at which evaluation begins. Initial concentration
c             must be given at this node.
c  NRx:       number of chemcal reaction.
c  NSens:     number of sensitivity species.
c  NSp:       NSpecies less H2O and 2H2O.  Used to save computation.
c  NSpecies:  number of chemical species including gas species
c  NSurfRx:   number of surface reaction in the reaction matrix.
c             Surface reaction must be at the end of the matrix.
c  OutFile:   output file name.
c  PDJ:       column vector for jacobian matrix.
c  pH :	      pH of coolant. Used for PWR ECP calculations
c  pHMode:    either "pHInput" (pH is read as input) or "BLiCalc"- calculate
c 	      using the total Boron and Lithium- and equilibrium constants 
c  PlotFile:  plot data file to be read by KaleidaGraph.
c  PlotOut:   flag for PlotFile output to be read by KaleidaGraph.
c             true(default)=generate plot file,false=no plot file
c  Pressure:  system pressure (MPa).
c  RateConst: rate constant at system temperature (1/s in general).
c  RCInit:    rate constant at reference temperature (1/s in general).
c  ResXXXXX:  variable XXXXX for response calculation.
c  RxName:    array of reaction name.
c  SensLoop:  flag used for sensitivity analysis. If SensLoop is false,
c             SensComp is overridden and no sensitivity will be carried out
c             in any of the components.
c  SensSpecies:sensitivity species name array.
c  SensStep:  dx used in sensitivity evaluation.
c  SpeciesName:array of species name.
c  Surface:   surface material of flow path.
c  Temp:      temperature along the flow channel (kelvin).
c  TempIn:    inlet temperature (kelvin).
c  TempOut:   outlet temperature (kelvin).
c  TempRef:   reference temperature for Arrhenius' law (kelvin).
c  TimeX:     computer system time used in calculating execution time.
c  TitleLine: first line of input file which contains file information.
c  VelGas:    vapor velocity along the channel (cm/s).
c  VelInlet:  inlet liquid velocity (cm/s).
c  VelLiq:    liquid velocity along the channel (cm/s).
c  VoidCoef:     coefficients for void fraction shape polynomial.
c  WriteRx:  flag indicating whether temperature-adjusted reaction
c             matrix is to be printed for a component.
c  WritePara: flag for printing parameters with each concentration output 
c  XBoil:     position of onset of boiling in two phase flow (cm).
c  XOut:      final position to evaluate radiolysis (cm).
c  XIn:       initial position of channel (cm).
c  XStep:     position step to be taken for output (cm).

c  DLSODE variables are defined in the DLSODE write-up.

c  Non-Standard Vax Fortran Functions Called:
c       
c  Date:      returns today's date as found in the system clock.
c  include:   includes an external text file as a part of the source.
c             'radical.blk' is used to declare global variables.
c  namelist : compact way of reading input data.  This may be rewritten
c             to read input parameters one by one in standard way.
c  Secnds:    passes system clock in seconds to real*4 variable.
c             This function may be omitted without affecting
c             the essential part of the code.  
c  Time:      returns current time as found in the system clock.
c    
c***********************************************************************

      include 'radical.blk'
      real*8 RWork(22+(9+ISP)*ISP)

      nullMsg=' '
      BatchDone=.false.
      call IsItBatch            !is it Batch Mode?
      
10    call InitializeLoop       !reads input parameters and prepare them
      if (BatchDone) goto 999

c  perform heat balance

      if (HeatBalance) call DoHeatBalance  !calculate heat balance

c  calculate radiolysis

      if (CalcInject) then
c      if (CalcHWC) then
c        do while (HWCInject(iHWC).ge.0.d0)   !Change by Grover 4/30/96
        do while (Inject(iHWC).ge.0.d0)
          call ScreenDisplay(38,[ConcInMode],[0.d0],nullMsg) !HWC Injection is...
cy          NCycle=ICY
		LastCycle = 1					!add by Yasu
          call InitCompVariables
          call CalcLoop(RWork)    !evaluate loop radiolysis
          iHWC=iHWC+1
        enddo
      else
        call CalcLoop(RWork)    !evaluate loop radiolysis
      endif

c  finish up the run

      call Terminate            !writes run statistics and finish job

c  continue if batch mode

      if (BatchMode) goto 10    !continue batch process

999   call ScreenDisplay(33,[0],[0.d0],nullMsg) !finished batch mode...
      
      pause
      stop
      end  ! of radical


      subroutine IsItBatch

c***********************************************************************
c     Version:        radical 1.6          25 Oct 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by radical

c     see if the batch file 'radical.bat' is present in the current folder.
c     If it is, abandon interactive mode and jump into batch mode.
c***********************************************************************

      include 'radical.blk'
      character Confirm*10

      BatchMode=.false.

      open (IBF,file=BatchFile,status='old',err=10)  !open input data file
      print 1
1     format(' Are you sure you want to run in the '
     +       '	`batch mode? [yes/no] '$)
      read 2,Confirm
2     format(a10)

      if (Confirm(1:1).eq.'n') return      !user abandons Batch Mode

      BatchMode=.true.
      call ScreenDisplay(32,[0],[0.d0],nullMsg)    !Beginning Batch Mode

10    return
      end  ! of IsItBatch


      subroutine InitializeLoop

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by radical
c     Calls ReadLoop, CheckInput, SetUpRx, SetUpNode, WriteLoop

c     Opens input and output files and reads input data.
c     Prepares input data for radiolysis and prints them in output file.
c***********************************************************************

      include 'radical.blk'

      Time1=Secnds(0.0)         !start clock to measure total execution time

      call InitLoopVariables
      call InitCompVariables
      call OpenInFile           !open input file
      write (*,*) 'Finished opening input file'
      if (BatchDone) return     !batch job is finished
      call ReadLoop             !read plant info
      write (*,*) 'Finished reading plant info'
      call CheckLoopInput       !validate input data
      write (*,*) 'Finished validating input data'
      call SetUpRx              !prepare reaction for radiolysis calc
      write (*,*) 'Finished preparing rxns for rad calc'
      call SetUpNode            !prepare node information for CalcLoop
      write (*,*) 'Finished preparing node info for CalcLoop'

      NConv=0
      do 10 i=1,NSpecies
        if (ConvSpecies(i).ne.'        ') NConv=i
10    continue

      write (*,*) 'Finished tweaking species'

      call OpenOutFile          !open output files
      write (*,*) 'Opened output file'

      call WriteLoop            !writes title and rx to output file
      write (*,*) 'Wrote title and reactions to output'


      write (*,*) 'Finished initializing loop'

      return
      end  ! of InitializeLoop


      subroutine InitLoopVariables

c***********************************************************************
c     Version:        radical 1.6          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Having the batch mode forces us to dynamically assign these
c     initial values instead of using the data statement.
c***********************************************************************

      include 'radical.blk'

c  assign default values for loop variables

      OutFile='radical.out'
      PlotFile='radical.plot'
      ECPFile='ECP.out' ! added by Jarvis
c      HWCFile='radical.hwc'
      InjectFile='radical.hwc'   !Change by Grover 4/30/96

      NSurfRx=0
      NCycle=ICY
      NStep=0
      NFunc=0
      NJacob=0

      PowerFactor = 1.0
      DoseFactor = 1.0
      GammaFactor = 1.0

      NodeStart=1
      TempRef=298.d0
      FlowRateTot=1.d0

      ConcInMode=ppb
      ConcOutMode=ppb

      EnthDif=0.d0
      HeatBalComp='                '

      ECPOut=.false.
      PlotOut=.true.
      SensLoop=.false.
      CalcConc=.true.
      SurfLoop=.true.
      HeatBalance=.true.
      SameRxSet=.true. !added by Jarvis
      SameGVal=.true. ! added by Jarvis
      do 10 i=1,IDE
        Debug(i)=.false.
10    continue
      do 20 i=1,ICY
        CycleOut(i)=.false.
        CyclePlot(i)=.true.     !write to plot file for all cycles
20    continue
      CycleOut(1)=.true.        !always output at first cycle

      ConvMin = 0.001
      LastCycle = 1
      do i=1,ISP
        ConvSpecies(i)='        '
      enddo
      ConvComp='                '
      
      CalcInject=.false.
c      CalcHWC=.false.
      SpeciesInject ='H2'
      do i=1,IPO
c        HWCInject(i)=-1.d0
        Inject(i)=-1.d0       ! Change by Grover 4/30/96
      enddo
      InjectComp='                '  ! Change by Grover 4/30/96
c      HWCComp='                '
      iHWC=1

      end  ! of InitLoopVariables


      subroutine InitCompVariables

c***********************************************************************
c     Version:        radical 1.6          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Having the batch mode forces us to dynamically assign these
c     initial values instead of using the data statement.
c***********************************************************************

      include 'radical.blk'

c  default values for components

      XBoil=9999.d0
      XBoilOffset=1.d-10

      TempIn=298.d0
      TempOut=298.d0
      Diameter=1.d0
      Pressure=1.d0
      DensLiq=0.741d0
      DensGas=0.0362d0
      EnthIn=1.d0
      Diffusion=3.5d-4
      Viscosity=1.4d-3
      FlowOrient=0.d0
      AreaIn=0.d0
      AreaOut=0.d0


      SurfComp=.true.
      SensComp=.false.
      WriteRx=.false.
      WritePara=.true.
      Boiling=.false.
      FlowModel=Chexal
      ThermoModel=PowerIn

      QualMin=1.d-5
      GammaInMode=polynomial
      NeutInMode=polynomial
      AlphaInMode=polynomial ! change by Jarvis 10/24/12
      PowerInMode=dataPoints
      Surface='   '

      ATol=1.d-15
      MF=21
      ITol=1
      IState=1
      ITask=4
      RTol=1.d-5    ! mmm rtol =1d-4 originally.	 but cf. Grover's thesis
      IOpt=0
      do 30 i=1,7
        ConcRWork(i)=0.d0
        IWork(i)=0
        AdjRWork(i)=0.d0
        AdjIWork(i)=0
        ResRWork(i)=0.d0
        ResIWork(i)=0
30    continue
      AdjATol=1.d-10
      AdjMF=21
      AdjITol=1
      AdjITask=4
      AdjRTol=1.d-5	 ! mmm adjrtol =1d-5 originally , but cf. Grover's thesis
      AdjIOpt=0
      ResATol=1.d-15
      ResMF=21
      ResITol=1
      ResITask=4
      ResRTol=1.d-5
      ResIOpt=0

      end  ! of InitCompVariables


      subroutine OpenInFile

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Opens input file.
c***********************************************************************

      include 'radical.blk'

3     if (BatchMode) then        !read input file name from batch file

10      read (IBF,100,end=20) InFile
100     format (a80)
        IC=index(InFile,'#')     !see if the line is a comment
        if ((IC.eq.1).or.(InFile.eq.' ')) then  !it's a comment line
          goto 10                !skip this line and read the next line
        else
          open (IIF,file=InFile,status='old',err=600)  !open input data file
          call ScreenDisplay(0,[0],[0.d0],nullMsg)      !print greetings to screen
        endif 

      else                       !read input file name interactively

        call ScreenDisplay(0,[0],[0.d0],nullMsg)      !print greetings to screen
5       print 1
1       format(1x,'Please type the input file name and press return: '$)
        read 2,InFile
2       format(a)
        open (IIF,file=InFile,status='old',err=610)  !open input data file
      endif
      call ScreenDisplay(34,[0],[0.d0],nullMsg)     !reading from input file...

      return
      
c**** input error handling	   

600   call ErrorDisplay(74,[0],[0.d0],nullMsg)
      goto 3
610   call ErrorDisplay(1,[0],[0.d0],nullMsg)
      goto 3
20    BatchDone=.true.

      return
      end  !of OpenInFile


      subroutine OpenOutFile

c***********************************************************************
c     Version:        radical 1.6          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Opens output file and plot file.
c***********************************************************************

      include 'radical.blk'

      write (*,*) 'Opened common include file'
3     open (IOF,file=OutFile,status='unknown',err=602)  !output file
      write (*,*) 'Opened output data file'
4     if (PlotOut) open (IPF,file=PlotFile,status='unknown',err=604)  !plot file
c5     if (CalcHWC) open (IHF,file=HWCFile,status='unknown',err=605)  !HWC file
      write (*,*) 'Opened HWC plot file'
5     if (CalcInject) open(IHF,file=InjectFile,status='unknown',err=605)  !Species injection file
      write (*,*) 'Opened species injection file'
      if (ECPOut) open (IEF,file=ECPFile,status='unknown',err=602) 
     


      return
      
c**** output error handling

602   call ErrorDisplay(2,[0],[0.d0],nullMsg)      !problem opening output file...
      write (*,*) 'Opening output file crapped its pants'
      goto 3
604   call ErrorDisplay(3,[0],[0.d0],nullMsg)      !problem opening plot file...
      goto 4
605   call ErrorDisplay(10,[0],[0.d0],nullMsg)     !problem opening HWC file...
      goto 5

      end  !of OpenOutFile
  
  
      subroutine ReadLoop

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by InitializeLoop

c     Reads loop information.
c***********************************************************************

      include 'radical.blk'
cy      character TheName*16,Line*80,Sp*8
      character TheName*30,Line*80,Sp*8	!change by Yasu
      dimension Sp(ISP)

c      namelist /FileName/ OutFile,PlotFile,HWCFile
      namelist /FileName/ OutFile,PlotFile,InjectFile,ECPFile     ! change by Grover 4/30/96
      namelist /Control/ NCycle,NodeStart,FlowRateTot,PowerFactor,
     +                   PlotOut,SensLoop,SurfLoop,Debug,CalcConc,
     +                   CycleOut,CyclePlot,HeatBalance,HeatBalComp,
     +                   ConcInMode,ConcOutMode,DoseFactor,GammaFactor,
     +                   ConvComp,ConvMin,ConvSpecies,ECPOut,
     +                   CalcInject,InjectComp,Inject,SpeciesInject, !Change by Grover 4/30/96
     +                   SameRxSet,SameGVal   
c     +                   CalcHWC,HWCComp,HWCInject
      namelist /RxControl/ NSurfRx,TempRef,WaterImplicit

c     FLAGS USED IN FindLine

      NZero=0                   !print message and stop if TheName not found
      IGFlag=1                  !notify caller if TheName not found.

      read (IIF,110) TitleLine
110   format (a80)
      rewind (IIF)      
      write (*,*) 'Read TitleLine'
      read (IIF,nml=FileName) !,err=602)  !read OutFile, PlotFile, HWCFile name
      rewind (IIF)
      read (IIF,nml=Control,end=109)
      CycleOut(NCycle)=.true.          !default output at ncycle

c  read gamma, neutron g-values and molecular weights

109   rewind (IIF)
      if(SameGVal) then
        TheName='$GValue'
      else 
        TheName='$Species and molecular weights'	!change by Yasu
      endif
      call FindLine(TheName,IGFlag)
      if ((IGFlag.lt.0).and.(ConcOutMode.ne.ppb)) goto 114
      i=0                    !first determine NSpecies
10    read(IIF,222) Line
      IC=index(Line,'$')     !see if the line '$END'
      if (IC.eq.2) goto 221  !it is!
      i=i+1
      goto 10
221   NSpecies=i
      write (*,*) 'Read number of species'
      rewind(IIF)            !reset the input pointer to '$GValues'
      call FindLine(TheName,IGFlag)
      write (*,*) 'Found line for GValues'
      if(SameGVal) then
      	read(IIF,230)						
     +  (SpeciesName(i),GGamma(i),GNeut(i),GAlpha(i),MolWt(i),
     +   i=1,NSpecies) !change by Jarvis 10/31/12
      else     
      read(IIF,220)
     +  (SpeciesName(i),MolWt(i),i=1,NSpecies)		!change by Yasu
      endif
220   format(1x,a8,d15.8)			!change by Yasu
230   format(1x,a8,4d15.8) !change by Jarvis 10/31/12
222   format(a80)
      write (*,*) 'Read g-values and molecular weights'


c  read chemical reaction matrix

114   rewind (IIF)
      read (IIF,nml=RxControl,end=115)

115   rewind(IIF)
      if(SameRxSet) then
        TheName='$Reaction'    !read reaction information
      else
        TheName='$Reaction sets'    !read reaction information  !change by Yasu
      end if
      call FindLine(TheName,NZero)
      i=0                    !first determine NRx
20    read(IIF,222) Line
      IC=index(Line,'$')     !see if the line '$END'
      if (IC.eq.2) goto 140  !it is!
      i=i+1
      goto 20
140   NRx=i
      rewind(IIF)            !reset the input pointer to '$Reaction'

      call FindLine(TheName,IGFlag)
      do 141 i=1,NRx
        if(SameRxSet) then
          read(IIF,102)					
     +   RxName(i),(Sp(k),k=1,INR+INP),RCMode(i),(RC(i,k),k=1,5) !change by Jarvis 11/12
        else
          read(IIF,100) RxName(i),(Sp(k),k=1,INR+INP)  !change by Yasu
        endif
        do 143 k=1,INR
          IR(i,k)=0
          do 142 j=1,NSpecies
            if (Sp(k).eq.SpeciesName(j)) IR(i,k)=j
142       continue  !for species
143     continue  !for reactants
        do 144 k=1,INP
          IP(i,k)=0
          do 145 j=1,NSpecies
            if (Sp(k+INR).eq.SpeciesName(j)) IP(i,k)=j
145       continue  !for species
144     continue  !for products
141   continue  !for reactions

100   format(1x,a3,1x,3a8,1x,4a8)					!change by Yasu
102   format(1x,a3,1x,3a8,1x,4a8,a1,5d15.8)     ! change by Jarvis 10/24/12
      write (*,*) 'read chemical reaction matrix'

c  read component node information

      TheName='$Component'   !read loop info
      call FindLine(TheName,NZero)
      i=0                    !first determine NComp
30    read(IIF,222) Line
      IC=index(Line,'$')     !see if the line '$END'
      if (IC.eq.2) goto 150  !it is!
      i=i+1
      goto 30
150   NComp=i
      rewind(IIF)            !reset the input pointer to '$Reaction'
      call FindLine(TheName,IGFlag)
      do 120 i=1,NComp
        read (IIF,130) CompName(i),(CompNode(i,j),j=1,2)
120   continue
130   format(1x,a16,1x,3(i4))

      write (*,*) 'read component node information'

      return
      
c**** input error handling

602   call ErrorDisplay(4,[0],[0.d0],nullMsg)

      end  !of ReadLoop


      subroutine FindLine(TheName,LFlag)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by input subroutines.

c     Scans input file and looks for 'TheName'.  Once it finds the text,
c     the input pointer points to the next line.     

c     LFlag is used to notify error condition and to transfer control.
c     If LFlag=0 upon call and TheName is not found, program stops.
c     If LFlag=1 upon call and TheName is not found, subroutine returns
c     to the caller with LFlag=-1 to notify the error.
c***********************************************************************

      include 'radical.blk'
cy      character*16 AName,TheName
      character*30 AName,TheName		!change by Yasu

      rewind (IIF)
      Kount=0                   !used to see if entire file has been scanned
c      write (*,*) 'Just before looking for TheName'
100   read (IIF,110,end=120) AName  !look for TheName
c      write (*,*) 'Just after looking for TheName'
      if (AName.eq.TheName) goto 130
      goto 100
120   rewind (IIF)
      write (*,*) 'Just after error in looking for TheName'
      if (Kount.eq.0) then      !scan only once through
        Kount=1
        rewind IIF              !reset input pointer to the top
        goto 100                !and scan only one more time
      elseif (LFlag.eq.0) then  !caller chose to stop if TheName not found
        call ErrorDisplay(5,[0],[0.d0],TheName)
      else
        LFlag=-1                !notify error to the caller
      endif
cy110   format(1x,a16)
110   format(1x,a30)					!change by Yasu

130   return
      end  !of FindLine


      subroutine CheckLoopInput
c
c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by InitializeLoop
c
c     Validates input data to make sure everything is within limits.
c***********************************************************************
c
      include 'radical.blk'
      real*8 Mass,NeutMass
      logical*4 Error
      data Error/.false./

      if (NSpecies.gt.ISP) then
        call ErrorDisplay(6,[0],[0.d0],nullMsg)
        Error=.true.
      endif

      if (NRx.gt.IRX) then
        call ErrorDisplay(7,[0],[0.d0],nullMsg)
        Error=.true.
      endif        

      if (NSurfRx.gt.IRX) then
        call ErrorDisplay(8,[0],[0.d0],nullMsg)
        Error=.true.
      endif        

      if (NComp.gt.ICO) then
        call ErrorDisplay(9,[0],[0.d0],nullMsg)
        Error=.true.
      endif        

      if (NCycle.lt.1) then
        call ErrorDisplay(11,[0],[0.d0],nullMsg)
        Error=.true.
      endif        

      if (TempRef.lt.0.d0) then
        call ErrorDisplay(12,[0],[0.d0],nullMsg)
        Error=.true.
      endif

      if ((ConcInMode.lt.molLiter).or.(ConcInMode.gt.ppb)) then
        call ErrorDisplay(32,[0],[0.d0],nullMsg)
        Error=.true.
      endif

      if ((ConcOutMode.lt.molLiter).or.(ConcOutMode.gt.ppb)) then
        call ErrorDisplay(33,[0],[0.d0],NullMsg)
        Error=.true.
      endif

      do 200 i=1,NSp           !check for all species data
cy	next 9 lines moved to CheckCompInp by Yasu
cy        if (GGamma(i).lt.0.d0) then
cy          call ErrorDisplay(13,i,[0.d0],' ')
cy          Error=.true.
cy        endif
cy        if (GNeut(i).lt.0.d0) then
cy          call ErrorDisplay(14,i,[0.d0],' ')
cy          Error=.true.
cy        endif
        if (MolWt(i).lt.0.d0) then
          call ErrorDisplay(15,[i],[0.d0],nullMsg)
          Error=.true.
        endif
200   continue  !through all species
        
c  assign molecular weight for H2O and 2H2O prior to mass balance check.
c  also assign NSp, ie, NSpecies minus H2O and 2H2O if they are at
c  end of the list to save computation.

      NSp=NSpecies
      IH2O=NSpecies+1           !setting it this way, it doesn't mess
      I2H2O=NSpecies+1          !up calc if H2O doesn't exist.
      do 30 i=NSpecies,1,-1     !scan backward to reduce NSpecies
        IC=index(SpeciesName(i),'H2O ')
        if (IC.eq.1) then       !it's H2O
          MolWt(i)=MolWtH2O
          IH2O=i                !assign index to H2O
          if (i.eq.NSp) NSp=NSp-1
        endif
        IC=index(SpeciesName(i),'2H2O ')
        if (IC.eq.1) then       !it's 2H2O
          MolWt(i)=2*MolWtH2O
          I2H2O=i               !assign index to 2H2O
          if (i.eq.NSp) NSp=NSp-1
        endif
30    continue

cy	next 13 lines moved to CheckCompInp
cyc  mass balance for G-VALUES
cy
cy      GammaMass=0.d0
cy      NeutMass=0.d0
cy      do 180 i=1,NSp
cy        GammaMass=GammaMass+GGamma(i)*MolWt(i)
cy        NeutMass=NeutMass+GNeut(i)*MolWt(i)
cy180   continue
cyc      if (dmod(GammaMass,MolWtH2O).gt.1.d0)     commented out by RGB's request
cyc     +   call ErrorDisplay(16,[0],GammaMass,' ')  950605 chun
cyc      if (dmod(NeutMass,MolWtH2O).gt.1.d0)
cyc     +   call ErrorDisplay(17,[0],NeutMass,' ')
      
      do 140 i=1,NRx            !check for all reactions
        do 120 k=1,INR          !check for reactants
          if((IR(i,k).lt.0).or.(IR(i,k).gt.NSpecies)) then
            call ErrorDisplay(18,[i],[0.d0],nullMsg)
            Error=.true.
          endif
120     continue
        do 130 k=1,INP          !check for products
          if((IP(i,k).lt.0).or.(IP(i,k).gt.NSpecies)) then
            call ErrorDisplay(18,[i],[0.d0],nullMsg)
            Error=.true.
          endif
130     continue
cy	next 9 lines moved to CheckCompInp
cy        if (RCInit(i).lt.0.d0) then
cy          call ErrorDisplay(19,i,[0.d0],' ')
cy          Error=.true.
cy        endif
cy        if ((.not.WaterImplicit).and.(EA(i).lt.-1.d0)) then
cy          call ErrorDisplay(20,i,[0.d0],' ')
cy          Error=.true.
cy        endif
140   continue  !through all reactions

c   mass balance for CHEMICAL REACTIONS

      MolWt(0)=0.d0
      do 170 j=1,NRx
        Mass=0.d0
        do 171 i=1,INP
          Mass=Mass+MolWt(IP(j,i))
171     continue
        do 172 i=1,INR
          Mass=Mass-MolWt(IR(j,i))
172     continue
        if (int(Mass).ne.0) then
c          call ErrorDisplay(21,j,0.d0,' ')  commented out by RGB's request 950605 chun
        endif
170   continue

999   if (Error) call ErrorDisplay(22,[0],[0.d0],nullMsg)

      return
      end	!of CheckLoopInput


      subroutine SetUpRx

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by InitializeLoop

c     Sets up chemical reaction equations for radiolysis calculation.
c     defines dC/dx with all appropriate reaction considering whether
c     the species is produced or consumed, first or second order.
c***********************************************************************

      include 'radical.blk'
      integer*4 Ko(IRX,0:ISP)

c  initialize the coefficient matricies(Koef) for DifEq

      do 10 i=1,NSpecies        !chun 2/11/91
        do 20 j=1,NRx           !this initilization is added after finding
          Koef(j,i)=0           !out that MacFortran doesn't automatically
          Ko(j,i)=0             !initializes arrays to zero
20      continue
10    continue

c  set up the coefficient matricies Koef for DifEq

      do 140 i=1,NRx

c       check for second order reactants

        if (((IR(i,1).eq.IR(i,2)).or.(IR(i,2).eq.IR(i,3)))
     +    .and.(IR(i,2).ne.0)) then
          Koef(i,IR(i,2))=-2
          Ko(i,IR(i,2))=-2
        endif

c       check for first order reactants

        do 120 k=1,INR
          if ((IR(i,k).ne.0).and.(Koef(i,IR(i,k)).ne.-2)) then
            Koef(i,IR(i,k))=-1
            Ko(i,IR(i,k))=-1
          endif
120     continue

c       check for second order products

        if (((IP(i,1).eq.IP(i,2)).or.(IP(i,2).eq.IP(i,3)))
     +    .and.(IP(i,2).ne.0)) then
          Koef(i,IP(i,2))=2
        endif
        if (((IP(i,2).eq.IP(i,3)).or.(IP(i,3).eq.IP(i,4)))
     +    .and.(IP(i,3).ne.0)) then
          Koef(i,IP(i,3))=2
        endif

c       fill up the products matrix for first order products

        do 130 k=1,INP
          if((IP(i,k).ne.0).and.(Koef(i,IP(i,k)).ne.2))then
            Koef(i,IP(i,k))=1
          endif
130     continue
140   continue

c  remove catalytic reactants and products

      do 150 k=1,NSpecies
        do 151 i=1,NRx
          if ((Koef(i,k).ne.Ko(i,k)).and.(Ko(i,k).ne.0))
     +       Koef(i,k)=Koef(i,k)+Ko(i,k)
151     continue
150   continue

      return
      end  !of SetUpRx


      subroutine SetUpNode

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by InitializeLoop

c     Sets up node information array to be used by CalcLoop.
c     CompNode(comp,1) = inlet node for comp
c     CompNode(comp,2) = outlet node for comp
c     NodeCount(node,1) = # of components which have inlet at node
c     NodeCount(node,2) = # of components which have outlet at node
c     NodeInfo(node,1,comp) = at node, comp enters
c     NodeInfo(node,2,comp) = at node, comp exits
c***********************************************************************

      include 'radical.blk'
      logical*4 NodeStartExist

c  find the largest node number

      NodeStartExist=.false.
      do 100 j=1,NComp
        do 110 k=1,2
          MaxNode=max(CompNode(j,k),MaxNode)
          if (NodeStart.eq.CompNode(j,k)) NodeStartExist=.true.
110     continue
100   continue
      if (MaxNode.gt.INO) then
        call ErrorDisplay(75,[0],[0.d0],nullMsg)   !error - too many nodes input...
      elseif (.not.NodeStartExist) then
        call ErrorDisplay(76,[0],[0.d0],nullMsg)   !error - NodeStart doesn't exist...
      else
        call ScreenDisplay(1,[0],[0.d0],nullMsg)   !max node is...
      endif

c  vectorize node information

      do 200 i=1,MaxNode
        NodeCount(i,1)=0
        NodeCount(i,2)=0
        do 210 j=1,NComp
          if (CompNode(j,1).eq.i) then
            NodeCount(i,1)=NodeCount(i,1)+1
            NodeInfo(i,1,NodeCount(i,1))=j
          elseif (CompNode(j,2).eq.i) then
            NodeCount(i,2)=NodeCount(i,2)+1
            NodeInfo(i,2,NodeCount(i,2))=j
          endif      
210     continue
200   continue

      write (*,*) 'Setup nodes'

      return
      end  !of SetUpNode


      subroutine WriteLoop

c***********************************************************************
c     Version:        radical 1.6          12 Sep 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by InitializeLoop

c     Writes title, some input info and rx matrix.
c***********************************************************************

      include 'radical.blk'
      character*8 date  			!next 20 lines changed by Yasu"
      character*10 time

	write (IOF,105)
105   format(
     + 6x'***********************************************************'
     +/6x'                                                           '
     +/6x'RRRRRR      A     DDDDD    IIIII   CCCCC      A     L      '
     +/6x'R     R    A A    D    D     I    C     C    A A    L      '
     +/6x'R     R   A   A   D     D    I    C         A   A   L      '
     +/6x'RRRRRR   A     A  D     D    I    C        A     A  L      '
     +/6x'R   R    AAAAAAA  D     D    I    C        AAAAAAA  L      '
     +/6x'R    R   A     A  D    D     I    C     C  A     A  L      '
     +/6x'R     R  A     A  DDDDD    IIIII   CCCCC   A     A  LLLLLLL'
     +/6x'                                                           '
     +/6x'***********************************************************')
      call Date_and_Time(date,time)
      write (IOF,120) date,time
120   format(6x'RADICAL 1.8 OUTPUT',/6x'DATE(yyyymmdd)='a8,/6x
     +'TIME(hhmmss)='a6/)

c      integer*2 Month,Day,Year,Hour,Minute,Second
c
c      call Date(Month,Day,Year)     !modified VAX function 2/11/91 chun
c      call Time(Hour,Minute,Second) !modified VAX function 2/11/91 chun
c      write (IOF,120) Month,Day,Year,Hour,Minute,Second
c120   format(
c     + 12x'_______________________________________________________'
c     +/12x'|                                                     |'
c     +/12x'|                 RADICAL 1.6b22 OUTPUT               |'
c     +/12x'|                                                     |'
c     +/12x'|'16x,i2'/'i2'/'i4,2x,i2':'i2.2':'i2.2,17x'|'
c     +/12x'_______________________________________________________')

      write (IOF,140)
      write (IOF,150)
      write (IOF,140)
      write (IOF,134) TitleLine
      write (IOF,135) InFile, OutFile
      if (PlotOut) write (IOF,136) PlotFile
      write (IOF,130) NSpecies,NRx,NSurfRx,NComp,NCycle
140   format(/80('_')/)
150   format(/37x'INPUT')
134   format(a80/)
135   format( 5x,'Input File Name                 = 'a35/
     +        5x,'Output File Name                = 'a35)
136   format( 5x,'Plot File Name                  = 'a35)
130   format(/5x,'Number of Species Evaluated     = 'i8/
     +        5x,'Number of Chemical Reactions    = 'i8/
     +        5x,'Number of Surface Reactions     = 'i8/
     +        5x,'Number of Components            = 'i8/
     +        5x,'Number of Cycles                = 'i8/)

      write(IOF,110) NodeStart,TempRef,FlowRateTot
110   format( 5x,'Starting Node                   = 'i8/
     +       /5x,'Reference Temperature           = 'f14.5' Kelvin'
     +       /5x,'Total Flow Rate                 = '1pe14.5' g/s')

c  write loop control flags

      if (HeatBalance) write(IOF,112) HeatBalComp
112   format( 5x,'Heat Balanced at Component      = 'a16)

      if (ConcInMode.eq.molLiter) then   !input in mol/liter
        ConcInUnit =' [mol/L]'
      elseif (ConcInMode.eq.ppb) then    !input in ppb
        ConcInUnit =' [ppb]  '
      endif
      if (ConcOutMode.eq.molLiter) then  !write in mol/liter
        ConcOutUnit=' [mol/L]'
      elseif (ConcOutMode.eq.ppb) then   !write in ppb
        ConcOutUnit=' [ppb]  '
      endif
      write (IOF,256) ConcInUnit,ConcOutUnit,WaterImplicit,
     +                SurfLoop,SensLoop,PlotOut
256   format(/5x,'Concentration Input Mode        = 'a10
     +       /5x,'Concentration Output Mode       = 'a10
     +       /5x,'H2O Is Implicit In Reaction Set = 'l8
     +       /5x,'Enable Surface Decomp For Loop  = 'l8
     +       /5x,'Enable Sensitivity For Loop     = 'l8
     +       /5x,'Write To Plot File              = 'l8//)

c  write loop node information

      write(IOF,191)
191   format(25x'Inlet'7x'Exit'
     +       /5x'Component Name'7x'Node'7x'Node'
     +       /5x'----------------'2(3x'--------'))
      do 196 i=1,NComp
        write (IOF,195) CompName(i),(CompNode(i,j),j=1,2)
196   continue
195   format(5x,a16,4x,i4,7x,i4,6x,i4)

c  write g-values and molecular weight

      if ((IGFlag.eq.-1).and.(ConcOutMode.ne.ppb)) goto 211
      write (IOF,190)
cy190   format(//17x'Gamma'5x'Neutron'4x'Molecular'
cy     +        /16x'G-Values'3x'G-Values'4x,'Weight'
cy     +        /5x'Species'4x'(#/100eV)'2x'(#/100eV)'2x'(g/mole)'
cy     +        /5x'-------- '3(2x'---------'))
190   format(//16x'Molecular'/17x'Weight'       !change by Yasu
     +/5x'Species'4x'(g/mole)'/5x'-------- '1(2x'---------'))
      do 200 i=1,NSpecies
cy        write(IOF,210) SpeciesName(i),GGamma(i),GNeut(i),MolWt(i)
        write(IOF,210) SpeciesName(i),MolWt(i)	!change by Yasu
200   continue
cy210   format(6x,a8,3(1x,e10.3))
210   format(6x,a8,1(1x,e10.3))					!change by Yasu

c  write chemical reaction set

211   write(IOF,292) FF        !insert page break
      write(IOF,10)
      write(IOF,140)
      write(IOF,11)
292   format(a,80('_')/)
cy10    format(/10x,
cy     +'Chemical Reactions, Rate Constants, and Activation Energies')
cy11    format(/26x'Reaction'30x'Rate'2x'Activation'
cy     +       /62x'Constant'2x'Energies'
cy     +       /70x'(kJ/mol-K)'/)
10    format(/10x,'Chemical Reactions')	!change by Yasu
11    format(/16x'Reaction'/)

      SpeciesName(0)='        '
      do 160 i=1,NRx
cy        if (EA(i).ne.-1.d0) then
          write(IOF,111) RxName(i),(SpeciesName(IR(i,k)),k=1,INR),
     +                  (SpeciesName(IP(i,k)),k=1,INP)	!change by Yasu
cy     +                  (SpeciesName(IP(i,k)),k=1,INP),
cy     +                   dabs(RCInit(i)),dabs(EA(i))
cy        else
cy          write(IOF,113) RxName(i),(SpeciesName(IR(i,k)),k=1,INR),
cy     +                  (SpeciesName(IP(i,k)),k=1,INP),
cy     +                   dabs(RCInit(i)),'Mass Tran'
cy        endif          
160   continue
cy111   format(a3,1x,3a8'>'4a8,1pe9.2,1x,e9.2) !change by Yasu
111   format(a3,1x,3a8'>'4a8)
cy113   format(a3,1x,3a8'>'4a8,1pe9.2,1x,a9)

c  write species name to plot file - tab delimited for direct input to Excel

      if (PlotOut) then         !write concentration results
        write (IPF,430) TitleLine
        write (IPF,431) '     ',
     +                  Tab,'Molecular Weight',Tab,'         ',
     +                 (Tab,MolWt(i),i=1,NSpecies)
        write (IPF,432) 'Cycle',
     +                  Tab,'Component       ',Tab,'Distance [cm]   ',
     +                 (Tab,SpeciesName(i),ConcOutUnit,i=1,NSpecies),     !Change by MPS, SpeciesName(i)/ConcOutUnit to SpeciesName(i),ConcOutUnit
     +                  Tab,'ECP [mV]        ',Tab,'Temp [Kelvin]   ',
     +                  Tab,'Power [Watts]   ',Tab,'Enthalpy [J/g]  ',
     +                  Tab,'Liq Dens [g/cc] ',Tab,'Gas Dens [g/cc] ',
     +                  Tab,'Liq Vel [cm/s]  ',Tab,'Gas Vel [cm/s]  ',
     +                  Tab,'Void Frac       ',Tab,'Quality         ',
     +                  Tab,'Gamma [rad/s]   ',Tab,'Neutron [rad/s] ',
     +                  Tab,'Alpha [rad/s]   '                            !change by Jarvis 10/24/12 
      endif ! this w

c added by jarvis . write header for the ECP file
      if(ECPOut) then  
        write (IEF,430) TitleLine
        write (IEF,432) 'Cycle',
     +                  Tab,'Component       ',Tab,'Distance [cm]   ',
     +                  Tab,'H2 [mol/L]      ',Tab,'H+ [mol/L]', 
     +                  Tab,'O2 [mol/L]      ',Tab,'H2O2 [mol/L]',
     +                  Tab,'ECP [mV]        ',Tab,'Corr. Pot.[mV]  ',
     +                  Tab,'H2 Pot. [mV]    ',Tab,'O2 Pot. [mV]    ', 
     +			Tab,'H2O2 Pot. [mV]  ',Tab,'i_Corr          ',
     +                  Tab,'i_H2            ',Tab,'i_O2            ',
     +                  Tab,'i_H2O2          ',Tab,'io_H2           ',
     +			Tab,'io_O2           ',Tab,'io_H2O2         ',
     +			Tab,'ila_H2          ',Tab,'ilc_H2          ',
     +			Tab,'ilc_O2          ',Tab,'ilc_H2O2        ',
     +                  Tab,'Re              ',Tab,'pH              ',
     +                  Tab,'pH Con H+(mol/l)',Tab,'pH Con OH-(mol/l'     ! end change

      endif !

c  write species name to HWC file - tab delimited for direct input to Excel

      if (CalcInject) then         !write concentration results  !change by Grover 4/30/96
c      if (CalcHWC) then         !write concentration results
        write (IHF,430) TitleLine
        write (IHF,433)     '                ',
     +                  Tab,'Molecular Weight',Tab,'                ',
     +                 (Tab,MolWt(i),i=1,NSp)
        write (IHF,434)     'H2 Injection    ',
     +                  Tab,'Component       ',Tab,'Distance [cm]   ',
     +                 (Tab,SpeciesName(i)//ConcOutUnit,i=1,NSp),
     +                  Tab,'ECP [mV]        '
      endif

430   format (a80)
431   format (a5,a,a16,a,a10,999(a,g12.5))
432   format (a5,999(a,a16))
433   format (3(a16,a),999(g12.5,a))
434   format (999(a16,a))

      return
      end  !of WriteLoop


      subroutine DoHeatBalance

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by radical
c     Calls ReadLoop, CheckInput, SetUpRx, SetUpNode, WriteLoop

c     Performs energy balance on a loop by fixing inlet enthalpy
c     at the component HeatBalComp.

c     How does it work?
c     DoHeatBalance calculates enthalpies for each component through
c     one complete cycle and compares the initial enthalpy at
c     NodeStart with the calculated value at the same node.
c     Any difference between the two values is due to energy imbalance.
c     This discrepancy is corrected at the component HeatBalComp,
c     thus ensuring energy conservation for the entire loop.

c     Heat balance can be done manually also by specifying inlet
c     temperature, carry under or carry over.
c***********************************************************************

      include 'radical.blk'
      integer*4 NCycleHold
      logical*4 CalcConcHold,SensLoopHold

c  initialize and save loop control parameters

      call ScreenDisplay(36,[0],[0.d0],nullMsg)  !entering Heat Balance...
      CalcConcHold=CalcConc
      CalcConc=.false.        !don't calculate radiolysis
      SensLoopHold=SensLoop
      SensLoop=.false.
      NCycleHold=NCycle
      NCycle=1                !one cycle is enough

c  call CalcLoop - only one cycle is necessary

      call CalcLoop(RWork)
      EnthDif=EnthNodeStart-Enthalpy  !this is what we need for balance

c  restore original values

      CalcConc=CalcConcHold   !restore original values
      NCycle=NCycleHold
      SensLoop=SensLoopHold
      HeatBalance=.false.
      call ScreenDisplay(37,[0],[0.d0],nullMsg)

      return
      end  ! of DoHeatBalance


      subroutine CalcLoop(RWork)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by radical
c     Calls CalcComp, Push, Pull, SumFlow, AverageFlow

c     Iterates through the entire loop and calculates radiolysis component
c     by component at each node.  To handle multiple parallel-series
c     combination of components, recurssive routine is used which 
c     utilizes a node stack to keep track of recursion information.

c  Local Variables

c     CompEval:     true if the component has been evaluated.
c                   false if the component has not been evaluated.
c     NCompAtNode:  number of components at node.
c     NodeEval:     true if the node has been evaluated by evaluating
c                   all preceeding components.  If not, recursive routine
c                   is called in to evaluat all preceeding components.
c     NodePrev:     node number of the previous node.
c     Stack:        stack to hold node numbers in recurssive calls.
c     StackPointer: stack pointer. 
c     SumFlowRateL: total flow rate weighted by liquid density.
c     SumFlowRateG: total flow rate weighted by liquid density.
c***********************************************************************

      include 'radical.blk'
      real*8 RWork(*)
cy      integer*4 StackPointer,Stack(INO)
      integer*4 StackPointer,Stack(INO),NCycle0	!change by Yasu
      logical*4 CompEval(ICO),NodeEval(INO)

c  initialization for loop calc

	NCycle0=NCycle								!added by Yasu
10    ICycle=0
      Node=NodeStart            !begin calc at NodeStart
      StackPointer=0            !resets the stack
      call ScreenDisplay(2,[0],[0.d0],nullMsg)

c  initialization for each cycle

101   ICycle=ICycle+1         !increment cycle counter

      do 300 i=1,NComp
        CompEval(i)=.false.   !reset all component flags to false
300   continue
      do 310 i=1,MaxNode
        NodeEval(i)=.false.   !reset all node flags to false
310   continue

      NodeEval(NodeStart)=.true. !true for the starting node
      do 20 i=1,MaxNode
        if (NodeCount(i,2).eq.0) NodeEval(i)=.true.  !true for dangling nodes
20    continue

c**** loop which evaluates components one by one at a node starts here.     

100   Node=CompNode(NodeInfo(Node,1,1),2)  !proceed to exit node
      call ScreenDisplay(3,[Node],[0.d0],nullMsg) !cycle=...  node=...
200   SumFlowRateL=0.d0         !initialize total flowrate at each node
      SumFlowRateG=0.d0
      SumFlowRate=0.d0
      do 130 k=1,NSp            !initialize concentration
        ConcNode(Node,k)=0.d0
130   continue
      EnthNode(Node)=0.d0

      NCompAtNode=NodeCount(Node,2)  !# of components ending at node i
      do 110 j=1,NCompAtNode
        IComp=NodeInfo(Node,2,j)   !component ending at node i
        NodePrev=CompNode(IComp,1) !previous node for this comp
        if ((.not.CompEval(IComp)).and.NodeEval(NodePrev)) then

c       evaluated at node and component is not computed yet

          call ScreenDisplay(4,[0],[0.d0],nullMsg)
          call CalcComp(RWork)
          CompEval(IComp)=.true.  !this component has been evaluated

        elseif (.not.NodeEval(NodePrev)) then

c       there are components before ICOMP that need be calculated

          call Push(Node,Stack,StackPointer,MaxNode)
          Node=CompNode(IComp,1)
          goto 200              !recursion 
        endif

      if (NCompAtNode.gt.1) call SumFlow(Node)

110   continue  !through all parallel components ending at this node

      call AverageFlow(Node,NCompAtNode) 

      NodeEval(Node)=.true.     !evaluation of this node is complete

      if (StackPointer.gt.0) then  !pull and calc the previous node
        call Pull(Node,Stack,StackPointer)
        goto 200
      endif

      if (Node.ne.NodeStart) goto 100

c  continue through entire loop

      if (ICycle.lt.NCycle) goto 101
	NCycle=NCycle0								!added by Yasu

c  continue through NCycles

      return
      end  !of CalcLoop


      subroutine CalcComp(RWork)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by CalcLoop
c     Calls ReadComp, PrepareComp, WriteComp, Radiolysis, WriteStat

c     Evaluates radiolysis of a component.
c***********************************************************************

      include 'radical.blk'
      real*8 RWork(*)
      logical*4 Converged

      Time2=Secnds(0.0) !start clock to measure component execution time

c  start component calculation

      call ReadComp             !read component parameters from file
      call CheckCompInput       !check for input error
      call PrepareComp          !prepares component for calc
      if ((XLength.eq.0.d0).or.(.not.CalcConc)) goto 380  !skip if null component
      call WriteComp            !write input parameters
      call Radiolysis(RWork)    !evaluate radiolysis
      if (ICycle.eq.NCycle) call WriteStat

c  check convergence using the function Converged

      if (ConvComp.eq.CompName(IComp)) then
        if (Converged()) then
          NCycle=LastCycle+1
          CycleOut(NCycle)=.true.
          CyclePlot(NCycle)=.true.
        else
          LastCycle=ICycle+1      !go one more cycle
        endif
      endif

c  store final concentration

380   do 390 i=1,NSp
        ConcFinal(IComp,i)=Conc(i)
390   continue
      EnthFinal(IComp)=Enth(NPowerData-1)
      
      if (SensLoop.and.SensComp.and.(XLength.gt.0.d0)
     +   .and.(ICycle.eq.NCycle))
     +  call Sensitivity(RWork)

      return
      end  !of CalcComp      


      logical*4 function Converged()

c***********************************************************************
c     Version:        radical 1.6          24 Aug 1993
c     Author:         John H. Chun
c***********************************************************************
c     Tests convergence of certain species to within ConvMin.
c***********************************************************************

      include 'radical.blk'

      Converged=.false.

      do j=1,NConv
        do i=1,NSp
          if (ConvSpecies(j).eq.SpeciesName(i)) then
            if (ConcFinal(IComp,i).ne.0.d0) then
              ConcChange=(Conc(i)-ConcFinal(IComp,i))/ConcFinal(IComp,i)
              call ScreenDisplay(40,[i],[ConcChange],nullMsg) !Convergence for...
            else
              return
            endif
            if (dabs(ConcChange).gt.ConvMin) return
          endif
        enddo
      enddo

      Converged=.true.
      call ScreenDisplay(41,[0],[0.d0],nullMsg) !Converged...

      return
      end  !of Converged


      subroutine Push(Node,Stack,StackPointer,StackTop)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by CalcLoop

c     Pushes node number into the stack.

      integer*4 StackPointer,Stack(*),StackTop,In(2)
      character*80 nullMsg
      nullMsg=' '

      In(1)=Node
      In(2)=StackPointer
      call ScreenDisplay(5,In,[0.d0],nullMsg)

      if (StackPointer.le.StackTop) then
        StackPointer=StackPointer+1
        Stack(StackPointer)=Node
      else
        call ErrorDisplay(23,[0],[0.d0],nullMsg)  !stack pushed too far. Something's wrong!
      endif

      return
      end  !of Push


      subroutine Pull(Node,Stack,StackPointer)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by CalcLoop

c     Pulls node number from the stack.
c***********************************************************************

      integer*4 StackPointer,Stack(*),In(2)
      character*80 nullMsg
      nullMsg=' '

      In(1)=Node
      In(2)=StackPointer
      call ScreenDisplay(6,In,[0.d0],nullMsg)

      if (StackPointer.ge.1) then  !pull stack
        Node=Stack(StackPointer)
        StackPointer=StackPointer-1
      else
        call ErrorDisplay(24,[0],[0.d0],nullMsg)  !stack pulled too far. Something's wrong!
      endif

      return
      end  !of Pull


      subroutine SumFlow(Node)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by CalcLoop

c     Sums density weighted flowrates of all components at a node.
c     Also sums up enthalpies weighted by mass flowrate.
c***********************************************************************

      include 'radical.blk'

      call ThermalHydro(XLength)

      CompFlowL(IComp)=FlowRate*(1.d0-Quality)/DensLiq  !liquid
      SumFlowRateL=SumFlowRateL+CompFlowL(IComp)
      CompFlowG(IComp)=FlowRate*Quality/DensGas         !gas
      SumFlowRateG=SumFlowRateG+CompFlowG(IComp)
      SumFlowRate=SumFlowRate+FlowRate

      do 120 k=1,NSp           !average concentration at node
        IC=index(SpeciesName(k),'G')
        if (IC.eq.0) then       !liquid
          ConcNode(Node,k)=ConcNode(Node,k)+
     +                     ConcFinal(IComp,k)*CompFlowL(IComp)
        else                    !gas
          ConcNode(Node,k)=ConcNode(Node,k)+
     +                     ConcFinal(IComp,k)*CompFlowG(IComp)
        endif
120   continue  !through all species
      EnthNode(Node)=EnthNode(Node)+EnthFinal(IComp)*FlowRate

      return
      end  !of SumFlow


      subroutine AverageFlow(Node,NOfComp)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by CalcLoop

c     Averages concentration of all parallel components at a node by
c     weighing volumetric flowrates of all components at the node.
c***********************************************************************

      include 'radical.blk'

      if (NOfComp.eq.1) goto 150 !no need to average if only one comp   

      if (SumFlowRateL.le.0.d0) call ErrorDisplay(25,[0],[0.d0],nullMsg)  !input error condition

      do 140 k=1,NSp            !weigh by total volume flowrate
        IC=index(SpeciesName(k),'G')
        if (IC.eq.0) then                    !liquid
          ConcNode(Node,k)=ConcNode(Node,k)/SumFlowRateL
        elseif (SumFlowRateG.ne.0.d0) then  !gas
          ConcNode(Node,k)=ConcNode(Node,k)/SumFlowRateG
        endif          
140   continue  !through all species
      EnthNode(Node)=EnthNode(Node)/SumFlowRate
      return

150   do 160 k=1,NSp
        ConcNode(Node,k)=ConcFinal(IComp,k)
160   continue
      EnthNode(Node)=EnthFinal(IComp)
      
      return
      end  !of AverageFlow


      subroutine ReadComp

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by CalcComp

c     Reads component input parameters from input file.
c***********************************************************************

      include 'radical.blk'

      character TheName*30,Line*80,Sp*8	!added by Yasu
      dimension Sp(ISP)					!added by Yasu

      namelist /Position/ XIn,XLength,XStep,XBoil,XBoilOffset,PlotStep
      namelist /State/ TempIn,TempOut,Diameter,
     +                 Pressure,FlowRate,FlowFrac,Surface,
     +                 Area,AreaIn,AreaOut,CarryUnder,CarryOver,
     +                 QualMin,Diffusion,Viscosity,
     +                 FlowOrient
      namelist /DoseShape/ GammaAvg,NeutAvg,AlphaAvg,GammaInMode, 
     +                     GammaCoef,NeutInMode,NeutCoef,AlphaInMode,
     +                     AlphaCoef      !change by Jarvis(added alpha)
      namelist /PowerShape/ PowerAvg,PowerInMode,PowerData
      namelist /VoidShape/ VoidInMode,VoidCoef
      namelist /QualShape/ QualInMode,QualCoef
      namelist /InitialConc/ ConcInit
      namelist /Flag/ SurfComp,FlowModel,SensComp,WriteRx,WritePara,
     +                RadHeat,ThermoModel,ECPModel,pHMode,pH,BTot,LiTot
      namelist /Sensitivity/ SensStep,SensSpecies
      namelist /DLSODEData/ ITask,RTol,ITol,ATol,ConcRWork,IWork,MF,IOpt
      namelist /AdjData/ AdjITask,AdjRTol,AdjITol,AdjATol,AdjMF,
     +                   AdjIOpt,AdjRWork,AdjIWork
      namelist /ResData/ ResITask,ResRTol,ResITol,ResATol,ResMF,
     +                   ResIOpt,ResRWork,ResIWork

c  set default values for each component

      do 10 i=1,NSp
        ConcInit(i)=ConcNode(CompNode(IComp,1),i)  !set to previous node's conc
        SensSpecies(i)='        '
10    continue
      EnthIn=EnthNode(CompNode(IComp,1))      

      GammaAvg=0.d0
      NeutAvg=0.d0
      PowerAvg=0.d0
      AlphaAvg=0.d0 ! added jarvis
      do 20 i=0,IPO
        GammaCoef(i)=1.d-99
        NeutCoef(i)=1.d-99
        AlphaCoef(i)=1.d-99
        VoidCoef(i)=1.d-99
20    continue

      XIn=XOut
      if (CompNode(IComp,1).eq.NodeStart) XIn=0.d0
      XLength=0.d0
      XStep=0.d0
      PlotStep=0.d0
      VelInlet=0.d0
      FlowRate=0.d0
      TempIn=0.d0
      CarryUnder=0.d0
      CarryOver=0.d0
      SensStep=0
      NZero=0
      Diameter=0.d0
      AreaIn=0.d0
      AreaOut=0.d0
c     initialize default ECP settings
      ECPModel='null' 
      pHMode='pHInput'
      pH=-1.0d0
      BTot=-1.0d0
      LiTot=-1.0d0
      

c  start reading component input

      call FindLine('@'//CompName(IComp),NZero)  !position input pointer
      read (IIF,nml=Position,err=600)
      write (*,*) 'read position input pointer'

      call FindLine('@'//CompName(IComp),NZero)
      read (IIF,nml=State,err=602)

      call FindLine('@'//CompName(IComp),NZero)
      read (IIF,nml=Flag,err=100)

100   call FindLine('@'//CompName(IComp),NZero)
      read (IIF,nml=DoseShape,err=120)

120   call FindLine('@'//CompName(IComp),NZero)
      if (FlowModel.eq.Chexal) then      !Chexal-Lellouche
        read (IIF,nml=PowerShape,end=130)
      elseif (FlowModel.eq.BankoffVoid) then  !Bankoff - Void fraction is input
        read (IIF,nml=VoidShape,end=130)
      elseif (FlowModel.eq.BankoffQual) then  !Bankoff - Quality is input
        read (IIF,nml=QualShape,end=130)
      elseif (FlowModel.ne.SinglePhaseFlow) then
        call ErrorDisplay(31,[0],[0.d0],nullMsg)  !input error...
      endif

      write (*,*) 'read component flow model'

c     skip reading InitialConc at NodeStart if beyond first cycle

130   if ((ICycle.gt.1).and.(CompNode(IComp,1).eq.NodeStart)) goto 140
      call FindLine('@'//CompName(IComp),NZero)
      read (IIF,nml=InitialConc,err=140)

140   call FindLine('@'//CompName(IComp),NZero)
      if (SensLoop.and.SensComp) read (IIF,nml=Sensitivity,end=110)

110   call FindLine('@'//CompName(IComp),NZero)
      read (IIF,nml=DLSODEData,end=111)  !read DLSODE control variables

111   call FindLine('@'//CompName(IComp),NZero)
      if (SensLoop.and.SensComp) read (IIF,nml=AdjData,end=112) !Adjoint DLSODE data

112   call FindLine('@'//CompName(IComp),NZero)
      if (SensLoop.and.SensComp) read (IIF,nml=ResData,end=113) !Response DLSODE data

cy	next 22 lines moved from ReadLoop with a little change by Yasu

      write (*,*) 'read component DLSODE data'

c  read gamma, neutron g-values and molecular weights

cy109   rewind (IIF)
     
113   if(.not.SameGVal) then
	call FindLine('@'//CompName(IComp),NZero)	!change by Yasu
      TheName='$GValue'
      call FindLine(TheName,IGFlag)
      read(IIF,220)						!change by Yasu
     +  (SpeciesName(i),GGamma(i),GNeut(i),GAlpha(i),i=1,NSpecies) !change by Jarvis 10/31/12
220   format(1x,a8,3d15.8) !change by Jarvis 10/31/12
222   format(a80)

      write (*,*) 'read component g-values and molecular weights'
      endif

c  read chemical reaction matrix

      if(.not.SameRxSet) then
      call FindLine('@'//CompName(IComp),NZero)	!change by Yasu
      TheName='$Reaction'    !read reaction information
      call FindLine(TheName,IGFlag)
      do 141 i=1,NRx
        read(IIF,102,end=116)						!line number change by Yasu
     +   RxName(i),(Sp(k),k=1,INR+INP),RCMode(i),(RC(i,k),k=1,5) !change by Jarvis 11/12
141   continue  !for reactions
102   format(1x,a3,1x,3a8,1x,4a8,a1,5d15.8)     ! change by Jarvis 10/24/12
      write (*,*) 'read component chemical reaction matrix'
      endif
116   return					!line number change by Yasu
      
600   call ErrorDisplay(26,[0],[0.d0],nullMsg)     !position info not found...   quit
602   call ErrorDisplay(27,[0],[0.d0],nullMsg)     !state info not found...      quit

      Area=AreaIn    !initilize area 2/3/96 by D. Grover

      end  !of ReadComp


      subroutine CheckCompInput
c
c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by InitializeLoop
c
c     Validates input data to make sure everything is within limits.
c***********************************************************************
c
      include 'radical.blk'
      logical*4 Error
      data Error/.false./

      if (XLength.lt.0.d0) then
        call ErrorDisplay(51,[0],[0.d0],nullMsg)
        Error=.true.
      endif

      if ((TempIn.lt.0.d0).or.(TempOut.lt.0.d0)) then
        call ErrorDisplay(53,[0],[0.d0],nullMsg)
        Error=.true.
      endif

      if ((GammaAvg.lt.0.d0).or.(NeutAvg.lt.0.d0).or.(AlphaAvg.lt.0.d0))
     + then ! change by Jarvis 10/25/12
        call ErrorDisplay(54,[0],[0.d0],nullMsg)
        Error=.true.
      endif

      if (VelInlet.lt.0.d0) then
        call ErrorDisplay(55,[0],[0.d0],nullMsg)
        Error=.true.
      endif

      if (Diameter.lt.0.d0) then
        call ErrorDisplay(56,[0],[0.d0],nullMsg)
        Error=.true.
      endif

      if ((DensLiq.lt.0.d0).or.(DensGas.lt.0.d0)) then
        call ErrorDisplay(57,[0],[0.d0],nullMsg)
        Error=.true.
      endif

      if (Pressure.lt.0.d0) then
        call ErrorDisplay(58,[0],[0.d0],nullMsg)
        Error=.true.
      endif

      if (FlowRate.lt.0.d0) then
        call ErrorDisplay(59,[0],[0.d0],nullMsg)
        Error=.true.
      endif

      do 200 i=1,NSp           !check for all concentrations
        if (Conc(i).lt.0.d0) then
          call ErrorDisplay(63,[i],[0.d0],nullMsg)
          Error=.true.
        endif
200   continue  !through all species

      if ((MF.ne.10).and.(MF.ne.21).and.(MF.ne.22).and.
     +  (MF.ne.24).and.(MF.ne.25)) then
        call ErrorDisplay(65,[0],[0.d0],nullMsg)
        Error=.true.
      endif

      if ((AdjMF.ne.10).and.(AdjMF.ne.21).and.(AdjMF.ne.22).and.
     +  (AdjMF.ne.24).and.(AdjMF.ne.25)) then
        call ErrorDisplay(66,[0],[0.d0],nullMsg)
        Error=.true.
      endif
        
      if ((ResMF.ne.10).and.(ResMF.ne.21).and.(ResMF.ne.22).and.
     +  (ResMF.ne.24).and.(ResMF.ne.25)) then
        call ErrorDisplay(67,[0],[0.d0],nullMsg)
        Error=.true.
      endif

cy	next 35 lines moved from CheckLoopInp with a little change by Yasu
      do 202 i=1,NSp           !check for all species data   !line number change
        if (GGamma(i).lt.0.d0) then
          call ErrorDisplay(13,[i],[0.d0],nullMsg)
          Error=.true.
        endif
        if (GNeut(i).lt.0.d0) then
          call ErrorDisplay(14,[i],[0.d0],nullMsg)
          Error=.true.
        endif
        if (GAlpha(i).lt.0.d0) then
          call ErrorDisplay(77,[i],[0.d0],nullMsg)
          Error=.true.
        endif
202   continue  !through all species   !line number change

c  mass balance for G-VALUES

      GammaMass=0.d0
      NeutMass=0.d0
      do 180 i=1,NSp
        GammaMass=GammaMass+GGamma(i)*MolWt(i)
        NeutMass=NeutMass+GNeut(i)*MolWt(i)
180   continue
c      if (dmod(GammaMass,MolWtH2O).gt.1.d0)     commented out by RGB's request
c     +   call ErrorDisplay(16,0,GammaMass,' ')  950605 chun
c      if (dmod(NeutMass,MolWtH2O).gt.1.d0)
c     +   call ErrorDisplay(17,0,NeutMass,' ')
      
      do 140 i=1,NRx            !check for all reactions
        if (RCMode(i).eq.'A') then
          if(RC(1,i).lt.0.d0) then
            call ErrorDisplay(19,[i],[0.d0],nullMsg)
            Error=.true.
          endif
          if ((.not.WaterImplicit).and.(RC(2,i).lt.-1.d0)) then
            call ErrorDisplay(20,[i],[0.d0],nullMsg)
            Error=.true.
          endif
        endif
140   continue  !through all reactions

c     INSERT pH/ECP model checks
      if( (ECPModel.eq.'PAll600').or.(ECPModel.eq.'PAll690')
     +     .or.(ECPModel.eq.'PSS304') ) then
        if ( (pHMode.eq.'pHInput').and.(pH.le.0)) then
          call ErrorDisplay(78,[0],[0.d0],nullMsg)
          Error=.true.
        endif
      if( (pHMode.eq.'BLiCalc').and.((Btot.lt.0.d0).or.
     +     (LiTot.lt.0.d0))) then
        call ErrorDisplay(79,[0],[0.d0],nullMsg)
        Error=.true.
        endif
      endif 
  
999   if (Error) call ErrorDisplay(68,[0],[0.d0],nullMsg)

      return
      end  !of CheckCompInput


      subroutine PrepareComp

c***********************************************************************
c     Version:        radical 1.6          13 Sep 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by CalcComp

c     Adjusts input data for radiolysis calculation.
c***********************************************************************

      include 'radical.blk'

c  assign XOut

      XOut=XIn+XLength
c      if (XLength.eq.0.d0) return
      if (XStep.le.0.d0) XStep=XLength/2.d0
      if (PlotOut.and.(PlotStep.le.0.d0)) PlotStep=XLength/10.d0

c  determine the maximum order

      MaxOrdGamma=-1
      MaxOrdNeut=-1
      MaxOrdVoid=-1
      MaxOrdAlpha=-1 ! added by Jarvis
      NPowerData=-1
      do 20 i=0,IPO
        if (GammaCoef(i).ne.1.d-99) MaxOrdGamma=i
        if (NeutCoef(i).ne.1.d-99) MaxOrdNeut=i
        if (VoidCoef(i).ne.1.d-99) MaxOrdVoid=i
        if (AlphaCoef(i).ne.1.d-99) MaxOrdAlpha=i !added by jarvis 10/25/12
        if (PowerData(i).ne.1.d-99) NPowerData=i  ! added by Jarvis. This seemed to be missing
20    continue
      if (MaxOrdGamma.eq.-1) GammaAvg=0.d0
      if (MaxOrdNeut.eq.-1) NeutAvg=0.d0
      if (MaxOrdVoid.eq.-1) PowerAvg=0.d0
      if (MaxOrdAlpha.eq.-1) AlphaAvg=0.d0 !added jarvis
      if (NPowerData.eq.-1) NPowerData=0.d0  ! added by jarvis. seems like power was missing
      if (GammaInMode.eq.dataPoints) MaxOrdGamma=MaxOrdGamma+1
      if (NeutInMode.eq.dataPoints) MaxOrdNeut=MaxOrdNeut+1
      if (VoidInMode.eq.dataPoints) MaxOrdVoid=MaxOrdVoid+1
      if (AlphaInMode.eq.dataPoints) MaxOrdAlpha=MaxOrdAlpha+1 !change by Jarvis
c      if (PowerInMode.eq.dataPoints) NPowerData=NPowerData+1   ! added by Jarvis. seems like power was missing

c  initialize thermal-hydraulics parameters

      call InitializeThermo

c  inject hydrogen if HWC

      if (CalcInject.and.(CompName(IComp).eq.InjectComp)) then    !change by Grover 4/30/96
c      if (CalcHWC.and.(CompName(IComp).eq.HWCComp)) then
        call ScreenDisplay(39,[0],[0.d0],nullMsg)
        do i=1,NSp
c  **************************************************************************************
c
c   Change added by D. Grover on April 30, 1996
c    Change allows injection of other chemical species beyond hydrogen
c     old line followed by changed line

c          if (SpeciesName(i).eq.'H2') ConcInit(i)=HWCInject(iHWC)
          if (SpeciesName(i).eq.SpeciesInject) 
     +       ConcInit(i)=Inject(iHWC)
c
c     end change
c ******************************************************************************************
        enddo
      endif

c  adjust initial concentrations to input mode

      call ThermalHydro(0.d0)       !get DensLiq
      do 10 i=1,NSp
        if ((ConcInMode.eq.ppb).and.  !ppb to mol/L for internal calc
     +    (ConcInit(i).ne.ConcNode(CompNode(IComp,1),i)))
     +    ConcInit(i)=ConcInit(i)*DensLiq/MolWt(i)/1.d6  !adjust only if newly input
        Conc(i)=ConcInit(i)      !set Conc to initial concentrations
10    continue

      ConcH2O=1.d3*DensLiq/MolWtH2O !fix water concentrations
      Conc(IH2O)=ConcH2O            !it's H2O
      Conc(I2H2O)=ConcH2O*ConcH2O   !it's 2H2O

c  calculate diameter from area if SurfComp, but no diameter is input

      if (SurfComp.and.(Diameter.eq.0.d0)) Diameter=dsqrt(4.d0*Area/Pi)
      if (NSurfRx.eq.1) Surface=RxName(NRx)

c  initialize sensitivity routine parameters

400   if (SensLoop.and.SensComp) then

        NSensStep=XLength/XStep*SensStep
        if ((SensStep.le.0).or.(NSensStep.gt.IST))
     +     SensStep=IST/XLength*XStep  !maximize SensStep
        if (NSensStep.gt.IST) call ScreenDisplay(7,[0],[0.d0],nullMsg) 

        NSens=0
        do 100 i=1,NSp
          if (SensSpecies(i).ne.'        ') NSens=i
100     continue
        if (NSens.le.0) SensComp=.false.

      endif

      return
      end  !of PrepareComp


      subroutine InitializeThermo

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by CalcComp

c     Adjusts input data for radiolysis calculation.
c***********************************************************************

      include 'radical.blk'
	          
c  common blocks for CONVRT  930610 Davood & chun
      COMMON /CNTROL/PP,TT,DDH,PM,DHM,IOPTc,IUNIT
c      COMMON /PRO/VisL,VisG,P,PC,RF,RG,SIG,TMP,IER,TSAT,IFL
      COMMON /PRO/VisL,VisG,P,PC,RF,RG,SIG,TMP,TSAT,IER,IFL	!change by Yasu
      COMMON /MODEL/DH,WF,WG,ORT
c  common blocks for STMTAB  930610 Davood & chun
      COMMON/TABSTM/PRESS,TEMPF,QUAL,SATLIQ(3),STEAM(3),IERc  !for STMTAB

c  avoid blow-up at XBoil

      if (XLength.eq.XBoil) then
        XLength=XLength-XBoilOffset  !evaluate up to just before XBoil
      endif

c  initialize thermal-hydraulic parameters

      if (FlowRate.le.0.d0) FlowRate=FlowRateTot*FlowFrac

c  flow parameter for Bankoff's model

      FlowPara=0.71d0+1.4112306d-2*Pressure  !for Bankoff model; P in MPa

c  initialization for Chexal-Lellouche model

      P=Pressure*ucPressure
      PP=Pressure               !MPa
      DDH=Diameter/100.d0       !diameter cm to m  DAVOOD 10/1/93
      TT=0.d0                   !specify saturation properties
      IUNIT=0
      WF=FlowRate/1.d3          !g/s to kg/s
      IFL=1
      ORT=FlowOrient            !flow orientation is vertical
      call CONVRT               !sets up parameters for GLENNS in ThermalHydro
      DensGas=RG/ucDensity      !lbm/ft3 to g/cc
      DensLiqSat=RF/ucDensity   !lbm/ft3 to g/cc

c  get saturated properties

      call STMTAB (4,P,0.d0)      !saturated quantities
      EnthLiq=SATLIQ(2)/ucEnthalpy !Btu/lbm to J/g
      EnthGas=STEAM(2)/ucEnthalpy  !Btu/lbm to J/g
      call STMTAB (1,P,0.d0)    !get sat temp @ P
      TempSat=(TEMPF-32.d0)/1.8d0+ZeroC
      
c  any of the following conditions will cause enthalpy to be reevaluated 
c  1. if this component is the HeatBalComp
c  2. if temperature has been input for this component
c  3. if carry under has been input for this component
c  4. if carry over has been input for this component
c  only one of these conditions should be specified for any given comp

      if (CompName(IComp).eq.HeatBalComp) then
        EnthIn=EnthIn+EnthDif/FlowFrac
      elseif (TempIn.gt.0.d0) then  !new TempIn has been read for this comp
        TinF=(TempIn-ZeroC)*1.8d0+32.d0
        H=HPT(P,TinF)           !get enthalpy @ P,TinF - retran call
        EnthIn=H/ucEnthalpy     !Btu/lbm to J/g
        if (IComp.eq.NodeInfo(NodeStart,1,1)) EnthNodeStart=EnthIn
      elseif (CarryUnder.gt.0.d0) then  !carry under is mass fraction of steam
        EnthIn=(1.d0-CarryUnder)*EnthLiq+CarryUnder*EnthGas
      elseif (CarryOver.gt.0.d0) then   !carry over is mass fraction of liquid
        EnthIn=CarryOver*EnthLiq+(1.d0-CarryOver)*EnthGas
      else                    !no new TempIn has been read for this comp
        TempIn=TempOutOld
      endif
      TempOutOld=TempOut
      
c  create enthalpy profile array

      EnthLength=XLength
      if (NPowerData.gt.1) then
        EnthStep=XLength/(NPowerData-1)
        do 300 i=1,NPowerData-1
          Enth(i)=Enth(i-1)+PowerData(i)*PowerAvg*PowerFactor
     +            /XLength/FlowRate*EnthStep
300     continue
      else
        EnthStep=XLength
        NPowerData=1
      endif

c  nuclear heating may be included by setting the flag RadHeat to true.
c  this is necessarily an approximation since we find VelLiq based on
c  direct thermal power found above.  Otherwise the evaluation of
c  nuclear heating becomes cyclic.
c  1 rad = 1e-5 J/g

      if (RadHeat) then
        do 310 i=1,NPowerData-1
          x=(i-1)*EnthStep
          call ThermalHydro(x)
          call DoseShape(x)
          Enth(i)=Enth(i)+(Gamma+Neutron)*1.d-5*EnthStep/VelLiq
310     continue
      endif
      
      if (Debug(11)) call ScreenDisplay(17,[0],[0.d0],nullMsg)  !write enthalpies...

      return
      end  !of InitializeThermo


      subroutine WriteComp

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by CalcComp

c     Writes component data to output file.
c***********************************************************************

      include 'radical.blk'
      character*30 FlowModelName,ECPModelName,pHModelName

      if ((ICycle.gt.1).and.(ICycle.lt.NCycle)) return !write first & last cycles only
      if (HeatBalance.or.(iHWC.gt.1)) return
      
c  write component parameters

      write (IOF,292) FF          !insert page break (form feed)
      write (IOF,291) ICycle,CompName(IComp)
      write (IOF,290)
292   format (a,80('_'),/)
291   format(/20x'Output For Cycle'i5' at 'a16)
290   format (/80('_'),/)

c  write geometry parameters

      write(IOF,105) XIn,XOut,XLength,XStep
      if ((FlowModel.eq.BankoffVoid).or.(FlowModel.eq.BankoffQual))
     +  write(IOF,104) XBoil
105   format(/5x,'Inlet Position                  = 'f14.5' cm'
     +       /5x,'Exit Position                   = 'f14.5' cm'
     +       /5x,'Flow Length                     = 'f14.5' cm'
     +       /5x,'Position Increment              = 'f14.5' cm')
104   format( 5x,'Position of Onset of Boiling    = 'f14.5' cm')

c  write thermal-hydraulic parameters

      write(IOF,110) TempIn,TempOut
110   format(/5x,'Inlet Temperature               = 'f14.5' Kelvin'
     +       /5x,'Outlet Temperature              = 'f14.5' Kelvin')
      write(IOF,106) VelInlet,Pressure,FlowFrac,FlowRate
106   format( 5x,'Inlet Liquid Velocity           = 'f14.5' cm/s'
     +       /5x,'Pressure                        = 'f14.5' MPa'
     +       /5x,'Fraction of Total Flow Rate     = 'f14.5
     +       /5x,'Component flow rate             = '1pe14.5' g/s')
      if (FlowModel.eq.Chexal) then
        write(IOF,112) AreaIn,FlowOrient,PowerAvg*PowerFactor,QualMin
        if (CarryUnder.gt.0.d0) then
          write(IOF,113) CarryUnder
        elseif (CarryOver.gt.0.d0) then
          write(IOF,114) CarryOver
        endif
      endif
112   format( 5x,'Cross Sectional Area            = ' f14.5' cm2'
     +       /5x,'Flow Orientation                = ' f14.5' degrees'
     +           ' from top'
     +       /5x,'Bundle Average Power            = '1pe14.5' watts'
     +       /5x,'Quality Minimum Threshold       = ' e14.5)
113   format( 5x,'Carry Under (mass fraction)     = '  f14.5)
114   format( 5x,'Carry Over (mass fraction)      = '  f14.5)

cy	next 41 lines moved from WriteLoop with a little change by Yasu
c  write g-values and molecular weight

      if ((IGFlag.eq.-1).and.(ConcOutMode.ne.ppb)) goto 211
      write (IOF,190)
190   format(//17x'Gamma'5x'Neutron'6x'Alpha'4x'Molecular'
     +        /16x'G-Values'3x'G-Values'3x'G-Values'4x'Weight'
     +        /5x'Species'4x'(#/100eV)'2x'(#/100eV)'2x'(#/100eV)'
     +        2x'(g/mole)'
     +        /5x'-------- '4(2x'---------'))
      do 200 i=1,NSpecies
        write(IOF,210) SpeciesName(i),GGamma(i),GNeut(i),GAlpha(i),
     +                 MolWt(i)
200   continue
210   format(6x,a8,4(1x,e10.3))

c  write chemical reaction set

211   write(IOF,2922) FF        !insert page break  !line number change by Yasu
      write(IOF,1002)				!line number change by Yasu
      write(IOF,1402)				!line number change by Yasu
      write(IOF,1102)				!line number change by Yasu
2922  format(a,80('_')/)			!line number change by Yasu
1402  format(/80('_')/)		!added by Yasu
1002  format(/10x,                              !line number change by Yasu
     +'Chemical Reactions, Rate Constants, and Activation Energies')

1102  format(/26x'Reaction'28x'Rxn Type'3x'Rate Cnst'2x'Act. En.' !line number change by Yasu
     +       /83x'(kJ/mol-K)' /76x 'or'
     +       /62x'P.Coef.1'3x'P.Coef.2'2x'P.Coef.3'2x'P.Coef.4'/)

      SpeciesName(0)='        '
      do 1602 i=1,NRx				!line number change by Yasu
        if (RCMode(i).eq.'A') then
          write(IOF,1112) RxName(i),(SpeciesName(IR(i,k)),k=1,INR),
     +                  (SpeciesName(IP(i,k)),k=1,INP),
cj     +                   dabs(RCInit(i)),dabs(EA(i))
     +                   'Arrhenius',dabs(RC(i,1)),dabs(RC(i,2)) !change by Jarvis 11/12
        elseif (RCMode(i).eq.'M') then
          write(IOF,1132) RxName(i),(SpeciesName(IR(i,k)),k=1,INR),
     +                  (SpeciesName(IP(i,k)),k=1,INP),
cj     +                   dabs(RCInit(i)),'Mass Tran'
     + 			'Mass Trans',dabs(RC(i,1))	
	else ! RCMode = 'P'
	  write(IOF,1142) RxName(i),(SpeciesName(IR(i,k)),k=1,INR),
     +                  (SpeciesName(IP(i,k)),k=1,INP),  
     +                 'Poly. Fit',(RC(i,k),k=1,4) 
        endif          
1602  continue                                   !line number change by Yasu
1112  format(a3,1x,3a8'>'4a8,a10,1x,1pe9.2,1x,e9.2) 
1132  format(a3,1x,3a8'>'4a8,a10,1x,1pe9.2)
1142  format(a3,1x,3a8'>'4a8,a10,1x,1pe9.2,1x,1pe9.2,
     +       1x,1pe9.2,1x,1pe9.2) 

c  write H2O2 surface decomposition parameters

      if (SurfLoop.and.SurfComp) write(IOF,107) Surface,Diameter
107   format(/5x,'Surface Material                = 'a3
     +       /5x,'Pipe Hydraulic Diameter         = 'f14.5' cm')

      if (SensComp.and.SensLoop) then
        write(IOF,108) (i,SensSpecies(i),i=1,NSens)
        write(IOF,109) SensStep
      endif
108   format(/5x,'Sensitivity Species 'i3,9x'=',7x,a8)
109   format( 5x,'SensStep                        = 'i8)

c  write dose profile parameters

      write (IOF,230) GammaAvg*PowerFactor*DoseFactor*GammaFactor,
     +                NeutAvg*PowerFactor*DoseFactor
230   format(/5x,'Gamma Dose Rate Multiplier      = '1pe14.5' rad/s'
     +       /5x,'Neutron Dose Rate Multiplier    = ' e14.5' rad/s')

      if ((GammaAvg.gt.0.d0).and.(GammaInMode.eq.polynomial)) then
        write (IOF,300) 
        write (IOF,310) (i,GammaCoef(i),i=0,MaxOrdGamma)
      elseif ((GammaAvg.gt.0.d0).and.(GammaInMode.eq.dataPoints)) then
        write (IOF,301) 
        write (IOF,311) (i,GammaCoef(i),i=0,MaxOrdGamma-1)
      endif
300   format(/5x'Gamma Dose Profile Polynomial Coefficients')
310   format( 5x'Gamma Dose Coefficient    'i3,3x'= '1pe14.5)
301   format(/5x'Gamma Dose Profile Data Points')
311   format (5x'Gamma Dose Profile Data   'i3,3x'= '1pe14.5)

252   if ((NeutAvg.gt.0.d0).and.(NeutInMode.eq.polynomial)) then
        write (IOF,320) 
        write (IOF,330) (i,NeutCoef(i),i=0,MaxOrdNeut)
      elseif ((NeutAvg.gt.0.d0).and.(NeutInMode.eq.dataPoints)) then
        write (IOF,321) 
        write (IOF,331) (i,NeutCoef(i),i=0,MaxOrdNeut)
      endif
320   format(/5x'Neutron Dose Profile Polynomial Coefficients')
330   format( 5x'Neutron Dose Coefficient  'i3,3x'= '1pe14.5)
321   format(/5x'Neutron Dose Profile Data Points')
331   format( 5x'Neutron Dose Data 'i3,3x'= '1pe14.5)

c  write power, void fraction, or quality profile

245   if ((FlowModel.eq.Chexal).and.(PowerAvg.gt.0.d0)) then
        if (PowerInMode.eq.polynomial) then
          write (IOF,360)
          write (IOF,370) (i,PowerData(i),i=0,NPowerData)
        else
          write (IOF,361)
          write (IOF,371) (i,PowerData(i),i=0,NPowerData-1)
        endif
      elseif (FlowModel.eq.BankoffVoid) then
        if (VoidInMode.eq.polynomial) then
          write (IOF,340) 
          write (IOF,350) (i,VoidCoef(i),i=0,MaxOrdVoid)
        else
          write (IOF,341) 
          write (IOF,351) (i,VoidCoef(i),i=0,MaxOrdVoid-1)
        endif
      elseif (FlowModel.eq.BankoffQual) then
        if (QualInMode.eq.polynomial) then
          write (IOF,342) 
          write (IOF,352) (i,QualCoef(i),i=0,MaxOrdQual)
        else
          write (IOF,343) 
          write (IOF,353) (i,QualCoef(i),i=0,MaxOrdQual)
        endif
      endif
360   format(/5x'Power Profile Polynomial Coefficients')
370   format (5x'Power Coefficient 'i3,3x'= '1pe14.5)
361   format(/5x'Power Profile Data Points')
371   format (5x'Power Profile Data        'i3,3x'= '1pe14.5)
340   format(/5x'Void Fraction Polynomial Coefficients')
350   format (5x'Void Fraction Coefficient 'i3,3x'= '1pe14.5)
341   format(/5x'Void Fraction Data Points')
351   format (5x'Void Fraction Data        'i3,3x'= '1pe14.5)
342   format(/5x'Quality Profile Polynomial Coefficients')
352   format (5x'Quality Coefficient       'i3,3x'= '1pe14.5)
343   format(/5x'Quality Profile Data Points')
353   format (5x'Quality Data              'i3,3x'= '1pe14.5)

c  write component control flags

      if (FlowModel.eq.SinglePhaseFlow) then
        FlowModelName='Single Phase'
      elseif (FlowModel.eq.Chexal) then
        FlowModelName='Chexal-Lellouche'
      elseif (FlowModel.eq.BankoffVoid) then
        FlowModelName='Bankoff w/ Void Fraction Input'
      elseif (FlowModel.eq.BankoffQual) then
        FlowModelName='Bankoff w/ Quality Input'
      endif

      if(ECPModel.eq.'EPRI') then
         ECPModelName ='EPRI BWR ECP Model'
      elseif(ECPModel.eq.'PSS304') then
         ECPModelName ='Mixed Potential PWR- 304SS'
      elseif(ECPModel.eq.'PAll600') then
         ECPModelName ='Mixed Potential PWR-Alloy 600'
      elseif(ECPModel.eq.'PAll690') then
         ECPModelName ='Mixed Potential PWR-Alloy 690'
      else 
         ECPModelName ='ECP Not Calculated'
      endif
      
      if(pHMode.eq.'pHInput') then
         pHModelName='pH as input'
      elseif(pHMode.eq.'BLiCalc') then
         pHModelName='Calculate from B and Li'
      elseif(pHMode.eq.'BWRCalc') then
         pHModelName = 'Calculate from H+ concentration'
      endif

      write (IOF,256) SurfComp,SensComp,WriteRx,WritePara,
     +                RadHeat,ThermoModel,FlowModelName,
     +                ECPModelName,pHModelName
256   format(/5x,'Calc H2O2 Surface Decomposition = 'l8
     +       /5x,'Evaluate Sensitivity For Comp   = 'l8
     +       /5x,'Write Rx Set w/Adjust RateConst = 'l8
     +       /5x,'Write Thermalhydraulics         = 'l8
     +       /5x,'Calculate Nuclear Heating       = 'l8
     +       /5x,'Thermodynamics Model            = 'i8
     +       /5x,'Thermalhydraulic Model          = 'a30
     +       /5x,'ECP Model                       = 'a30
     +       /5x,'pH determined from              = 'a30)

c  write DLSODE tolerances

      write (IOF,250) ATol,RTol
      if (SensLoop.and.SensComp) write (IOF,255) AdjATol,AdjRTol,
     +                                           ResATol,ResRTol
250   format(/5x,'Radiolysis Absolute Tolerance   = '1pe14.5
     +       /5x,'           Relative Tolerance   = 'e14.5)
255   format (5x,'Adjoint    Absolute Tolerance   = '1pe14.5
     +       /5x,'           Relative Tolerance   = 'e14.5
     +       /5x,'Response   Absolute Tolerance   = 'e14.5
     +       /5x,'           Relative Tolerance   = 'e14.5)

c  write temperature adjusted rate constants

      if (WriteRx) then
        call Arrhenius  !x=0.d0
        write (IOF,292) FF
        write (IOF,10) CompName(IComp)
        write (IOF,290)
        write (IOF,11)
        do 160 i=1,NRx
cj          if (EA(i).ne.-1.d0) then
            write(IOF,111) RxName(i),(SpeciesName(IR(i,k)),k=1,INR),
     +                    (SpeciesName(IP(i,k)),k=1,INP),
cj     +                     RateConst(i),dabs(EA(i))  
     +                     RateConst(i)  
cj          else
cj            write(IOF,115) RxName(i),(SpeciesName(IR(i,k)),k=1,INR),
cj     +                    (SpeciesName(IP(i,k)),k=1,INP),
cj     +                     RateConst(i),'Mass Tran'
cj          endif          
160     continue
      endif

10    format(/19x'Chemical Reactions For 'a16)
cj11    format(/26x'Reaction'30x'Rate'2x'Activation' !Jarvis changed output- no longer include activation energy  
cj     +       /62x'Constant'2x'Energies'
cj     +       /70x'(kJ/mol-K)'/)
11    format(/26x'Reaction'30x'Rate' /62x'Constant' /)
cj111   format(a3,1x,3a8'>'4a8,1pe9.2,1x,e9.2)
111   format(a3,1x,3a8'>'4a8,1pe9.2)
115   format(a3,1x,3a8'>'4a8,1pe9.2,1x,a9)

999   return
      end  !of WriteComp


      subroutine Radiolysis(RWork)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by CalcComp
c     Calls Concentration, WriteConc

c     Evaluates radiolysis of a component using DLSODE.
c***********************************************************************

      include 'radical.blk'
      real*8 RWork(*)

c  initialize for DLSODE

      Conc(0)=1.0d0             !assign zero-order rx
      call InitializeDLSODE(XLength,IWork,ConcRWork,RWork)
      x     = 0.d0
      XInc  = 0.d0

      if (SensLoop.and.SensComp) then
        XStep =XStep/SensStep
        Iter  = 1
      endif

c  initialize for stepping

      XOutput = XLength
      if (CycleOut(ICycle)) XOutput = 0.d0
      XPlot = XLength
      if (PlotOut.and.CyclePlot(ICycle)) XPlot = 0.d0
      XHWC = XLength
      HWCStep = XLength/2.d0
      if (CalcInject.and.(ICycle.eq.NCycle)) XHWC = 0.d0  ! change by Grover 4/30/96
c      if (CalcHWC.and.(ICycle.eq.NCycle)) XHWC = 0.d0
        
c**** main loop of radiolysis begins

280   call Concentration(x,XInc,RWork)

      do 100 i=1,NSp       !fix up concentrations to be nonnegative
        if (Conc(i).lt.0.d0) Conc(i)=0.d0
100   continue

      if (SensLoop.and.SensComp) then
        IArg=mod(Iter-1,SensStep)  !write only at original XStep
        if (((IArg.eq.0).or.(x.eq.XLength)).and.CycleOut(ICycle)) 
     +     call WriteConc(x)
        do 281, i=1,NSpecies   !save concentration curve for sensitivity calc
          ConcCurve(Iter,i)=Conc(i)
281     continue
        if (Debug(2)) call ScreenDisplay(18,[0],[x],nullMsg)
        Iter=Iter+1
      endif

      if (CalcInject.and.(ICycle.eq.NCycle).and.(XInc.eq.XHWC)) then     ! change by Grover 4/30/94
c      if (CalcHWC.and.(ICycle.eq.NCycle).and.(XInc.eq.XHWC)) then
        call WriteHWC(x)
        XHWC = XHWC + HWCStep
        if (XHWC.gt.XLength) XHWC=XLength
      endif
      
      if (CycleOut(ICycle).and.((XInc.eq.XOutput).or.(XInc.eq.XLength)))
     +  then
        if (iHWC.eq.1) call WriteConc(x)
        XOutput = XOutput + XStep
      endif
      
      if (PlotOut.and.CyclePlot(ICycle).and.
     +   ((XInc.eq.XPlot).or.(XInc.eq.XLength))) then
        if (iHWC.eq.1) call WritePlot(x)
        XPlot = XPlot + PlotStep
      endif
      
c  exit loop upon XLength or DLSODE error.

10    if (IState.lt.0) then
        return
      elseif (XInc.lt.XLength) then  !increment XInc and continue
        XInc = dmin1(XOutput,XPlot,XHWC,XLength)
c        XInc = dmin1(XOutput,XPlot,XHWC,XSens,XLength)
        goto 280
      endif

c**** continue through time steps until XLength

380   MaxIter=Iter-1

      return
      end  !of Radiolysis


      subroutine InitializeDLSODE(EndPoint,IWorkIn,RWorkIn,RWork)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by Radiolysis

c     The following optional inputs may be declared for each component
c     by setting IOpt=1.  See DLSODE writeup for more info.

c     RWork(5)  The step size to be attempted on the first step.
c               The default value is determined by the solver.
c     RWork(6)  The maximum absolute step size allowed.
c               The default value is infinite.
c     RWork(7)  The minimum absolute step size allowed.
c               The default value is 0.  (This lower bound is not
c               enforced on the final step before reaching tcrit
c               when itask = 4 or 5.)
c     IWork(5)  The maximum order to be allowed.  The default
c               value is 12 if meth = 1, and 5 if meth = 2.
c               If maxord exceeds the default value, it will
c               be reduced to the default value.
c               If maxord is changed during the problem, it may
c               cause the current order to be reduced.
c     IWork(6)  Maximum number of (internally defined) steps
c               allowed during one call to the solver.
c               the default value is 500.
c     IWork(7)  Maximum number of messages printed (per problem)
c               warning that t + h = t on a step (h = step size).
c               this must be positive to result in a non-default
c               value.  The default value is 10.
c***********************************************************************

      include 'radical.blk'
      real*8 EndPoint,RWorkIn(*),RWork(*)
      integer*4 IWorkIn(*)

      IState=1                  !this is the first call to DLSODE
      RWork(1)=EndPoint         !evaluate up to EndPoint
      do 100 i=5,7
        RWork(i)=RWorkIn(i)     !set RWork to user input
        IWork(i)=IWorkIn(i)     !set IWork to user input
100   continue
      IWork(11)=0               !reset # step counter
      IWork(12)=0               !reset # func eval counter
      IWork(13)=0               !reset # jacobian counter
      IWork(17)=0               !reset RWork size
      IWork(18)=0               !reset IWork size

      return
      end  !of InitializeDLSODE


      subroutine Concentration(x,XInc,RWork)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by Radiolysis.
c     Calls DLSODE for radiolysis evaluation.
c***********************************************************************

      include 'radical.blk'
      real*8 x,XInc,RWork(*)
      external DifEq,Jacob

280   call DLSODE(DifEq,NSp,Conc(1),x,XInc,ITol,RTol,ATol,ITask,
     +           IState,IOpt,RWork,LRW,IWork,LIW,Jacob,MF)

      if (IState.eq.-1) then    !DLSODE error - excessive work done
        IState=2
        call ScreenDisplay(8,[0],[0.d0],nullMsg)
        goto 280                !reset and try again
      elseif (IState.lt.0) then
        call ErrorDisplay(70,[0],[0.d0],nullMsg)
      endif

      return
      end  !of Concentration


      subroutine DifEq(n,x,ConcVec,dCdx)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by DLSODE
c     Calls DoseShape, ThermalHydro, Arrhenius

c     DifEq calculates the spatial mass balance differential equation:
c     dC/dx = Chemical Generation - Chemical Annihilation
c           + Generation By Radiation + Convection 
c           + Mass Transfer Between Gas And Liquid 
c***********************************************************************

      include 'radical.blk'
      real*8 ConcVec(*),dCdx(*) !ConcVec is equivalent to Conc

c  call property routines

      if (Debug(9)) call ScreenDisplay(19,[0],[x],nullMsg)  !entering DifEq...
      call DoseShape(x)
      call ThermalHydro(x)      !evaluate two-phase parameters
      call Arrhenius         !adjust rate constants at new temp

c  initialize for calc

      do 10 i=1,NSp             !make sure concentrations are nonnegative
        if (Conc(i).lt.0.d0) Conc(i)=0.d0
10    continue

      ConcH2O=1.d3*DensLiq/MolWtH2O !fix water concentrations to density
      Conc(IH2O)=ConcH2O            !it's H2O
      Conc(I2H2O)=ConcH2O*ConcH2O   !it's 2H2O
      
c  evaluate dC/dx.
c  outer loop iterates through all of the nodes, and the inner
c  loop iterates over the applicable reaction for each node.

      do 110 i=1,NSp
        dCdx(i) = 0.0d0         !initialize to zero
        if ((i.eq.IH2O).or.(i.eq.I2H2O)) goto 110   !skip H2O and 2H2O
        IC=index(SpeciesName(i),'G')  !see if the species is gas

c       calc chemical reaction and mass transfer between liquid and gas

        do 100 j=1,NRx
          if (Koef(j,i).eq.0) goto 100 
          if (RCMode(j).eq.'M') then ! change Jarvis
cJ          if (EA(j).eq.-1.d0) then  !adjust mass transfer rate
cJ            RateConst(j)=RCInit(j)*Void/(1.d0-Void)  !liquid
            RateConst(j)=RC(j,1)*Void/(1.d0-Void) ! added by Jarvis 
cJ            if ((IC.ne.0).and.(Boiling)) RateConst(j)=RCInit(j) !gas
            if ((IC.ne.0).and.(Boiling)) RateConst(j)=RC(j,1) !change Jarvis
          endif
          dCdx(i)=dCdx(i)+RateConst(j)*Koef(j,i)*
     +            Conc(IR(j,1))*Conc(IR(j,2))*Conc(IR(j,3))
100     continue

c       calc irradiation and convection terms

        GConvert=ucGValue*DensLiq !convert from #species/100ev to moles/l-rad
        if (IC.eq.0) then         !liquid 

c  ********************************************************************************
c
c   Beginning of Changes to RADICAL made by D. Grover on 12/30/95
c
c   Concentration of species in liquid phase adjusted for variable pipe area.
c   Original equations commented out with modified equations immediately following.
c
c          dCdx(i)=(dCdx(i)+GGamma(i)*GConvert*Gamma
c    +                    +GNeut(i)*GConvert*Neutron
c    +            -Conc(i)*(dVLdx-VelLiq/(1.d0-Void)*dVFdx))
c    +            /VelLiq

           dCdx(i)=(dCdx(i)+GGamma(i)*GConvert*Gamma
     +                    +GNeut(i)*GConvert*Neutron
     +                    +GAlpha(i)*GConvert*Alpha ! added jarvis 10/26/12 
     +            -Conc(i)*(dVLdx-VelLiq/(1.d0-Void)*dVFdx
     +            +VelLiq/Area*dAdx))/VelLiq
c
c   End of Changes to RADICAL made by D. Grover on 12/30/95
c
c  ********************************************************************************

        elseif (VelGas.gt.0.d0) then  !gas

c  ********************************************************************************
c
c   Beginning of Changes to RADICAL made by D. Grover on 12/30/95
c
c   Concentration of species in gas phase adjusted for variable pipe area.
c   Original equations commented out with modified equations immediately following.
c
c
c          dCdx(i)=(dCdx(i)-Conc(i)*(dVGdx+VelGas/Void*dVFdx))
c    +            /VelGas      
c
           dCdx(i)=(dCdx(i)-Conc(i)*(dVGdx+VelGas/Void*dVFdx
     +            +VelGas/Area*dAdx))/VelGas      
c
c   End of Changes to RADICAL made by D. Grover on 12/30/95
c
c  ********************************************************************************

        endif
        if (Debug(10)) call ScreenDisplay(20,[0],[dCdx(i)],nullMsg)
110   continue  !through all species

      return
      end  !of DifEq


      subroutine DoseShape(x)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by DifEq

c     Evaluate dose rates as a function of travel up the channel
c     Takes the MaxOrder-th polynomial-coefficient array
c     GammaCoef and NeutCoef and evaluate the doesrates at x
c     for Gamma and Neutron.
c***********************************************************************

      include 'radical.blk'
      
      Gamma=Evaluate(x,XLength,GammaCoef,MaxOrdGamma,GammaInMode,0)
      Neutron=Evaluate(x,XLength,NeutCoef,MaxOrdNeut,NeutInMode,0)
      Alpha=Evaluate(x,XLength,AlphaCoef,MaxOrdAlpha,AlphaInMode,0) !added by Jarvis

      Gamma=GammaAvg*Gamma*PowerFactor*DoseFactor*GammaFactor     !Total doserate is this product
      Neutron=NeutAvg*Neutron*PowerFactor*DoseFactor
      Alpha=AlphaAvg*Alpha*PowerFactor*DoseFactor         !added by Jarvis 10/25/12

      if (Gamma.lt.0.0d0) Gamma=0.0d0  !Doserate must be non-negative
      if (Neutron.lt.0.0d0) Neutron=0.0d0
      if (Alpha.lt.0.0d0) Alpha=0.0d0 ! added by Jarvis 10/25/12

      return
      end  !of DoseShape


      subroutine ThermalHydro(x)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by DifEq

c     Evaluate two-phase parameters using either Bankoff's equations
c     or Chexal-Lellouche equations.

c     930603 Chexal-Lellouche routines added by Davood
c***********************************************************************

      include 'radical.blk'

      real*8 Interpolate

c  find temperature, enthalpy, and liquid density

      P=Pressure*ucPressure     !MPa to psia
      if (ThermoModel.eq.TinTout) then  !Tin and Tout are input
        Temp=(TempOut-TempIn)/XLength*x+TempIn
        if ((XBoil.ge.0.d0).and.(XBoil.lt.XLength)) then
          if (.not.Boiling) then  !subcooled
            Temp=(TempOut-TempIn)/XBoil*x+TempIn
          else                    !saturated 
            Temp=TempOut
          endif
        endif
        TinF=(Temp-ZeroC)*1.8d0+32.d0
        H=HPT(P,TinF)           !get enthalpy @ P,TinF - retran call
        Enthalpy=H/ucEnthalpy   !Btu/lbm to J/g
      else                      !power profile is input
        Enthalpy=Interpolate(x,EnthStep,Enth(0),NPowerData,0)
        H=Enthalpy*ucEnthalpy	!J/g to Btu/lbm
        Temp=(TPHL(P,H)-32.d0)/1.8d0+ZeroC !F to K
      endif
      DensLiq=1.d0/VPHL(P,H)/ucDensity   !lbm/ft3 to g/cc
      
c  use the correct thermalhydraulics model

      if (FlowModel.eq.SinglePhaseFlow) then  !it's single phase
        call SinglePhase(x)
      elseif (FlowModel.eq.Chexal) then       !it's Chexal-Lellouche
        if (Enthalpy.le.EnthLiq) then
          call SinglePhase(x)
        else
          call ChexalLellouche(x)
        endif
      elseif ((FlowModel.eq.BankoffVoid).or.(FlowModel.eq.BankoffQual))
     +  then  !it's Bankoff
        if (x.le.XBoil) then
          call SinglePhase(x)
        else
          call Bankoff(x)
        endif
      endif

      if (Debug(13)) call ScreenDisplay(21,[0],[0.d0],nullMsg)
     
      return
      end  !of ThermalHydro


      subroutine SinglePhase(x)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by ThermalHydro

c     Parameters for single phase flow.
c***********************************************************************

      include 'radical.blk'

      call AreaChange(x)     !  moved from block below 1/30/96 D.Grover

      Void=0.d0
      Quality=0.d0
      dVFdx=0.d0
      VelLiq=FlowRate/Area/DensLiq

c  ********************************************************************************
c
c   Beginning of Changes to RADICAL made by D. Grover on 12/30/95
c
c   Modify differential of liquid velocity to account for variable area.
c   Original equations commented out with modified equations immediately following.
c
c     dVLdx=0.d0

c      call AreaChange(x)
      dVLdx=-flowrate*dAdx/Area/Area/DensLiq
       
c   End of Changes to RADICAL made by D. Grover on 12/30/95
c
c  ********************************************************************************

      VelGas=0.d0
      dVGdx=0.d0
      Boiling=.false.
      
      do 10 i=1,NSp
        IC=index(SpeciesName(i),'G')  !see if the species is gas
        if (IC.ne.0) Conc(i)=0.d0     !set gas concentrations to zero
10    continue

      return
      end  !of SinglePhase

      subroutine AreaChange(x)

c***********************************************************************
c     Version:        radical 1.6          25 Jan 1995
c     Author:         David J. Grover
c***********************************************************************
c     Called by SinglePhase and ChexalLellouche
c
c     Evaluate the change in area between nodes.
c
c***********************************************************************

      include 'radical.blk'

      if(AreaOut.eq.0) then
         Area=AreaIn
         dAdx=0.d0
      else   
         if(AreaIn.gt.AreaOut) then
            dAdx=-(AreaIn-AreaOut)/XLength
            Area=AreaIn+dAdx*x
            Diameter = (Area*4.d0/3.14159)**0.5
         elseif(AreaIn.lt.AreaOut) then
            dAdx=(AreaOut-AreaIn)/XLength
            Area=AreaIn+dAdx*x
            Diameter = (Area*4.d0/3.14159)**0.5
         elseif(AreaIn.eq.AreaOut) then
            dAdx=0.d0
            Area=AreaIn
         endif
      endif
c      dAdx=(AreaOut-AreaIn)/XLength
c
c      if(dAdx.ne.0) Area=AreaIn+dAdx*x


      return
      end    !of AreaChange         

      subroutine ChexalLellouche(x)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by ThermalHydro

c     Evaluate two-phase parameters using Chexal-Lellouche equations.

c     930603 Chexal-Lellouche routines added by Davood
c***********************************************************************

      include 'radical.blk'

C  CHANGES MADE BY DAVOOD    930608
      real*8 JF,JG
      COMMON /GLENN/JF,JG,GVOID(2),GVJG(2),GCZ(2),GQUAL(2)
c  end of changes made by Davood

      if (Debug(14)) call ScreenDisplay(9,[0],[x],nullMsg)
      if (Debug(12)) call ScreenDisplay(10,[0],[0.d0],nullMsg)

      Quality=(Enthalpy-EnthLiq)/(EnthGas-EnthLiq)
      if (Quality.le.QualMin) then  !help numerical convergence
        call SinglePhase(x)
        return
      endif

      Boiling=.true.
      Temp=TempSat
      DensLiq=DensLiqSat
      
c  calculate void fraction by calling Chexal-Lellouche routine

      call AreaChange(x)


      JF=FlowRate*(1.d0-Quality)/DensLiq/Area*ucLength
      JG=FlowRate*Quality/DensGas/Area*ucLength
      call GLENNS
      Void=GVOID(1)
      C0=GCZ(1)                 !gas concentration parameter
      Vgj=GVJG(1)/ucLength      !drift velocity, ft/s to cm/s
      
c  calculate liquid and gas velocities and derivatives

      VelLiq=FlowRate*(1.d0-Quality)/Area/DensLiq/(1.d0-Void)
      VelGas=FlowRate*Quality/Area/DensGas/Void      
      Power=PowerAvg*PowerFactor
     +     *Evaluate(x,XLength,PowerData,NPowerData,PowerInMode,0)
      dQdx=Power/XLength/FlowRate/(EnthGas-EnthLiq) 

c  ********************************************************************************
c
c   Beginning of Changes to RADICAL made by D. Grover on 12/30/95
c
c   Call subroutine AreaChange to get dAdx
c   Modify differentials of gas and liquid velocities and void fraction to account
c   for variable area.
c   Original equations commented out with modified equations immediately following.

c      call AreaChange(x)
c
c     dVFdx=Void*Void/Quality/Quality*(C0*DensGas/DensLiq
c    +     +DensGas*Vgj*Area/FlowRate)*dQdx

      dVFdx=Void*Void/Quality/Quality*(C0*DensGas/DensLiq
     +     +DensGas*Vgj*Area/FlowRate)*dQdx
     +     -FlowRate*Quality*dAdx/DensGas/Area/Area/Vgj

c     dVLdx=VelLiq*dVFdx/(1.d0-Void)
c    +     -FlowRate*dQdx/Area/DensLiq/(1.d0-Void)

      dVLdx=VelLiq*dVFdx/(1.d0-Void)
     +     -FlowRate*dQdx/Area/DensLiq/(1.d0-Void)
     +     -VelLiq*dAdx/Area

c     dVGdx=-VelGas*dVFdx/Void+FlowRate*dQdx/Area/DensGas/Void

      dVGdx=-VelGas*dVFdx/Void+FlowRate*dQdx/Area/DensGas/Void
     +     -VelGas*dAdx/Area

c   End of Changes to RADICAL made by D. Grover on 12/30/95
c
c  ********************************************************************************

      return
      end  !of ChexalLellouche


      subroutine Bankoff(x)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by DifEq

c     Evaluate two-phase parameters using Bankoff's equations.

c***********************************************************************

      include 'radical.blk'

      if (FlowModel.eq.BankoffVoid) then      !void fraction is input
        dVFdx=Evaluate(x,XLength,VoidCoef,MaxOrdVoid,VoidInMode,1)
        Void=Evaluate(x,XLength,VoidCoef,MaxOrdVoid,VoidInMode,0)
        Quality=1.d0/((FlowPara/Void-1.d0)*DensLiq/DensGas+1.d0)
      elseif (FlowModel.eq.BankoffQual) then  !quality is input
        Quality=Evaluate(x,XLength,QualCoef,MaxOrdQual,QualInMode,0)
        Void=FlowPara/(1.d0-DensGas/DensLiq*(1.d0-1.d0/Quality))
        dQdx=Evaluate(x,XLength,QualCoef,MaxOrdQual,QualInMode,1)
        dVFdx=Void*Void/FlowPara*DensGas/DensLiq/Quality/Quality*dVFdx
      endif
      
      if (Quality.le.QualMin) then  !help numerical convergence
        call SinglePhase(x)
        return
      endif

      Boiling=.true.
      Temp=TempSat
      DensLiq=DensLiqSat

100   SlipRatio=(1.d0-Void)/(FlowPara-Void)
      VelLiq=VelInlet/(Void*(DensGas/DensLiq*SlipRatio-1.d0)+1.d0)
      VelGas=SlipRatio*VelLiq
      dSRdx=dVFdx/(FlowPara-Void)*(SlipRatio-1.d0)
      dVLdx=-VelLiq*VelLiq/VelInlet
     +      *(dVFdx*(DensGas/DensLiq*SlipRatio-1.d0)
     +      +Void*DensGas/DensLiq*dSRdx)
      dVGdx=dSRdx*VelLiq+SlipRatio*dVLdx

      return
      end  !of Bankoff


      subroutine Arrhenius

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by DifEq

c     Use Arrhenius' law to correct rate constants at new temp.
c     Temperature is evaluated along the path by interpolating TInlet
c     and TOutlet linearly. But temperature is kept constant in the
c     boiling region, temperature rising only up to the onset of 
c     boiling to TOut.

      include 'radical.blk'
      real*8 kAct,kDif
      real*8 kH2O, kH2O2,kOH,kHO2,kH
      

c     calculate the equilibrium constants needed for the AEC reaction set
      TC = Temp - 273.15 !temp in celsius, needed for calculating the equilibrium constants
      kH2O = 10**(-16.69+4.262e-2*TC-2.071e-4*TC**2+5.594e-7*TC**3
     +      -7.161e-10*TC**4)
      kH2O2 = 10**(-12.383+3.02e-2*TC-1.700e-4*TC**2+5.151e-7*TC**3
     +      -6.960e-10*TC**4)
      kOH = kH2O2
      kHO2 = 10**(-4.943+6.230e-3*TC-4.125e-5*TC**2+8.182e-9*TC**3)
      kH = 10**(-10.551+4.43e-2*TC-1.902e-4*TC**2+4.661e-7*TC**3
     +      -5.980e-10*TC**4)

      ConcH2O=1.d3*DensLiq/MolWtH2O
      do 277 i=1,NRx            !don't evaluate if same temp as before
        if (RCMode(i).eq.'A') then ! added jjarvis
          RateConst(i)=dabs(RC(i,1))*dexp(-dabs(RC(i,2))/GasConst*
     +                 (1.d0/Temp-1.d0/TempRef))
          if (WaterImplicit.and.(RC(i,1).lt.0.d0)) !1st-order in H2O
     +        RateConst(i)=RateConst(i)*ConcH2O
          if (WaterImplicit.and.(RC(i,2).lt.-1.d0))    !2nd-order in H2O
     +        RateConst(i)=RateConst(i)*ConcH2O            
        elseif (RCMode(i).eq.'M') then
	  RateConst(i)=RC(i,1)
        else ! currently the only other form is the polynomial form, and the variations of it 
	   Const=10**(RC(i,1)+RC(i,2)/Temp+RC(i,3)/(Temp**2)
     +         +RC(i,4)/(Temp**3)+RC(i,5)/(Temp**4))	
           if(RCMode(i).eq.'P') RateConst(i) = Const 
	   if(RCMode(i).eq.'Q') RateConst(i) = Const*kH2O
	   if(RCMode(i).eq.'R') RateConst(i) = Const*kH2O/kOH
	   if(RCMode(i).eq.'S') RateConst(i) = Const*kHO2
	   if(RCMode(i).eq.'T') RateConst(i) = Const*kH2O2
	   if(RCMode(i).eq.'U') RateConst(i) = Const*kOH
	   if(RCMode(i).eq.'V') RateConst(i) = Const*kH2O/kH2O2
	   if(RCMode(i).eq.'W') RateConst(i) = Const*kH2O/kHO2
	   if(RCMode(i).eq.'X') RateConst(i) = Const*kH
	   if(RCMode(i).eq.'Y') RateConst(i) = Const*kH2O/kH
      endif
277   continue

c  hydrogen peroxide surface decomposition reaction

c  Ref:  C.C. Lin;"Decomposition of Hydrogen Peroxide in BWR Coolant
c  Circuit", Water Chemistry of Nuclear Reactor Systems 6, BNES, London,
c  1992, pp. 85-88.

      if (SurfLoop.and.SurfComp.and.(NSurfRx.gt.0)) then
        do 120 i=NRx-NSurfRx+1,NRx
          if (RxName(i).eq.Surface) then
            kAct=RateConst(i)/Diameter  !diffusion controlled
            kDif=0.092d0*(Diffusion**0.5d0)/(Viscosity**0.3d0)
     +           *(VelLiq**0.8d0)/(Diameter**1.2d0)
c           ge 1996 correlation from KRamp memo
            Diffusion = 5.d-4
               RateConst(i)=1.5d0/Diameter/((1.58*dlog(VelLiq*Diameter*
     +         DensLiq/Viscosity)-3.28)**2)*VelLiq*(Viscosity/DensLiq/
     +         Diffusion-0.6666)
c        end of 1996 GE correlation
c            RateConst(i)=1.d0/(1.d0/kDif+1.d0/kAct)
          else
            RateConst(i)=0.d0     !no surface decompostion reaction
          endif
120     continue
      endif

      return
      end  !of Arrhenius


      subroutine Jacob(n,x,ConcVec,ML,MU,Jac,NRowJac)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by DLSODE

c     Jacob calculates the full jacobian matrix of dC/dx.
c***********************************************************************

      include 'radical.blk'
      real*8 Jac(NRowJac,*),ConcVec(*)  !ConcVec is equiv to  Conc

      do 100 j=1,NSp

c       chemical reaction and mass transfer terms

        do 101 i=1,NSp
          Jac(i,j)=0.0d0
          if ((i.eq.IH2O).or.(i.eq.I2H2O)) goto 101   !skip H2O and 2H2O
          IC=index(SpeciesName(i),'G')  !see if the species is gas
          do 102 k=1,NRx
            if((Koef(k,j).ge.0).or.(Koef(k,i).eq.0)) goto 102
cJ            if (EA(k).eq.-1.d0) then    !adjust mass transfer rate
cJ              RateConst(k)=RCInit(k)*Void/(1.d0-Void)
cJ              if ((IC.ne.0).and.Boiling) RateConst(k)=RCInit(k)
            if (RCMode(k).eq.'M') then    !adjust mass transfer rate
              RateConst(k)=RC(k,1)*Void/(1.d0-Void)
              if ((IC.ne.0).and.Boiling) RateConst(k)=RC(k,1)
            endif
            RCT=RateConst(k)*Koef(k,i)

            if(Koef(k,j).eq.-2)then      !second-order reactant
              Jac(i,j)=Jac(i,j)+2.d0*RCT*Conc(IR(k,1))*Conc(IR(k,3))
            elseif (IR(k,1).eq.j) then  !first-order reactant
              Jac(i,j)=Jac(i,j)+RCT*Conc(IR(k,2))*Conc(IR(k,3))
            elseif (IR(k,2).eq.j) then
              Jac(i,j)=Jac(i,j)+RCT*Conc(IR(k,1))*Conc(IR(k,3))
            else
              Jac(i,j)=Jac(i,j)+RCT*Conc(IR(k,1))*Conc(IR(k,2))
            endif
102       continue
          Jac(i,j)=Jac(i,j)/VelLiq
101     continue

c       convection terms
c  ******************************************************************************
c
c   Change made 6/5/96 by David J. Grover
c   Change to update Jacobian for variable area components
c   revised code is immediately followed by the original code.
c
        IC=index(SpeciesName(j),'G')
        if (IC.eq.0) then       !liquid
          Jac(j,j)=Jac(j,j)-dVLdx/VelLiq+dVFdx/(1.d0-Void)+DAdx/Area
        elseif (Void.gt.0.d0) then  !Gas
          Jac(j,j)=(Jac(j,j)*VelLiq-dVGdx)/VelGas-dVFdx/Void-DAdx/Area
        endif

c        IC=index(SpeciesName(j),'G')
c        if (IC.eq.0) then       !liquid
c          Jac(j,j)=Jac(j,j)-dVLdx/VelLiq+dVFdx/(1.d0-Void)
c        elseif (Void.gt.0.d0) then  !Gas
c          Jac(j,j)=(Jac(j,j)*VelLiq-dVGdx)/VelGas-dVFdx/Void
c        endif
c
c  *****************************************************************************

100   continue

      return
      end  !of Jacob


      subroutine WriteConc(x)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by Radiolysis

c     Writes concentration at each step to output file.
c***********************************************************************

      include 'radical.blk'
      real*8 x,Coef(ISP)

      call ThermalHydro(x)
      if(ECPModel.eq.'EPRI') then ! changed by Jarvis 11/12 to allow for different ECP models
        call Potential   !Added by grover 2/7/96
      else 
        call MixedPotential(.false.,x)
      endif
c  write to output file

      write (IOF,290)
      do 100 i=1,NSpecies
        Coef(i)=1.0d0
        IC=index(SpeciesName(i),'G')  !see if the species is gas
        if (ConcOutMode.eq.ppb) then    !convert to ppb
          Coef(i)=MolWt(i)*1.0d6/DensLiq
          if (IC.ne.0) Coef(i)=MolWt(i)*1.0d6/DensGas  !gas 
        endif
100   continue

      write (IOF,130) ICycle,CompName(IComp),x
      write (IOF,110) ConcOutUnit,x+XIn
      write (IOF,320) (SpeciesName(i),Coef(i)*Conc(i),i=1,NSpecies)

290   format (80('_'),/)
110   format (12x'   Concentrations'a10' at Position = 'f11.4' cm'/)
130   format (5x'Cycle'i5,8x'Position in 'a16' = 'f11.4' cm')
320   format (2(5x,a8' = '1pe15.6' **'))

c  write ECP using C.C.Lin's correlation,p S-3, EPRI NP-7033, 1991

c      write(IOF,342) 'ECP     ',ECP()
      if(ECPModel.eq.'EPRI') then  !change by Jarvis (VelRCE only needed for EPRI correlation)
        write(IOF,342) 'RCE Velocity',VelRCE ,'  rpm'
      else
        write(IOF,342) 'pH',pH,' '
        if(pHMode.eq.'BLiCalc') then
          write(IOF,343) 'Total Boron',Btot,' ppm'
          write(IOF,343) 'Total Li',Litot,' ppm'
        endif
      endif
      write(IOF,342) 'ECP     ',ECP ,'  mV'     !changed by grover 2/7/96
342   format(/5x,a15,' = ',f15.6,a8)
343   format(/5x,a15,' = ',f15.1,a8)
      
c  write gas partial pressure in MPa

      if (Boiling) then
        write (IOF,*)
        do 340 i=1,NSp
          IC=index(SpeciesName(i),'G')
          if (IC.ne.0) then !find partial pressure assuming ideal gas
            PartialPressure=Conc(i)*MolWtH2O*1.d-3/DensGas*Pressure
            write(IOF,330) SpeciesName(i),PartialPressure
          endif
340     continue
      endif
330   format(5x,a8,' = ',1pe15.6,' MPa')
      
c  write parameters at x

350   if (WritePara) then
        call DoseShape(x)
        call ThermalHydro(x)      !evaluate two-phase parameters
        call Arrhenius
        Power=PowerAvg*PowerFactor
     +       *Evaluate(x,XLength,PowerData,NPowerData,PowerInMode,0)
        write (IOF,300) IWork(11),Temp,Power,Enthalpy,DensLiq
        if (Boiling) write (IOF,305) DensGas
        write (IOF,306) VelLiq,Area,dAdx,x,dVLdx
        if (Boiling) write (IOF,304) VelGas,Void,Quality
        write (IOF,303) Gamma,Neutron,Alpha ! change jarvis added alpha
      endif
300   format(/5x'No. Steps           = 'i8
     +       /5x'Temperature         = 'f14.5' Kelvin'
     +       /5x'Power               = '1pe14.5' watts'
     +       /5x'Enthalpy            = '0pf14.5' J/g'
     +       /5x'Liquid Density      = 'f14.5' g/cc')
305   format( 5x'Gas Density         = 'f14.5' g/cc')
306   format( 5x'Liquid Velocity     = 'f14.5' cm/s'
     +       /5x'Area                = 'f14.5' cm^2'
     +       /5x'dAdx                = 'f14.5' cm'
     +       /5x'x                   = 'f14.5' cm'
     +       /5x'dVLdx               = 'f14.5' /s')
304   format( 5x'Gas Velocity        = 'f14.5' cm/s'
     +       /5x'Void Fraction       = 'f14.5
     +       /5x'Quality             = 'f14.5)
303   format( 5x'Gamma Dose Rate     = '1pe14.5' rad/s'
     +       /5x'Neutron Dose Rate   = ' e14.5' rad/s'
     +       /5x'Alpha Dose Rate     = ' e14.5' rad/s') !jarvis added alpha

      return
      end  !of WriteConc


      subroutine WritePlot(x)

c***********************************************************************
c     Version:        radical 1.6          10 Aug 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by Radiolysis

c     Writes concentration at each step to plot file.
c     Output format for PlotFile has been modified for Macintosh-based
c     plotting method. KaleidaGraph plotting application is recommended
c     for plotting concentration results from PlotFile.
c     v1.11 note: the exponent d is changed to e for concentrations for
c     easier import to KaleidaGraph. 9/13/91 chun
c***********************************************************************

      include 'radical.blk'
      real*8 x,Coef(ISP)

      if ((ICycle.gt.1).and.(ICycle.lt.NCycle)) return
c	 !write first & last cycles only  !added 6/5/96 to make plot file a managable size
      call DoseShape(x)
      call ThermalHydro(x)      !evaluate two-phase parameters
      call Arrhenius 
      if(ECPModel.eq.'EPRI') then ! changed by Jarvis to allow for other ECP models
        call Potential   !Added by grover 2/7/96
      else 
        call MixedPotential(.true.,x)
      endif      
      Power=PowerAvg*PowerFactor
     +     *Evaluate(x,XLength,PowerData,NPowerData,PowerInMode,0)
      
c  write to plot file          2/18/91 chun

      do 100 i=1,NSpecies
        Coef(i)=1.0d0
        IC=index(SpeciesName(i),'G')  !see if the species is gas
        if (ConcOutMode.eq.ppb) then  !convert to ppb
          Coef(i)=MolWt(i)*1.0d6/DensLiq
          if (IC.ne.0) Coef(i)=MolWt(i)*1.0d6/DensGas  !gas 
        endif
100   continue

      write (IPF,460) ICycle,Tab,CompName(IComp),Tab,XIn+x,
     +  (Tab,Coef(i)*Conc(i),i=1,NSpecies),
c     +  Tab,ECP(),Tab,Temp,Tab,Power,Tab,Enthalpy,   ! Change by Grover 2/7/96
     +  Tab,ECP,Tab,Temp,Tab,Power,Tab,Enthalpy,
     +  Tab,DensLiq,Tab,DensGas,
     +  Tab,VelLiq,Tab,VelGas,Tab,Void,Tab,Quality,
     +  Tab,Gamma,Tab,Neutron,Tab,Alpha !jarvis, added alpha
460   format (i5,a,a16,999(a,1pe10.3))

      return
      end  !of WritePlot


      subroutine WriteHWC(x)

c***********************************************************************
c     Version:        radical 1.6          10 Aug 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by Radiolysis

c     Writes concentration at each step to HWC file.
c***********************************************************************

      include 'radical.blk'
      real*8 x,Coef(ISP)

      call ThermalHydro(x)
      if(ECPModel.eq.'EPRI') then  !changed by Jarvis  
        call Potential   !Added by grover 2/7/96
      else 
        call MixedPotential(.false.,x)
      endif

c  write to HWC file

      do i=1,NSp
        Coef(i)=1.0d0
        IC=index(SpeciesName(i),'G')  !see if the species is gas
        if (ConcOutMode.eq.1) then    !convert to ppb
          Coef(i)=MolWt(i)*1.0d6/DensLiq
          if (IC.ne.0) Coef(i)=MolWt(i)*1.0d6/DensGas  !gas 
        elseif (ConcOutMode.eq.2) then  !normalize to density
          Coef(i)=1.0d0/DensLiq
          if (IC.ne.0) Coef(i)=1.0d0/DensGas           !gas 
        endif
      enddo

c      write (IHF,460) HWCInject(iHWC),Tab,CompName(IComp),Tab,XIn+x,
      write (IHF,460) Inject(iHWC),Tab,CompName(IComp),Tab,XIn+x,  ! Change by Grover 4/30/96
c     +  (Tab,Coef(i)*Conc(i),i=1,NSp),Tab,ECP()
     +  (Tab,Coef(i)*Conc(i),i=1,NSp),Tab,ECP    ! Change by Grover  2/7/96
460   format (f10.3,a,a16,999(a,1pe10.3))

      return
      end  !of WriteHWC


c      real*8 function ECP()    
c
c***********************************************************************
c     Version:        radical 1.6          14 Aug 1993
c     Author:         John H. Chun
c***********************************************************************
c     find ECP using C.C.Lin's correlation,p S-3, EPRI NP-7033, 1991
c***********************************************************************
c
c      include 'radical.blk'
c
c      ECP=-9999.d0   !some ridiculous number 950605 chun
c      do i=1,NSp
c        if (SpeciesName(i).eq.'O2') then
c          O2ppb=Conc(i)*MolWt(i)*1.d6/DensLiq
c          if (O2ppb.gt.0.d0) ECP=174.d0*dlog(O2ppb)-400.d0  !modified 950605 chun
c        endif
c      enddo
c      
c      return
c      end  !of ECP


      Subroutine Potential

c***********************************************************************
c     Version:        radical 1.6          7 Feb 1996
c     Author:         David J. Grover
c***********************************************************************
c
c     find ECP using CC Lin et. al. GE Correlation from EPRI Draft Report
c     Prediction of Electrochemical Corrosion Potentials in BWR
c     Primary Systems, Volume 2. EPRI# ********
c
c***********************************************************************

      include 'radical.blk'

      real*8 ConcH2, ConcH2O2, ConcO2, Concen, SumConc, VelRCE
c      real*8 Slope
      real*8 H2O2C1, H2O2C2, H2O2C3, H2O2C4, H2O2C5 
      real*8 O2C1, O2C2, O2C3, O2C4, O2C5
      real*8 H2O2ECP, O2ECP, ConcECP, ECPTest 
      integer j

      ECP=-9999.d0
      H2O2ECP=-9999.d0     !initilize at out of scale number
      O2ECP=-9999.d0
      ConcH2O2=1.0d-6
      ConcH2=1.0d-6
      ConcO2=1.0d-6
c
c  Pull the concentrations of the relevent chemical species and convert to ppb
c
      do i=1,Nsp
         if (SpeciesName(i).eq.'O2') then
            ConcO2=Conc(i)*MolWt(i)*1.d6/DensLiq
c            Slope=dCdx(i)
         elseif (SpeciesName(i).eq.'H2') then
            ConcH2=Conc(i)*MolWt(i)*1.d6/DensLiq
         elseif (SpeciesName(i).eq.'H2O2') then
            ConcH2O2=Conc(i)*MolWt(i)*1.d6/DensLiq
         endif
      enddo
c
c   If any concentrations are equal to zero initilize at a small number to prevent log(0) run time errors

      if (ConcH2.eq.0.d0) ConcH2=1.0d-6
      if (ConcH2O2.eq.0.d0) ConcH2O2=1.0d-6
      if (ConcO2.eq.0.d0) ConcO2=1.0d-6

c
c   Convert the liquid velocity to equivalent RCE electrode velocity used in the ECP correlation

      VelRCE= 3.01d0*dexp(0.425d0+1.25d0*dlog(VelLiq)
     +        -0.179d0*dlog(Diameter))
     
c
c   Calculate the correlation constants

c      For Hydrogen Peroxide

      H2O2C5=-4.62d0*ConcH2**0.808d0/dexp(0.00280d0*ConcH2)
     +        +1.50d0*VelRCE**0.5d0-192.d0
      H2O2C4=25.33d0
      H2O2C3=0.569d0
      H2O2C2=0.00574d0*ConcH2**0.772d0-0.00754d0*VelRCE**0.5d0+0.811d0  
      H2O2C1=H2O2C5+510.d0

c      For Oxygen               GE report on ten plants did not differentiate between increasing
c                               and decreasing O2 concentrations     

c      if (Slope.ge.0.d0)then  !for increasing O2 content
c         O2C3=1.37d0
c         O2C2=0.00531d0*ConcH2**0.772d0-0.0111d0*VelRCE**0.5d0+1.30d0
c      else                 !for decreasing O2 content
         O2C3=1.02d0
         O2C2=0.00531d0*ConcH2**0.772d0-0.0111d0*VelRCE**0.5d0+1.78d0
c      endif

         O2C5=-18.6d0*ConcH2**0.264d0-177.d0
         O2C4=18.7d0
         O2C1=O2C5+510.d0
      
c
c   Calculate the ECP for oxygen and hydrogen peroxide  separately

      H2O2ECP=H2O2C1*dtanh((dlog10(ConcH2O2)-H2O2C2)/H2O2C3)
     +        +H2O2C4*dlog10(ConcH2O2)+H2O2C5
        
      O2ECP=O2C1*dtanh((dlog10(ConcO2)-O2C2)/O2C3)
     +        +O2C4*dlog10(ConcO2)+O2C5

c  Determine equivalent concentration of species with the lowest ECP
c   to reoresent the species with the higher ECP

      Concen=0.1d0
      EqConc=0.1d0
      do i=1,10
         do j=10000,100000, 10000
            Concen=EqConc+j/(1.d1**i)
            if (H2O2ECP.ge.O2ECP) then
                ECPTest=H2O2ECP
                ConcECP=O2C1*dtanh((dlog10(Concen)-O2C2)/O2C3)
     +                +O2C4*dlog10(Concen)+O2C5
            else
                ECPTest=O2ECP
                ConcECP=H2O2C1*dtanh((dlog10(Concen)-H2O2C2)/H2O2C3)
     +                  +H2O2C4*dlog10(Concen)+H2O2C5
            endif
            if (ECPTest.lt.ConcECP) goto 888
         enddo
888      EqConc=Concen-1.d4/(1.d1**i)
      enddo

c      Calculate the final ECP by adding the equivalent concentration to the calculated concentration 
c      then calculate the total ECP using the appropriate constants.

      if (H2O2ECP.ge.O2ECP) then
         SumConc=ConcO2+EqConc
         ECP=O2C1*dtanh((dlog10(SumConc)-O2C2)/O2C3)
     +       +O2C4*dlog10(SumConc)+O2C5
      else
         SumConc=ConcH2O2+EqConc
         ECP=H2O2C1*dtanh((dlog10(SumConc)-H2O2C2)/H2O2C3)
     +       +H2O2C4*dlog10(SumConc)+H2O2C5
      endif
      
      return
      end  !of Potential


      subroutine WriteStat

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by CalcComp

c     WriteStat writes component-run statistics to the output file.
c***********************************************************************

      include 'radical.blk'

      if (iHWC.gt.1) return
      
c  print run statistics

      NStep=NStep+IWork(11)
      NFunc=NFunc+IWork(12)
      NJacob=NJacob+IWork(13)
      ET=Secnds(Time2)          !elapsed time
      write (IOF,290)
      write (IOF,381) ICycle,CompName(IComp)
      write (IOF,290)
      write (IOF,390) IWork(17),IWork(18),IWork(11),IWork(12),
     +                IWork(13),ET
290   format (/80('_'),/)
381   format(/16x'Run Statistics for Cycle'i5' at 'a16)
390   format( 5x'Required RWork Size             = 'i9
     +       /5x'IWork Size                      = 'i9
     +       /5x'Number of Steps                 = 'i9
     +       /5x'# of Function Evaluations       = 'i9
     +       /5x'# of Jacobian Evaluations       = 'i9,
     +       /5x'Component Job Time              = 'f10.0' seconds')

      if (IState.gt.0) then     !success
        print 395, CompName(IComp)
      else                      !failure
        print 400, IState,Bel
        write (IOF,400) IState
      endif
395   format (1x,'Concentration profile of 'a16
     +         ' has been evaluated successfully!')
400   format (/'#### ERROR HALT...IState =',i3,a)

      return
      end  !of WriteStat


      subroutine Sensitivity(RWork)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by CalcComp
c     Calls Adjoint, Response, WriteSens

c     Calculates sensitivity with respect to specified parameters.
c***********************************************************************

      include 'radical.blk'
      real*8 RWork(*)

      IterHold=Iter
      do 100 i=1,NSens

        ISens=0
        do 110 j=1,NSp         !determine ISens
          if (SensSpecies(i).eq.SpeciesName(j)) ISens=j
110     continue

        if (ISens.eq.0) then    !input error
          call ErrorDisplay(71,[i],[0.d0],nullMsg)
          goto 100
        endif

        Time2=Secnds(0.0)       !start clock to measure execution time
        Iter=IterHold
        call Adjoint(RWork)
	write(IOF,111)
111     format(/1x 'Adjoint completed')

        Time2=Secnds(0.0)       !start clock to measure execution time
        call Response(RWork)
        call WriteSens

100   continue  !through all sensitivity species

      return
      end  !of Sensitivity


      subroutine Adjoint(RWork)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by Sensitivity
c     Calls DLSODE 

c     Calculates adjoint with respect to specified parameters.
c     The integral is taken backward along the flow path.
c***********************************************************************

      include 'radical.blk'
      real*8 RWork(*)
      external AdjFro,AdjJacob

      call ScreenDisplay(11,[0],[0.d0],nullMsg)

c  initial values for adjoints are always zero

      do 100, i=1,NSp
        AdjConc(i)=0.0d0
100   continue

c  initialize for DLSODE

      call InitializeDLSODE(0.d0,AdjIWork,AdjRWork,RWork)
      x   =XLength
      XInc=XLength
      Iter=MaxIter           !MaxIter is passed from Radiolysis

c**** start integration loop here from XOut to XIn

200   call DLSODE(AdjFro,NSp,AdjConc,x,XInc,AdjITol,AdjRTol,
     +           AdjATol,AdjITask,IState,AdjIOpt,RWork,
     +           LRW,IWork,LIW,AdjJacob,AdjMF)

      if (IState.eq.-1) then    !DLSODE error - excessive work done
        IState=2
        call ScreenDisplay(12,[0],[0.d0],nullMsg)  !working hard...
        goto 200                !reset and try again
      endif

      do 281, i=1,NSp           !save adjoint curve for response calc
        AdjCurve(Iter,i)=AdjConc(i)
281   continue

      if (Debug(2)) call ScreenDisplay(22,[0],[x],nullMsg)
      Iter=Iter-1

c  exit loop upon XLength or DLSODE error

      if ((Iter.eq.0).or.(x.le.0.d0).or.(IState.lt.0)) goto 380

c  decrement XInc and continue

      XInc = XInc - XStep
      if (IState.eq.1) XInc=(Iter-1)*XStep   !adjust final dx
      if (XInc.lt.0.d0) XInc=0.d0
      goto 200

c**** end of the main loop

380   if (IState.ne.2) call ErrorDisplay(72,[0],[0.d0],nullMsg)

      call ScreenDisplay(13,[0],[0.d0],nullMsg)

      AdjIWork(1)=IWork(17)     !save for print out
      AdjIWork(2)=IWork(18)
      AdjIWork(3)=IWork(11)
      AdjIWork(4)=IWork(12)
      AdjIWork(5)=IWork(13)
      AdjET=Secnds(Time2)      

      return
      end  !of Adjoint


      subroutine AdjFro(n,x,AdjVec,dAdjdx)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by DLSODE
c     Calls Interpolate, ThermalHydro, Jacob

c     Calculates d(Adjoint)/dx.
c***********************************************************************

      include 'radical.blk'
      real*8 AdjVec(*),dAdjdx(*),Interpolate

      do 10 i=1,NSpecies
        Conc(i)=Interpolate(x,XStep,ConcCurve(1,i),MaxIter,0)
10    continue

      call ThermalHydro(x)      !evaluate two-phase parameters
      call Arrhenius         !adjust rate constants at new temp
      call Jacob(NSp,x,Conc(1),ML,MU,Jacobian,ISP)

      do 110 i=1,NSp
        dAdjdx(i) = -Jacobian(ISens,i)
        do 100 j=1,NSp
          dAdjdx(i)=dAdjdx(i)-AdjVec(j)*Jacobian(j,i)
100     continue
110   continue  !through all species

      if (Debug(3)) call ScreenDisplay(23,[0],[x],nullMsg)
      if (Debug(6)) call ScreenDisplay(24,[0],[0.d0],nullMsg)

      return
      end  !of AdjFro


      subroutine AdjJacob(n,x,AdjVec,ML,MU,AdjJac,NRowJac)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by DLSODE
c***********************************************************************

      include 'radical.blk'
      real*8 AdjJac(NRowJac,*),AdjVec(*),Interpolate

      do 10 i=1,NSpecies
        Conc(i)=Interpolate(x,XStep,ConcCurve(1,i),MaxIter,0)
10    continue

      call ThermalHydro(x)      !evaluate two-phase parameters
      call Arrhenius         !adjust rate constants at new temp
      call Jacob(NSp,x,Conc(1),ML,MU,Jacobian,ISP)

      do 110 j=1,NSp
        do 100 i=1,NSp
          AdjJac(i,j)=-Jacobian(j,i)
100     continue
110   continue  !through all species

      return
      end  !of AdjJacob


      subroutine Response(RWork)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by Sensitivity.
c     Calls ResCalc.

c     Calculates response with respect to specified parameters.
c     To conserve memory, response calculation is performed in a
c     lump of NSpecies in the following order: gamma g-values,
c     neutron g-values, initial concentrations, and rate constants.
c***********************************************************************

      include 'radical.blk'
      real*8 RWork(*)
      integer*4 NRes,n          !keep these in this order
      external ResFroGamma,ResFroNeut,ResFroAlpha,ResFroConc,ResFroRate

      call ScreenDisplay(14,[0],[0.d0],nullMsg)

c  initial values for Response

      do 10 i=1,NSp*4+NRx
        ResConc(i)=0.d0
10    continue
      NResStep=0
      NResFunc=0
      NResJacob=0

c  calc response with respect to gamma g-values

      call ScreenDisplay(28,[0],[0.d0],nullMsg)
      call ResCalc(NSp,ResConc(1),ResFroGamma,RWork)

c  calc response with respect to neutron g-values

      call ScreenDisplay(29,[0],[0.d0],nullMsg)
      n=NSp+1
      call ResCalc(NSp,ResConc(n),ResFroNeut,RWork)

c  calc resonse with respect to alpha g-values
      n=n+NSp  ! added by Jarvis, 11/12
      call ResCalc(NSp,ResConc(n),ResFroAlpha,RWork) ! added by Jarvis, 11/12      


c  calc response with respect to initial concentrations
c  930624 jhc  commented out because this takes too long

c      call ScreenDisplay(30,[0],[0.d0],' ')
      n=n+NSp
c      call ResCalc(NSp,ResConc(n),ResFroConc,RWork)

c  calc response with respect to rate constants
      n = n+NSp  ! added by Jarvis 11/12. This fixes a bug. 
      NRes=NSpecies
      do 20 i=1,NRx/NSpecies         !rate constants
cJ        n=n+NSpecies  ! change by Jarvis. This isn't correct unless NSp=NSpecies
	NResBatch = n +(i-1)*NRes  ! NResBatch now takes the place of n. NResBatch is a global variable, n is not. 
        call ScreenDisplay(31,[NResBatch],[0.d0],nullMsg)
        call ResCalc(NRes,ResConc(NResBatch),ResFroRate,RWork)
20    continue
      NRes=NRx-(NRx/NSpecies)*NSpecies   !calc remaining rate constants
      if (NRes.ge.1) then
        NResBatch=NResBatch+NSpecies
        call ScreenDisplay(31,[NResBatch],[0.d0],nullMsg)
        call ResCalc(NRes,ResConc(NResBatch),ResFroRate,RWork)
      endif

      call ScreenDisplay(16,[0],[0.d0],nullMsg)

      return
      end  !of Response


      subroutine ResCalc(NRes,ResConcVec,ResFro,RWork)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by Response.
c     Calls DLSODE.

c     Calculates response with respect to specified parameters.
c***********************************************************************

      include 'radical.blk'
      real*8 ResConcVec(*),RWork(*)
      external ResFro,ResJacob

      call InitializeDLSODE(XLength,ResIWork,ResRWork,RWork)
      x=0.d0
      XInc=XLength
c     
200   call DLSODE(ResFro,NRes,ResConcVec,x,XInc,ResITol,ResRTol,
     +           ResATol,ResITask,IState,ResIOpt,RWork,
     +           LRW,IWork,LIW,ResJacob,ResMF)

      if (IState.eq.-1) then    !DLSODE error - excessive work done
        IState=2
        call ScreenDisplay(15,[0],[0.d0],nullMsg)  !working hard
        goto 200                !reset and try again
      endif

      if (IState.ne.2) call ErrorDisplay(73,[0],[0.d0],nullMsg)

      NResStep=NResStep+IWork(11)
      NResFunc=NResFunc+IWork(12)
      NResJacob=NResJacob+IWork(13)

      return
      end  !of ResCalc


      subroutine ResFroGamma(NRes,x,ResVec,dRdx)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by DLSODE
c     Calls Interpolate, DoseShape

c     Calculates d(Response)/dx for g-values of gamma.
c***********************************************************************

      include 'radical.blk'
      real*8 ResVec(*),dRdx(*),Interpolate  !ResVec is same as ResCon

      if (Debug(5)) call ScreenDisplay(25,[0],[x],nullMsg)
      if (Debug(7)) call ScreenDisplay(26,[0],[0.d0],nullMsg)
      if (Debug(8)) call ScreenDisplay(27,[0],[0.d0],nullMsg) 

      do 10 i=1,NSp             !returns AdjConc at x
        AdjConc(i)=Interpolate(x,XStep,AdjCurve(1,i),MaxIter,0)
10    continue

      call ThermalHydro(x)
      call DoseShape(x)

      do 200 i=1,NSp          !for gamma g-values
        dRdx(i)=GConvert*Gamma*AdjConc(i)
        if (i.eq.ISens) dRdx(i)=dRdx(i)+GConvert*Gamma
        if (GGamma(i).eq.0.d0) dRdx(i)=0.d0

        IC=index(SpeciesName(i),'G')
        if (IC.eq.0) then              !liquid
          dRdx(i)=dRdx(i)/VelLiq
        elseif (VelGas.gt.0.d0) then   !gas
          dRdx(i)=dRdx(i)/VelGas
        endif
200   continue

      return
      end  !of ResFroGamma


      subroutine ResFroNeut(NRes,x,ResVec,dRdx)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by DLSODE
c     Calls Interpolate, DoseShape

c     Calculates d(Response)/dx for g-values of neutron.
c***********************************************************************

      include 'radical.blk'
      real*8 ResVec(*),dRdx(*),Interpolate  !ResVec is same as ResCon

      if (Debug(5)) call ScreenDisplay(25,[0],[x],nullMsg)
      if (Debug(7)) call ScreenDisplay(26,[0],[0.d0],nullMsg)
      if (Debug(8)) call ScreenDisplay(27,[0],[0.d0],nullMsg) 

      do 10 i=1,NSp            !returns AdjConc at x
        AdjConc(i)=Interpolate(x,XStep,AdjCurve(1,i),MaxIter,0)
10    continue

      call ThermalHydro(x)
      call DoseShape(x)

      do 210 i=1,NSp           !for neutron g-values
        dRdx(i)=GConvert*Neutron*AdjConc(i)
        if (i.eq.ISens) dRdx(i)=dRdx(i)+GConvert*Neutron
        if (GNeut(i).eq.0.d0) dRdx(i)=0.d0

        IC=index(SpeciesName(i),'G')
        if (IC.eq.0) then              !liquid
          dRdx(i)=dRdx(i)/VelLiq
        elseif (VelGas.gt.0.d0) then  !gas
          dRdx(i)=dRdx(i)/VelGas
        endif
210   continue

      return
      end  !of ResFroNeut


      subroutine ResFroAlpha(NRes,x,ResVec,dRdx)

c***********************************************************************
c     Version:        radical 1.8.4         2012
c     Author:         John H. Chun
c***********************************************************************
c     Called by DLSODE
c     Calls Interpolate, DoseShape

c     Calculates d(Response)/dx for g-values of alpha.
c***********************************************************************

      include 'radical.blk'
      real*8 ResVec(*),dRdx(*),Interpolate  !ResVec is same as ResCon

      if (Debug(5)) call ScreenDisplay(25,[0],[x],nullMsg)
      if (Debug(7)) call ScreenDisplay(26,[0],[0.d0],nullMsg)
      if (Debug(8)) call ScreenDisplay(27,[0],[0.d0],nullMsg) 

      do 10 i=1,NSp            !returns AdjConc at x
        AdjConc(i)=Interpolate(x,XStep,AdjCurve(1,i),MaxIter,0)
10    continue

      call ThermalHydro(x)
      call DoseShape(x)

      do 220 i=1,NSp           !for neutron g-values
        dRdx(i)=GConvert*Alpha*AdjConc(i)
        if (i.eq.ISens) dRdx(i)=dRdx(i)+GConvert*Alpha
        if (GAlpha(i).eq.0.d0) dRdx(i)=0.d0

        IC=index(SpeciesName(i),'G')
        if (IC.eq.0) then              !liquid
          dRdx(i)=dRdx(i)/VelLiq
        elseif (VelGas.gt.0.d0) then  !gas
          dRdx(i)=dRdx(i)/VelGas
        endif
220   continue

      return
      end  !of ResFroAlpha


      subroutine ResFroConc(NRes,x,ResVec,dRdx)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by DLSODE
c     Calls Interpolate

c     Calculates d(Response)/dx with respect to other species.
c***********************************************************************

      include 'radical.blk'
      real*8 ResVec(*),dRdx(*),Interpolate  !ResVec is same as ResCon
      character*8 a

      if (Debug(5)) call ScreenDisplay(25,[0],[x],nullMsg)
      if (Debug(7)) call ScreenDisplay(26,[0],[0.d0],nullMsg)
      if (Debug(8)) call ScreenDisplay(27,[0],[0.d0],nullMsg) 

      do 10 i=1,NSpecies        !returns Conc & AdjConc at x
        Conc(i)=Interpolate(x,XStep,ConcCurve(1,i),MaxIter,0)
        AdjConc(i)=Interpolate(x,XStep,AdjCurve(1,i),MaxIter,0)
10    continue

      call ThermalHydro(x)      !evaluate two-phase parameters
      call Arrhenius         !adjust rate constants at new temp
      call Jacob(NSp,x,Conc(1),ML,MU,Jacobian,ISP)

      do 300 i=1,NSp
        a=SpeciesName(i)
        if ((a.eq.'OH-').or.(a.eq.'H+').or.(a.eq.'H2').or.(a.eq.'O2')
     +     .or.(a.eq.'H2O2')) then
          dRdx(i)=Jacobian(ISens,i)
          do 310 j=1,NSp
            dRdx(i)=dRdx(i)+AdjConc(j)*Jacobian(j,i)
310       continue
        endif
300   continue  !through all species

      return
      end  !of ResFroConc


      subroutine ResFroRate(NRes,x,ResVec,dRdx)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by DLSODE
c     Calls Interpolate

c     Calculates d(Response)/dx.
c***********************************************************************

      include 'radical.blk'
      real*8 ResVec(*),dRdx(*),Interpolate  !ResVec is same as ResConc
      integer*4 NRes

      if (Debug(5)) call ScreenDisplay(25,[0],[x],nullMsg)
      if (Debug(7)) call ScreenDisplay(26,[0],[0.d0],nullMsg)
      if (Debug(8)) call ScreenDisplay(27,[0],[0.d0],nullMsg) 

      do 10 i=1,NSpecies        !returns Conc & AdjConc at x
        Conc(i)=Interpolate(x,XStep,ConcCurve(1,i),MaxIter,0)
        AdjConc(i)=Interpolate(x,XStep,AdjCurve(1,i),MaxIter,0)
10    continue

      call ThermalHydro(x)

      do 110 i=1,NRes
        m=NResBatch+i-4*NSp-1
        Concen=Conc(IR(m,1))*Conc(IR(m,2))*Conc(IR(m,3))
        dRdx(i)=Koef(m,ISens)*Concen
        IC=index(SpeciesName(ISens),'G')
        if (IC.eq.0) then              !liquid
          dRdx(i)=dRdx(i)/VelLiq
cj          if ((EA(m).eq.-1.d0).and.(Void.gt.0.d0)) 
          if ((RCMode(m).eq.'M').and.(Void.gt.0.d0)) ! changed for new RC input format
     +       dRdx(i)=dRdx(i)*(1.d0-Void)/Void  !get mass transfer rate
        elseif (VelGas.gt.0.d0) then   !gas
          dRdx(i)=dRdx(i)/VelGas
        endif

        do 100 j=1,NSpecies
          RCT=AdjConc(j)*Koef(m,j)*Concen
          IC=index(SpeciesName(j),'G')
          if (IC.eq.0) then     !liquid
            RCT=RCT/VelLiq
cj            if ((EA(m).eq.-1.d0).and.(Void.gt.0.d0))
            if ((RCMode(m).eq.'A').and.(Void.gt.0.d0)) ! changed for new RC input format
     +         RCT=RCT*(1.d0-Void)/Void     !get mass transer rate
          elseif (VelGas.gt.0.d0) then  !gas
            RCT=RCT/VelGas
          endif
          dRdx(i)=dRdx(i)+RCT
100     continue
110   continue  !through all rate constants

      return
      end  !of ResFroRate


      subroutine ResJacob(NRes,x,ResVec,ML,MU,ResJac,NRowJac)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by DLSODE

c     Jacobian of response function is zero.
c***********************************************************************

      return
      end  !of ResJacob


      subroutine WriteSens

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by Sensitivity

c     Writes sensitivity results to output file.
c     SensFile of ver. 1.0 is no longer generated in this version.
c***********************************************************************

      include 'radical.blk'

c  write sensitivity heading

      write (IOF,290) FF             !insert page break (form feed)
      write (IOF,100) CompName(IComp),SpeciesName(ISens)
      write (IOF,291)
290   format(a,80('_'),/)
100   format(/14x,a16' Sensitivity results for 'a8)

c  write adjoint results

      write (IOF,667)
667   format (/14x' ============ Adjoint Results ============='/)

      write (IOF,320) (SpeciesName(i),AdjCurve(1,i),i=1,NSp)
320   format (2(5x,a8' = '1pe15.6' **'))

c  write sensitivity titles

      write (IOF,130)
130   format(//36x,'Absolute',6x,'Relative',
     +      /13x,'Parameter',13x,'Sensitivity',3x,'Sensitivity',
     +      /5x,'-------------------------',2x,2('  ------------')/)

c  write gamma g-value sensitivity

      do 140 i=1,NSp
        RelSens=ResConc(i)*GGamma(i)/ConcInit(ISens)
        if (RelSens.ne.0.d0) write (IOF,110) 
     +     'Gamma   G-Value of '//SpeciesName(i),ResConc(i),RelSens
140   continue

c  write neutron g-value sensitivity

      do 145 i=1,NSp
        m=i+NSp
        RelSens=ResConc(m)*GNeut(i)/ConcInit(ISens)
        if (RelSens.ne.0.d0) write (IOF,110) 
     +     'Neutron G-Value of '//SpeciesName(i),ResConc(m),RelSens
145   continue

c  write alpha g-value sensitivity. Added by Jarvis 11/12

      do 147 i=1,NSp
        m=i+2*NSp
        RelSens=ResConc(m)*GAlpha(i)/ConcInit(ISens)
        if (RelSens.ne.0.d0) write (IOF,110) 
     +     'Alpha G-Value of '//SpeciesName(i),ResConc(m),RelSens
147   continue

c  write sensitivity with respect to other species

      do 150 i=1,NSp
        m=i+3*NSp ! changed by jarvis
        RelSens=ResConc(m)*ConcInit(i)/ConcInit(ISens)
        if (RelSens.ne.0.d0) write (IOF,110) 
     +     'Concentration of   '//SpeciesName(i),ResConc(m),RelSens
150   continue

c  write sensitivity with respect to rate constants and mass transfer rate

      call Arrhenius      !adjust rate constants at new temp
      do 120 i=1,NRx
        m=i+4*NSp ! changed by Jarvis 
        RelSens=ResConc(m)*RateConst(i)/ConcInit(ISens)
        IC=index(SpeciesName(ISens),'G')  !see if it's gas
cj        if ((EA(i).eq.-1.d0).and.(IC.eq.0).and.Boiling)
        if ((RCMode(i).eq.'M').and.(IC.eq.0).and.Boiling)
     +     RelSens=RelSens*(1.d0-Void)/Void  !mass transfer rate
        if (RelSens.ne.0.d0) write (IOF,110) 
     +     'Rate Const of '//RxName(i)//'          ',ResConc(m),RelSens
120   continue

110   format(5x,a27,2(1pe14.5))

c  print run statistics

      ET=Secnds(Time2)          !elapsed time
      write (IOF,291)
      write (IOF,381) CompName(IComp)
      write (IOF,291)
      write (IOF,385)
      write (IOF,390) AdjIWork(1),IWork(17),AdjIWork(2),IWork(18),
     +                AdjIWork(3),NResStep,AdjIWork(4),NResFunc,
     +                AdjIWork(5),NResJacob,AdjET,ET
291   format (/80('_'),/)
381   format(/17x,a16,'Sensitivity Run Statistics')
385   format(/36x,'Adjoint',21x,'Response',
     +       /36x,'-------',21x,'--------')
390   format(/5x'Required RWork Size       = 'i9,20x,i9,
     +       /5x'IWork Size                = 'i9,20x,i9,
     +       /5x'Number Of Steps           = 'i9,20x,i9,
     +       /5x'# Of Function Evaluations = 'i9,20x,i9,
     +       /5x'# Of Jacobian Evaluations = 'i9,20x,i9,
     +       /5x'Sensitivity Job Time      = 'f10.0' seconds'
     +                                    11x,f10.0' seconds')

      if (IState.gt.0) then     !success
        print 395, SpeciesName(ISens),CompName(IComp)
      else                      !failure
        print 400, IState,Bel
        write (IOF,400) IState
      endif
395   format ( 'Sensitivity of ',a8,'in ',a16,
     +         'has been evaluated successfully!')
400   format (/'#### ERROR HALT in Sensitivity routine...IState =',i3,a)

      return
      end  !of WriteSens


      subroutine Terminate

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by radical

c     Terminate writes final run statistics to the output file and
c     closes all files.
c***********************************************************************

      include 'radical.blk'

      ET=Secnds(Time1)          !total elapsed time
      write (IOF,390) NStep,NFunc,NJacob,ET
390   format(///5x'Total Number of Steps           = 'i9
     +       /5x'Total # of Function Evaluations = 'i9
     +       /5x'Total # of Jacobian Evaluations = 'i9,
     +       /5x'Total Job Time                  = 'f10.0' seconds')

      close (IIF)               !close input file
      close (IOF)               !close output file
      close (IEF)               !close ECP file
      if (PlotOut) close (IPF)  !close plot file
      if (CalcInject) close (IHF)  !close HWC file  change by Grover 4/30/96
c      if (CalcHWC) close (IHF)  !close HWC file

      print *
      print *,'         **************** End of a radical run. ',
     +        '****************'
      print *,'         ****************** Have a great day! ',
     +        '******************'
      print *
      print *,'Please press return to close this window......'
      print *,Bel,Bel,Bel

      return
      end  !of Terminate


      subroutine ErrorDisplay(ErrorNo,In,Re,Ch)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Writes messages to screen and output file.
c     In is integer passing parameter array and Re is the real array.
c     Ch is a character array for passing character parameters.
c***********************************************************************

      include 'radical.blk'
      integer*4 ErrorNo,In(*)
      real*8 Re(*)
      character*80 Ch

      goto (1,2,3,4,5,6,7,8,9,10,
     +      11,12,13,14,15,16,17,18,19,20,
     +      21,22,23,24,25,26,27,28,29,30,
     +      31,32,33,34,35,36,37,38,39,40,
     +      41,42,43,44,45,46,47,48,49,50,
     +      51,52,53,54,55,56,57,58,59,60,
     +      61,62,63,64,65,66,67,68,69,70,
     +      71,72,73,74,75,76,77,78,79) ErrorNo
      
1     print 1001,InFile,Bel
      read *
      return
1001  format(/1x,'There is a problem opening this input file.  'a80/
     +        ' Please make sure everything is ok and press RETURN.',a)
                
2     print 1002,OutFile,Bel
      read *
      return
1002  format(/1x,'There is a problem opening the output file.  'a80/
     +        ' Please make sure everything is ok and press RETURN.',a)

3     print 1003,PlotFile,Bel
      read *
      return
1003  format(/1x,'There is a problem opening the plot file.  'a80/
     +        ' Please make sure everything is ok and press RETURN.',a)

4     print 1004,Bel
      goto 999
1004  format(1x,'Error in output file names in the input file.'/
     +       1x,'Please check the input and rerun RADICAL.'/
     +       1x,'Please press RETURN to quit.',a)

5     print 1005,Ch,InFile,Bel,Bel,Bel
      write(IOF,1005) Ch,InFile
      print *
      goto 998
1005  format (' ',a16,' is not found in the file ',a35,
     +       /'Program aborted at subroutine FindLine!',3a)

6     print *,'#### INPUT DATA ERROR - Too many species!',
     +        ' NSpecies must be ²',ISP,Bel
      return
      
7     print *,'#### INPUT DATA ERROR - Too many reactions!',
     +        ' NRx must be ²',IRX,Bel
      return

8     print *,'#### INPUT DATA ERROR - Too many reactions!',
     +        ' NSurfRx must be ²',IRX,Bel
      return
      
9     print *,'#### INPUT DATA ERROR - Too many components!',
     +        ' NComp must be ²',ICO,Bel
      return

10    print 1010,InjectFile,Bel   ! change by Grover 4/30/96
c10    print 1010,HWCFile,Bel
      read *
      return
1010  format(/1x,'There is a problem opening the HWC file.  'a80/
     +        ' Please make sure everything is ok and press RETURN.',a)

11    print *,'#### INPUT DATA ERROR - Too few cycles?!',
     +        ' NCycle must be ³ 1',Bel
      return

12    print *,'#### INPUT DATA ERROR - TempRef must be ³ 0.0 K!',Bel
      return

13    print *,'#### INPUT DATA ERROR - Gamma g-value for ',
     +         SpeciesName(In(1)),' must be ³ 0.0 /100eV',Bel
      return

14    print *,'#### INPUT DATA ERROR - Neutron g-value for ',
     +         SpeciesName(In(1)),' must be ³ 0.0 /100eV',Bel
      return

15    print *,'#### INPUT DATA ERROR - Molecular weight for ',
     +         SpeciesName(In(1)),' must be ³ 0.0 g/mol',Bel
      return

16    print 1016,Re(1),Bel
      return
1016  format ('**** INPUT DATA WARNING - mass is not balanced'
     +        ' for gamma g-values:'f8.3,a)

17    print 1017,Re(1),Bel
      return
1017  format ('**** INPUT DATA WARNING - mass is not balanced'
     +        ' for neutron g-values:'f8.3,a)

18    print 1018,In(1),ISP
      return
1018  format ('#### INPUT DATA ERROR - Species numbers for reactants ',
     + 'and products in'/24x'reaction',i4,' must be ³ 0 and ²',i3)

19    print 1019,In(1),Bel
      return
1019  format ('#### INPUT DATA ERROR - Rate constant in reaction',
     + i4' must be ³ 0.0',a)
     
20    print 1020,In(1),Bel
      return
1020  format ('#### INPUT DATA ERROR - Activation energy in reaction',
     + i4' must be ³ -1.0',a)

21    print 1021,In(1),Bel
      return
1021  format ('**** INPUT DATA WARNING - mass is not balanced'
     +        ' in reaction',i4,a)

22    print *
      print *
      print *,'#### EXECUTION TERMINATED DUE TO INPUT ERROR!'
      print *,' '
      print *,'---- Please correct input data and try again.'
      print *
      print *,'Please press RETURN to close this window.'
      print *,Bel,Bel,Bel
      goto 999

23    print 1023,Bel,Bel,Bel
      write(IOF,1023)
      goto 999
1023  format ('#### INPUT ERROR! - Node information ',
     +        ' is not valid.',
     +        /' Program terminated at subroutine Push.',3a) 

24    print 1024,Bel,Bel,Bel    !ring bell
      write(IOF,1024)
      goto 999
1024  format('#### INPUT ERROR! Program terminated at',
     +       ' subroutine Pull.',3a)
      
25    print 1025,Bel,Bel,Bel
      write(IOF,1025)
      goto 999
1025  format ('#### ERROR IN INPUT NODE INFORMATION.',
     +        ' Sum of flowrates is zero.',
     +       /' Program terminated at subroutine AverageFlow.',3a)

26    print 1026,CompName(IComp),Bel
      goto 999
1026  format(1x,'Position information is not found for ',a16,
     +       1x,' in the input file.'/
     +       1x,'Please check the input and rerun RADICAL.'/
     +       1x,'Please press RETURN to quit.',3a)

27    print 1027,CompName(IComp),Bel,Bel,Bel
      goto 999
1027  format(1x,'State information is not found for ',a16,
     +       1x,' in the input file.'/
     +       1x,'Please check the input and rerun RADICAL.'/
     +       1x,'Please press RETURN to quit.',3a)

28    return
29    return

30    MaxNSpecies=(sqrt(4.*(In(1)-22)+81.)-9)/2
      iSize=22+(9+NSp)*NSp
      print 1030,NSp,In(1),MaxNSpecies,iSize-In(1)+10000
      goto 999
1030  format(1x,'The input requires',i3,' species but there is not '
     +       'enough memory to run this size.'
     +      /'Available space is',i8,' bytes which is good'
     +       'for only',i3,' species.'
     +      /'You can either reduce the number of species to this value'
     +      /'or increase the application memory by',i8,' bytes '
     +       'in the Get Info box.'
     +      /'Please hit RETURN to continue.')

31    print *,'#### INPUT DATA ERROR - FlowModel must be 1 for ',
     +        'Single Phase,'
      print *,'2 for Chexal-Lellouche, or 3 for Bankoff Model.',Bel
      goto 998

32    print *,'#### INPUT DATA ERROR - ConcInMode must be 0 for ',
     +        'mol/liter or'
      print *,'2 for ppb.',Bel
      return

33    print *,'#### INPUT DATA ERROR - ConcOutMode must be 0 for ',
     +        'mol/liter,'
      print *,'2 for ppb.',Bel
      return

34    return
35    return
36    return
37    return
38    return
39    return
40    return
41    return
42    return
43    return
44    return
45    return
46    return
47    return
48    return
49    return

50    print *,'#### INPUT DATA ERROR - XOut must be ³ XIn!',Bel
      return

51    print *,'#### INPUT DATA ERROR - XLength must be ³ 0.0 cm!',Bel
      return

52    print *,'#### INPUT DATA ERROR - XStep must be > 0.0 cm!',Bel
      return

53    print *,'#### INPUT DATA ERROR - Temp must be > 0.0 K!',Bel
      return

54    print *,'#### INPUT DATA ERROR - Doserates must be > 0.0 rad/s!'
     +       ,Bel
      return

55    print *,'#### INPUT DATA ERROR - Velocity must be > 0.0 cm/s!',Bel
      return

56    print *,'#### INPUT DATA ERROR - Diameter must be > 0.0 cm!',Bel
      return

57    print *,'#### INPUT DATA ERROR - Density must be > 0.0 g/cc!',Bel
      return

58    print *,'#### INPUT DATA ERROR - Pressure must be > 0.0 MPa!',Bel
      return

59    print *,'#### INPUT DATA ERROR - FlowRate must be > 0.0g/s!',Bel
      return

60    print *,'#### INPUT DATA ERROR - MaxOrdGamma must be ³ 0 and ²',
     +        IPO,Bel
      return

61    print *,'#### INPUT DATA ERROR - MaxOrdNeut must be ³ 0 and ²',
     +        IPO,Bel
      return

62    print *,'#### INPUT DATA ERROR - MaxOrdVoid must be ³ 0 and ²',
     +        IPO,Bel
      return

63    print *,'#### INPUT DATA ERROR - Concentration for ',
     +         SpeciesName(In(1)),' must be ³ 0.0 mol/L',Bel
      return

64    print *,'#### INPUT DATA ERROR - NSens must be <',
     +         NSpecies,'!',Bel
      return

65    print *,'#### INPUT DATA ERROR - MF must be 10, 21,',
     +        ' 22, 24 or 25',Bel
      return

66    print *,'#### INPUT DATA ERROR - AdjMF must be 10, 21, 22,',
     +        ' 24 or 25',Bel
      return

67    print *,'#### INPUT DATA ERROR - ResMF must be 10, 21, 22,',
     +        ' 24 or 25',Bel
      return

68    goto 998

69    return

70    print *,'#### DLSODE ERROR. IState =',IState,Bel
      if (Debug(1)) write (IOF,*)'**** DLSODE ERROR. IState =',IState
      goto 999

71    print 1071, SensSpecies(In(1))
      write (IOF,1071) SensSpecies(In(1))
      return
1071  format ('#### INPUT DATA ERROR - SensSpecies "'a8'" not found.')

72    print 1072, IState,Bel
      write (IOF,1072) IState
      goto 999
1072  format (/'#### ERROR HALT in Adjoint evaluator...IState =',i3,a)

73    print 1073, IState,Bel
      write(IOF,1073) IState
      goto 999
1073  format (/'#### ERROR HALT in Response evaluator...IState =',i3,a)

74    print *
      print *,'###################################################'
      print *
      print 1074,InFile,Bel
      return
1074  format(/1x,'An error prevented from opening this input file.  'a80/
     +        ' This input file will be skipped.',a///)

75    print *,'#### INPUT DATA ERROR - Too many nodes =',MaxNode,
     +        '  must be <',INO,'!',Bel
      goto 998

76    print *,'#### INPUT DATA ERROR - NodeStart =',NodeStart,
     +        ' does not exist!',Bel
      goto 998

77    print *,'#### INPUT DATA ERROR - Alpha g-value for ',
     +         SpeciesName(In(1)),' must be ³ 0.0 /100eV',Bel
      return

78    print *,'#### INPUT DATA ERROR -pH is not valid ',Bel
      return

79    print *,'#### INPUT DATA ERROR -BTot or LiTot is invalid',Bel
      return

998   print *
      print *
      print *,'#### EXECUTION TERMINATED DUE TO INPUT ERROR!'
      print * 
      print *,'---- Please correct input data and try again.'
      print *
      print *,'Please press RETURN to close this window.'
      print *,Bel,Bel,Bel
999   write(*,'(" 1 ")') !BP
      read(*,*)
      stop
      end  !of ErrorDisplay


      subroutine ScreenDisplay(MsgNo,In,Re,Ch)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Writes messages to screen and output file.
c     In is integer passing parameter array and Re is the real array.
c     Ch is a character array for passing character parameters.
c***********************************************************************

      include 'radical.blk'
      integer*4 MsgNo,In(*)
      real*8 Re(*)
      character*80 Ch

      goto (1,2,3,4,5,6,7,8,9,10,
     +      11,12,13,14,15,16,17,18,19,20,
     +      21,22,23,24,25,26,27,28,29,30,
     +      31,32,33,34,35,36,37,38,39,40,
     +      41) MsgNo

35    print *
      print *,
     +     'Welcome to RADICAL - RADiation Chemistry Analysis Loop code'
      print *
      return

1     print *
      print *,'Largest node number =',MaxNode
      return

2     print *
      print *,'Number of cycle = ',NCycle
      return

3     print *
      print *,'Cycle =',ICycle,'      Node =',In(1)
      if (Debug(1)) write (IOF,*) 'Cycle =',ICycle,' Node = ',In(1)
      return

4     print 1004,IComp,CompName(IComp),InFile
      if (Debug(1)) write(IOF,1004) IComp,CompName(IComp),InFile
      return
1004  format(/1x,'Calculating component',i3,1x,a16' from 'a80)

5     print *
      print *,'Push into node ',In(1),' Pointer=',In(2)
      if (Debug(1)) write(IOF,*) 
     +   'Push into node ',In(1),' Pointer=',In(2)
      return

6     print *
      print *,'Pull stack node =',In(1),' Pointer=',In(2)
      if (Debug(1)) write(IOF,*)
     +   'Pull stack node =',In(1),' Pointer=',In(2)
      return

7     print *,'**** SensStep TOO LARGE; Adjusted to',SensStep
      return

8     print *,'**** WORKING HARD in Concentration!',Bel
      if (Debug(1)) write (IOF,*)'**** WORKING HARD in Concentration!'
      return

9     print *,'Entering Chexal at x=',Re(1)
      write(IOF,*) 'Entering Chexal at x=',Re(1)
      write(IOF,*) 'Enthalpy=',Enthalpy,'  P=',Pressure,
     +             '  DensLiq=',DensLiq
      return

10    write(IOF,*) '************* Saturated.'
      return

11    print 1011, SpeciesName(ISens)
      if (Debug(1)) write (IOF,1011) SpeciesName(ISens)
      return
1011  format (1x,'Entering Adjoint routine for  ',a8)

12    print *,'**** WORKING HARD in Adjoint!',Bel
      if (Debug(1)) write (IOF,*)'**** WORKING HARD in Adjoint!'
      return

13    print *,'Adjoint completed!'
      if (Debug(1)) write (IOF,*) 'Adjoint completed!'
      return

14    print *,'Entering Response routine for ',SpeciesName(ISens)
      if (Debug(1)) write (IOF,*)
     +   'Entering Response routine for ',SpeciesName(ISens)
      return

15    print *,'**** WORKING HARD in Response!',Bel
      if (Debug(1)) write (IOF,*)'**** WORKING HARD in Response!'
      return

16    print *,'Exiting Response routine.'
      if (Debug(1)) write (IOF,*) 'Exiting Response routine.'
      return

17    write(IOF,*) 'EnthIn=',EnthIn,'  EnthLiq=',EnthLiq,
     +   '  EnthGas=',EnthGas
      write(IOF,*) 'DensLiq=',DensLiq,'  DensLiqSat=',
     +   DensLiqSat,'  DensGas=',DensGas
      return

18    write(IOF,*) 'x ',Re(1),' Iter',Iter
      return

19    write(IOF,*) 'Entering DifEq at x =',Re(1)
      return

20    write(IOF,*) 'x =',Re(1),' dCdx(',In(1),') = ',Re(2)  !use x from call 19
      return

21    write(IOF,*) 'Quality=',Quality,'  Void=',Void
      write(IOF,*) 'dVFdx=',dVFdx,'  dVLdx=',dVLdx,'  dVGdx=',dVGdx,
     +             '  dQdx=',dQdx
      return

22    write(IOF,*) 'x',Re(1),' Iter ',Iter
      return

23    write(IOF,*) 'in AdjFro, x=',Re(1)
      return

24    write(IOF,1024) (SpeciesName(i),Conc(i),i=1,NSpecies)
      return
1024  format(2('Con'2x,a8' + 'd15.6' **'))

25    write(IOF,*) 'Entering ResFro, x =',Re(1)
      return

26    write(IOF,1026) (SpeciesName(i),Conc(i),i=1,NSpecies)
      return
1026  format (2('Con',2x,a8,' = ',d15.6,' **'))

27    write(IOF,1027) (SpeciesName(i),AdjConc(i),i=1,NSp)
      return
1027  format (2('Adj',2x,a8,' = ',d15.6,' **'))

28    print *,'Entering GAMMA g-value sensitivity routine.'
      return

29    print *,'Entering NEUTRON g-value sensitivity routine.'
      return

30    print *,'Entering CONCENTRATION sensitivity routine.'
      return

31    print *,'Entering RATE CONSTANT sensitivity routine.',In(1)
      return

32    print *,'Beginning Batch Mode Calculations.'
      print *
      return

33    print *
      print *
      print *,'Finished Batch Mode Calculations.'
      return

34    print *
      print *,'Reading from the input file:   ',InFile
      print *
      return

36    print *
      print *,'Calculating Heat Balance...'
      print *
      return
      
37    print *
      print *,'Finished Heat Balance.  EnthDif =',EnthDif
      print *
      return

38    print *
      if (ConcInMode.eq.molLiter) then   !input in mol/liter
c        print *,'HWC Injection is ',HWCInject(iHWC),' mol/L at ',HWCComp
        print *,SpeciesInject,' Injection is ',Inject(iHWC),   !change by Grover 4/30/96
     +  ' mol/L at ',InjectComp
      elseif (ConcInMode.eq.ppb) then    !input in ppb
c        print *,'HWC Injection is ',HWCInject(iHWC),' ppb at ',HWCComp
        print *,SpeciesInject,'Injection is ',Inject(iHWC),
     +   ' ppb at ',InjectComp
      endif
      return

c39    print *,'Injecting',HWCInject(iHWC),' ppb Hydrogen.'
39    print *,'Injecting',Inject(iHWC),' ppb ',SpeciesInject   !change by grover 4/30/96
      return

40    print *
      print *,'Convergence for ',SpeciesName(In(1))
      print 1040,ConcFinal(IComp,In(1)),Conc(In(1)),Re(1),ConvMin
      return
cy1040  format(1x,'Old    = ',e14.4,'     New       = ',e14.4,/,
cy     +       1x,'Change = ',e14.4,'     Criterion = ',e14.4)
1040  format(1x,'Old    = ',es14.4,'     New       = ',es14.4,/,
     +       1x,'Change = ',es14.4,'     Criterion = ',es14.4)

41    print *
      print *,'********* Concentrations Have Converged!',Bel,Bel
      return

      end  !of ScreenDisplay


      real*8 function Evaluate(x,Length,Coef,MaxOrder,InMode,OutMode)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Evaluate value at x by calling either Polynomial or Interpolate.
c     InMode   = 0  input is given as polynomial of MaxOrder.
c     InMode   = 1  input is given as MaxOrder number of data points.
c     OutMode  = 0  returns the value at x.
c     OutMode  = 1  returns the first derivative at x.
c***********************************************************************

      real*8 x,Length,Coef(0:*)
      real*8 Step,L,Interpolate,Polynomial
      integer*4 MaxOrder,InMode,OutMode
c     volatile Step,L

      if (InMode.eq.0) then     !input is in polynomial coefficients
        Evaluate=Polynomial(x,Coef,MaxOrder,OutMode)
      else                      !input is data points
        if (MaxOrder.gt.1) then !next 5 lines modified to trap div by zero error
          Step=Length/(MaxOrder-1)    !950605 chun
        else
          Step=Length
        endif
        L=Length
        Evaluate=Interpolate(x,Step,Coef,MaxOrder,OutMode)
      endif

      return
      end  !of Evaluate


      real*8 function Polynomial(x,Coef,MaxOrder,Mode)

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Evaluate the polynomial at x for given coefficients of order
c     MaxOrder.
c     Mode = 0  returns the value of the polynomial at x.
c     Mode = 1  returns the first derivative at x.
c***********************************************************************

      real*8 x,Coef(0:*)
      real*8 dPdx
      integer*4 MaxOrder,Mode
      integer*4 i
      
      if (MaxOrder.ge.0) then      !modified to trap out of bound error
        Polynomial=Coef(MaxOrder)  !950605 chun
        dPdx=MaxOrder*Polynomial
        do 100 i=MaxOrder-1,0,-1
          Polynomial=x*Polynomial+Coef(i)
          if (i.gt.0) dPdx=x*dPdx+i*Coef(i)
100     continue
        if (Mode.eq.1) Polynomial=dPdx
      else
        Polynomial=0.d0
        dPdx=0.d0
      endif

      return
      end  !of Polynomial


      real*8 function Interpolate(x,Interval,Profile,nData,Mode)

c***********************************************************************
c     Version:        radical 1.7           June 2003
c     Author:         Yasuyuki Otsuka
c***********************************************************************
c
c	See the memorandum about the revision record.
c
c***********************************************************************

c***********************************************************************
c     Version:        radical 1.5          20 May 1993
c     Author:         John H. Chun
c***********************************************************************
c     Called by AdjFro, AdjJacob, ResFro

c     Finds value at x from profile array by linear interpolation.
c     The lowest value of x is 0.
c     If x is out of bounds (x<0 or x>xMax) then the value is set
c     for x=0 or x=xMax.

c     Mode=0  Interval(1) = x interval, Interval(2) = xMax
c     Mode=1  Same as Mode=0, but returns the derivative
c     Mode=2  Interval(*) has x data points, Profile(*) has y data points.
c     Mode=3  Same as Mode=2, but returns the derivative
c***********************************************************************

cy      real*8 x,Interval(*),Profile(*)
      real*8 x,Interval,Profile(*)					!change by Yasu
      real*8 dx,xMax,Remainder,FinalDx,dy
      integer*4 nData,Mode
      integer*4 ILo,IHi
      
cy      if ((nData.lt.1).or.(Interval(1).le.0.d0)) then
      if ((nData.lt.1).or.(Interval.le.0.d0)) then	!change by Yasu
cy        Mode=-1
		Interpolate=0.d0							!change by Yasu
        return
      elseif (nData.eq.1) then
        Interpolate=Profile(1)
cy        if ((Mode.eq.1).or.(Mode.eq.3)) Interpolate=0.d0
        if (Mode.eq.1) Interpolate=0.d0				!change by Yasu	
        return
      endif
        
cy      if ((Mode.eq.0).or.(Mode.eq.1)) then			!change by Yasu

cy        dx=Interval(1)
cy        xMax=Interval(2)
        dx=Interval									!change by Yasu
        xMax=Interval*(nData-1)						!change by Yasu

        ILo=int(x/dx)+1      !index of low-end point
        IHi=ILo+1
        Remainder=x-dx*int(x/dx)

c    correct for the last interval of non-evenly divided case

        FinalDx=xMax-dx*int(xMax/dx)
        if (x.gt.(xMax-FinalDx)) dx=FinalDx

        dy=Profile(IHi)-Profile(ILo)
        Interpolate=dy/dx*Remainder+Profile(ILo)

        if (x.le.0.d0) Interpolate=Profile(1) !handle out-of-bound cases
        if (x.ge.xMax) Interpolate=Profile(nData)

        if (Mode.eq.1) Interpolate=dy/dx  !return the derivative

cy      elseif ((Mode.eq.2).or.(Mode.eq.3)) then
cy
cy        IHi=2                   !simple sequential search
cy10      if ((Interval(IHi).lt.x).and.(x.le.Interval(nData))) then
cy          IHi=IHi+1
cy          goto 10
cy        endif
cy        ILo=IHi-1
cy        dx=Interval(IHi)-Interval(ILo)
cy        dy=Profile(IHi)-Profile(ILo)
cy        Remainder=x-Interval(ILo)
cy        Interpolate=dy/dx*Remainder+Profile(ILo)
cy
cy        if (x.le.Interval(1)) Interpolate=Profile(1) !handle out-of-bound cases
cy        if (x.ge.Interval(nData)) Interpolate=Profile(nData)
cy
cy        if (Mode.eq.3) Interpolate=dy/dx  !return the derivative
cy
cy      endif
cy
      return
      end  !of Interpolate


      subroutine MixedPotential(WriteECP,x)

c***********************************************************************
c     Version:        radical 1.8.4          31 November 2012
c     Author:         Jennifer A. Jarvis
c***********************************************************************
c 	Calcuates the ECP for PWR coolant (hydrogen overpressure) 
c 	using a mixed potential model. 
c 	
c***********************************************************************

      include 'radical.blk'
c      real*8 ECP, ECPNew
c      real*8 bH, bO, PotDifH2, PotDifCorr, PotDifO2, PotDifH2O2
c      real*8 ConcH2,ConcHP, pKH2, pH, ConcH2O2, ConcO2,pKO2
      real*8 iH2,iCorr,diffiH2,diffiCorr,diffiO2,diffiH2O2,iO2,iH2O2
      F =  96485.335  ! faraday constant 
      RT = GasConst*1000.0*Temp !
      viscosity = dexp(-6.140834d0-1103.164d0/Temp+
     +     457155.3d0*Temp**(-2.0))  !kinematic viscosity, [cm2/s]


c  Pull the concentrations of the relevent chemical species (in units of mol/L)
      do i=1,Nsp
         if (SpeciesName(i).eq.'H2') then
            ConcH2=Conc(i)
            if (ConcH2.lt.1.0d-12) ConcH2=1.0d-12
	 elseif (SpeciesName(i).eq.'H+') then
            ConcHP=Conc(i)
            if (ConcHP.lt.1.0d-20) ConcHP=1.0d-20
	 elseif (SpeciesName(i).eq.'O2') then
            ConcO2=Conc(i)
            if (ConcO2.lt.1.0d-20) ConcO2=1.0d-20
	 elseif (SpeciesName(i).eq.'H2O2') then
            ConcH2O2=Conc(i)
            if (ConcH2O2.lt.1.0d-20) ConcH2O2=1.0d-20
         endif
      enddo  

c  Calculate pH if necessary
      mH = -1.0
      mOH = -1.0
      if(pHMode.eq.'BLiCalc') then
          call CalculatepH    ! calculate pH if needed
      elseif(pHMode.eq.'BWRCalc') then
         pH = -1.0*log10(ConcHP)
      endif
      
c      if(mH.ne.0) ConcHP = mH*DensLiq

c     equilibrium potential for H2/H+ redox pair using Nernst Eq.
      pKH2 = -1321.0/Temp+10.703-0.010468*Temp ! henry's constant for H2
      pKO2 = -1202.0/Temp+9.622-0.009049*Temp ! henry's constant for O2
      EoH2 = -2.303*(RT)/(2.0*F)*(dlog10(ConcH2/DensLiq)+pKH2+2*pH) 
      EoO2 = 1.518489-0.001121*Temp+6.024d-7*Temp**(2.0)
     +       -3.2733d-10*Temp**(3.0)
     +       +2.303*(RT)/(4.0*F)*(dlog10(ConcO2/DensLiq)+pKO2-4*pH)
      EoH2O2 = 1.978968-7.23d-4*Temp-9.888d-8*Temp**(2.0)
     +       +3.6793d-10*Temp**(3.0)-1.37202d-13*Temp**(4.0)
     +       +2.303*(RT)/(2.0*F)*(dlog10(ConcH2O2)-2*pH)
      bH=0.065 ! anodic and cathodic Tafel constants ba =bc =b, units Volts
      bO=0.071


c     set parameters based on the surface material
      if(ECPModel.eq.'PSS304') then
        ExCurrentH2 =0.0114841*(ConcH2/1000.)**0.5*dexp(-14244./RT) ! note that that GasConst is in kJ/mol   !********MODIFIED TO REMOVE /1000
        EoCorr = 0.122-1.5286d-3*Temp 
        ExCurrentO2= 0.0114841*(ConcO2/1000.)**0.48633*dexp(-14244./RT)  !!!!!!!!MODIFIED TO REMOVE /1000 
        ExCurrentH2O2=0.0114841*(ConcH2O2/1000.)**0.48633*
     + dexp(-14244./RT)
c	ExCurrentH2O2=ExCurrentO2
      elseif(ECPModel.eq.'PAll600') then
        ExCurrentH2 = 1.79d-10*exp(-30562./RT)*(ConcH2**0.64)
     +            *ConcHP**(-1.39)
        EoCorr = 1.8-7.43d-3*Temp-9.13/pH+0.038*Temp/pH
      elseif(ECPModel.eq.'PAll690') then
        ExCurrentH2 = 1.18d-10*exp(-35619/RT)*(ConcH2**0.54)
     +       *ConcHP**(-1.45)
        EoCorr = 0.91-5.2d-3*Temp-4.9/pH+0.027*Temp/pH
      else
        ECP =999999  ! not a reasonable number
        return
      endif

c     Calculate limit currents for REDOX pairs
      DH2 = dexp(-5.700267d0-296.7439d0/Temp-288379.2d0*Temp**(-2.0)) !diffusivity of H2 [cm2/s]
      DHp = 2*DH2
      DO2 = 8.03d-3*exp(-3490/RT) !diffusivity of O2 [cm2/s]
      viscosity = dexp(-6.140834d0-1103.164d0/Temp+
     +     457155.3d0*Temp**(-2.0))  !kinematic viscosity, [cm2/s]
c       Re = FlowRate/(Area*DensLiq)*(1.0-Quality)*Diameter*(1.0-Void)
c     +      /viscosity      
      Re = VelLiq*Diameter/viscosity 

      LimCurrAH2 = 0.0165*2*F*DH2*(ConcH2/1.0d3)*(Re**0.86)*
     +    (viscosity/DH2)**0.3/Diameter
      LimCurrCH2 = -0.0165*2*F*DHp*(ConcHP/1.0d3)*(Re**0.86)*
     +    (viscosity/DHp)**0.3/Diameter 
      LimCurrCO2 = -0.0165*4*F*DO2*(ConcO2/1.0d3)*(Re**0.86)*
     +    (viscosity/DO2)**0.3/Diameter
      LimCurrCH2O2 = -0.0165*2*F*DO2*(ConcH2O2/1.0d3)*(Re**0.86)*
     +    (viscosity/DO2)**0.3/Diameter


c     guess intial ECP
      ECPNew = 0.5*(EoCorr+EoH2); ! guess average of two
      if(ECPModel.eq.'PSS304') ECPNew=0.5*(EoCorr+EoH2O2)
      ECPdiff = 1.d0
      diffiO2= 0.d0
      diffiH2O2= 0.d0
      iO2= 0.d0
      iH2O2= 0.d0

      loops = 0
      do while((dabs(ECPdiff).gt.1.0d-5).and.(loops.lt.20000))   ! iterate until converge
         loops=loops+1
         ECP = ECPNew ! update ECP
         PotDifH2 = ECP-EoH2  ! potential difference for H2 redox pair
         PotDifCorr = ECP-EoCorr ! potential difference for corrosion
         PotDifO2 = ECP-EoO2  
	 PotDifH2O2 = ECP-EoH2O2

c        calculate currents and derivatives of currents
c      The function RedoxCurr(PotDif,b,ExCurrent,LimCurrA,LimCurrC,Mode,Anodic) is used 
         iH2 = 
     +  RedoxCurr(PotDifH2,bH,ExCurrentH2,LimCurrAH2,LimCurrCH2,0,1)
         diffiH2 = 
     +  RedoxCurr(PotDifH2,bH,ExCurrentH2,LimCurrAH2,LimCurrCH2,1,1)
         if(ECPModel.eq.'PSS304') then
            iCorr = Current304Corr(PotDifCorr,0)
            diffiCorr = Current304Corr(PotDifCorr,1)
            iO2 = RedoxCurr(PotDifO2,bO,ExCurrentO2,1.d0,LimCurrCO2,0,0)
            iH2O2 = 
     +      RedoxCurr(PotDifH2O2,bO,ExCurrentH2O2,1.d0,LimCurrCH2O2,0,0)
            diffiO2 =
     +       RedoxCurr(PotDifO2,bO,ExCurrentO2,1.d0,LimCurrCO2,1,0)
            diffiH2O2 = 
     +      RedoxCurr(PotDifH2O2,bO,ExCurrentH2O2,1.d0,LimCurrCH2O2,1,0)
         else
            iCorr = CurrentInconel(PotDifCorr,ECPModel,0,Temp)
            diffiCorr = CurrentInconel(PotDifCorr,ECPModel,1,Temp)
         endif
         ECPDiff = -(iH2+iCorr+iO2+iH2O2)
     +            /(diffiH2+diffiCorr+diffiO2+diffiH2O2) ! change in ECP
         if(ECPDiff.gt.0.1) ECPDiff = 0.1  !limit the change in ECP
         if(ECPDiff.lt.-0.1) ECPDiff = -0.1  !limit the change in ECP
         ECPNew = ECP + ECPDiff
      enddo      

      ECP=ECPNew*1000.0  ! convert ECP to mV

c write results to plot file

      if ((ECPOut).and.(WriteECP)) write (IEF,470) 
     +  ICycle,Tab,CompName(IComp),Tab,XIn+x,
     +  Tab,ConcH2,Tab,ConcHP,Tab,ConcO2,Tab,ConcH2O2,
     +  Tab,ECP,Tab,EoCorr*1000.,Tab,EoH2*1000.,Tab,
     +  EoO2*1000.,Tab,EoH2O2*1000.,Tab,
     +  iCorr,Tab,iH2,Tab,iO2,Tab,iH2O2,Tab,
     +  ExCurrentH2,Tab,ExCurrentO2,Tab,ExCurrentH2O2,Tab,
     +  LimCurrAH2,Tab,LimCurrCH2,Tab,LimCurrCO2,Tab,
     +  LimCurrCH2O2, Tab, Re, Tab, pH, Tab, mH, Tab, mOH
470   format (i5,a,a16,999(a,1pe10.3))


 
      return
      end  !of MixedPotentialPWR

      subroutine CalculatePH

c***********************************************************************
c     Version:        radical 1.8.4          31 November 2012
c     Author:         Jennifer A. Jarvis
c***********************************************************************
c 	Calcuates the pH for PWR coolant with boron and lithium 
c 	injection using equilibrium rate constants and mass and charge
c	balance
c 	
c***********************************************************************

      include 'radical.blk'
  
      real*8 m1, m2, m3, m4, m5, m6, m7
      real*8 act,mu, Bmol, Limol
      real*8 RateConst1, RateConst2, RateConst3, RateConst4
      real*8 RateConst5, RateConstW, A, B, ao, TC
      real*8 F10, F20, A1, A2, B1, B2 
      real*8 dmH, dm1
      real*8 DOH,D21,D22,D31,D32,D41,D42,D51,D52,D71,D72,denom

c     convert Btot and Litot to mol/kg
      Bmol = BTot/(1.0d3*10.81)
      Limol = LiTot/(1.0d3*6.94) 

c      write(IOF,51) Bmol, Limol
51    format(/5x 'Bmol = ',1pe15.6,/5x,'limol = ',1pe15.6)

c     calculate rate constants for the reactions
      RateConst1=10**(1573/Temp+28.6059+0.012078*Temp-
     +              13.2258*log10(Temp))
      RateConst2=10**(2756.1/Temp-18.966+5.835*log10(Temp))
      RateConst3=10**(3339.5/Temp-8.084+1.497*log10(Temp))
      RateConst4=1.99
      RateConst5=2.12
      RateConstW = 10**(-4.098-3245/Temp+2.23d5*Temp**(-2.0)
     +        -3.998d7*Temp**(-3.0)
     +        +(13.95-1262.3/Temp+8.56d5*Temp**(-2.0))*log10(DensLiq)) !density of the liquid in g/cc. 

c     calculate terms for activity coefficients
      TC=Temp-273.15 ! temp in celsius
      ao = 4.5d-8
      A = 0.4241+0.00321*TC-2.0d-5*(TC**2.0)+5.95143d-8*(TC**3.0)
      B = 0.327+0.00019*TC-2.12586d-7*(TC**2.0)+1.4241d-9*(TC**3.0)

c      write(IOF,55) Temp,RateConstW,RateConst1,RateConst2
55    format(/5x 'T= ',1pe15.6,/5x,'RW = ',1pe15.6
     +       /5x 'R1 = ',1pe15.6,/5x,'R2 = ',1pe15.6 )
    
c     guess intial concentrations
      mH = 1.0d-7
      m1 = 0.5*Bmol
      act = 0.98
      F10 =1.0;
      F20=1.0;

c     loop until converged
      loops=0
      do while(((dabs(F10).gt.1.0d-9).or.(dabs(F20).gt.1.0d-7))
     +      .and.(loops.lt.10000))
        loops=loops+1
c         write(IOF,52) mH, dmH, m1,dm1
c       calculate concentrations
        mOH=RateConstW/(mH*act*act)
        m2 = RateConst1*m1*mOH
        m3 = RateConst2*(m1**2.0)*mOH
        m4 = RateConst3*(m1**3.0)*mOH
        m5 = Limol/(1.0+act*act*(RateConst4*mOH+RateConst5*m2))
        m6 = RateConst4*m5*mOH*act*act
        m7 = RateConst5*m2*m5*act*act
c      write(IOF,54) mOH,m2,m3,m4
54    format(/5x 'mOH= ',1pe15.6,/5x,'m2 = ',1pe15.6
     +       /5x 'm3 = ',1pe15.6,/5x,'m4 = ',1pe15.6 )


c       calculate F10 and F20
        F10 = mH+m5-mOH-m2-m3-m4
        F20=Bmol-m1-m2-2.0*m3-3.0*m4-m7

c     calculate Jacobian
        DOH=-RateConstW/(act*act*mH*mH)
        D21=RateConst1*m1*DOH
        D22=RateConst1*mOH
        D31=RateConst2*m1*m1*DOH
        D32=2.0*RateConst2*m1*mOH
        D41=RateConst3*(m1**3.0)*DOH
        D42=3.0*RateConst3*m1*m1*mOH
        denom = (1.0+act*act*(RateConst4*mOH+RateConst5*m2))**2.0
        D51=Limol*act*act*(RateConst4*DOH+RateConst5*D21)/denom
        D52=Limol*act*act*RateConst5*D22/denom
        D71=RateConst5*act*act*(m5*D21+m2*D51)
        D72=RateConst5*act*act*(m5*D22+m2*D52)

        A1= 1.0+D51-DOH-D21-D31-D41
        B1=D52-D22-D32-D42
        A2=-D21-2.0*D31-3.0*D41-D71
        B2=-1.0-D22-2.0*D32-3.0*D42-D72

c      write(IOF,53) A1,A2,B1,B2
53    format(/5x 'A1= ',1pe15.6,/5x,'A2 = ',1pe15.6
     +       /5x 'B1 = ',1pe15.6,/5x,'B2 = ',1pe15.6)

c       compute new guess
        dmH = (F20*B1-F10*B2)/(A1*B2-A2*B1)
        dm1 = (F10*A2-F20*A1)/(A1*B2-A2*B1)  

c        write(IOF,52) mH, dmH, m1,dm1 
        if((dmH+mH).le.0.0) dmH = -.9*mH
   
        mH = mH+dmH
        m1 = m1+dm1
        

c       compute new activity
        mu=0.5*(mOH+mH+m2+m3+m4+m5)
        act = 10**(-A*sqrt(mu)/(1.0+B*ao*sqrt(mu)))
      enddo

      pH = -log10(act*mH)

      mH = mH*DensLiq
      mOH = mOH*DensLiq
c      write(IOF,52) mH, mH*DensLiq, mOH,mOH*DensLiq
52    format(/5x 'mH = ',1pe15.6,/5x,'dmH = ',1pe15.6
     +       /5x 'mOH = ',1pe15.6,/5x,'dmOH = ',1pe15.6)

      return
      end  !of CalculatePH       


      real*8 function Current304Corr(PotDif,Mode)

c***********************************************************************
c     Version:        radical 1.8.4           November 2012
c     Author:         Jennifer Jarvis
c***********************************************************************
c
c	Calcuates the current due to H2/H+ redox couple
c       Mode 0 returns the current density
c       Mode 1 returns the first derivative wrt. ECP
c***********************************************************************
      include 'radical.blk'
      real*8 PotDif, b
      real*8 term1, dterm1dE, denom, curr,term2
      integer*4 Mode
 
      b = 0.06 ! units Volts
     
      term1 = exp(PotDif/b)/((2.61d-3)*dexp(-4416.0/
     +               (Temp+0.523*(abs(PotDif))**0.5))) !defined as X in MacDonald's papers
      denom = 384.62*exp(4416.0/Temp)+term1
      curr = 2*sinh(PotDif/b)/denom
      dterm1dE=term1*(1.0/b-4416.0*0.523/(2*sqrt(abs(PotDif)))
     +          /((Temp+0.523*sqrt(abs(PotDif)))**2.0)) 

      if (Mode.eq.0) then
        Current304Corr = curr
      else
	Current304Corr=(2.0*dcosh(PotDif/b)/b-curr*dterm1dE)/denom
      endif
      
c      write(IOF,52) term1,dterm1dE
52    format(/1x 'X = ',1pe15.6,
     +       /1x 'dterm1dE = ',1pe15.6)  
 
      return 
      end ! of CurrentH2

      real*8 function CurrentInconel(PotDif,ECPModel,Mode,Temp)

c***********************************************************************
c     Version:        radical 1.8.4           November 2012
c     Author:         Jennifer Jarvis
c***********************************************************************
c
c	Calcuates the current due to H2/H+ redox couple
c       Mode 0 returns the current density
c       Mode 1 returns the first derivative wrt. ECP
c***********************************************************************

      real*8 PotDif, ba, bc,Temp
      real*8 A,C,F
      real*8 term1, denom, curr
      integer*4 Mode
      character*10 ECPModel
 
      if(ECPModel.eq.'PAll600') then
        ba = 0.035
        bc = 0.095
        A = 1.18d-2*exp(-5411.3/Temp)
        C = 7.18
        F = 0.44
      elseif(ECPModel.eq.'PAll690') then
        ba = 0.055
        bc = 0.095
        A = 3.13d-4*exp(-3572.7/Temp)
        C = 6.41
        F = 0.43
      endif

      denom = 1.0/A + exp(PotDif/ba)/(A*exp(C*(abs(PotDif))**F))
      curr = (exp(PotDif/ba)-exp(-PotDif/bc))/denom

      if(Mode.eq.0) then
         CurrentInconel=curr
      else
         term1 =exp(PotDif/ba)/ba+exp(-PotDif/bc)/bc-curr*
     +      exp(PotDif/ba)/(A*exp(C*(abs(PotDif))**F)) *
     +      (1/ba-C*F*(abs(PotDif))**(F-1.0))

          CurrentInconel=term1/denom
      endif
      
      return 
      end ! of CurrentInconel

      real*8 function RedoxCurr(PotDif,b,ExCurrent,LimCurrA,LimCurrC,
     +       Mode,Anodic)

c***********************************************************************
c     Version:        radical 1.8.4           November 2012
c     Author:         Jennifer Jarvis
c***********************************************************************
c
c	Calcuates the current due to a redox couple
c       Mode 0 returns the current density
c       Mode 1 returns the first derivative wrt. ECP
c       Anodic = 0 . discounts the anodic term in the denominator 
c	(this happens when the annodic limiting current is sufficiently greater) 
c***********************************************************************
      include 'radical.blk'

      real*8 PotDif, b, ExCurrent
      real*8 term1, term2, term3, Denom
      real*8 LimCurrA, LimCurrC
      integer*4 Mode
      integer*4 Anodic
      
      term1 = 1/ExCurrent;
      if (Anodic.eq.0) then
        term2 = 0.0
      else 
        term2 = 1/LimCurrA
      endif
      term3 = 1/LimCurrC
      Denom = term1 + term2*exp(PotDif/b)-term3*exp(-PotDif/b)
      curr = 2*dsinh(PotDif/b)/Denom 

      if (Mode.eq.0) then
        RedoxCurr = curr
      else
	RedoxCurr=((1.0-curr*term2)*dexp(PotDif/b)
     +            +(1.0-curr*term3)*dexp(-PotDif/b))/(b*Denom) 
      endif
      
      return 
      end ! of RedoxCurr





