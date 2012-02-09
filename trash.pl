#! /usr/bin/perl

use strict;
use warnings;
use 5.010;
use Cwd;

my $homeDirectory = $ENV{"HOME"};
my $trashDirectoryPath = $homeDirectory . "/.Trash/";
unless( $trashDirectoryPath =~ m#\/$# ){
    $trashDirectoryPath .= "/";
}

#make ".Trash" directory if "~/.Trash" is not exist.
unless( -e $trashDirectoryPath ){
    mkdir "$trashDirectoryPath", 0755 or die "Cannot make directory: $!";
}

#Kill this processing if @ARGV is undef
if( scalar @ARGV == 0 ){
    exit;
}

#remove options
my @fileName;
foreach( @ARGV ){
    unless( /^\s*-+\w+\b/g ){
        s/^\s*//;
        push( @fileName, $_ );
    }
}

#Kill this processing if @fileName is undef
if( scalar @fileName == 0 ){
    exit;
}

#Are target files exist?
my @existFileName;
foreach( @fileName ){
    if( -e $_ ){
        push( @existFileName, $_ );
    }else{
        warn "$_ : No such file or directory\n"
    }
}

#Kill this processing if target file or directory
#is not exist
if( scalar @existFileName == 0 ){
    exit;
}

#Get timestamp
my ( $sec, $min, $hour, $day, $mon, 
     $year, $wday, $yday, $isdst ) = localtime(time);
$year += 1900;
$mon += 1;

my $timeStamp = sprintf "%4d%02d%02d%02d%02d%02d",
                        $year, $mon, $day, $hour, $min, $sec;

#Get Current Directory Path
my $currentDirectoryPath =  getcwd();

#Make trash directory in ".Trash/"
$trashDirectoryPath .= $timeStamp;
mkdir "$trashDirectoryPath", 0755 or die "Cannot make directory: $!";

#Write out "original directory path" into ".PATH" file
$trashDirectoryPath .= "/";
my $pathFile = $trashDirectoryPath . ".PATH";
unless( open OUT, " >$pathFile" ){
    die "Cannot create PATH file : $!\n";
}
print OUT $currentDirectoryPath . "\n";
close OUT;

#Move target file to trash directory
foreach( @existFileName ){
    rename $_, $trashDirectoryPath.$_;
    say "$_ -> $trashDirectoryPath";
}
