#! /usr/bin/perl

use strict;
use warnings;
use 5.010;
use File::Path;

#Set Trash directory path
my $homeDirectory = $ENV{"HOME"};
my $trashDirectory = $homeDirectory . "/.Trash/";
unless( $trashDirectory =~ m#\/$# ){
    $trashDirectory .= "/";
}

#Get Trash directory's directory list
#rmtree glob $trashDirectory."*";
my @trashDirectoryList = glob $trashDirectory."*";
foreach( @trashDirectoryList ){
    rmtree $_;
}
