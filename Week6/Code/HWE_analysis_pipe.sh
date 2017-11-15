#!/bin/bash


# usage: ./Analysis.sh [PLINKIN] [outfile_prefix]



PLINK=$1    # Plink file set indicated by the user
OUT=$2      # outfile prefix indicated by the user


# the following are the necessary file names needed for the various steps

DIR=$OUT"_results"  #this is the name of the results directory
FRQX=$OUT".frqx"    # name of the .frqx file
GENO=$OUT".geno"    # name of the .geno file
OVE=$OUT"_Ob_v_Ex_het.pdf"   					#name of the observed v expected heterzygosity plot
MOVEF=$OUT"_F.pdf"					        # name of the moving F plot
HWE=$OUT".hwe"					            # name of the .hwe file
SNPS=$OUT"_hwe_outliers.txt"					# name of the file containing the 50 most extreme SNPs



# Make a results directory


mkdir ../Results/$DIR


# give the commands for running the analyses exactly as you would on the terminal,
# however you should replace the file names with the appropriate variables


plink --bfile $PLINK --freqx --out $OUT   	#run plink to calculate genotype proportions


../Code/frqx2geno.pl $FRQX $GENO   		#convert the plink output to .geno format


Rscript ../Code/Ob_v_Ex_het.R $GENO $OVE			# plot the observed versus expected heterozygosity


Rscript ../Code/Moving_F.R $GENO $MOVEF			# plot the moving F values


plink --bfile $PLINK --hardy --out $OUT		# run Hardy Weinberg analysis


sort -k9 $HWE | tail -n 50 >$SNPS		    # command to write the 50 most extreme SNPs to file



# Move everything into the results directory

mv $FRQX ../Results/$DIR     	# move the .frqx file to results
mv $GENO ../Results/$DIR     	# move the .geno file to results
mv $OVE ../Results/$DIR		# move the observed v expected plot to results
mv $MOVEF ../Results/$DIR 		# move the moving F plot to results
mv $HWE ../Results/$DIR 		# move the .hwe file to results
mv $SNPS ../Results/$DIR 		# move the 50 SNPs file to results



mv $OUT".log" ../Results/$DIR  # also move the plink log file to results. This is the record of what you have done


# cleanup

rm $OUT.nosex  #get rid of unnecessary files
