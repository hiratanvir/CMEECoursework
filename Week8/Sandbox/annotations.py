#maximum x value
max_x = one_group['1/kT'].max(axis=0)

#overlaying plots on same graph
fig, ax = plt.subplots()

#Sorting xvalues in ascending order
#L = sorted(zip(xvalues,yvalues), key=operator.itemgetter(0))
#new_x, new_y = zip(*L)

#Convert new_x and new_y back to np.arrays
#X = np.array(new_x)
#Y = np.array(new_y)

#To plot slope for e estimate, get xi value that corresponds to max y value
#make a vector containing x values starting from xi to max x
#and get a corresponding vector of y values and then plot line.

#Plotting data using seaborn sns plots:
#ax = sns.regplot(data = one_group, x = "1/kT", y = "log_TraitValues")
#fig = ax.get_figure()
#fig.savefig('one_group.png')
#if you do a robust regression then set ci=None
#ax = sns.regplot(data = one_group, x = "1/kT", y = "log_TraitValues", ci=None, robust=True)

#OR...

m, b = np.polyfit(x1, y1, 1)
plt.plot(x,y,'.')
plt.plot(x1, y1,'-')
plt.savefig('plt.png')

fig, ax = plt.subplots(1,1)
ax1.scatter(x, y)
ax.plot(y1, [i*beta_1 for i in x1], label="best fit")
ax.legend(loc="best")
plt.savefig('out_plot.png')

#and params to extract the coefficient on the single regressor:
beta_1 = sm.OLS(y1, x1).fit().params

#from operator import itemgetter


#Get the index of the max x value
idx = np.where(xvalues==xvalues.max(axis=0))
#one_group = one_group.assign(log_B0="", E="", Eh="", El="", Th="", Tl="")


    log_B0_list.append(log_B0)
    E_list.append(E)
    Eh_list.append(Eh)
    El_list.append(El)
    Th_list.append(Th)
    Tl_list.append(Tl)

    log_B0_list = []
    E_list = []
    Eh_list = []
    El_list = []
    Th_list = []
    Tl_list = []

    params = ('log_B0', 'E', 'Eh', 'El', 'Th', 'Tl')
    #for group in one_group['uniqueID']:
    tempDF = pd.DataFrame(columns = params)
    tempDF['log_B0'] = float(g.loc[g['Temp(kel)']==(find_nearest(Temp,value)), 'StandardisedTraitValue'])
    tempDF['E'] = E_estimate[0]
    tempDF['Eh'] = Eh_estimate[0]
    tempDF['El'] = E/2
    tempDF['Th'] = float(xvalues[idy])
    tempDF['Tl'] = g['1/kT'].min(axis=0)

    print(tempDF)
    print('\n')

    one_group.append(tempDF)

masterDF = pd.concat(one_group, ignore_index=True)

    Tmp = pd.DataFrame({'log_B0':[log_B0],
                        'E':[E],
                        'Eh':[Eh],
                        'El':[El],
                        'Th':[Th],
                        'Tl':[Tl]})

    print('ID: '+str(i))
    print(g.log_B0.tolist())
    print(g.E.tolist())

    one_group.loc['g'] = g.append(pd.DataFrame({'log_B0':B0}))
    #g.assign(log_B0="log_B0", E="E", Eh="Eh", El="El", Th="Th", Tl="Tl"

        #two_group = one_group.append(pd.DataFrame({'log_B0': log_B0_list, 'E': E_list}))

#Converting all values in column to floats
subset_dF.ConTemp = subset_dF.ConTemp.astype(float)
subset_dF.StandardisedTraitValue = subset_dF.StandardisedTraitValue.astype(float)
subset_dF['Temp(kel)'] = subset_dF['Temp(kel)'].astype(float)
