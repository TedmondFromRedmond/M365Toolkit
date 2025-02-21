# Purpose: File is imported to a script to provide script specific functions for testing.
# 
# Insert Functions below
#----
#
# Functions begin here
#
#--------

Function fn_ListFilesAndValidateCount {
    #--------------------------------------------------------------
    # Function: fn_ListFilesAndValidateCount
    #--------------------------------------------------------------
    <#
    .SYNOPSIS
        Testing function for pester. Lists all files in a specified directory and validates the file count.
    
    .DESCRIPTION
        This function retrieves all files in a given directory and compares the count of files 
        against a user-specified expected count. If the counts do not match, a message is 
        displayed to the console and the function returns a message stating the actual count.
    
    .PARAMETER p_DirectoryPath
        The directory from which to list the files.
    
    .PARAMETER p_ExpectedFileCount
        The expected number of files in the directory for validation.
    
    .EXAMPLE
        fn_ListFilesAndValidateCount -p_DirectoryPath "C:\Temp" -p_ExpectedFileCount 10
    
    .NOTES
    # Returns
    # Output Directory does not exist.
    # File count mismatch.
    # File count created matches.
    #-----------------
    #Revision History:
    #-----------------
    #2025-02-20 | Added function to check count in directory
    #2024-06-01 | Author: TedmondFromRedmond
    
    #>
    #
    
        param (
            [string]$p_DirectoryPath,
            [int]$p_ExpectedFileCount
        )
    
        # Ensure the directory exists
        if (-not (Test-Path -Path $p_DirectoryPath)) {
            Write-Host "Error: Directory '$p_DirectoryPath' not found."
            return "Output Directory does not exist."
        }
    
        # Retrieve files in the directory
        $fn_IF_Files = Get-ChildItem -Path $p_DirectoryPath -File
        $fn_IF_FileCount = $fn_IF_Files.Count
    
        # Display file count to console
        Write-Host "Total files found in '$p_DirectoryPath': $fn_IF_FileCount"
    
        # Validate file count
        if ($fn_IF_FileCount -ne $p_ExpectedFileCount) {
            Write-Host "Warning: Expected $p_ExpectedFileCount files, but found $fn_IF_FileCount."
            write-host "File count mismatch: Expected $p_ExpectedFileCount, Found $fn_IF_FileCount."
            return "File count mismatch."
        }
    
        return "File count matches."
    } # fn_ListFilesAndValidateCount
    #--------------------------------------------------------------


    # Replace with path to dot source your function
. '..\fn_CreateSequentialFiles.ps1'



    
    
