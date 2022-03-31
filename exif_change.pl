#!/usr/bin/perl

use File::Find::Rule;	# find all the subdirectories of a given directory

use Image::ExifTool qw(:Public);

$path_DCIM = "/Volumes/CK_10TB/Downloads iMac/_media for unRAID/Insta360 ONE X/2022-03-18 - Toronto Comicon Day 1/DCIM/Camera01/";

$path_screenshot="/Volumes/CK_10TB/Downloads iMac/_media for unRAID/Insta360 ONE X/2022-03-18 - Toronto Comicon Day 1/_Studio/Camera01/";

# go through DCIM folders to gather locations of .insp files

my @folders_DCIM = File::Find::Rule->file
                              ->name( '*.insp' )
							  ->in( $path_DCIM );		# looking for .insp files

foreach my $filepath_DCIM (@folders_DCIM)				# going through the directory
{
	$filepath_DCIM =~ /(.*)\/(.*\.insp)/;		# separating path from file name
	$path_DCIM = $1;
	$file_DCIM = $2;
    $insp_path{$file_DCIM} = $filepath_DCIM;    # recording the path for each file
}

$c = 0; 

print "\n======================================== go through screenshots\n\n";

my @folders_screenshot = File::Find::Rule->file
                              ->name( 'IMG_20220318_094121_*_screenshot.jpg' )
							  ->in( $path_screenshot );		# looking for .insp files

print "PATH is " . $path_screenshot . "\n\n";

my $exifTool = new Image::ExifTool;         # define the $exifTool variable


foreach my $screenshot (sort @folders_screenshot)				# going through the directory
{
	$screenshot =~ /(.*)\/(.*\.jpg)/;		# separating path from file name
	$path_screenshot = $1;
	$file_screenshot = $2;

    my $info_screenshot = ImageInfo($screenshot);     # Read image file and return meta information

    ++$c;                                               # increment counter

    # 2022-03-25_09-38-07_screenshot --- remove the last 35 characters of the screenshot filename, the remainder of which references the original .insp file
    
    $insp_part = substr $file_screenshot, 0, -35;
    $insp_ref = $insp_part . ".insp";                   # recreate .insp filename for reference

    print "=========================== screenshot #$c from .insp =========================================================\n";

    $screenshot_line  = sprintf ('%s        %s %s                    %s', $file_screenshot, $$info_screenshot{DateTimeOriginal},  $$info_DCIM{Model}, $$info_screenshot{FileName} );

    print $screenshot_line . "\n" ;
    
    # Step 2: extract DateTimeOriginal from .insp

    my $info_DCIM = ImageInfo($insp_path{$insp_ref});

    $insp_line  = sprintf ('%s                                      %s       %s %s', $insp_ref, $$info_DCIM{DateTimeOriginal}, $$info_DCIM{Model}, $$info_DCIM{FileName});
    print $insp_line . "\n" ;

    # print "going to system for exiftool command\n";

    # system "exiftool -DateTimeOriginal '$insp_path{$insp_ref}'";
    # system "echo '$insp_path{$insp_ref}'";

    # system "exiftool -tagsFromFile '$insp_path{$insp_ref}' '$screenshot'";
    # print "done with system\n";

    # system "exiftool '-alldates<\${directory}\$filename' -execute -alldates-=4 '-gpstimestamp<createdate' -model='Narrative Clip' -common_args -r -overwrite_original -progress $spath ";			# set date/time and model


    my $info = $exifTool->SetNewValuesFromFile($insp_path, 'DateTimeOriginal');    # attempting to use the .insp file as the source for DateTimeOriginal

    print "exifTool = $exifTool\n";
    print "info = $info\n";

    # $exifTool->SetNewValuesFromFile($insp_path, 'Model');

    # $exifTool->SetNewValue(DateTimeOriginal => '4:00', Shift => -1);

    # write EXIF to screenshot jpeg

    $errcode = $exifTool->WriteInfo($screenshot);

    print "errcode = $errcode\n";

    my $info_screenshot = ImageInfo($screenshot);

    print "info_screenshot = $info_screenshot\n";

    $screenshot_line  = sprintf ('%s        %s ', $file_screenshot, $$info_screenshot{DateTimeOriginal}, $$info_screenshot{Model});
    print $screenshot_line . "\n" ;

    $exifTool->SetNewValue();
exit;
}

