#!/usr/bin/perl
use strict;
use warnings;

while(my $inp = <>){

 next if($inp =~ m/^#/);

 my @cols = split("\t", $inp); 

 my $start = $cols[1]-1;

 my $type = $cols[7];
 $type =~ s/^.*SVTYPE=//;
 $type =~ s/\;.*$//;

 next unless($type eq "DEL" || $type eq "INS");

 my $end = 0;

 if($type eq "DEL"){
  my $len = $cols[7];
  $len =~ s/^.*SVLEN=//;
  $len =~ s/\;.*$//;
 
  $end = $start+abs($len);

 }elsif($type eq "INS"){
  $end = $start+1;
 }

print "$cols[0]\t$start\t$end\t$type\n";

}
