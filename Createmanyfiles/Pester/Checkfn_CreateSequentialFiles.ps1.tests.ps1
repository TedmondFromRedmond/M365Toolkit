<#
# Purpose:
# To execute a black box test for 1 or many tests.
# Pester Test Script for function. aka, the calling or reader script.
# This script calls a Pester script and interprets the script as Passed or Failed based upon a returned object after invoke-pester with -passthru parm
# If one or many tests exist, the overall pass / fail is evaluated and written to the console and the Data Report file,
# DataReport is generated with all test names, pass/fail, duration ...

# Pester Folder structure of Framework:
# Top level contains source code being tested
# fn....ps1/Pester/Release # Used for final versions of Pester files
# .../Pester/Dev # Used for dev and backups
# e.g. Functions.Tests.ps1, [fn.Name].Tests.ps1, PesterTests.ps1 any other input files and test data are saved here. This directory is promoted to Source Control


# How To use:
# 1. In Main, modify varaiable $myTestDirectory to point to Test directory specified in step 2. 
# 2. In Main, modify varaiable $DataReportCSV to the location of the Data Report Directory which is the output of the test cases and their pass/fail

# Flow of script:
# This script is called a reader/caller script and executes the fn_function.Tests.ps1 script.
# Call and execute scriptname.tests.ps1 with correct pester parameters.
# Pester object is returned.
# Pester object is evaluated for pass or fail and action is taken based upon pass or fail.
# Exports object data to csv for Data Reporting for each test case whether it is pass or fail.
#>
#######
# Functions begin here
#
#-----------------------------------------------------------------------------------------------------------
function fn_DateandTimeStamp {
    <#
    .SYNOPSIS
    Generates a date and time stamp in a concatenated format.
    
    .DESCRIPTION
    This function retrieves the current date and time, formatting it as "yyyyMMdd_HHmmss" for use in logs, filenames, or other timestamp needs.
    
    .Inputs
    A file with characters to replace.

    .Outputs
    Returns Date and time in object format.

    .EXAMPLE
    $My_DateAndTime = fn_DateandTimeStamp
    Write-Host "Date and time concatenation is $GBL_DateAndTime"
    # Output format example: 20250208_124532
    #>
    
        # Get the current date and time
        $fn_IF_CurrentDateTime = Get-Date -Format "yyyyMMdd_HHmmss"
         
        # Return the date and time stamp
        # Write-Host "Date and Time Stamp Generated: $fn_IF_CurrentDateTime"
        
        Return $fn_IF_CurrentDateTime
    } 
#----


# End of functions
#########
####
# MAIN
####

# Date and Time
$My_DateAndTime = fn_DateandTimeStamp

# Initialize variables
$MyTestDirectory = 'C:\Users\TedmondFromRedmond\OneDrive - StartOS.com LLC\Documents\PowerShell\Projects\RefactorGithubtools\SourceFirstTransformationToStandards\AnyKey\Pester'
sl $MyTestDirectory

# Specify the Test directory when you created the repro
$MyOutputDir = "c:\temp"
$DataReportCSV = $MyOutputDir + '\' + $My_DateAndTime + 'DataReportfn_Anykey.csv'

# Specify the Pester test file to invoke
$myPesterTestFile = $MyTestDirectory + '\Releases\' + 'AnyKey.Tests.ps1'

# Call the fn_Anykey.tests script
Write-Host "Starting test and calling Pester test script..." -ForegroundColor Green
try {
    # Failure to specify the invoke-pester and -passthru will leave the object blank
    $mytest = Invoke-Pester $myPesterTestFile -passthru # Note: passthru is required if you want data in the object returned
    Write-Host "scriptname executed successfully." -ForegroundColor Green
}
catch {
    Write-Error "Error during execution $myPesterTestFile in directory $MyTestDirectory"
    Exit
}
# End of Call the fn_AnyKey function

# Used for Testing
# Open output file for visual validation
# Notepad.exe $testOutputFile
# write-host "Displaying test results"

# 
if($mytest.result -eq "Passed"){
write-host "Pester Passed. promote code to Prod "
write-host "Need to promote Release folder to production."
write-host ""
write-host "Data Report: $datareportcsv"
}else
{
write-host "Failed validation. Stopping program. Writing Report to:"
write-host $DataReportCSV
# Assume you've already invoked Pester, e.g.:
# $mytest = Invoke-Pester -Path .\MyTests.Tests.ps1 -PassThru
} # End of if pass or fail

# Export all tests to CSV with pscustom object
$mytest.Tests | ForEach-Object {
        [PSCustomObject]@{
            Name       = $_.Name
            Result     = $_.Result
            ExecutedAt = $_.ExecutedAt
            Passed     = $_.Passed
            Skipped    = $_.Skipped
            Duration   = $_.Duration
        }
    } | Export-Csv -Path $DataReportCSV -NoTypeInformation -append

# write-host $mytest
# notepad.exe $DataReportCSV

write-host "The End of Pester Testing."

###############################





