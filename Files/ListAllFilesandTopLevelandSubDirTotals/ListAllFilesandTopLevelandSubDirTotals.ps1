#--------------------------------------------------------------------------------
function fn_SummarizeFoldersAndSizes {
    <#
    .Synopsis
    Summarizes the total sizes of top-level folders and their subfolders and outputs to a CSV file.
    
    .Description
    This function calculates the total size of each folder (including its subfolders) in the specified directory. The results include the size of each folder and all its subdirectories.
    
    Usage:
    fn_SummarizeFoldersAndSizes -fn_IF_DirectoryPath "C:\TargetFolder" -fn_IF_OutputFile "C:\Output\FolderSummary.csv"
    
    .Example
    fn_SummarizeFoldersAndSizes -fn_IF_DirectoryPath "C:\Data" -fn_IF_OutputFile "C:\Reports\FolderSummary.csv"
    #>
    
        param (
            [Parameter(Mandatory=$true)]
            [string]$fn_IF_DirectoryPath,
    
            [Parameter(Mandatory=$true)]
            [string]$fn_IF_OutputFile
        )
    
        # Validate the input directory path
        if (-not (Test-Path $fn_IF_DirectoryPath)) {
            Write-Host "Error: The specified directory '$fn_IF_DirectoryPath' does not exist."
            return
        }
    
        # Initialize an array to hold the results
        $results = @()
    
        # Helper function to calculate the size of a directory recursively
        function Get-DirectorySize {
            param (
                [string]$DirPath
            )
            $size = Get-ChildItem -Path $DirPath -Recurse -File | Measure-Object -Property Length -Sum
            return $size.Sum
        }
    
        # Process top-level folders and their subfolders
        Get-ChildItem -Path $fn_IF_DirectoryPath -Directory | ForEach-Object {
            try {
                # Calculate the size of the top-level folder
                $folderSize = Get-DirectorySize -DirPath $_.FullName
    
                # Add the top-level folder to the results
                $results += [PSCustomObject]@{
                    FolderName    = $_.Name
                    FullPath      = $_.FullName
                    TotalSize     = $folderSize
                    ParentFolder  = "Top-Level"
                    CreationDate  = $_.CreationTime
                }
    
                # Process subfolders
                Get-ChildItem -Path $_.FullName -Directory | ForEach-Object {
                    $subFolderSize = Get-DirectorySize -DirPath $_.FullName
                    $results += [PSCustomObject]@{
                        FolderName    = $_.Name
                        FullPath      = $_.FullName
                        TotalSize     = $subFolderSize
                        ParentFolder  = $_.PSParentPath -replace ".*\\", ""
                        CreationDate  = $_.CreationTime
                    }
                }
            } catch {
                Write-Host "Error: Failed to process folder '$_'. $_"
            }
        }
    
        # Export the results to CSV
        try {
            $results | Export-Csv -Path $fn_IF_OutputFile -NoTypeInformation -Force
            Write-Host "Success: Folder summary has been exported to '$fn_IF_OutputFile'."
        } catch {
            Write-Host "Error: Failed to write to CSV file. $_"
        }
    } # End of fn_SummarizeFoldersAndSizes
    #--------------------------------------------------------------------------------
    
#######################################
# MAIN
#######################################

fn_SummarizeFoldersAndSizes -fn_IF_DirectoryPath ".\" -fn_IF_OutputFile ".\FolderSummary.csv"

