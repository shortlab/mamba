#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#This file is used to parametric analysis on chimeny density linspace(5.0e8,4.0e9,8), the other parameters' values stay the same with the typical PWR
for chimney_outer in 0.025231325220202 0.017841241161528 0.014567312407894 0.012615662610101 0.011283791670955 0.010300645387285 0.009536544540178 0.008920620580764;
do
  echo chimney_outer $chimney_outer

thickness=0.025
vapor_height=0.008
liquid_height=$(echo "$thickness-$vapor_height" | bc -l)
chimney_outer_SI=$(echo "$chimney_outer/1000" | bc -l) #SI unit for chimney
i=0

sed "/ymin/ c ymin = $vapor_height" sub_5th_typical.i > sub_5th_typical_temp1_$i.i
sed "/xmax/ c xmax = $chimney_outer" sub_5th_typical_temp1_$i.i > sub_5th_typical_temp2_$i.i
sed "/outer/ c cell_outer_radius = $chimney_outer_SI" sub_5th_typical_temp2_$i.i > sub_5th_typical_temp3_$i.i

sed "/ymax/ c ymax = $vapor_height" subsub_5th_typical.i > subsub_5th_typical_temp1_$i.i
sed "/xmax/ c xmax = $chimney_outer" subsub_5th_typical_temp1_$i.i > subsub_5th_typical_temp2_$i.i
sed "/outer/ c cell_outer_radius = $chimney_outer_SI" subsub_5th_typical_temp2_$i.i > subsub_5th_typical_temp_$i.i

sed "/input_files/ c input_files = /home/mmjin/projects/mamba-dev/problems/Miaomiao/MultiApp/InterpolationTransfer/parametric_chimneydensity_typicalPWR/subsub_5th_typical_temp_$i.i" sub_5th_typical_temp3_$i.i > sub_5th_typical_temp_$i.i


mpiexec -n 16 ~/projects/mamba-dev/mamba-dev-opt -i sub_5th_typical_temp_$i.i

python MyScript_vaporheight.py > temp.txt
h_vapor_from_sub=$(sed 's/e/E/g' temp.txt)
echo $h_vapor_from_sub chimney_outer $chimney_outer i $i vapor_height $vapor_height >> vapor_height.txt
#h_vapor_from_sub=$(cat $SCRIPT_DIR/temp.txt)

cp sub_5th_typical.csv sub_5th_typical_${i}_$chimney_outer.csv
cp subsub_5th_typical.csv subsub_5th_typical_${i}_$chimney_outer.csv
rm sub_5th_typical.csv subsub_5th_typical.csv temp.txt

while [ $i -lt 22 ];
do
  i=$((i+1))
#The follow is to find whether h is too small or too large and then change vapor region dimension
  if [ $(echo "$h_vapor_from_sub < 0.01" | bc) -eq 1 ]; then
    vapor_height=$(echo "$vapor_height-0.0004" | bc -l)
  elif [ $(echo "$h_vapor_from_sub > 0.06 " | bc) -eq 1 ]; then
    vapor_height=$(echo "$vapor_height+0.0003" | bc -l)
  else
    echo i $i and chimney_outer $chimney_outer vapor_height $vapor_height stop here  >> log.txt
    break
  fi

  sed "/ymin/ c ymin = $vapor_height" sub_5th_typical.i > sub_5th_typical_temp1_$i.i
  sed "/xmax/ c xmax = $chimney_outer" sub_5th_typical_temp1_$i.i > sub_5th_typical_temp2_$i.i
  sed "/outer/ c cell_outer_radius = $chimney_outer_SI" sub_5th_typical_temp2_$i.i > sub_5th_typical_temp3_$i.i


  sed "/ymax/ c ymax = $vapor_height" subsub_5th_typical.i > subsub_5th_typical_temp1_$i.i
  sed "/xmax/ c xmax = $chimney_outer" subsub_5th_typical_temp1_$i.i > subsub_5th_typical_temp2_$i.i
  sed "/outer/ c cell_outer_radius = $chimney_outer_SI" subsub_5th_typical_temp2_$i.i > subsub_5th_typical_temp_$i.i

  sed "/input_files/ c input_files = /home/mmjin/projects/mamba-dev/problems/Miaomiao/MultiApp/InterpolationTransfer/parametric_chimneydensity_typicalPWR/subsub_5th_typical_temp_$i.i" sub_5th_typical_temp3_$i.i > sub_5th_typical_temp_$i.i

  mpiexec -n 16 ~/projects/mamba-dev/mamba-dev-opt -i sub_5th_typical_temp_$i.i
  python MyScript_vaporheight.py > temp.txt
  h_vapor_from_sub=$(sed 's/e/E/g' temp.txt)
  echo $h_vapor_from_sub chimney_outer $chimney_outer i $i vapor_height $vapor_height >> vapor_height.txt
  #h_vapor_from_sub=$(cat $SCRIPT_DIR/temp.txt)

  cp sub_5th_typical.csv sub_5th_typical_${i}_$chimney_outer.csv
  cp subsub_5th_typical.csv subsub_5th_typical_${i}_$chimney_outer.csv
  rm sub_5th_typical.csv subsub_5th_typical.csv temp.txt
done
rm *temp1* *temp2*
done 
  
