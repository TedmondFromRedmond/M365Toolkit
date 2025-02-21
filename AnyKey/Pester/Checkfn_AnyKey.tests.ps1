<#
# Purpose:
# Test Script for function
# To execute a black box test for 1 or many tests
# This script calls a Pester script and interprets the script as Passed or Failed.
# Based upon the return value from the Pester tests, action is taken.

# Folder structure of Framework
# e.g.
# Anykey.ps1/Pester/Release # Used for final versions of Pester files
# Top level contains source code being tested
# e.g. Functions.Tests.ps1 and [fn.Name].Tests.ps1

# .../Pester/Dev # Used for dev and backups
# 

# How To use:
# 1. copy this .ps1 file to same directory as .test scripts.
# 2. Copy the function to be tested to the directory above the pester directory
# 3. In Main, modify varaiable $myTestDirectory to point to Test directory specified in step 2. 
# 4. In Main, modify varaiable $MyOutputDir to the location of the Data Report Directory which is the output of the returned Pester object

# Flow of script:
# This script is called a reader script and executes the fn_function.Tests.ps1 script.
# Call and execute scriptname.tests.ps1 with correct pester parameters.
# Pester object is returned.
# Pester object is evaluated for pass or fail and action is taken based upon pass or fail.
# Exports object data to csv for Data Reporting for each test case whether it is pass or fail.
#>

####
# MAIN
####

# Initialize variables
$MyTestDirectory = 'C:\Users\TedmondFromRedmond\OneDrive - StartOS.com LLC\Documents\PowerShell\Projects\RefactorGithubtools\SourceFirstTransformationToStandards\AnyKey\Pester'
sl $MyTestDirectory

# Specify the Test directory when you created the repro
$MyOutputDir = 'c:\temp'
$DataReportCSV = $MyOutputDir + '\' + 'DataReportfn_Anykey.csv'

# Specify the Pester test file to invoke
$myPesterTestFile = $MyTestDirectory + '\Releases\' + 'AnyKey.Tests.ps1'

# Call the fn_ChangeLine.tests script
Write-Host "Starting test and calling tests script..." -ForegroundColor Green
try {
    # Failure to specify the invoke-pester and -passthru will leave the object blank
    $mytest = Invoke-Pester $myPesterTestFile -passthru # Note: passthru is required if you want data in the object returned
    Write-Host "scriptname executed successfully." -ForegroundColor Green
}
catch {
    Write-Error "Error during execution $myPesterTestFile in directory $MyTestDirectory"
    Exit
}
# End of Call the fn_ChangeLine function

# Used for Testing
# Open output file for visual validation
# Notepad.exe $testOutputFile
# write-host "Displaying test results"

# 
if($mytest.result -eq "Passed"){
write-host "Pester Passed. promote code to Prod "
write-host "Need to promote Release folder to production."
}else
{
write-host "Failed validation. Stopping program. Writing Report to:"
write-host $DataReportCSV
# Assume you've already invoked Pester, e.g.:
# $mytest = Invoke-Pester -Path .\MyTests.Tests.ps1 -PassThru

    $mytest.Tests | ForEach-Object {
        [PSCustomObject]@{
            Name       = $_.Name
            Result     = $_.Result
            ExecutedAt = $_.ExecutedAt
            Passed     = $_.Passed
            Skipped    = $_.Skipped
            Duration   = $_.Duration
        }
    } | Export-Csv -Path $DataReportCSV -NoTypeInformation -Force

} # End of if pass or fail

# write-host $mytest

notepad.exe $DataReportCSV

write-host "The End of Pester Testing."

###############################





