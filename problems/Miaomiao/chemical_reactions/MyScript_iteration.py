#!/usr/bin/env python
import csv, sys, glob, os
from collections import defaultdict
filename=[]
for file in glob.glob("*.csv"):
    filename.append(file)
#print filename
#print filename[-2]

columns1 = defaultdict(list) # each value in each column is appended to a list

with open(filename[-1]) as f:
    reader = csv.DictReader(f) # read rows into a dictionary format
    for row in reader: # read a row as {column1: value1, column2: value2,...}
        for (k,v) in row.items(): # go over each column name and value 
            columns1[k].append(v) # append the value into the appropriate list
                                 # based on column name k

liquidheight =float(columns1['liquid_height'][-1])
correction=float(columns1['vapor_height'][-1])
liquidheight_new =liquidheight-correction
G_suction=float(columns1['Suction_crud_coolant'][-1])
VaporTempAvg=float(columns1['VaporTempAvg'][-1])
print(liquidheight_new)
if correction > 2.0e-4:
    print(1)
else:
    print(0)
print(G_suction)
print(VaporTempAvg)
