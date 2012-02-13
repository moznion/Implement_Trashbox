#! /usr/bin/perl

use strict;
use warnings;
use 5.010;
use File::Path;

print "Empty the trash box? [y/n] : ";
while(1){
    chomp( my $switch = <STDIN> );
    if( $switch =~ /^[nN]$/ ){
        exit;
    }elsif( $switch =~ /^[yY]$/ ){
        last;
    }else{
        print "Please input 'y' or 'n' : "
    }
}

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

say "Succeeded."
