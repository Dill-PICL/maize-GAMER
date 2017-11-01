#!/usr/local/bin/perl
use strict;
my $file = shift;
my $column = shift;

open(OF,$file);

while(<OF>){
	if($_ =~ /\t(IBA|IC|IDA|IEP|IGI|IMP|IPI|ISS|RCA|TAS)\t/){
		print($_);
	}
}
