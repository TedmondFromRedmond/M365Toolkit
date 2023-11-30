<#

CSV Snippits

To Use:

1) Download zip file to a directory such as c:\myPOSH
2) Open up ISE or VSCode
3) SL c:\myPOSH
4) validate the CSV file named SampleCSVInput.csv is in the directory
5) Execute powershell


Ref:
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-csv?view=powershell-7.2


#>



# Overrides
$ScriptFiletoSearch='.\SampleCSVInput.csv'
$ScriptOutputFileName=".\DefaultLoggingFile.csv"


# Import CSV file

$File1=import-csv $scriptFiletoSearch


# Display properties and methods of CSV
$File1|gm


# To find total number of items in csv, use the .count property
$File1.count


# Obtain very first row from csv and display to screen
$o=$file1|select * |select-object -First 1
$o


# Measure-object to determine the number of items in a file by filtering a selection criteria
$t=$file1|select *|where-object {$_.$fnColumnToSearch -eq $fnValueToSearchFor}|measure-object
$t.count

# Filter column with like looking for Group Name containing My
# 
$stuff='Group Name'
$file1.$stuff|Where-Object{$_ -like '*My*'}



#-------------------------------------






