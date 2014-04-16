// Include statements, preprocessor directives

#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<string.h>
#include<time.h>

// Function prototypes

void SetVariableBounds();	// Ask the user for ranges for scripted variable lower and upper bounds
int RecursiveDefineSimulation(unsigned char, char *);	// Recursively decide when to run simulations and/or increment variables
void BuildInputFiles();		// Builds the input files for the simulation
void Run2D3D(char *);			// Runs the simulations in question
void AppendCurrentDataPoint();	// Appends the current datapoint to the master file

// Create a global structure that has all the variables that will vary during the simulation

typedef struct {
	char FancyName[100];
	char CodeName[50];
	double LowerBound;
	double UpperBound;
	double Increment;
	double CurrentValue;
} ScriptedVariable;

// Initialize the names of the variables for the global structures

ScriptedVariable MyVars[8];


void SetVariableBounds(void)
{
	strncpy(MyVars[0].FancyName, "CRUD Thickness in Microns", 100);
	strncpy(MyVars[0].CodeName, "crud_thickness_microns", 50);

	strncpy(MyVars[1].FancyName, "Chimney Radius in Microns", 100);
	strncpy(MyVars[1].CodeName, "chimney_radius_microns", 50);

	strncpy(MyVars[2].FancyName, "Chimney Density in chim/m2", 100);
	strncpy(MyVars[2].CodeName, "chimney_density_m", 50);

	strncpy(MyVars[3].FancyName, "Boric Acid in Mole Fraction", 100);
	strncpy(MyVars[3].CodeName, "coolant_boric_acid_mole_frac", 50);

	strncpy(MyVars[4].FancyName, "Coolant Temperature in Kelvin", 100);
	strncpy(MyVars[4].CodeName, "coolant_temperature_K", 50);

	strncpy(MyVars[5].FancyName, "Skeletal Porosity (fraction)", 100);
	strncpy(MyVars[5].CodeName, "skeletal_porosity", 50);

	strncpy(MyVars[6].FancyName, "Clad Heat Flux in W/m2", 100);
	strncpy(MyVars[6].CodeName, "clad_heat_flux_W_m2", 50);

	strncpy(MyVars[7].FancyName, "Heat Trans. Coeff. at Coolant in W/m2K", 100);
	strncpy(MyVars[7].CodeName, "h_conv_crud_coolant_W_m2s", 50);

	unsigned char i;
	for (i=0; i<(sizeof(MyVars)/sizeof(ScriptedVariable)); i++)
	{
		printf("Variable: %s\n", MyVars[i].FancyName);		// Print the variable
		printf("Lower bound = ");
		scanf("%lf", &MyVars[i].LowerBound);	// Ask the user for the lower bound
		printf("Upper bound = ");
		scanf("%lf", &MyVars[i].UpperBound);	// Ask the user for the upper bound
		printf("Increment = ");
		scanf("%lf", &MyVars[i].Increment);		// Ask the user for the increment bound
		MyVars[i].CurrentValue = MyVars[i].LowerBound;		// Set the current value to the lower bound
	}
}


