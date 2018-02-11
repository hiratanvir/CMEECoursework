#Miniproject codes that also work

#Filtering outliers in StandardisedTraitValue for each uniqueID
#res = subset_dF.groupby("uniqueID")["StandardisedTraitValue"].quantile([0.05, 0.95]).unstack(level=1)
subset_dF = subset_dF.loc[((res.loc[subset_dF.uniqueID, 0.05]<subset_dF.StandardisedTraitValue.values)&(subset_dF.StandardisedTraitValue.values<res.loc[subset_dF.uniqueID, 0.95])).values]

with PdfPages('outputx.pdf') as pdf:
    for i, group in subset_dF.groupby("uniqueID"):
        plot = sns.regplot(data = group, x = "1/kT", y = "log_TraitValues", plot_kws=dict(robust=True))
        plot.set_title(str(i))
        fig = plot.get_figure()
        pdf.savefig(fig, bbox_inches='tight')
        plt.close(fig)


with PdfPages('kde.pdf') as pdf_pages:
    for i, group in subset_dF.groupby("uniqueID"):
        plot = sns.regplot(data = group, x="1/kT", y="log_TraitValues", fit_reg=False)
            for j, group in subset_dF.groupby(["uniqueID"])["log_TraitValues"].max())
            x=t1.iloc[:, i]
            y=t1.iloc[:, j]
            joint_grid = sns.jointplot(x=x, y=y, kind="kde", dropna=True)
            pdf_pages.savefig(joint_grid.fig)
