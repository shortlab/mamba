#!/usr/bin/env python
import csv, sys
from collections import defaultdict


#thickness=0.050 #crud thicknesss
columns = defaultdict(list) # each value in each column is appended to a list

with open('crud_chem_5th.csv') as f:
    reader = csv.DictReader(f) # read rows into a dictionary format
    for row in reader: # read a row as {column1: value1, column2: value2,...}
        for (k,v) in row.items(): # go over each column name and value 
            columns[k].append(v) # append the value into the appropriate list
                                 # based on column name k

liquidheight =float(columns['liquid_height'][-1])
print(liquidheight)
