###############################################################################
# Purpose:
# To import a csv file and iterate through file 
#
#
#
# Inputs:
# 'C:\Users\next1\OneDrive\Documents\PowerShell\CSV\SampleCSVInput.csv'
#
#
#
# Outputs:
#
#
# Usage:
# .\TemplateCSV.ps1 -pFileToSearch '.\SampleCSVInput.csv' -pScriptOutputDir 'C:\Users\next1\OneDrive\Documents\PowerShell\CSV' -pSummaryOutputFleName 'stuff.csv' 
#
#
#-----------------------------------------------------------------------------------------------------------
# Revision History:
# Date               | Description
#-----------------------------------------------------------------------------------------------------------
# 20231101 | TFR - Maker
#
#-----------------------------------------------------------------------------------------------------------
#
#
#-----------------------------------------------------------------------------------------------------------
# 
#-----------------------------------------------------------------------------------------------------------
# Description        | Action
#
############################################################################################################
param([string]$pFileToSearch,[string]$columnToSearch,[string]$pScriptOutputDir,[string]$pScriptOutputFileName)

# Functions to deal with CSV


#---------------------------------------------------------------------#
##### Main #####



# -- xform parms to script values for script processing
# parm values begin with lowercase p


# get date
$date=get-date
$dateout=$date.GetDateTimeFormats()[105]




# --> Initialize variables
# Setup vars for processing and clear values used in script to avoid ISE errors w/multiple scripts open
$CoreModuleLocation=''
$myoutstring=''
$myrc=''
$ReportName=''
$scriptOutputDir=''
$scriptOutputFileName=''
$scriptFiletoSearch=''
$TelemetryFile=''
$TelemetryMethod=''

 $global:myMetaData=@()
 $global:myOutputArray=@()
 $global:myArray=@()
 $myarray=@('Title','Number of items','Size (MB)','Has Workflows')


# .\TemplateCSV.ps1 -pFileToSearch '.\SampleCSVInput.csv' -pScriptOutputDir 'C:\Users\next1\OneDrive\Documents\PowerShell\CSV' -pSummaryOutputFleName 'stuff.csv' 

# --> Key Values
# Setup vars for processing and clear values used in script to avoid ISE errors w/multiple scripts open
$myoutstring=''
$ReportName='TemplateCSV Report'

$scriptFiletoSearch=$pFileToSearch
$scriptOutputDir=$pScriptOutputDir

$scriptOutputFileName=$scriptOutputDir + "\" + $pScriptOutputFileName
$TelemetryDir='c:\Telemetry'
$TelemetryFile='MyTelemetry.csv'
$TelemetryFileOut=$TelemetryDir + '\' + $TelemetryFile

# Overrides
$scriptFiletoSearch='.\SampleCSVInput.csv'
$scriptOutputFileName=".\DefaultLoggingFile.csv"

#-------------------------------------------
$myrc=''
# PreChecks
# See if CSV input file exists
# if not, then write out error and EXIT
# call function 
# fn_ckFileExistence "C:\SharePoint\Ichiro.txt"
$myrc=''
if (($myrc=fn_ckFileExistence $scriptFiletoSearch) -eq 0){write-host 'ERR: Input CSV File NOT found. Ending Program - ck vars for parms';EXIT}

# End of PreChecks
#-------------------------------------------


# Import modules
$CoreModuleLocation='C:\Users\next1\OneDrive\Documents\PowerShell\CoreModules\COREModules.psm1'
if(Get-Module 'COREModules') 
{write-host 'CoreModule Found.'}
Else
{Import-module $CoreModuleLocation}

#  CSV file to var $file1
# Iterate loop thru each item in the csv
# Setup an array to loop through and look for certain text

$myoutstring=''
$myoutstring='#----------------------------------------------#'
fn_writefile $scriptOutputFileName


# Import CSV
$File1=import-csv $scriptFiletoSearch
$myoutstring=''
$myoutstring=$dateout + ',' + $ScriptName + ',' + 'ReportStart'


# Obtain very first row only from csv
# $o=$file1|select * |select-object -First 1

# # search for the count of a file
# select with where object to determine the count
# $t= $file1|select *|where-object {$_.$fnColumnToSearch -eq $fnValueToSearchFor}|measure-object
#     Return $t.count
# # end of the count of a file


# #
#
# $t=$file1|select *|where-object {$_.$fnColumnToSearch -eq $fnValueToSearchFor}|measure-object
# Retrun 
# #


$myoutstring=''
$myoutstring=$dateout + ',' + $ReportName + ',' + 'ReportFinish'
fn_writefile '.\ServerLogDoNotDelete.txt' $myoutstring
fn_writefile $scriptOutputFileName 'Report Name: End of it all'


# Remove from local GAC
if(Get-Module 'COREModules') 
{write-host 'CoreModule Found. Removing Module from GAC...'
Remove-module 'COREModules'
}
Else
{write-host 'COREModule not found in memory..continuing'}




#-------------------------------------



