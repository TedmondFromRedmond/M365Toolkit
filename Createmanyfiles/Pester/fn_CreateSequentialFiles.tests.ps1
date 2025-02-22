<#
.SYNOPSIS
This script executes one or many Pester tests as defined in Pester.Tests.ps1.
The script can operate stand alone or executed by a caller script.

.DESCRIPTION
This script is called by fnCreateSequentialFilescheck.Tests.ps1 and runs Pester tests in the specified functions.

.EXAMPLE
.\fn_CreateSequentialFiles.tests.ps1 -p_MyTestDir "C:\Temp\Test\m365Toolkit\CreateManyFiles"

.PARAMETER p_MyTestDir
Optional parameter specifying the test directory.

.NOTES
Author: TedmondFromRedmond

#>

#-------------------
param(
    [string]$p_MyTestDir  # Optional parameter for the directory path
)
#-------------------


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

# Import Pester Module
Import-Module Pester -PassThru

# Import Functions
. .\fn_CreateSequentialFilesFunctions.tests.ps1
. '..\fn_CreateSequentialFiles.ps1'

#-----------------------------------------------------------------------------------------------------------
# MAIN SCRIPT EXECUTION
#-----------------------------------------------------------------------------------------------------------

# Setup default date and time
$script:s_DateandTimeStamp = fn_DateandTimeStamp 

# Set default test directory if the parameter is null or empty
if ([string]::IsNullOrEmpty($p_MyTestDir)) {
    $Global:GBL_TestDir = "C:\Temp\test\M365Toolkit\Createmanyfiles\Pester"
} else {
    $Global:GBL_TestDir = $p_MyTestDir 
}

# Change working directory
Set-Location $Global:GBL_TestDir

# Pause for window initialization
Start-Sleep -Seconds 2

#-----------------------------------------------------------------------------------------------------------
# PESTER TEST EXECUTION
#-----------------------------------------------------------------------------------------------------------
Describe 'fn_CreateSequentialFiles Tests' {
    BeforeAll {
        # Cleanup previous test files
        if (Test-Path "C:\Temp\PesterCreateManyFiles") { 
            Remove-Item -Path "C:\Temp\PesterCreateManyFiles" -Recurse -Force 
        }
    } # End of BeforeAll
    
    AfterAll {
        # Cleanup test files post-execution
        if (Test-Path "C:\Temp\PesterCreateManyFiles") { 
            Remove-Item -Path "C:\Temp\PesterCreateManyFiles" -Recurse -Force 
        }
    } # End of AfterAll

    Context 'Test fn_CreateSequentialFiles' {
        # Test Case 1
        It 'Test Case 1 - Call fn and create files then check return' {
            Try {
                $s_TestResult = fn_CreateSequentialFiles -p_DirectoryPath "C:\Temp\PesterCreateManyFiles" -p_FileCount 101
                $s_TestResult | Should -Be "File creation completed."
            } catch {
                Throw $_
            }
        } # End of Test Case 1

        # Test Case 2
        It 'Test Case 2 - Validate incorrect file count should error' {
            Try {
                $s_TestResult = fn_ListFilesAndValidateCount -p_DirectoryPath "C:\Temp\PesterCreateManyFiles" -p_ExpectedFileCount 100
                $s_TestResult | Should -Be 'File count mismatch.'
            } catch {
                Throw $_
            }
        } # End of Test Case 2

        # Test Case 3
        It 'Test Case 3 - Validate correct file count should succeed' {
            Try {
                $s_TestResult = fn_ListFilesAndValidateCount -p_DirectoryPath "C:\Temp\PesterCreateManyFiles" -p_ExpectedFileCount 101
                $s_TestResult | Should -Be "File count matches."
            } catch {
                Throw $_
            }
        }  # End of Test Case 3

        # Test Case 4
        It 'Test Case 4 - Test invalid file count passed' {
            Try {
                $s_TestResult = fn_ListFilesAndValidateCount -p_DirectoryPath "C:\Temp\PesterCreateManyFiles" -p_ExpectedFileCount 0
                $s_TestResult | Should -Be "File Count Mismatch."
            } catch {
                Throw $_
            }
        }  # End of Test Case 4

        # Test Case 5
        It 'Test Case 5 - Test invalid parameter should fail' {
            Try {
                $s_TestResult = fn_ListFilesAndValidateCount -p_DirectoryPath "C:\Temp\PesterCreateManyFiles"
                $s_TestResult | Should -Be "File Count Mismatch."
            } catch {
                Throw $_
            } # End of try catch
        }  # End of Test Case 5
    } # End of Context
} # End of Describe

#-----------------------------------------------------------------------------------------------------------
