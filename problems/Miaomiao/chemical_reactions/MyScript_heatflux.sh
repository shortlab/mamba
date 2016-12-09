#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo heatflux liquidheight_mm suctionflux_kg/m^2/s vaporavgtemp_K >> VaporAvgTemp_Tcoolant.txt
for heatflux in $(seq -s ' ' 6.0e5 4.0e5 1.2e6);
do
echo heatflux $heatflux
for value in $(seq -s ' ' 600 4.0 600.01);
do
echo Tcoolant $value
rm *.csv
echo crud_chem_5th.i starts
#This is for heat flux 1e6, 0.025 mm thickness, h=13000~1.5e4
~/Projects/mamba-dev/mamba-dev-opt -i crud_chem_5th.i Materials/material_CRUD/CladHeatFluxIn=$heatflux BCs/temperature_up/T_coolant=$value BCs/temperature_up/h_convection_coolant=19000.0 Materials/material_CRUD/ConvectionCoefficient=19000.0 
cp crud_chem_5th.csv crud_chem_5th_${value}_19000_${heatflux}.txt

python MyScript_liquidheight.py > temp.txt
liquidheight=$(cat $SCRIPT_DIR/temp.txt)
rm temp.txt
rm *.csv

echo "sub_5th_1.i starts"
~/Projects/mamba-dev/mamba-dev-opt -i sub_5th.i Mesh/ymax=$liquidheight Postprocessors/vapor_height/thickness=$liquidheight BCs/temperature_up/T_coolant=$value Materials/material_CRUD/CladHeatFluxIn=$heatflux BCs/temperature_up/h_convection_coolant=19000 Materials/material_CRUD/ConvectionCoefficient=19000 Outputs/file_base=sub_5th_1
cp sub_5th_1.csv sub_5th_1_${value}_19000_${heatflux}.txt

python MyScript_iteration.py > temp1.txt
liquidheight_new=$(sed -n '1p' temp1.txt)
difference=$(sed -n '2p' temp1.txt)
G=$(sed -n '3p' temp1.txt)
VaporAvgTemp=$(sed -n '4p' temp1.txt)
rm temp1.txt
rm *.csv

count=2
while [ $difference -eq 1 ] && [ $count -lt 3 ]
do
echo "sub_5th_${count} starts"
~/Projects/mamba-dev/mamba-dev-opt -i sub_5th.i Mesh/ymax=$liquidheight_new Postprocessors/vapor_height/thickness=$liquidheight_new Materials/material_CRUD/CladHeatFluxIn=$heatflux BCs/temperature_up/T_coolant=$value BCs/temperature_up/h_convection_coolant=19000 Materials/material_CRUD/ConvectionCoefficient=19000 Outputs/file_base=sub_5th_${count}
cp sub_5th_${count}.csv sub_5th_${count}_${value}_19000_${heatflux}.txt

python MyScript_iteration.py > temp2.txt
liquidheight_new=$(sed -n '1p' temp2.txt)
difference=$(sed -n '2p' temp2.txt)
count=$(($count+1))
G=$(sed -n '3p' temp2.txt)
VaporAvgTemp=$(sed -n '4p' temp2.txt)
python MyScript_vaporheight.py > temp3.txt
rm temp2.txt
rm *.csv
done

echo $heatflux $liquidheight_new $G $VaporAvgTemp >> VaporAvgTemp_Tcoolant.txt
done

#tar -zcvf 25_0.5_19000_${value}_heatflux.tgz *.txt
#rm *.txt
done

