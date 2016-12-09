#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for porosity in $(seq -s ' ' 0.8 0.05 0.8);
do
  echo porosity $porosity

thickness=0.025
vapor_height=0.0021
liquid_height=$(echo "$thickness-$vapor_height" | bc -l)

i=18

sed "/ymin/ c ymin = $vapor_height" sub_5th_typical.i > sub_5th_typical_temp1_$i.i
sed "/init_porosity/ c init_porosity = $porosity" sub_5th_typical_temp1_$i.i > sub_5th_typical_temp2_$i.i
sed "/ymax/ c ymax = $vapor_height" subsub_5th_typical.i > subsub_5th_typical_temp1_$i.i
sed "/###/ c value = $porosity ###" subsub_5th_typical_temp1_$i.i > subsub_5th_typical_temp_$i.i
sed "/input_files/ c input_files = /home/mmjin/projects/mamba-dev/problems/Miaomiao/MultiApp/InterpolationTransfer/parametric_typicalPWR/subsub_5th_typical_temp_$i.i" sub_5th_typical_temp2_$i.i > sub_5th_typical_temp_$i.i

mpiexec -n 16 ~/projects/mamba-dev/mamba-dev-opt -i sub_5th_typical_temp_$i.i

python MyScript_vaporheight.py > temp.txt
h_vapor_from_sub=$(sed 's/e/E/g' temp.txt)
echo $h_vapor_from_sub porosity $porosity i $i >> vapor_height.txt
#h_vapor_from_sub=$(cat $SCRIPT_DIR/temp.txt)

cp sub_5th_typical.csv sub_5th_typical_${i}_$porosity.csv
cp subsub_5th_typical.csv subsub_5th_typical_${i}_$porosity.csv
rm sub_5th_typical.csv subsub_5th_typical.csv temp.txt

while [ $i -lt 22 ];
do
  i=$((i+1))
#The follow is to find whether h is too small or too large and then change vapor region dimension
  if [ $(echo "$h_vapor_from_sub < 0.01" | bc) -eq 1 ]; then
    vapor_height=$(echo "$vapor_height-0.0004" | bc -l)
  elif [ $(echo "$h_vapor_from_sub > 0.1 " | bc) -eq 1 ]; then
    vapor_height=$(echo "$vapor_height+0.0003" | bc -l)
  else
    echo i $i and porosity $porosity stop here  >> log.txt
    break
  fi

  sed "/ymin/ c ymin = $vapor_height" sub_5th_typical.i > sub_5th_typical_temp1_$i.i
  sed "/init_porosity/ c init_porosity = $porosity" sub_5th_typical_temp1_$i.i > sub_5th_typical_temp2_$i.i
  sed "/ymax/ c ymax = $vapor_height" subsub_5th_typical.i > subsub_5th_typical_temp1_$i.i
  sed "/###/ c value = $porosity ###" subsub_5th_typical_temp1_$i.i > subsub_5th_typical_temp_$i.i
  sed "/input_files/ c input_files = /home/mmjin/projects/mamba-dev/problems/Miaomiao/MultiApp/InterpolationTransfer/parametric_typicalPWR/subsub_5th_typical_temp_$i.i" sub_5th_typical_temp2_$i.i > sub_5th_typical_temp_$i.i

  mpiexec -n 16 ~/projects/mamba-dev/mamba-dev-opt -i sub_5th_typical_temp_$i.i
  python MyScript_vaporheight.py > temp.txt
  h_vapor_from_sub=$(sed 's/e/E/g' temp.txt)
  echo $h_vapor_from_sub porosity $porosity i $i >> vapor_height.txt
  #h_vapor_from_sub=$(cat $SCRIPT_DIR/temp.txt)

  cp sub_5th_typical.csv sub_5th_typical_${i}_$porosity.csv
  cp subsub_5th_typical.csv subsub_5th_typical_${i}_$porosity.csv
  rm sub_5th_typical.csv subsub_5th_typical.csv temp.txt
done
rm *temp1* *temp2*
done 
  
