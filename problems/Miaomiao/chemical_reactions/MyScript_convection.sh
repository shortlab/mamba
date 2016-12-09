#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo h_convection_W/m^2 liquidheight_mm suctionflux_kg/m^2/s vaporavgtemp_K >> VaporAvgTemp_hconv.txt
for value in $(seq -s ' ' 1.42e4 0.4e3 1.5001e4);
do
echo convection coefficient $value
rm *.csv
echo crud_chem_5th.i starts
#This is for heat flux 1e6, 0.025 mm thickness, Tcoolant=584
~/Projects/mamba-dev/mamba-dev-opt -i crud_chem_5th.i BCs/temperature_up/h_convection_coolant=$value
cp crud_chem_5th.csv crud_chem_5th_hconv_$value.txt

python MyScript_liquidheight.py > temp.txt
liquidheight=$(cat $SCRIPT_DIR/temp.txt)
rm temp.txt
rm *.csv

echo "sub_5th_1.i starts"
~/Projects/mamba-dev/mamba-dev-opt -i sub_5th.i Mesh/ymax=$liquidheight Postprocessors/vapor_height/thickness=$liquidheight BCs/temperature_up/h_convection_coolant=$value Materials/material_CRUD/ConvectionCoefficient=$value Outputs/file_base=sub_5th_1
cp sub_5th_1.csv sub_5th_1_hconv_$value.txt

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
~/Projects/mamba-dev/mamba-dev-opt -i sub_5th.i Mesh/ymax=$liquidheight_new Postprocessors/vapor_height/thickness=$liquidheight_new  Materials/material_CRUD/ConvectionCoefficient=$value Outputs/file_base=sub_5th_${count}
cp sub_5th_${count}.csv sub_5th_${count}_hconv_$value.txt

python MyScript_iteration.py > temp2.txt
liquidheight_new=$(sed -n '1p' temp2.txt)
difference=$(sed -n '2p' temp2.txt)
count=$(($count+1))
G=$(sed -n '3p' temp2.txt)
VaporAvgTemp=$(sed -n '4p' temp2.txt)
rm temp2.txt
rm *.csv
done

echo $value $liquidheight_new $G $VaporAvgTemp >> VaporAvgTemp_hconv.txt
done

