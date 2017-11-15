#!/usr/bin/perl

use strict;
use warnings;


my $infile = $ARGV[0];
my $outfile = $ARGV[1];


unless ($infile and $outfile) {
	die "\n\nERROR: You need to specify a .freqx file and an outfile.geno name\n\n";
}

unless (-f $infile) {
	die "\n\nERROR: Cannot find $infile. Check file path.\n\n";
}


open IN, $infile;

<IN>;

open OUT, ">$outfile";

print OUT "CHR SNP A1 A2 nA1A1 nA1A2 nA2A2\n";


while (<IN>) {
	my $line = $_;
	chomp $line;
	my @l = split /\s/, $line;
	print OUT "$l[0] $l[1] $l[2] $l[3] $l[4] $l[5] $l[6]\n";
}


close IN;
close OUT;




exit;