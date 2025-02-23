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
Function fn_ListFilesAndValidateCount {
    #--------------------------------------------------------------
    # Function: fn_ListFilesAndValidateCount
    #--------------------------------------------------------------
    <#
    .SYNOPSIS
        Testing function for pester. Lists all files in a specified directory and validates the file count.
    
    .DESCRIPTION
        This function retrieves all files in a given directory and compares the count of files 
        against a user-specified expected count. If the count does not match, function returns 
        value 'File count mismatch'. If it does match returns value of 'File count matches.' 
        There are more Return codes listed in the Notes section below.
    
    .PARAMETER p_DirectoryPath
        Source to obtain files count from.
    
    .PARAMETER p_ExpectedFileCount
        The expected number of files in the directory for validation.
    
    .EXAMPLE
        fn_ListFilesAndValidateCount -p_DirectoryPath "C:\Temp\CreateManyFiles" -p_ExpectedFileCount 10
    
    .NOTES
    # Returns
    File count mismatch.
    Success.

    # 20240601 | Author: TedmondFromRedmond
    #>
       
    param (
        [string]$p_DirectoryPath,
        [int]$p_ExpectedFileCount 
    )
    

    #--- ck p_expectedfilecount for 0 and return "Invalid File Count."
    if(-not $p_ExpectedFileCount -gt 0){return "Invalid File Count."}

        #----
        # Retrieve all of the files in the directory
        $fn_IF_Files = Get-ChildItem -Path $p_DirectoryPath -File
        $fn_IF_FileCount = $fn_IF_Files.Count
    
        # Display file count to console
        Write-Host "Total files found in '$p_DirectoryPath': $fn_IF_FileCount"
    
        # Case - Mismatch on expected number of files returned
        if ($fn_IF_FileCount -ne $p_ExpectedFileCount) {
            Write-Host 'Warning: Expected $p_ExpectedFileCount files, but found $fn_IF_FileCount.'
            write-host 'File count mismatch: Expected $p_ExpectedFileCount, Found $fn_IF_FileCount.'
            $mystring=""
            $mystring="File count mismatch."
            # return "File count mismatch."
            return $mystring
        }
        if($fn_IF_FileCount -eq $p_ExpectedFileCount) {
            Write-Host 'Success.'
            return "Success."
        }



} # End of fn_ListFilesAndValidateCount
#-----------------------------------------------------------------------------------------------------------


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


# Import Functions
#. .\fn_CreateSequentialFilesFunctions.tests.ps1

# Actual fn_CreateSequentialFiles function to modify
. '..\fn_CreateSequentialFiles.ps1'

#-----------------------------------------------------------------------------------------------------------
# MAIN SCRIPT EXECUTION
#-----------------------------------------------------------------------------------------------------------

# Initialize vars
$global:gbl_DefaultMyTestDir = $null

# Constants
$global:gbl_DefaultMyTestDir = 'C:\Temp\test\M365Toolkit\Createmanyfiles\Pester'

# Import Pester Module
Import-Module Pester -PassThru

# Setup default date and time
$script:s_DateandTimeStamp = fn_DateandTimeStamp 

# Set default test directory if the parameter is null or empty
if ([string]::IsNullOrEmpty($p_MyTestDir)) {
    $Global:GBL_TestDir = $global:gbl_DefaultMyTestDir
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
                $s_TestResult | Should -Be "Success."
                write-host
            } catch {
                Throw $_
            }
        } # End of Test Case 1

        # Test Case 2
        It 'Test Case 2 - Validate incorrect file count should error' {
            Try {
                $s_TestResult = fn_ListFilesAndValidateCount -p_DirectoryPath "C:\Temp\PesterCreateManyFiles" -p_ExpectedFileCount 100
                $s_TestResult | Should -Be 'File count mismatch.'
                Write-Host
            } catch {
                Throw $_
            }
        } # End of Test Case 2

        # Test Case 3
        It 'Test Case 3 - Validate correct file count should succeed' {
            Try {
                $s_TestResult = fn_ListFilesAndValidateCount -p_DirectoryPath "C:\Temp\PesterCreateManyFiles" -p_ExpectedFileCount 101
                $s_TestResult | Should -Be "Success."
                Write-Host
            } catch {
                Throw $_
            }
        }  # End of Test Case 3

        # Test Case 4
        It 'Test Case 4 - Test invalid file count passed' {
            Try {
                $s_TestResult = fn_ListFilesAndValidateCount -p_DirectoryPath "C:\Temp\PesterCreateManyFiles" -p_ExpectedFileCount 0
                $s_TestResult | Should -Be "Invalid File Count." 
                write-host
            } catch {
                Throw $_
            }
        }  # End of Test Case 4

     } # End of Context
} # End of Describe

#-----------------------------------------------------------------------------------------------------------
