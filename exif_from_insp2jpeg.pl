#!/usr/bin/perl

use strict;

use File::Find::Rule;	# find all the subdirectories of a given directory

use Image::ExifTool qw(:Public);

my $Insta360_main   = "/Volumes/CK_10TB/Downloads iMac/_media for unRAID/Insta360 ONE X/";  # main path
my $Insta360_date   = "2022-04-09";

my $path_DCIM       = $Insta360_main . $Insta360_date . "/DCIM/";   # DCIM path

my $path_screenshot = $Insta360_main . $Insta360_date . "/_Studio/";    # jpeg screenshot path

# go through DCIM folders to gather locations of .insp files

my @folders_DCIM = File::Find::Rule->file
                              ->name( '*.insp' )
							  ->in( $path_DCIM );		# looking for .insp files

my $filepath_DCIM;
my $path_DCIM;
my $camera_DCIM; 
my $file_DCIM;
my $ref_DCIM;
my %insp_path;

foreach my $filepath_DCIM (@folders_DCIM)				# going through the directory
{
	$filepath_DCIM =~ /(.*)\/(Camera\d\d.*\.insp)/;		# separating path from CameraXX/file name
	$path_DCIM = $1 . "/" . $2;
    $camera_DCIM = $2;
	$file_DCIM = $3;

    $ref_DCIM  = $camera_DCIM . $file_DCIM;

    $insp_path{$ref_DCIM} = $path_DCIM;    # recording the path for each file
}

my $c = 0; 

print "\n=================== go through screenshots ";

my @folders_screenshot = File::Find::Rule->file
                              ->name( '*.jpg' )
							  ->in( $path_screenshot );		# looking for .insp files

print "under $path_screenshot =========================================================\\n\n";

my $exifTool = new Image::ExifTool;         # define the $exifTool variable

my $path_screenshot;
my $camera_screenshot;
my $file_screenshot;
my $ref_screenshot;
my $upperpath_screenshot;

my $formattted = "%s   %s         %s  %s\n";

use File::Basename;

foreach my $screenshot (sort @folders_screenshot)				# going through the directory
{

    print "screenshot = $screenshot\n";
	$path_screenshot = dirname($screenshot);
	$file_screenshot = basename($screenshot);

    $upperpath_screenshot = $Insta360_main . $Insta360_date . "/_Studio/";    # jpeg screenshot path

    $camera_screenshot = $path_screenshot;
    $camera_screenshot =~ s/$upperpath_screenshot//;

    $ref_screenshot = $camera_screenshot . "/" . $file_screenshot;    # creating camera+file reference

    my $info_screenshot = ImageInfo($screenshot);     # Read image file and return meta information

    ++$c;                                               # increment counter

    # 2022-03-25_09-38-07_screenshot --- remove the last 35 characters of the screenshot filename, the remainder of which references the original .insp file

    my $insp_ref;

    if ( $ref_screenshot =~ /_screenshot.jpg/ )             # check if .jpeg is a screenshot
    {
        my $insp_part = substr $ref_screenshot, 0, -35;
        $insp_ref = $insp_part . ".insp";                   # recreate .insp filename for reference
    }
    else
    {
        $insp_ref = $ref_screenshot;
        $insp_ref =~ s/.jpg/.insp/;
    }

    print "=========================== screenshot #$c from .insp to .jpeg =========================================================\n\n";

    printf $formattted, "Date/Time Original", "Camera", "CameraXX/FileName";
    print "\n";

    # IMG_20220318_094121_00_016_2022-03-25_09-40-20_screenshot.jpg

    my $formattted = "%s  %s  %s  %s\n";

    # check if screenshot has DateTimeOriginal before adding DateTimeOriginal

    printf $formattted, $$info_screenshot{DateTimeOriginal},  $$info_screenshot{Model}, $ref_screenshot;

    my $do_this = "yes";

#   if (! $$info_screenshot{DateTimeOriginal})   # check if screenshot already has DateTimeOriginal

    if ( $do_this eq "yes" )
    {
    
        # Step 2: extract DateTimeOriginal from .insp

        my $info_DCIM = ImageInfo($insp_path{$insp_ref});


        printf $formattted, $$info_DCIM{DateTimeOriginal}, $$info_DCIM{Model}, $insp_ref;

        # "If you want to copy a time with SetNewValuesFromFile, then write a shifted value, you could set the GlobalTimeShift API option before calling SetNewValuesFromFile.  Of course, this would then apply to all date/time tags copied"

        # "Time shift to apply to all extracted date/time PrintConv values. Does not affect ValueConv values"

        # -- Phil Harvey, ExifTool Author, from https://exiftool.org/forum/index.php?topic=13438.0

        # Date/time shift string with leading '-' for negative shifts

        # my $info = $exifTool->Options(GlobalTimeShift => '-4');

        my $info = $exifTool->SetNewValuesFromFile($insp_path{$insp_ref}, 'DateTimeOriginal', 'Model');    # attempting to use the .insp file as the source for DateTimeOriginal

        # write EXIF to screenshot jpeg

        my $errcode = $exifTool->WriteInfo($screenshot);

        my $info_screenshot = ImageInfo($screenshot);   # re-reading modified EXIF of screenshot

        printf $formattted, $$info_screenshot{DateTimeOriginal}, $$info_screenshot{Model}, $ref_screenshot;
        print "\n";
        
        $exifTool->SetNewValue();
    }
  #      exit;

}

