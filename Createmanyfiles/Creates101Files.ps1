##################################################################
# Description
# Creates 101 files 
#
# -------------------
# Revision History
# -------------------
# 20231116 - Maker: TFR
##################################################################

function fn_CreateSequentialFiles {
    <#
    .Synopsis
    Creates 101 files with sequential numbers in the filename.

    .Description
    This function generates 101 empty text files. The files will be named sequentially from File1.txt to File101.txt.

    .Example
    fn_CreateSequentialFiles -p_DirectoryPath "C:\path\to\folder"

    .Parameter p_DirectoryPath
    The directory where the files will be created. If not specified, the files will be created in the current directory.

    .Notes
    Author: Professor POSH
    #>

    param (
        [string]$p_DirectoryPath = "."
    )

    # Ensure the directory exists
    if (-not (Test-Path -Path $p_DirectoryPath)) {
        Write-Host "Directory not found. Creating directory: $p_DirectoryPath"
        New-Item -Path $p_DirectoryPath -ItemType Directory
    }

    # Create 101 files with sequential numbers
    1..101 | ForEach-Object {
        $fileName = "File$_.txt"
        $fullPath = Join-Path $p_DirectoryPath $fileName
        New-Item -Path $fullPath -ItemType File -Force | Out-Null
        Write-Host "Created file: $fullPath"
    }

    Write-Host "All files created successfully."
}

# Example usage
# fn_CreateSequentialFiles -p_DirectoryPath "C:\MyFiles"
