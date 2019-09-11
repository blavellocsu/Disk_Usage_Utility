#!/usr/bin/perl
#diskusage.pl





# ---------------
# --- MODULES ---
# ---------------

use warnings;
use strict;
use Data::Dumper;





# ------------------
# --- SUBROUTINE ---
# ------------------

printCSV ();





# -----------------
# --- VARIABLES ---
# -----------------

my @file;

#Parameter Variables
my @keywords;

#Controller Variables
my @controllerLines;
my @controllerArray;
my $controllerCount = 0;

#Filesystem Variables
my @filesystemLines;
my @filesystemArray;
my $filesystemCount = 0;

#Header Variables
my @csvControllerHeader = split(/,/, "Controller Name,System ID,Serial Number,Model,Status,\n-------------------------,-------------,-----------------,--------,-----------");
my @csvFilesystemHeader = split (/,/, "Filesystem,total,used,avail,capacity,Mounted on,Vserver");

#REGEX Variables
my $controllerRegex = qr/[a-zA-Z0-9]+\s+[0-9]+\s+[0-9]+\s+[A-Za-z0-9]+\s+[a-zA-Z]+/;
my $filesystemRegex = qr/[\/\._a-zA-Z0-9]+\s+([0-9]+[KkMmGgTtPp]?[Bb]\s+){3}[0-9]{1,2}%\s+[\_\-\/\.a-zA-Z0-9]+\s+[\_\-\/\.a-zA-Z0-9]+/;

#Filename Variable
my $filename;





# --------------------------
# --- CAPTURE PARAMETERS ---
# --------------------------

#Set filename to user defined file.

($filename, @keywords) = @ARGV;

#If no file is given, exit
if (!defined $filename) {
    print "ERROR: No file specified.\n";
    print "Use the format: ./disk_usage.pl [FILENAME] [KEYWORDS]\n\n";
    exit;
}





# -----------------
# --- OPEN FILE ---
# -----------------

open ( my $fh, '<', $filename)
or die "Could not open file \"$filename\": $!.\nUse the format: ./disk_usage.pl [FILENAME] [KEYWORDS]\n\n";

#Read File in Line by Line
while( my $line = <$fh> )
{
    #Filter for Keywords
    my $filter = -1;
    foreach my $word( @keywords ) {
        if($filter == -1){
            $filter = index($line, $word);
        };
    };
    if($filter == -1){
        chomp($line);
        $line =~ s/^\s+//g;
        push @file, $line;
    };
};

#Separate controller lines from Filesystem lines into different arrays
foreach my $word ( @file ){
    if ($word =~ qr/$controllerRegex/){
        @controllerLines = (@controllerLines, $word);
    }
    elsif($word =~ qr/$filesystemRegex/){
        @filesystemLines = (@filesystemLines, $word);
    };
};

#Split controller into array
foreach my $word(@controllerLines){
    #Split scalar into array elements
    my @controllerSplit = split(/\s+/, $word);
    #Get address of array
    my $controllerRef = \@controllerSplit;
    #Set controllerArray to ref
    @controllerArray = (@controllerArray, $controllerRef);
}

#Filter filesystems
foreach my $word(@filesystemLines){
    #Split scalar into array elements
    my @filesystemSplit = split(/\s+/, $word);
    #Get address of array
    my $filesystemRef = \@filesystemSplit;
    #Set filesystemArray to ref
    @filesystemArray = (@filesystemArray, $filesystemRef);
}





# ------------------
# --- SORT ARRAY ---
# ------------------

#Get rid of % cause that messes sorting
my $percentIncrement = 0;
foreach my $percent (@filesystemArray) {
    my @removePercent = @$percent;

    #Use Regex to remove %
    ($removePercent[4] =~ s/%//g);
    
    #Copy it back to Array for sorting
    $filesystemArray[$percentIncrement]=\@removePercent;
    
    #increment
    $percentIncrement++;
}
    
#Sort Array by %
my @sorted = sort { ($b->[4]) <=> ($a->[4]) } @filesystemArray;






# ------------------
# --- CSV OUTPUT ---
# ------------------


my $fileIncrement =0;
    
#Generate filename variable
my $outputFile = $filename . "_sorted.csv";

#Open Filename
open (FH, ">$outputFile") or die "$!";

#Write initial Controller Header Data
printCSV (@csvControllerHeader);

#Write Controller Data
foreach my $print( @controllerArray ){
    printCSV(@$print);
    $controllerCount++;
};

#Write Total Controller Entries displayed
print FH "$controllerCount entries were displayed.\n";
print FH " \n";

#Write Filesystem Header Data
printCSV (@csvFilesystemHeader);

#Write Filesystem Data
foreach my $print (@sorted) {
    @$print [4] = @$print[4] . '%';
    my @sortedArray = @$print;
    printCSV (@sortedArray);
    $filesystemCount++;
}


print FH "$filesystemCount entries were displayed.\n";
print FH " \n";





# ------------------
# --- CLOSE FILE ---
# ------------------

close(FH); #end main





# -----------------------------
# --- CSV EXPORT SUBROUTINE ---
# -----------------------------

#Export out to CSV through subroutine
sub printCSV {
    foreach $_( @_ ) {
        print FH "$_";
        if ($_ ne $_[-1]) {
            print FH ",";
        }
        else {
            print FH "\n";
        } #end else
    } #end foreach
} #end sub
