<#
###############################################################################
 Purpose:
 To execute tests using pester for the function
 fn_ChangeLine.Tests.ps1
 and provide Test results in a csv file from variable $script:pstrcsvFile

 How to use:
 Phase I: Environment Setup
 0. Modify the variables under MAIN heading
        $MyTestDir = The directory this script resides in
        $script:scr_DateandTimeStamp = fn_DateandTimeStamp # Date and time format 
        $script:pstrcsvFile = ".\fn_ChangeLine_pstrTestResults.csv" # Log file for script
        $script:pstrTestInputFile = ".\TestInput.txt" # Source input file is not overwritten
        $script:pstrTestOutputFile = ".\TestOutput.txt" # Changed source file output
        $script:pstrTestResults = @() # Array to hold custom objects for output to csv file aka $script:pstrcsvFile

 1. Install Pester module on server/workstation with: 
 2. Install-module Pester
 3. Execute Reader proc script to call this script

 Phase II:
 Use Passthru parameter to allow tracking of 1 or more tests. if script is called by another script, then set object = calling this script.
 Calling script syntax execution should be similar to $myTests = .\fn_Changline.Tests.ps1

 Since the imports Import-Module Pester -PassThru, there is no need to import the Pester module twice

 Phase III:
 Use a separate script to call this script as shown below
 Pester invocation to call a script and store in variable
 $myPesterOutcome = Invoke-Pester -Path .\fn_ChangeLine.Tests.ps1 -passthru


# Flow of script
# Test script name is designated a test script in vscode with .Tests in the name,
e.g. scriptname.Tests.ps1 
# First, import the Pester module.
# Second, check input file existence, if not then fail.
# Executes the tests

# Monitor Test results in csv file named
- Review file specified in variable $script:pstrcsvFile

###############################################################################
#>

