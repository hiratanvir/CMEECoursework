#!usr/bin/python

"""Chapter 6.6 Networks in Python (and R)"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

import networkx as nx #Package creates graphs
import scipy as sc  #allows operations on arrays
import matplotlib.pyplot as plt #allows plotting in python
import pandas as pd #reads in data as dataframes
import csv #allows csv files to be read

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

#9. Creating a dictionary and setting nodes 'id' as key, and 'Type' as value
location_type = nodes.set_index('id')['Type'].to_dict()

#10. Creating lists of nodes according to location type

#University
University_nodes = [key for key, value in location_type.items() if value == 'University']
print University_nodes

#Hosting Partner
HP_nodes = [key for key, value in location_type.items() if value == 'Hosting Partner']
print HP_nodes

#Non-Hosting Partner
NonHP_nodes = [key for key, value in location_type.items() if value == 'Non-Hosting Partners']
print NonHP_nodes

#10. Plotting the graph
G = nx.Graph() #Creating an empty graph called G
G.add_nodes_from(New_nodes) #Adding the list of nodes to graph
nx.set_node_attributes(G,'location', location_type)
pos = nx.spring_layout(G) #using a spring layout to fix node positions

#plotting the links between nodes and weights of edges between nodes
nx.draw_networkx_edges(G, pos, edgelist=Lnks, width=list(relative_weight))

#increasing the size of the nodes, setting labels and colours according to network type
nx.draw_networkx_nodes(G, pos, node_size = 3000, nodelist = University_nodes, node_color = 'g', label = 'University')
nx.draw_networkx_nodes(G, pos, node_size = 3000, nodelist = HP_nodes, node_color = 'b', label = 'Hosting Partner')
nx.draw_networkx_nodes(G, pos, node_size = 3000, nodelist = NonHP_nodes, node_color = 'r', label = 'Non-Hosting Partners')

nx.draw_networkx_labels(G, pos) #adding labels to the nodes

#Adding a legend to the graph and adjusting it's size and position
plt.legend(title="Network Type", fontsize=10, loc='best', markerscale=0.2, scatterpoints=1)
plt.tight_layout()
plt.savefig('../Results/networks.svg')
plt.show()
