#--------------------------------------------------------------------------------
function fn_ListFilesAndFolders {
<#
# Maker: 20241203 - TFR
.Synopsis
Lists all files and folders with their respective sizes and outputs the data to a CSV file.

.Description
This function recursively scans a specified directory and captures details of all files and folders, 
including their names, types, sizes, and creation dates. Directory sizes are calculated as the 
cumulative size of all files within them. The output is saved to a specified CSV file.

Usage:
fn_ListFilesAndFolders -fn_IF_DirectoryPath "C:\TargetFolder" -fn_IF_OutputFile "C:\Output\Report.csv"

.Example
fn_ListFilesAndFolders -fn_IF_DirectoryPath "C:\Users" -fn_IF_OutputFile "C:\Reports\DirectorySizes.csv"
#>

    param (
        [Parameter(Mandatory=$true)]
        [string]$fn_IF_DirectoryPath,

        [Parameter(Mandatory=$true)]
        [string]$fn_IF_OutputFile
    )

    # Validate that the directory exists
    if (-not (Test-Path $fn_IF_DirectoryPath)) {
        Write-Host "Error: The specified directory path '$fn_IF_DirectoryPath' does not exist."
        return
    }

    # Initialize an array to hold results
    $results = @()

    # Define a helper function to calculate directory size
    function Get-DirectorySize {
        param (
            [string]$DirPath
        )
        $size = Get-ChildItem -Path $DirPath -Recurse -File | Measure-Object -Property Length -Sum
        return $size.Sum
    }

    # Recursively process the directory
    Get-ChildItem -Path $fn_IF_DirectoryPath -Recurse | ForEach-Object {
        if ($_.PSIsContainer) {
            # If it's a folder, calculate its size
            $dirSize = Get-DirectorySize -DirPath $_.FullName
            $results += [PSCustomObject]@{
                Name          = $_.Name
                Path          = $_.FullName
                Type          = "Folder"
                SizeInBytes   = $dirSize
                CreationDate  = $_.CreationTime
            }
        } else {
            # If it's a file, record its size
            $results += [PSCustomObject]@{
                Name          = $_.Name
                Path          = $_.FullName
                Type          = "File"
                SizeInBytes   = $_.Length
                CreationDate  = $_.CreationTime
            }
        }
    }

    # Export results to CSV
    try {
        $results | Export-Csv -Path $fn_IF_OutputFile -NoTypeInformation -Force
        Write-Host "Success: Data has been written to '$fn_IF_OutputFile'"
    } catch {
        Write-Host "Error: Failed to write to the file. $_"
    }
} # End of fn_ListFilesAndFolders
#--------------------------------------------------------------------------------
############################################################
# MAIN
############################################################

fn_ListFilesAndFolders -fn_IF_DirectoryPath ".\" -fn_IF_OutputFile ".\DirectorySizes.csv"
