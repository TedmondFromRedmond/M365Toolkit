<#
# Purpose:
##### TIP OF THE CENTURY:
#####
##### ANYKEY SCRIPT Must start in Admin Mode or System properties intermittently appear.
# Call the script performing pester and tests.
# When the script is returned it will return 1 or many test results.

# How To use:
# 1. In Main, modify varaiable $myTestDirectory to point to Test directory specified in step 2. 
# 2. Modify the name of the script to call. e.g. [ScriptName]Check.tests.ps1
# 3. In Main, modify varaiable $DataReportCSV to the location of the Data Report Directory which is the output of the test cases and their pass/fail

# Flow of this script:
# This script is referred to as a caller/reader script and executes the [ScriptName].Tests.ps1 script.
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
# Import Pester Module
Import-Module Pester -PassThru

# Date and Time
$My_DateAndTime = fn_DateandTimeStamp

# Initialize variables
$MyTestDirectory = 'C:\temp\test\m365Toolkit\Anykey\Pester'
Set-Location $MyTestDirectory

# Specify the Test directory when you created the repro
# $MyOutputDir = "c:\temp"
$MyOutputDir = $MyTestDirectory
$DataReportCSV = $MyOutputDir + '\' + $My_DateAndTime + 'DataReportfn_Anykey.csv'

# Specify the Pester test file to invoke
$myPesterTestFile = $MyTestDirectory + '\' + 'fn_AnyKey.Tests.ps1'


# Must start in Admin Mode or System properties intermittently appear.
# Check if the script is running as Administrator
<#
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting script as Administrator..."
    
    # Relaunch in an elevated window
    Start-Process -FilePath "powershell.exe" `
        -ArgumentList "-NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs

    Exit # Close the current non-admin session
}
#>


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
            CallerScript = "fn_AnyKeyCheck.tests.ps1"
            TestName   = $_.Name
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





