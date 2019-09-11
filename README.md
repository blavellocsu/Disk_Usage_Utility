# Perl_Disk_Usage_Utility
This utility sorts disk usage and produces a relevant report.

Author: Brandon Lavello


## BASIC USE
The first line in this script ```!#/bin/bash."``` specifies the file path to BASH so that the shell uses the correct interpreter.

To run this program, the user should exectute script in the following format:
```bash 
./disk_usage.pl [FILENAME] [OPTIONAL KEYWORDS]
```

The user may choose whether or not to filter keywords, only a filename is required as a parameter.

Example of command with just the file.
  ```bash
   $ ./disk_usage.pl raw_info_sample.txt
  ```
This command does not filter any data, it just sorts the raw_info_sample.txt data from highest to lowest.

An example of the script running with multiple keywords:
  ```bash
  $ ./disk_usage.pl raw_info_sample.txt snapshot filer
  ```

This command filters data containing the words `snapshot` and `filer`, and it sorts the `raw_info_sample.txt` data from highest to lowest.


'use warnings' and 'use strict' is used to avoid mistakes in the code. 

### SUBROUTINE
I defined the use of a subroutine printCSV at the beginning of the program to print the results to a CSV file.


### VARIABLES
`my @file` - an array that holds in the values of each word read in as elements.
`my @keywords` - an array that holds in the values of each of the keywords input as parameters by the user.
`my @controllerLines`, `@controllerArray`, and `$controllerCount` all handle the controller information in the file.
`my @filesystemLines`, `@filesystemArray`, and `$filesystemCount` all handle the filesystem information in the file.
`@csvControllerHeader` and `@csvFilesystemHeader` each hold values to put output directly to CSV
`my $controllerRegex` and `$filesystemRegex` contain regex to filter for the correct input lines from the raw data for the controller and filesytem.
`[a-zA-Z0-9]+\s+[0-9]+\s+[0-9]+\s+[A-Za-z0-9]+\s+[a-zA-Z]+/` ensure the controller is filtered correctly.
`[\/\._a-zA-Z0-9]+\s+([0-9]+[KkMmGgTtPp]?[Bb]\s+){3}[0-9]{1,2}%\s+[\_\-\/\.a-zA-Z0-9]+\s+[\_\-\/\.a-zA-Z0-9]+` ensures the filesystem is filtered correctly.
`my $filename` holds the filename variable that was read in as a parameter from the user.

### CAPTURE PARAMETERS

To capture the `@ARGV` from the user, first one is set to `$filename` and the following to `$keywords`.  
```bash
($filename, @keywords) = @ARGV;
```

Then, an if statement catches if the filename was not entered as a parameter.
This outputs correct usage to the user and exits the program with exit;.


### OPEN FILE

The fileheader opens with `$fh`.
A while loop reads through the file line by line by setting the `$fh` to the scalar value of `$line`.
Keyword filtering is implemented by using the `index()` function.  Index searches for one string within another; in this case, it searches for the keyword within the line.
It then will only push the value of the line to the file if the keyword does not match.

Data sanitization is hadnled with `chomp($line)` to get rid of the end whitespace, and `s/^\s+//g` to get rid of whitespace at the beginning.

The controller lines are separated from the filesystem lines into different arrays using the regex previously declared.

The scalar controller and filesystem lines are split into arrays using the split function within foreach loops. 
Each elements of the @controllerArray and @filesystem arrays are assigned to these values.


### SORT ARRAY

The percent sign causes issues when sorting.  To deal with this, the % is removed from the list of capacities.
This was done with a foreach loop that uses substitution with regex (similar to substitute in vi) to remove the % from element [4] of the variable.
Then, the array is populated with the removed % values.
The @sorted array holds the sorted values, and is set equal to sort command to get the sorted values by element [4](fifth column) of the filesystemArray. This places the data into a descending order by % used in the sorted array.


### CSV OUTPUT 
An outputFile is created that has the name of the original $filename, plus "_sorted.csv".


### CLOSE FILE 
Fileheader is closed with close(FH);.



