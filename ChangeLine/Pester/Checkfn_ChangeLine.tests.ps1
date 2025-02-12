<#
# Purpose:
# Test Script for fn_ChangeLine
# To execute a black box test for 1 or many tests
# This script calls a Pester script and interprets the script as Passed or Failed.
# Based upon the return value from the Pester tests, action is taken.

# How To use:
# 1. copy .ps1 file to same directory as .test scripts.
# 2. Copy the following to a test directory
    TestInput.txt
    fn_Changeline.ps1
    fn_Changeline.tests.ps1
# 3. In Main, modify varaiable $myTestDirectory to point to Test directory specified in step 2. 
# 4. In Main, modify varaiable $MyOutputDir to point to repo soure dir. Note: The source file will be overwritten in this directory.
# 5. in Main, modify $myPesterTestFile to point to the location of the Pester Reader Process. 

# Flow of script:
# Execute scriptname.tests.ps1 with correct pester parameters
# Determine if pester tests passed or failed and take appropriate action
#>

####
# MAIN
####

# Initialize variables
$MyTestDirectory = 'C:\Users\TedmondFromRedmond\OneDrive - StartOS.com LLC\Documents\PowerShell\Projects\RefactorGithubtools\SourceFirstTransformationToStandards\Testing\Fn_ChangeLine\Testing'
sl $MyTestDirectory

# Specify the Test directory when you created the repro
$MyOutputDir = 'c:\temp\test\m365toolkit'

# Specify the Pester test file to invoke
$myPesterTestFile = 'fn_ChangeLine.Tests.ps1'

# Call the fn_ChangeLine.tests script
Write-Host "Starting test for fn_ChangeLine..." -ForegroundColor Green
try {
    # Failure to specify the invoke-pester and -passthru will leave the object blank
    $mytest = Invoke-Pester $myPesterTestFile -passthru
    Write-Host "fn_ChangeLine executed successfully." -ForegroundColor Green
}
catch {
    Write-Error "Error during execution of fn_ChangeLine.tests.ps1"
}
# End of Call the fn_ChangeLine function

# Open output file for visual validation
# Notepad.exe $testOutputFile

write-host "Displaying test results"

if($mytest.result -eq "Passed"){
write-host "Pester Passed. promote code to Prod "

}else
{
write-host "Failed validation. Stopping program."
Exit
}

# write-host $mytest

write-host "The End"

###############################





