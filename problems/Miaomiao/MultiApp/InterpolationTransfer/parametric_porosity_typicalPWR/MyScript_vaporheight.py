#!/usr/bin/env python
import csv, sys
from collections import defaultdict
from numpy import *

#GOAL: based on vapor_height value from sub_5th_noTransfer.csv, we would change the vapor part dimension and corresponding 

thickness=0.025 #crud thicknesss
columns1 = defaultdict(list) # each value in each column is appended to a list
columns2 = defaultdict(list) # each value in each column is appended to a list
with open('subsub_5th_typical.csv') as f:
    reader = csv.DictReader(f) # read rows into a dictionary format
    for row in reader: # read a row as {column1: value1, column2: value2,...}
        for (k,v) in row.items(): # go over each column name and value 
            columns1[k].append(v) # append the value into the appropriate list
                                 # based on column name k

with open('sub_5th_typical.csv') as f:
    reader = csv.DictReader(f) # read rows into a dictionary format
    for row in reader: # read a row as {column1: value1, column2: value2,...}
        for (k,v) in row.items(): # go over each column name and value 
            columns2[k].append(v) # append the value into the appropriate list
                                 # based on column name k

thickness1=[float(columns1['vapor_height'][-3]),float(columns1['vapor_height'][-2]),float(columns1['vapor_height'][-1])]
vapor_height1=mean(thickness1)

thickness2=[float(columns2['vapor_height'][-3]),float(columns2['vapor_height'][-2]),float(columns2['vapor_height'][-1])]
vapor_height2=mean(thickness2)


print(vapor_height2)
