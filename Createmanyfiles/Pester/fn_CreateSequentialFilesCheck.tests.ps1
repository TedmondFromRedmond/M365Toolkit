<#
.SYNOPSIS
This script calls a Pester test script and returns an object with the results.
aka a caller script

.DESCRIPTION
- Runs a specified Pester test file and reports the results.
- Stores the results in a CSV report for tracking test cases.

.PARAMETER p_MyTestDirectory
Optional parameter specifying the test directory.

.PARAMETER p_My_ReportName
Optional parameter specifying the name of the test report file.

.EXAMPLE
.\Script.ps1 -p_MyTestDirectory "C:\Temp\Test" -p_My_ReportName "PesterReport.csv"
#>

param(
    [string]$p_MyTestDirectory,  # Optional parameter for the test directory path
    [string]$p_My_ReportName     # Optional parameter for specifying the Pester report name
)

#-----------------------------------------------------------------------------------------------------------
# Function: fn_DateandTimeStamp
#-----------------------------------------------------------------------------------------------------------
function fn_DateandTimeStamp {
    <#
    .SYNOPSIS
    Generates a date and time stamp.

    .DESCRIPTION
    This function retrieves the current date and time, formatting it as "yyyyMMdd_HHmmss".

    .EXAMPLE
    $s_DateAndTime = fn_DateandTimeStamp
    Write-Host "Date and time concatenation is $s_DateAndTime"
    # Output example: 20250208_124532
    #>
    
    # Get the current date and time
    $fn_IF_CurrentDateTime = Get-Date -Format "yyyyMMdd_HHmmss"
    
    # Return the formatted date-time
    Return $fn_IF_CurrentDateTime
}
#-----------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------------
# MAIN SCRIPT EXECUTION
#-----------------------------------------------------------------------------------------------------------

# Set default test directory if the parameter is null or empty
if ([string]::IsNullOrEmpty($p_MyTestDirectory)) {
    $Global:GBL_TestDirectory = "C:\Temp\test\M365Toolkit\CreateManyFiles\Pester"
} else {
    $Global:GBL_TestDirectory = $p_MyTestDirectory 
}

# Set default report name
if ([string]::IsNullOrEmpty($p_My_ReportName)) {
    $Global:GBL_ReportName = "DataReport_fn_CreateSequentialFiles.csv"
} else {
    $Global:GBL_ReportName = $p_My_ReportName
}

# Import Pester Module
Import-Module Pester -PassThru

# Set timestamp
$script:s_DateandTimeStamp = fn_DateandTimeStamp

# Define test file and output paths
$script:s_PesterTestFile = "fn_CreateSequentialFiles.tests.ps1"
Set-Location $Global:GBL_TestDirectory

$script:s_OutputDir = $Global:GBL_TestDirectory
$Global:GBL_DataReportCSV = "$script:s_OutputDir\$Global:GBL_ReportName"

$script:s_PesterTestFilePath = "$Global:GBL_TestDirectory\$script:s_PesterTestFile"

#-----------------------------------------------------------------------------------------------------------
# EXECUTE PESTER TESTS
#-----------------------------------------------------------------------------------------------------------
Write-Host "Starting test and calling Pester test script..." -ForegroundColor Green
try {
    # Ensure test file exists before execution
    if (-not (Test-Path $script:s_PesterTestFilePath)) {
        Throw "Error: Pester test file not found at $script:s_PesterTestFilePath"
    }

    # Execute Pester tests and capture the result
    $Global:GBL_PesterResult = Invoke-Pester $script:s_PesterTestFilePath -PassThru

    Write-Host "Sub Script executed successfully: $script:s_PesterTestFilePath" -ForegroundColor Green
}
catch {
    Write-Error "Execution error: $_"
    Exit ## STOP Run ##
}

#-----------------------------------------------------------------------------------------------------------
# PROCESS TEST RESULTS
#-----------------------------------------------------------------------------------------------------------
if ($Global:GBL_PesterResult.Result -eq "Passed") {
    Write-Host "Pester Passed. Promote code to Production."
    Write-Host "Promote Release folder to production."
    Write-Host "`nData Report: $Global:GBL_DataReportCSV"
} else {
    Write-Host "Failed validation. Stopping program. Writing report to:"
    Write-Host "$Global:GBL_DataReportCSV"
}

#-----------------------------------------------------------------------------------------------------------
# EXPORT TEST RESULTS TO CSV
#-----------------------------------------------------------------------------------------------------------
$Global:GBL_PesterResult.Tests | ForEach-Object {
    [PSCustomObject]@{
        CallerScript = "fn_CreateSequentialFilesCheck.tests.ps1"
        TestName     = $_.Name
        Result       = $_.Result
        ExecutedAt   = $_.ExecutedAt
        Passed       = $_.Passed
        Skipped      = $_.Skipped
        Duration     = $_.Duration
    }
} | Export-Csv -Path $Global:GBL_DataReportCSV -NoTypeInformation -Append

#-----------------------------------------------------------------------------------------------------------
# FINALIZE
#-----------------------------------------------------------------------------------------------------------
Write-Host "Pester testing completed. Report saved to: $Global:GBL_DataReportCSV"
