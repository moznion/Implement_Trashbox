#! /usr/bin/perl

use strict;
use warnings;
use 5.010;
use File::Path;

#Set Trash Directory Path
my $homeDirectory = $ENV{"HOME"};
my $trashDirectory = $homeDirectory . "/.Trash/";
unless( $trashDirectory =~ m#\/$# ){
	$trashDirectory .= "/";
}

#Get Trash Directory's Directory List
my @directoryList = glob $trashDirectory."*";
if( scalar @directoryList == 0 ){
	exit;
}
foreach ( @directoryList ){
	s#^$trashDirectory##;    
}

#Switching mode by option.
if( scalar @ARGV == 0 ){
	&undoRecent();
}elsif( $ARGV[0] =~ /^-/ ){
	if( $ARGV[0] eq "-a" or $ARGV[0] eq "--all" ){
		&undoAll();
	}else{
		say "`".$ARGV[0]."`"." is not this instruction's option.";
		exit;
	}
}else{
	&undoSpec();
}

sub undoRecent{
	#Get Target Directory
	my @sortedDirectoryList = sort @directoryList;
	my $targetDirectory = $sortedDirectoryList[-1];
	$targetDirectory = $trashDirectory . $targetDirectory;

	#Get Undo Target Location
	my $pathFileLocation = " <".$targetDirectory."/.PATH";
	unless( open PATH, $pathFileLocation ){
		die "Cannot open .PATH file: $!\n";
	}
	my $targetUndoLocation;
	while( <PATH> ){
		chomp;
		$targetUndoLocation = $_;
	}
	close PATH;

	#Make directory if target directory is not exist
	my @targetUndoLocationList = split /\//, $targetUndoLocation;
	shift @targetUndoLocationList;  #Remove null element
	my $directoryTest;
	foreach( @targetUndoLocationList ){
		$directoryTest .= "/" . $_;
		unless( -e $directoryTest ){
			mkdir "$directoryTest", 0755 or die "Cannot make directory: $!"; 
		}
	}

	#Remove PATH information file
	unlink $targetDirectory."/.PATH";

	#Undo
	my @targetUndoFileList = glob "$targetDirectory/* $targetDirectory/.*";
	my $targetUndoFile;
	foreach( @targetUndoFileList ){
		$targetUndoFile = $_;
		s#^$targetDirectory/##;
		unless( $targetUndoFile =~ /\.$/ ){
			rename $targetUndoFile, $targetUndoLocation."/".$_;
			say "Undo : $targetUndoFile -> $targetUndoLocation/";
		}
	}

	#Remove the newest directory
	rmtree $targetDirectory;
}

sub undoAll{
	#All files in trash box directory are revived.
	foreach my $_directory( sort @directoryList ){
		#Get Undo Target Location
		my $targetDirectory = $trashDirectory . $_directory;
		my $pathFileLocation = " <".$targetDirectory."/.PATH";
		unless( open PATH, $pathFileLocation ){
			die "Cannot open .PATH file: $!\n";
		}
		my $targetUndoLocation;
		while( <PATH> ){
			chomp;
			$targetUndoLocation = $_;
		}
		close PATH;

		#Make directory if target directory is not exist
		my @targetUndoLocationList = split /\//, $targetUndoLocation;
		shift @targetUndoLocationList;  #Remove null element
		my $directoryTest;
		foreach( @targetUndoLocationList ){
			$directoryTest .= "/" . $_;
			unless( -e $directoryTest ){
				mkdir "$directoryTest", 0755 or die "Cannot make directory: $!"; 
			}
		}

		#Remove PATH information file
		unlink $targetDirectory."/.PATH";

		#Undo
		my @targetUndoFileList = glob "$targetDirectory/* $targetDirectory/.*";
		my $targetUndoFile;
		foreach( @targetUndoFileList ){
			$targetUndoFile = $_;
			s#^$targetDirectory/##;
			unless( $targetUndoFile =~ /\.$/ ){
				rename $targetUndoFile, $targetUndoLocation."/".$_;
				say "Undo : $targetUndoFile -> $targetUndoLocation/";
			}
		}

		#Remove the newest directory
		rmtree $targetDirectory;
			
	}
}

sub undoSpec{
	#All files in trash box directory are revived.
	foreach my $_directory( @ARGV ){
		my $pathFileLocation = " <".$_directory."/.PATH";
		unless( open PATH, $pathFileLocation ){
			die "Cannot open .PATH file: $!\n";
		}
		my $targetUndoLocation;
		while( <PATH> ){
			chomp;
			$targetUndoLocation = $_;
		}
		close PATH;

		#Make directory if target directory is not exist
		my @targetUndoLocationList = split /\//, $targetUndoLocation;
		shift @targetUndoLocationList;  #Remove null element
		my $directoryTest;
		foreach( @targetUndoLocationList ){
			$directoryTest .= "/" . $_;
			unless( -e $directoryTest ){
				mkdir "$directoryTest", 0755 or die "Cannot make directory: $!";
			}
		}

		#Remove PATH information file
		unlink $_directory."/.PATH";

		#Undo
		my @targetUndoFileList = glob "$_directory/* $_directory/.*";
		my $targetUndoFile;
		foreach( @targetUndoFileList ){
			$targetUndoFile = $_;
			s#^$_directory/##;
			unless( $targetUndoFile =~ /\.$/ ){
				rename $targetUndoFile, $targetUndoLocation."/".$_;
				say "Undo : $targetUndoFile -> $targetUndoLocation/";
			}
		}

		#Remove the newest directory
		rmtree $_directory;

	}
}