void BuildInputFiles(void)
{

// Write a file with the current simulation parameters for both simulations,
// straight from the structs.

// The 2D simulation input file has aprepro algebra to convert the real chimney spacing
// in 3D to a modified spacing in 2D, so that the volume of CRUD
// in the 2D and 3D simulations are identical.

	FILE *InputHeader;
	InputHeader = fopen("InputHead.i", "w");
	int i;
	for (i=0; i<(sizeof(MyVars)/sizeof(ScriptedVariable)); i++)
	{
		fprintf(InputHeader, "#{%s = %lf}\n", MyVars[i].CodeName, MyVars[i].CurrentValue);
	}
	fclose(InputHeader);

// Copy this twice, once for 2D, once for 3D

	system("cp InputHead.i MAMBA-BDM-2D.i");
	system("cp InputHead.i MAMBA-BDM-3D.i");

// Copy the rest of the input file to something else, to avoid changing it by mistake

	system("cp MAMBA-BDM-2D-Append.i InputFoot-2D.i");
	system("cp MAMBA-BDM-3D-Append.i InputFoot-3D.i");

// Append each 2D/3D simulation's main input file to the parameters written above
// Now the input files are there and ready to be preprocessed

	system("cat InputFoot-2D.i >> MAMBA-BDM-2D.i");
	system("cat InputFoot-3D.i >> MAMBA-BDM-3D.i");

// OLD: DON'T aprepro here for the MAMBA script, since it takes care of that!!!
/*
// Run aprepro to evaluate the symbolic expressions in each input file

	system("aprepro MAMBA-BDM-2D.i MAMBA-BDM-2D-apreproed.i");
	system("aprepro MAMBA-BDM-3D.i MAMBA-BDM-3D-apreproed.i");
*/

// Clean up any files that are no longer needed

	system("rm InputFoot-2D.i");
	system("rm InputFoot-3D.i");
	system("rm InputHead.i");

// Now construct the mesh file for the 3D simulation, using aprepro to prepare
// a script for CUBIT on the command line.

// ***NOTE***  The current mesh includes CRUD, clad, and oxide for future expandability

// The 'for' loop just writes the first three structs, which are the ones
// that dictate CRUD chimney geometry.

	FILE *MeshHeader;
	MeshHeader = fopen("MAMBA-3D-One-Chimney.jou", "w");
	for (i=0; i<=2; i++)
	{
		fprintf(MeshHeader, "#{%s = %lf}\n", MyVars[i].CodeName, MyVars[i].CurrentValue);
	}
	fclose(MeshHeader);

// Append the rest of the journal file for CUBIT to make the 3D mesh

	system("cat 3D-CRUD-One-Chimney-Append.jou >> MAMBA-3D-One-Chimney.jou");

// Run aprepro to pre-process the CUBIT journal file

	system("aprepro MAMBA-3D-One-Chimney.jou MAMBA-3D-One-Chimney-apreproed.jou");

// Run CUBIT to generate the file "MAMBA-3D-One-Chimney.e" for the 3D simulation

	system("cubit -nogui -nographics -batch MAMBA-3D-One-Chimney-apreproed.jou");
//	system("cubit -batch MAMBA-3D-One-Chimney-apreproed.jou");

// Clean up the temporary files

	system("rm MAMBA-3D-One-Chimney.jou");
	system("rm MAMBA-3D-One-Chimney-apreproed.jou");
	system("rm cubit01.jou");
	system("rm history01.jou");
}


void Run2D3D(char * FN)
{

	double PeakCladTemp;

// Build the input files for this simulation

	BuildInputFiles();

// Tell the user which simulation is being run

	printf("Running simulation: \n");
	int i;
	for (i=0; i<(sizeof(MyVars)/sizeof(ScriptedVariable)); i++)
	{
		printf("%s = %lf\n", MyVars[i].FancyName, MyVars[i].CurrentValue);	// PLACEHOLDER
	}

// Run the simulation, first in 2D, then in 3D

	system("./run_MAMBA.sh MAMBA-BDM-2D.i");

// Open the PeakCladTemp.out file for reading

	FILE *input = fopen("PeakCladTemp.out", "r+");
	if (input == NULL)
		perror ("Error opening file");
	else
	{
		while(feof(input) == 0)
		{
			fscanf(input, "PeakCladTemp = ");
			fscanf(input, "%lf", &PeakCladTemp);
		}
		fclose(input);
	}

// Append data from 2D to the master datafile

	FILE *DataFile;
	DataFile = fopen(FN, "a");
	for (i=0; i<(sizeof(MyVars)/sizeof(ScriptedVariable)); i++)
	{
		fprintf(DataFile, "\"%lf\",", MyVars[i].CurrentValue);
	}
	fprintf(DataFile, "%lf,", PeakCladTemp);

// Run the 3D simulation

	system("./run_MAMBA.sh MAMBA-BDM-3D.i");

// Open the PeakCladTemp.out file for reading

	FILE *input2 = fopen("PeakCladTemp.out", "r+");
	if (input2 == NULL)
		perror ("Error opening file");
	else
	{
		while(feof(input2) == 0)
		{
			fscanf(input2, "PeakCladTemp = ");
			fscanf(input2, "%lf", &PeakCladTemp);
		}
		fclose(input2);
	}

// Append data from 3D to the master datafile

	fprintf(DataFile, "%lf\n", PeakCladTemp);

// Close the file, so nothing gets written by accident.

	fclose(DataFile);

// Clean up the input files

//	system("rm MAMBA-BDM-2D.i");
//	system("rm MAMBA-BDM-3D.i");
//	system("rm MAMBA-apreproed.i");

// Clean up the 3D mesh file

	system("rm MAMBA-3D-One-Chimney.e");

// Let the user know that we're done with this simulation

	printf("Simulation finished.\n\n\n");
}


