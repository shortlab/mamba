#!/usr/bin/env python
import csv, sys, glob, os
from collections import defaultdict
filename=[]
for file in glob.glob("*.csv"):
    filename.append(file)

columns = defaultdict(list) # each value in each column is appended to a list

thickness=0.0250
with open(filename[-1]) as f:
    reader = csv.DictReader(f) # read rows into a dictionary format
    for row in reader: # read a row as {column1: value1, column2: value2,...}
        for (k,v) in row.items(): # go over each column name and value 
            columns[k].append(v) # append the value into the appropriate list
                                 # based on column name k

vaporheight =thickness-float(columns['liquid_height'][-1])
print(vaporheight)
