#include <iostream>
#include <fstream>
#include <iomanip>
#include <string>
#include <cmath>
using namespace std;

int main(){

	// define variables

	//RADICAL reaction set 
	int Nrxn = 49;
	
	string rxn_name[] = {	"R2" , "R3" , "R4" , "R5" , "R6" ,
				"R7" , "R8" , "R9", "R10", "R11",
				"R12", "R13", "R14", "A14", "R15",
				"R16", "R17", "R18", "R19", "R20",
				"R21", "R22", "A22", "f23", "b23",
				"f24", "b24", "f25", "b25", "f26",
				"b26", "f27", "b27", "f28", "b28",
				"f29", "b29", "f30", "b30", "f31",
				"b31", "f32", "b32", "R33", "R34",
				"R35", "R36", "f37", "b37" };

	string reactants[][3] = {	{	"e-"	,	"e-"	,	" "	},   //	R2
					{	"H"	,	"H"	,	" "	},   //	R3
					{	"H"	,	"OH"	,	" "	},   //	R4
					{	"e-"	,	"H"	,	" "	},   //	R5
					{	"e-"	,	"OH"	,	" "	},   //	R6
					{	"H"	,	"OH"	,	" "	},   //	R7
					{	"e-"	,	"H2O2"	,	" "	},   //	R8
					{	"e-"	,	"O2"	,	" "	},   //	R9
					{	"e-"	,	"O2-"	,	" "	},   //	R10
					{	"e-"	,	"HO2"	,	" "	},   //	R11
					{	"H"	,	"H2O2"	,	" "	},   //	R12
					{	"H"	,	"O2"	,	" "	},   //	R13
					{	"H"	,	"HO2"	,	" "	},   //	R14
					{	"H"	,	"HO2"	,	" "	},   //	A14
					{	"H"	,	"O2-"	,	" "	},   //	R15
					{	"OH"	,	"H2O2"	,	" "	},   //	R16
					{	"OH"	,	"O2-"	,	" "	},   //	R17
					{	"OH"	,	"HO2"	,	" "	},   //	R18
					{	"HO2"	,	"HO2"	,	" "	},   //	R19
					{	"O2-"	,	"HO2"	,	" "	},   //	R20
					{	"O2-"	,	"O2-"	,	" "	},   //	R21
					{	"H2O2"	,	" "	,	" "	},   //	R22
					{	"H2O2"	,	" "	,	" "	},   //	A22
					{	" "	,	" "	,	" "	},   //	F23
					{	"H+"	,	"OH-"	,	" "	},   //	B23
					{	"H2O2"	,	" "	,	" "	},   //	F24
					{	"H+"	,	"HO2-"	,	" "	},   //	B24
					{	"H2O2"	,	"OH-"	,	" "	},   //	F25
					{	"HO2-"	,	"H2O"	,	" "	},   //	B25
					{	"OH"	,	" "	,	" "	},   //	F26
					{	"H+"	,	"O-"	,	" "	},   //	B26
					{	"OH"	,	"OH-"	,	" "	},   //	F27
					{	"O-"	,	"H2O"	,	" "	},   //	B27
					{	"HO2"	,	" "	,	" "	},   //	F28
					{	"H+"	,	"O2-"	,	" "	},   //	B28
					{	"HO2"	,	"OH-"	,	" "	},   //	F29
					{	"O2-"	,	"H2O"	,	" "	},   //	B29
					{	"H"	,	" "	,	" "	},   //	F30
					{	"H+"	,	"e-"	,	" "	},   //	B30
					{	"H"	,	"OH-"	,	" "	},   //	F31
					{	"e-"	,	"H2O"	,	" "	},   //	B31
					{	"H"	,	"H2O"	,	" "	},   //	F32
					{	"H2"	,	"OH"	,	" "	},   //	B32
					{	"OH"	,	"HO2-"	,	" "	},   //	R33
					{	"O-"	,	"H2O2"	,	" "	},   //	R34
					{	"O-"	,	"HO2-"	,	" "	},   //	R35
					{	"O-"	,	"H2"	,	" "	},   //	R36
					{	"O-"	,	"O2"	,	" "	},   //	F37
					{	"O3-"	,	" "	,	" "	}};   //	B37




	string products[][4] = {	{	"H2"	,	"OH-"	,	"OH-"	,	" "	},  //	R2
					{	"H2"	,	" "	,	" "	,	" "	},  //	R3
					{	"H2O2"	,	" "	,	" "	,	" "	},  //	R4
					{	"H2"	,	"OH-"	,	" "	,	" "	},  //	R5
					{	"OH-"	,	" "	,	" "	,	" "	},  //	R6
					{	"H2O"	,	" "	,	" "	,	" "	},  //	R7
					{	"OH"	,	"OH-"	,	" "	,	" "	},  //	R8
					{	"O2-"	,	" "	,	" "	,	" "	},  //	R9
					{	"H2O2"	,	"OH-"	,	"OH-"	,	" "	},  //	R10
					{	"HO2-"	,	" "	,	" "	,	" "	},  //	R11
					{	"OH"	,	"H2O"	,	" "	,	" "	},  //	R12
					{	"HO2"	,	" "	,	" "	,	" "	},  //	R13
					{	"H2O2"	,	" "	,	" "	,	" "	},  //	R14
					{	"OH"	,	"OH"	,	" "	,	" "	},  //	A14
					{	"HO2-"	,	" "	,	" "	,	" "	},  //	R15
					{	"HO2"	,	"H2O"	,	" "	,	" "	},  //	R16
					{	"O2"	,	"OH-"	,	" "	,	" "	},  //	R17
					{	"O2"	,	"H2O"	,	" "	,	" "	},  //	R18
					{	"H2O2"	,	"O2"	,	" "	,	" "	},  //	R19
					{	"H2O2"	,	"O2"	,	"OH-"	,	" "	},  //	R20
					{	"H2O2"	,	"O2"	,	"OH-"	,	"OH-"	},  //	R21
					{	"O"	,	"H2O"	,	" "	,	" "	},  //	R22
					{	"OH"	,	"OH"	,	" "	,	" "	},  //	A22
					{	"H+"	,	"OH-"	,	" "	,	" "	},  //	F23
					{	"H2O"	,	" "	,	" "	,	" "	},  //	B23
					{	"H+"	,	"HO2-"	,	" "	,	" "	},  //	F24
					{	"H2O2"	,	" "	,	" "	,	" "	},  //	B24
					{	"HO2-"	,	"H2O"	,	" "	,	" "	},  //	F25
					{	"H2O2"	,	"OH-"	,	" "	,	" "	},  //	B25
					{	"H+"	,	"O-"	,	" "	,	" "	},  //	F26
					{	"OH"	,	" "	,	" "	,	" "	},  //	B26
					{	"O-"	,	"H2O"	,	" "	,	" "	},  //	F27
					{	"OH"	,	"OH-"	,	" "	,	" "	},  //	B27
					{	"H+"	,	"O2-"	,	" "	,	" "	},  //	F28
					{	"HO2"	,	" "	,	" "	,	" "	},  //	B28
					{	"O2-"	,	"H2O"	,	" "	,	" "	},  //	F29
					{	"HO2"	,	"OH-"	,	" "	,	" "	},  //	B29
					{	"H+"	,	"e-"	,	" "	,	" "	},  //	F30
					{	"H"	,	" "	,	" "	,	" "	},  //	B30
					{	"e-"	,	"H2O"	,	" "	,	" "	},  //	F31
					{	"H"	,	"OH-"	,	" "	,	" "	},  //	B31
					{	"H2"	,	"OH"	,	" "	,	" "	},  //	F32
					{	"H"	,	"H2O"	,	" "	,	" "	},  //	B32
					{	"H2O"	,	"O2-"	,	" "	,	" "	},  //	R33
					{	"OH-"	,	"HO2"	,	" "	,	" "	},  //	R34
					{	"OH-"	,	"O2-"	,	" "	,	" "	},  //	R35
					{	"H"	,	"O2-"	,	" "	,	" "	},  //	R36
					{	"O3-"	,	" "	,	" "	,	" "	},  //	F37
					{	"O-"	,	"O2"	,	" "	,	" "	}};  //	B37
	





	double RC[][5] = 	{	{-4.753E+01,	4.920E+04,	-1.036E+07,	0	,	0	},   //	R2	above 150C only (see report for below 150C)	
					{5.100E+09,	1.550E+01,	0	,	0	,	0	},   //	R3		
					{8.054E+00,	2.193E+03,	-7.395E+05,	6.870E+07,	0	},   //	R4		
					{2.760E+10,	1.490E+01,	0	,	0	,	0	},   //	R5		
					{1.312E+01,	-1.023E+03,	7.624E+04,	0	,	0	},   //	R6		
					{1.100E+10,	9.100E+00,	0	,	0	,	0	},   //	R7		
					{1.400E+10,	1.570E+01,	0	,	0	,	0	},   //	R8		
					{2.300E+10,	1.160E+01,	0	,	0	,	0	},   //	R9		
					{1.300E+10,	1.300E+01,	0	,	0	,	0	},   //	R10		
					{1.300E+10,	1.300E+01,	0	,	0	,	0	},   //	R11		
					{3.600E+07,	2.110E+01,	0	,	0	,	0	},   //	R12		
					{1.070E+01,	2.840E+02,	-1.369E+05,	0	,	0	},   //	R13		
					{0	,	0	,	0	,	0	,	0	},   //	R14	currently advised to use A14 mechanism only (R14a)	
					{1.130E+10,	1.520E+01,	0	,	0	,	0	},   //	A14		
					{1.130E+10,	1.520E+01,	0	,	0	,	0	},   //	R15		
					{2.900E+07,	1.380E+01,	0	,	0	,	0	},   //	R16		
					{1.100E+10,	1.090E+01,	0	,	0	,	0	},   //	R17		
					{8.800E+09,	6.600E+00,	0	,	0	,	0	},   //	R18		
					{8.400E+05,	2.010E+01,	0	,	0	,	0	},   //	R19		
					{0	,	0	,	0	,	0	,	0	},   //	R20	?	no 
					{0	,	0	,	0	,	0	,	0	},   //	R21	?	don't use-  no available data
					{0	,	0	,	0	,	0	,	0	},   //	R22	?	only use one of R22 or R22a
					{1.000E-07,	6.300E+01,	0	,	0	,	0	},   //	A22	?	
					{2.093E+01,	-1.236E+04,	6.364E+06,	-1.475E+09,	1.237E+11},   //	F23	kB23 * KH2O	
					{2.093E+01,	-1.236E+04,	6.364E+06,	-1.475E+09,	1.237E+11},   //	B23		
					{1.641E+01,	-4.888E+03,	1.622E+06,	-2.004E+08,	0	},   //	F24	kB24*KH2O2	
					{1.641E+01,	-4.888E+03,	1.622E+06,	-2.004E+08,	0	},   //	B24	same as Kb28	
					{1.334E+01,	-2.220E+03,	7.330E+05,	-1.065E+08,	0	},   //	F25	same as Kf27	
					{1.334E+01,	-2.220E+03,	7.330E+05,	-1.065E+08,	0	},   //	B25	Kf25*KH2O/KH2O2	
					{1.641E+01,	-4.888E+03,	1.622E+06,	-2.004E+08,	0	},   //	F26	Kb26*KOH	
					{1.641E+01,	-4.888E+03,	1.622E+06,	-2.004E+08,	0	},   //	B26	same as Kb28	
					{1.334E+01,	-2.220E+03,	7.330E+05,	-1.065E+08,	0	},   //	F27		
					{1.334E+01,	-2.220E+03,	7.330E+05,	-1.065E+08,	0	},   //	B27	kF27 *KH2O/KOH	
					{1.641E+01,	-4.888E+03,	1.622E+06,	-2.004E+08,	0	},   //	F28	Kb28*KHO2	
					{1.641E+01,	-4.888E+03,	1.622E+06,	-2.004E+08,	0	},   //	B28		
					{1.334E+01,	-2.220E+03,	7.330E+05,	-1.065E+08,	0	},   //	F29	same as kf27	
					{1.334E+01,	-2.220E+03,	7.330E+05,	-1.065E+08,	0	},   //	B29	kf29*kH2O/KHO2	
					{3.913E+01,	-3.888E+04,	2.054E+07,	-4.899E+09,	4.376E+11},   //	F30	kb30*kH	
					{3.913E+01,	-3.888E+04,	2.054E+07,	-4.899E+09,	4.376E+11},   //	B30		
					{2.297E+01,	-1.971E+04,	1.137E+07,	-2.990E+09,	2.803E+11},   //	F31		
					{2.297E+01,	-1.971E+04,	1.137E+07,	-2.990E+09,	2.803E+11},   //	B31		
					{9.408E+00,	-2.827E+03,	-3.792E+05,	0	,	0	},   //	F32		
					{-1.156E+01,	3.255E+04,	-1.862E+07,	4.554E+09,	-4.136E+11},   //	B32		
					{8.100E+09,	1.190E+01,	0	,	0	,	0	},   //	R33	omit R34. (says to just assign combined rate constant to R33 or R34		
					{0	,	0	,	0	,	0	,	0	},   //	R34		
					{7.800E+08,	2.430E+01,	0	,	0	,	0	},   //	R35		
					{1.300E+08,	1.290E+01,	0	,	0	,	0	},   //	R36		
					{3.700E+09,	1.120E+01,	0	,	0	,	0	},   //	F37		
					{2.600E+03,	4.620E+01,	0	,	0	,	0	} };   //	B37		

	

 	string RCMode[] = { 	"P",   //	R2
			"A",   //	R3
			"P",   //	R4
			"A",   //	R5
			"P",   //	R6
			"A",   //	R7
			"A",   //	R8
			"A",   //	R9
			"A",   //	R10
			"A",   //	R11
			"A",   //	R12
			"P",   //	R13
			"A",   //	R14
			"A",   //	A14
			"A",   //	R15
			"A",   //	R16
			"A",   //	R17
			"A",   //	R18
			"A",   //	R19
			"A",   //	R20
			"A",   //	R21
			"A",   //	R22
			"A",   //	A22
			"Q",   //	F23
			"P",   //	B23
			"T",   //	F24
			"P",   //	B24
			"P",   //	F25
			"V",   //	B25
			"U",   //	F26
			"P",   //	B26
			"P",   //	F27
			"R",   //	B27
			"S",   //	F28
			"P",   //	B28
			"P",   //	F29
			"W",   //	B29
			"X",   //	F30
			"P",   //	B30
			"P",   //	F31
			"Y",   //	B31
			"P",   //	F32
			"P",   //	B32
			"A",   //	R33
			"A",   //	R34
			"A",   //	R35
			"A",   //	R36
			"A",   //	F37
			"A"};  //	B37

	double Tref = 298; // units in kelvin

	// g values
	int Nspecies = 15;
	string Species_Name[] = {"e-" ,	"H",	"H+",	"H2",	"OH",	
			"OH-",	"H2O2",	"H2O",	"HO2",	"HO2-", 
			"O2",	"O2-",	"O",	"O-",	"O3-"};


	double TC= 300; // Temperature in C

	double ggamma_e= 2.641+4.162e-3*TC+9.093e-6*pow(TC,2)-4.717e-8*pow(TC,3);
	double ggamma_H2O2=0.752-1.620e-3*TC;
	double ggamma_H2=0.419+8.721E-4*TC-4.971E-6*pow(TC,2)+1.503E-8*pow(TC,3);
	double ggamma_OH=2.531+1.134e-2*TC-1.269e-5*pow(TC,2)+3.513E-8*pow(TC,3);
	double ggamma_H= 0.556+2.198e-3*TC-1.184E-5*pow(TC,2)+5.223e-8*pow(TC,3);

	double G_Gamma[]= { 	ggamma_e, ggamma_H, ggamma_e, ggamma_H2, ggamma_OH, 
		0.0,	ggamma_H2O2, 0.0, 0.0, 0.0 ,
                0.0,  0.0,  0.0,  0.0, 	0.0 };


	double gneut_e= 0.96+1.09e-3*TC;
	double gneut_H2=0.75+8.02E-4*TC;
	double gneut_OH=0.99+6.26E-3*TC;
	double gneut_H2O2= 0.89-1.62E-3*TC;
	double gneut_HO2 = 0.03;
	double gneut_H = gneut_OH+2*gneut_H2O2-gneut_e-2*gneut_H2+3*gneut_HO2;

	double G_Neut[]= { gneut_e, gneut_H, gneut_e, gneut_H2, gneut_OH, 
		0.0,	gneut_H2O2, 0.0, gneut_HO2, 0.0 ,
                0.0,  0.0,  0.0,  0.0, 	0.0 };


	double G_Alpha[Nspecies];
	for (int i=0; i<Nspecies;i++)  {
		G_Alpha[i]=0.0;}
	double Mol_Weight[] = {	5.490E-04,1.000E+00,1.000E+00,2.000E+00,1.700E+01,
				1.700E+01,3.400E+01,1.800E+01,3.300E+01,3.300E+01,
				3.200E+01,3.200E+01,1.600E+01,1.600E+01,1.600E+01};
			

	ofstream WriteFile("aec.txt");

	WriteFile << " $Species and molecular weights" << endl ;
	WriteFile.setf(ios::left);
	WriteFile.setf(ios::showpoint);	
	for(int i=0;i<Nspecies;i++){
		WriteFile << ' ' << setw(8)  << Species_Name[i] << ' '
			<< setw(15) << Mol_Weight[i] <<endl;
	}
	WriteFile << " $Species and molecular weights" << endl <<endl;	 

	WriteFile << " $Reaction sets" << endl ;	
	for(int i=0;i<Nrxn;i++){	

		WriteFile << ' ' << setw(3) << rxn_name[i] << ' ' ;
		for(int j=0;j<3;j++) {
			WriteFile << setw(8) << reactants[i][j]; }
		WriteFile << '>' ;
		for(int j=0;j<4;j++) {
			WriteFile << setw(8) << products[i][j]; }
		WriteFile << endl;
	}
	WriteFile << " $End of Reaction sets" << endl <<endl;



	WriteFile << " $GValue" << endl ;
	WriteFile.setf(ios::left);
	WriteFile.setf(ios::showpoint);		
	for(int i=0;i<Nspecies;i++){
		WriteFile << ' ' << setw(8)  << Species_Name[i] 
			<< setw(15) << G_Gamma[i] 
			<< setw(15) << G_Neut[i] 
			<< setw(15) << G_Alpha[i] 
			<< setw(15) << Mol_Weight[i] <<endl;
	}
	WriteFile << " $End of GValue" << endl <<endl;	 



	//for rate constants(1x,a3,1x,3a8,1x,4a8,a1,5d15.8)
	WriteFile << " $Reaction" << endl ;	
	for(int i=0;i<Nrxn;i++){	

		WriteFile << ' ' << setw(3) << rxn_name[i] << ' ' ;
		for(int j=0;j<3;j++) {
			WriteFile << setw(8) << reactants[i][j]; }
		WriteFile << '>' ;
		for(int j=0;j<4;j++) {
			WriteFile << setw(8) << products[i][j]; }
		WriteFile <<  RCMode[i];
		for(int j=0;j<5;j++) {
			WriteFile << ' '<< setw(14) << RC[i][j]; }
		WriteFile << endl;
	}
	WriteFile << " $End of Reaction" << endl <<endl;
	WriteFile.close();	

	return 0;
}




