#!usr/bin/python

"""Chapter 6.6 Networks in Python (and R)"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

import networkx as nx
import scipy as sc
import matplotlib.pyplot as plt
import pandas as pd
import csv
from collections import Counter

#1. Reading in the edges as a dataframe
edges = pd.read_csv('../Data/QMEE_Net_Mat_edges.csv', sep=',')
print edges

#2. Reading in the nodes as a dataframe
nodes = pd.read_csv('../Data/QMEE_Net_Mat_nodes.csv', sep=',')
print nodes

#3. Creating an empty list and then converting the dataframe
#into a list of tuples which will fo into n_nodes

n_nodes=[]
for row in nodes.iterrows():
    index, data=row
    n_nodes.append(data.tolist())

#4. Getting the names of the nodes to be plotted
New_nodes = [i[0] for i in n_nodes]

#5. Gives integers below 0.8 in edges dataframe a False value and >0.8 True value
sc.triu(edges, 1) > 0

#6. Then extracting the rows/columns where it's True & shows you the upper part of triangle to avoid repeating co-ordinates
rows, cols = sc.where(sc.triu(edges > 0))

#7. Create a list comprehension (tuples of tuples) of node names where there is a link (edges)
Lnks = [(New_nodes[i], New_nodes[z]) for i, z in zip(rows, cols)]

#8. Weights of edges retrieved from Lnks
weights = [edges.iloc[i,z] for i,z in zip(rows,cols)]
relative_weight = weights/(min(weights)*2)
#def gen_edges(counter):
#    for k, v in counter.iteritems():
#        yield k[0], k[1], v

G = nx.Graph()
pos = nx.fruchterman_reingold_layout(G)
#C = Counter(zip(rows,cols))

G.add_nodes_from(New_nodes)
G.add_edges_from(Lnks)
nx.draw(G, pos, (width = relative_weight))
plt.show()
