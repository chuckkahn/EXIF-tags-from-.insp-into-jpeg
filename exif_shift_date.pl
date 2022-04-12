#!/usr/bin/perl

use strict;

use File::Find::Rule;	# find all the subdirectories of a given directory

use Image::ExifTool qw(:Public);

my $Insta360_main   = "/Volumes/CK_10TB/Downloads iMac/_media for unRAID/Insta360 ONE X/";  # main path

my $Insta360_date   = "2022-04-09";

my $Insta360_subdir  = "Camera05 20220328";

my $path_DCIM       = $Insta360_main . $Insta360_date . "/DCIM/" . $Insta360_subdir ;   # DCIM path

my @folders_DCIM = File::Find::Rule->file
                              ->name( '*.insp' )
							  ->in( $path_DCIM );		# looking for .insp files

my $filepath_DCIM;
my $file_DCIM;

print "\n=================== INSP files\n";

use File::Basename;

my $formattted = "%s  %s  %s  %s\n";

printf $formattted, "Date/Time Original", "Camera", "CameraXX/FileName";
print "\n";

my $dateshift_Mar27_am = "4:2:26 14:26:36";
my $dateshift_Apr09_pm = "4:3:8 14:31:52";

my $exifTool = new Image::ExifTool;         # define the $exifTool variable

foreach my $filepath_DCIM (@folders_DCIM)				# going through the directory
{
        my $info_DCIM = ImageInfo($filepath_DCIM);     # Read image file and return meta information
	$file_DCIM = basename($filepath_DCIM);

        print "before\n";
        printf $formattted, $$info_DCIM{DateTimeOriginal}, $$info_DCIM{Model}, $file_DCIM;

        my $dateTime = $$info_DCIM{DateTimeOriginal};

        my $errcode = Image::ExifTool::ShiftTime($dateTime, +$dateshift_Mar27_am);       # shift the date
        my $errcode = $exifTool->WriteInfo($filepath_DCIM);                             # write the result back to the .insp

        my $info_DCIM = ImageInfo($filepath_DCIM);     # re-Read image file and return meta information

        print "after\n";
        printf $formattted, $$info_DCIM{DateTimeOriginal}, $$info_DCIM{Model}, $file_DCIM;

        exit;
}