int RecursiveDefineSimulation(unsigned char CurrentIndex, char * FN)
{
	int FinishCode;		// Tells this function what the next level encountered
				// Codes:
				// -1 - Explosion!!!
				// 0 - Master escape: All simulations complete
				// 1 - Simulation finished successfully, upper bound reached
				// 2 - Current variable's upper bound reached

// Check for a negative CurrentIndex

	if (CurrentIndex < 0)
	{
		printf("Explosion!!!");
		return -1;
	}

// Run a simulation with the current set of parameters, if we're at the end of the chain

	if (CurrentIndex == 0)
	{
		MyVars[CurrentIndex].CurrentValue = MyVars[CurrentIndex].LowerBound;	// Start at the lowest value
		do
		{

			Run2D3D(FN);
			MyVars[CurrentIndex].CurrentValue += MyVars[CurrentIndex].Increment;
			if (MyVars[CurrentIndex].CurrentValue <= MyVars[CurrentIndex].UpperBound)
				printf("%s incremented to %lf, upper bound is %lf\n", MyVars[CurrentIndex].FancyName, MyVars[CurrentIndex].CurrentValue, MyVars[CurrentIndex].UpperBound);
		} while (MyVars[CurrentIndex].CurrentValue <= MyVars[CurrentIndex].UpperBound);
		return 1;
	}

// If not, move one link down the chain

	if (CurrentIndex > 0)
	{
		MyVars[CurrentIndex].CurrentValue = MyVars[CurrentIndex].LowerBound;// Start at the lowest value
		do
		{

// Master escape condition: the highest variable (first link) exceeds its upper bound

			if (MyVars[(sizeof(MyVars)/sizeof(ScriptedVariable)) - 1].CurrentValue > MyVars[(sizeof(MyVars)/sizeof(ScriptedVariable)) - 1].UpperBound)
			{
				printf("MASTER ESCAPE!!!\n\n\n\n\n\n\n");
				return 0;
			}

			FinishCode = RecursiveDefineSimulation((CurrentIndex - 1), FN);
			MyVars[CurrentIndex].CurrentValue += MyVars[CurrentIndex].Increment;
			if (MyVars[CurrentIndex].CurrentValue <= MyVars[CurrentIndex].UpperBound)
				printf("%s incremented to %lf, upper bound is %lf\n", MyVars[CurrentIndex].FancyName, MyVars[CurrentIndex].CurrentValue, MyVars[CurrentIndex].UpperBound);
		} while (MyVars[CurrentIndex].CurrentValue <= MyVars[CurrentIndex].UpperBound);
	}

	return 2;
}


int main(void)
{

// First, clear the screen

	system ("clear");

// Lock in the time that this simulation was started

	time_t start_sec = time(NULL);

// Display a welcome message

	printf("MAMBA-BDM 2D/3D Comparison Script\n\n");

// Start by asking the user for ranges for all the scripted variables

	SetVariableBounds();

// Create a CSV file to hold the accumulated results, tagged with POSIX time

	char Filename[100] = "MAMBA-BDM-Data-POSIX-";
	char Filetime[100];
	sprintf(Filetime, "%ld", start_sec);
	strcat(Filename, Filetime);

	FILE *DataFile;
	DataFile = fopen(Filename, "w");
	int i;
	for (i=0; i<(sizeof(MyVars)/sizeof(ScriptedVariable)); i++)
	{
		fprintf(DataFile, "\"%s\",", MyVars[i].FancyName);
	}
	fprintf(DataFile, "\"2D Peak Clad Temp (K)\",");
	fprintf(DataFile, "\"3D Peak Clad Temp (K)\"\n");
	fclose(DataFile);

// Set up a recursive loop to increment the current set of variable values

	RecursiveDefineSimulation((sizeof(MyVars)/sizeof(ScriptedVariable)), Filename);

// Text the user (Mike) when the simulations are finished

//	system("wget http://www.mike-short.com/FinishedSimulation.php");
//	system("rm FinishedSimulation.php");

	return 0;
}

