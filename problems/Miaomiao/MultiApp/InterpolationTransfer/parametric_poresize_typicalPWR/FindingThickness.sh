#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#This file is used to parametric analysis on pore size, the other parameters' values stay the same with the typical PWR
pore_min=0.00000025
#pore_max=$(seq -s ' ' 0.0000004 0.0000001 0.00000082)
for pore_max in $(seq -s ' ' 0.0000008 0.0000001 0.00000082);
do
  echo pore_max $pore_max

thickness=0.025
vapor_height=0.0044
liquid_height=$(echo "$thickness-$vapor_height" | bc -l)
pore_avg=$(echo "($pore_max+$pore_min)/2.0" | bc -l) #SI unit for chimney
i=10

sed "/ymin/ c ymin = $vapor_height" sub_5th_typical.i > sub_5th_typical_temp1_$i.i
sed "/pore_size_avg/ c pore_size_avg_baseline = $pore_avg" sub_5th_typical_temp1_$i.i > sub_5th_typical_temp2_$i.i
sed "/pore_size_max_baseline/ c pore_size_max_baseline = $pore_max" sub_5th_typical_temp2_$i.i > sub_5th_typical_temp3_$i.i

sed "/ymax/ c ymax = $vapor_height" subsub_5th_typical.i > subsub_5th_typical_temp1_$i.i
sed "/pore_size_avg/ c pore_size_avg_baseline = $pore_avg" subsub_5th_typical_temp1_$i.i > subsub_5th_typical_temp2_$i.i
sed "/pore_size_max_baseline/ c pore_size_max_baseline = $pore_max" subsub_5th_typical_temp2_$i.i > subsub_5th_typical_temp_$i.i

sed "/input_files/ c input_files = /home/mmjin/projects/mamba-dev/problems/Miaomiao/MultiApp/InterpolationTransfer/parametric_poresize_typicalPWR/subsub_5th_typical_temp_$i.i" sub_5th_typical_temp3_$i.i > sub_5th_typical_temp_$i.i


mpiexec -n 16 ~/projects/mamba-dev/mamba-dev-opt -i sub_5th_typical_temp_$i.i

python MyScript_vaporheight.py > temp.txt
h_vapor_from_sub=$(sed 's/e/E/g' temp.txt)
echo $h_vapor_from_sub pore_max $pore_max i $i vapor_height $vapor_height >> vapor_height.txt
#h_vapor_from_sub=$(cat $SCRIPT_DIR/temp.txt)

cp sub_5th_typical.csv sub_5th_typical_${i}_$pore_max.csv
cp subsub_5th_typical.csv subsub_5th_typical_${i}_$pore_max.csv
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
    echo i $i and pore_max $pore_max vapor_height $vapor_height stop here  >> log.txt
    break
  fi

  sed "/ymin/ c ymin = $vapor_height" sub_5th_typical.i > sub_5th_typical_temp1_$i.i
  sed "/pore_size_avg/ c pore_size_avg_baseline = $pore_avg" sub_5th_typical_temp1_$i.i > sub_5th_typical_temp2_$i.i
  sed "/pore_size_max_baseline/ c pore_size_max_baseline = $pore_max" sub_5th_typical_temp2_$i.i > sub_5th_typical_temp3_$i.i

  sed "/ymax/ c ymax = $vapor_height" subsub_5th_typical.i > subsub_5th_typical_temp1_$i.i
  sed "/pore_size_avg/ c pore_size_avg_baseline = $pore_avg" subsub_5th_typical_temp1_$i.i > subsub_5th_typical_temp2_$i.i
  sed "/pore_size_max_baseline/ c pore_size_max_baseline = $pore_max" subsub_5th_typical_temp2_$i.i > subsub_5th_typical_temp_$i.i

  sed "/input_files/ c input_files = /home/mmjin/projects/mamba-dev/problems/Miaomiao/MultiApp/InterpolationTransfer/parametric_poresize_typicalPWR/subsub_5th_typical_temp_$i.i" sub_5th_typical_temp3_$i.i > sub_5th_typical_temp_$i.i

  mpiexec -n 16 ~/projects/mamba-dev/mamba-dev-opt -i sub_5th_typical_temp_$i.i
  python MyScript_vaporheight.py > temp.txt
  h_vapor_from_sub=$(sed 's/e/E/g' temp.txt)
  echo $h_vapor_from_sub pore_max $pore_max i $i vapor_height $vapor_height >> vapor_height.txt
  #h_vapor_from_sub=$(cat $SCRIPT_DIR/temp.txt)

  cp sub_5th_typical.csv sub_5th_typical_${i}_$pore_max.csv
  cp subsub_5th_typical.csv subsub_5th_typical_${i}_$pore_max.csv
  rm sub_5th_typical.csv subsub_5th_typical.csv temp.txt
done
rm *temp1* *temp2*
done 
  