#-----------------------------------------------------------------------------------------------------------
function fn_DateandTimeStamp {
    <#
    .SYNOPSIS
    Generates a date and time stamp in a concatenated format.
    
    .DESCRIPTION
    This function retrieves the current date and time, formatting it as "yyyyMMdd_HHmmss" for use in logs, filenames, or other timestamp needs.
    
    .Inputs
    A file with characters to replace.
    # $script:pstrTestInputFile = ".\TestInput.txt" # Source input file for changeline fn.

    .Outputs
    # $script:pstrcsvFile = ".\fn_ChangeLine_pstrTestResults.csv" # CSV Log file for script
    # $script:pstrTestOutputFile = ".\TestOutput.txt" # Output file for changeline fn.
    # $script:pstrTestResults = @() # Array to hold custom objects for output to CSV log file for script

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


#----
function fn_ChangelineTest {
    <#
    .SYNOPSIS
        Executes a standardized test case for the fn_ChangeLine function.

    .DESCRIPTION
        This function:
        - Removes the output file if it exists.
        - Executes the fn_ChangeLine function with specified parameters.
        - Validates the output to check for the expected changes.
        - Logs the result (Pass/Fail) consistently with all necessary fields.

    .PARAMETER InputFile
        The path to the input file for fn_ChangeLine.

    .PARAMETER OutputFile
        The output file generated after applying changes.

    .PARAMETER BeforeChange
        The string to search for in the input file.

    .PARAMETER AfterChange
        The replacement string to substitute for BeforeChange.

    .PARAMETER ExpectedOutput
        The expected output string that validates the test.

    .PARAMETER TestCaseName
        The descriptive name for the test case.

    .PARAMETER Description
        A brief description of the test case.

    .PARAMETER ErrorMessage
        The custom error message to log in case of test failure.

    .Returns
        Returns an object with properties of Description, fn_success-binary of 0 means no issue 1 means problem, TestCaseName passed in
        $ResultObject = [PSCustomObject]@{
        Description = $Description
        fn_Success = "1or0" # 1 means error, 0 means success
        TestCase    = $TestCaseName
        Status = "PassedorFailed"}

    .EXAMPLE
        fn_ChangelineTest -InputFile ".\TestInput.txt" -OutputFile ".\TestOutput.txt" `
                              -BeforeChange "~" -AfterChange "#" `
                              -ExpectedOutput "Line 1: This is a test with #" `
                              -TestCaseName "Test 1 - Replace Tilde" `
                              -Description "Validates replacing ~ with #" `
                              -ErrorMessage "Test 1 failed: Tilde was not replaced."
    #>

    param (
        [Parameter(Mandatory)]
        [string]$InputFile,

        [Parameter(Mandatory)]
        [string]$OutputFile,

        [Parameter(Mandatory)]
        $BeforeChange,

        [Parameter(Mandatory)]
        $AfterChange,

        [Parameter(Mandatory)]
        [string]$ExpectedOutput,

        [Parameter(Mandatory)]
        [string]$TestCaseName,

        [Parameter(Mandatory)]
        [string]$Description,

        [Parameter(Mandatory)]
        [string]$ErrorMessage
    )

    # Capture the timestamp for consistency
    $timestamp = (Get-Date -Format "yyyyMMdd_HHmmss")

    # Remove the output file if it exists
    if (Test-Path -Path $OutputFile) {
        Remove-Item -Path $OutputFile -Force
    }

    # Execute the function under test
    # piped to null to stop pipeline from adding to return object
    fn_ChangeLine -p_InputFile $InputFile -p_b4Change $BeforeChange -p_AfterChange $AfterChange -p_OutputFile $OutputFile|out-null

    # Validate the output
    $result=$null
    $outputContent = Get-Content -Path $OutputFile
    # $result = $outputContent | Where-Object { $_ -contains $ExpectedOutput }
    $result = $outputContent | Where-Object {$_.contains($ExpectedOutput) }
    # Create the PSCustomObject to return from the function
    $ResultObject = [PSCustomObject]@{
        Description = $Description
        fn_Success = "1or0" # 1 means error, 0 means success
        TestCase    = $TestCaseName
        Status = "PassedorFailed"
    } # End of ResultObject

# Check for Result value
    if ($result) {
        # Log success
        $script:pstrTestResults += [PSCustomObject]@{
            TimeStamp   = $timestamp
            TestCase    = $TestCaseName
            Status      = 'Passed'
            Description = $Description
        }
        $ResultObject.fn_Success = "0"
        $ResultObject.Status = "Passed"

    } else {
        # Log failure (ensure timestamp is included)
        $script:pstrTestResults += [PSCustomObject]@{
            TimeStamp   = $timestamp
            TestCase    = $TestCaseName
            Status      = "Failed"
            Description = $ErrorMessage
        } # End of adding custom object to array

        $ResultObject.fn_Success = "1"
        $ResultObject.Status = "Failed"
    } # End of if $result

    # Return an object with specific details
    Return  $ResultObject

} # End of fn_ChangelineTest
#----

#----
# Dot source the fn_ChangeLine function into memory for testing
# Import function to test
. ".\fn_ChangeLine.ps1"  # Dot-sourcing to ensure the function is loaded into the current session
    #---- End of fn_ChangeLine ----
#----
    ### End of Functions ###
###############################################################################
#-----
# Main
#-----
$myTestDir = "C:\Users\TedmondFromRedmond\OneDrive - StartOS.com LLC\Documents\PowerShell\Projects\RefactorGithubtools\SourceFirstTransformationToStandards\Testing\Fn_ChangeLine\Testing"
# Import Pester Module
Import-Module Pester -PassThru

# Change into testing directory
# Set-Location "C:\Users\TedmondFromRedmond\OneDrive - StartOS.com LLC\Documents\PowerShell\Projects\RefactorGithubtools\SourceFirstTransformationToStandards\Testing\Fn_ChangeLine\Testing"
Set-Location $myTestDir


#---------------------
# Pester overview
# Describe is the top level
# It is the actual test case
# Beforeall executes before the It tests
# AFterall executes after all the tests
# Note: 
# Variables are scoped at different levels in Pester. Be careful and test accordingly.
# Test Cases Start Here with Describe

Describe "fn_ChangeLine Automated Tests" {

# Write-Host "Entering fn_changeline tests...."

    # First script block executed before the Test cases
    BeforeAll {
        # Ensure the test input file exists
        Write-Host "Entering BeforeAll tests...."

        $script:scr_DateandTimeStamp = fn_DateandTimeStamp # Date and time format 
        $script:pstrcsvFile = ".\fn_ChangeLine_pstrTestResults.csv" # Log file for script
        $script:pstrTestInputFile = ".\TestInput.txt" # Source input file is not overwritten
        $script:pstrTestOutputFile = ".\TestOutput.txt" # Changed source file output
        $script:pstrTestResults = @() # Array to hold custom objects for output to csv file aka $script:pstrcsvFile


        Write-Host "...Display values before processing..."
        Write-Host "pstrTestInputFile value $script:pstrTestInputFile" 
        Write-Host "pstrTestOutputFile value $script:pstrTestOutputFile" 
        Write-Host "pstrcsvFile value $script:pstrcsvFile" 
        Write-Host "pstrTestResults value $script:pstrTestResults"
        Write-Host "TimeStamp value $script:scr_DateandTimeStamp"

        if (-not (Test-Path $script:pstrTestInputFile)) {
            throw "Test input file does not exist: $script:pstrTestInputFile"
        }

        # Initialize the test results array
        $script:pstrTestResults = @()
    } # End of beforeall

    # Script block executed after all test cases
    AfterAll {
        # Clean up the output file after tests
        Write-Host "Entering After All... Log file is located at: $script:pstrTestOutputFile"

        # Export the table with objects created during processing
        $script:pstrTestResults | Export-Csv -Path $script:pstrcsvFile -Append -NoTypeInformation        
        
        Write-Output ""
        Write-Output "Test results saved to: $script:pstrcsvFile"
        Write-host ""
        # Get-Content $script:pstrcsvFile
        # notepad.exe $script:pstrcsvFile
        # notepad.exe $script:pstrTestOutputFile
    } # End of afterall

#----

#----

# Test Case 1 - Replaces tilde with sharp

It "Replaces tilde with sharp" {
    $myTest=fn_ChangelineTest -InputFile $script:pstrTestInputFile `
                              -OutputFile $script:pstrTestOutputFile `
                              -BeforeChange '~' -AfterChange '#' -ExpectedOutput 'Line 1: This is a test with #' `
                              -TestCaseName 'Test 1 - Replace Tilde with #' -Description 'Replaced ~ with # in Line 1' `
                              -ErrorMessage 'Test 1 Failed: Tilde was not replaced with #'

        try {

        $myTest.Status|should -Be "Passed"

        } catch {
        throw "Test 1 - Replace Tilde with #' -Description 'Replaced ~ with # in Line 1" 

        } # End of try catch

     
} # End of test case 1
#----


#----
# Test Case 2 Replaces BacktickTheReplacements with TildeTheReplacements
It "Replaces BacktickTheReplacements with TildeTheReplacements" {
    $myTest=fn_ChangelineTest -InputFile $script:pstrTestInputFile `
                          -OutputFile $script:pstrTestOutputFile `
                          -BeforeChange '`TheReplacements' -AfterChange '~TheReplacements' `
                          -ExpectedOutput 'Line 2: Another line with ~TheReplacements for backtick.' `
                          -TestCaseName 'Test 2 - Replace Backtick with Tilde' `
                          -Description 'Replaced `TheReplacements with ~TheReplacements in Line 2' `
                          -ErrorMessage 'Test 2 Failed: Backtick was not replaced with Tilde'
try {

$myTest.Status|should -Be "Passed"

} catch {
throw "Test 2 failed - Replace Backtick with Tilde" 

} # End of try catch


} # End of test case 2
#----


#----
# Test case 3 - Replaces tilde with ChangedTilde
It "Replaces tilde with ChangedTilde" {
    $myTest=fn_ChangelineTest -InputFile $script:pstrTestInputFile `
                            -OutputFile $script:pstrTestOutputFile `
                          -BeforeChange '~' -AfterChange 'ChangedTilde' `
                          -ExpectedOutput 'Line 3: This line contains a ChangedTilde (tilde).' `
                          -TestCaseName 'Test 3 - Replace Tilde with ChangedTilde' `
                          -Description 'Replaced ~ with ChangedTilde in Line 3' `
                          -ErrorMessage 'Test 3 Failed: Tilde was not replaced with ChangedTilde'

try {

$myTest.Status|should -Be "Passed"

} catch {
throw "Test case 3 Failed - Replaces tilde with ChangedTilde" 

} # End of try catch

} # End of test case 3



#----



#----
# Test Case 4


It "Test 4 Replace tilde with text behind it" {
$myTest=
    fn_ChangelineTest -InputFile ".\TestInput.txt" `
    -OutputFile ".\TestOutput.txt" `
    -BeforeChange '~TheTildeReplacement' `
    -AfterChange '!@#TILDREPLACEMENTWASHERE' `
    -ExpectedOutput 'Line 4: This line has !@#TILDREPLACEMENTWASHERE to be replaced' `
    -TestCaseName 'Test 4 Replace tilde with text behind it' `
    -Description 'Test 4 Replaces the tilde while retaining the text behind it' `
    -ErrorMessage 'Test 4 Failed: Tilde was not replaced correctly in line 4'`
    
    try {
        # Pester test with Should be
        # Remember to put throw in catch for pester to see it, otherwise it is assumed past even if there is an err
        $myTest.Status|should -Be "Passed"
    }
    catch {
        # dont forget, you have to throw the err for pester
        Throw "Failed Test 4 Replace tilde with text behind it"
        # Mytest failed to return a passed so pester failed
        write-host "Test 4 failed"
    }
    

} # End of Test 4
#----


#----
# Test Case 5
It "Test 5 Replace the backslash on line 5" {
    $mytest=fn_ChangelineTest -InputFile ".\TestInput.txt" `
    -OutputFile '.\TestOutput.txt' `
    -BeforeChange 'Line 5: A backslash \ in this line' `
    -AfterChange 'Line 5: A backslash !@# in this line.' `
    -ExpectedOutput 'Line 5: A backslash !@# in this line.' `
    -TestCaseName 'Test 5 Replace the backslash on line 5' `
    -Description 'Test 5 Replaces the backslash with !@#' `
    -ErrorMessage 'Test 5 Failed: Backslash was not replaced correctly'`

try {

$myTest.Status|should -Be "Passed"

} catch {
throw "Test 5 failed - Replace the backslash on line 5" 

}

    } # End of test case 5
#---

#----
# Test Case 6
It "Test 6 Replace Backslash with text" {
    $mytest=fn_ChangelineTest -InputFile ".\TestInput.txt" `
    -OutputFile '.\TestOutput.txt' `
    -BeforeChange 'Line 6: This is a \ThisisaBackslashTest to be' `
    -AfterChange 'Line 6: This is a  ThisisaBackslashTest to be' `
    -ExpectedOutput 'Line 6: This is a  ThisisaBackslashTest to be' `
    -TestCaseName 'Test 6 Line 6: This is a  ThisisaBackslashTest to be' `
    -Description 'Test 6 Replaces the backslash on Line 6' `
    -ErrorMessage 'Test 6 Failed: Backslash with trailing text was not replaced correctly'`

try {

$myTest.Status|should -Be "Passed"

} catch {
throw "Test 6 failed - Replaced backslash with a space on line 6" 

}

    } # End of test case 6

#----

#----
# Test 7 
It "Test 7Replaces the upper case word Pyracantha with the lower case p on Line 7" {
    $mytest=fn_ChangelineTest -InputFile ".\TestInput.txt" `
    -OutputFile '.\TestOutput.txt' `
    -BeforeChange 'Line 7: Pyracantha' `
    -AfterChange 'Line 7: pyracantha' `
    -ExpectedOutput 'Line 7: pyracantha' `
    -TestCaseName 'Test 7 Line 7: Change case of Pyracantha' `
    -Description 'Test 7 Replaces the upper case word Pyracantha with the lower case p on Line 7' `
    -ErrorMessage 'Test 7 Failed: lowercase p failed to replace upper case P in Pyracantha'`

try {
$myTest.Status|should -Be "Passed"
} catch {
throw "Test 7 failed - Replace p in Pyracantha with lowercase p" 
}
    } # End of test case 7

#----


#----
# Test 8
It "Test 8 - Replace Stuff with OrangeTrump" {
    $mytest=fn_ChangelineTest -InputFile ".\TestInput.txt" `
    -OutputFile '.\TestOutput.txt' `
    -BeforeChange 'Line 8: Stuff should remain or' `
    -AfterChange 'Line 8: Trump should remain' `
    -ExpectedOutput 'Line 8: Trump should remain' `
    -TestCaseName 'Test 8 - Replace Stuff with OrangeTrump' `
    -Description 'Test 8 - Replace Stuff with OrangeTrump' `
    -ErrorMessage 'Test 8 Failed: Test 8 - Replace Stuff with OrangeTrump' `

try {
$myTest.Status|should -Be "Passed"
} catch {
throw "Test 8 failed - Stuff was not replaced with OrangeTrump" 
}
    } # End of test case 8

#----


#--- Test Cases End
} # End of Describe block

