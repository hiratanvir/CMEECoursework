#!usr/bin/python

"""Chapter 6.6 Networks in Python (and R)"""

__author__ = 'Hira Tanvir (hira.tanvir@imperial.ac.uk)'
__version__ = '2.7.14'

"""
Plot a snapshot of a food web graph/network.
Needs: Adjacency list of who eats whom (consumer name/id in 1st
column, resource name/id in 2nd column), and list of species
names/ids and properties such as biomass (node abundance), or average
body mass.
"""

import networkx as nx
import scipy as sc
import matplotlib.pyplot as plt
# import matplotlib.animation as ani #for animation

def GenRdmAdjList(N = 2, C = 0.5): #N=2 as default
    """
    Generate random adjacency list given N nodes with connectance
    probability C
    """
    Ids = range(N)
    ALst = []
    for i in Ids:
            if sc.random.uniform(0,1,1) < C: #Generating uniformly distributred random number from 0-1 one time
                Lnk = sc.random.choice(Ids,2).tolist() #sc.random.choice(n, size) - creates an array of numbers from
#so it will randomnly generate 2 nodes that will be connected and adding it to Lnk
                if Lnk[0] != Lnk[1]: #avoid self loops
                    ALst.append(Lnk)
    return ALst

## Assign body mass range
SizRan = ([-10,10]) #use log scale
SizRan
## Assign number of species (MaxN) and connectance (C)
MaxN = 30
C = 0.75

## Generate adjacency list:
AdjL = sc.array(GenRdmAdjList(MaxN, C)) #giving it different input parameters here
# AdjL shows a list showing links between two different species - link generated randomnly
## Generate species (node) data:
Sps = sc.unique(AdjL) # get species ids
# Sps is a list of species that is created from 0 - 29
Sizs = sc.random.uniform(SizRan[0],SizRan[1],MaxN)# Generate body sizes (log10 scale)
# Sizs is the body sizes of each node(species) and is randomly generated
###### The Plotting #####
plt.close('all')

##Plot using networkx:

## Calculate coordinates for circular configuration:
## (See networkx.layout for inbuilt functions to compute other types of node
# coords)

pos = nx.circular_layout(Sps)
# pos are the co-ordinates of the species from 0-29
G = nx.Graph()
G
G.add_nodes_from(Sps)
G.add_edges_from(tuple(AdjL))
NodSizs= 10**-32 + (Sizs-min(Sizs))/(max(Sizs)-min(Sizs)) #node sizes in proportion to  - body sizes
nx.draw(G, pos, node_size = NodSizs*1000)
plt.show()
