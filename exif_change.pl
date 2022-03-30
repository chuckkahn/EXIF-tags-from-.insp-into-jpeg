#!/usr/bin/perl

use File::Find::Rule;	# find all the subdirectories of a given directory

use Image::ExifTool qw(:Public);

$path_DCIM = "/Volumes/CK_10TB/Downloads iMac/_media for unRAID/Insta360 ONE X/2022-03-18 - Toronto Comicon Day 1/DCIM/";

$path_screenshot="/Volumes/CK_10TB/Downloads iMac/_media for unRAID/Insta360 ONE X/2022-03-18 - Toronto Comicon Day 1/_Studio/";

# go through DCIM folders for .insp files

my @folders_DCIM = File::Find::Rule->file
                              ->name( '*.insp' )
							  ->in( $path_DCIM );		# looking for .insp files

foreach my $filepath_DCIM (@folders_DCIM)				# going through the directory
{
	$filepath_DCIM =~ /(.*)\/(.*\.insp)/;		# separating path from file name
	$path_DCIM = $1;
	$file_DCIM = $2;
    $insp_path{$file_DCIM} = $filepath_DCIM;
}

$c = 0; 

print "\n======================================== go through screenshots\n\n";

# go through screenshots

my @folders_screenshot = File::Find::Rule->file
                              ->name( 'IMG_20220318_094121_00_866*_screenshot.jpg' )
							  ->in( $path_screenshot );		# looking for .insp files

print "PATH is " . $path_screenshot . "\n\n";

foreach my $screenshots (sort @folders_screenshot)				# going through the directory
{
	$screenshots =~ /(.*)\/(.*\.jpg)/;		# separating path from file name
	$path_screenshot = $1;
	$file_screenshot = $2;
    my $info_screenshot = ImageInfo($screenshots);

    ++$c;

    # 2022-03-25_09-38-07_screenshot --- remove this part
    
    $insp_part = substr $file_screenshot, 0, -35;
    $insp_ref = $insp_part . ".insp";

    print "screenshot #$c\nscreenshot = $screenshots\t";
    print "DateTimeOriginal = $$info_screenshot{DateTimeOriginal}\ninsp_ref = $insp_ref\n";

    $insp_path = $insp_path{$insp_ref};
    
    print "insp_path  = $insp_path\t";

    # extract DateTimeOriginal from .insp

    my $info_DCIM = ImageInfo($insp_path);
    print "DateTimeOriginal = $$info_DCIM{DateTimeOriginal}\n";

    # $exifTool->SetNewValuesFromFile($insp_path, 'DateTimeOriginal');

    # write EXIF to screenshot jpeg

    # $errcode = $exifTool->WriteInfo($screenshots);

    my $info_screenshot = ImageInfo($screenshots);

    print "screenshot = $screenshots\t";
    print "$$info{DateTimeOriginal}\t$insp_file\n\n";

    exit;

}

