<#
# Maker: 20241203 - TFR
.SYNOPSIS
Captures details of all files in a directory and its subdirectories and exports the data to a CSV file.

.DESCRIPTION
This script recursively iterates through a specified directory and captures details such as file name, size, creation time, last access time, and last write time. The collected data is then exported to a CSV file.

.PARAMETER p_InputPath
The root directory to start the file search.

.PARAMETER p_OutputCSV
The full path of the CSV file where the results will be saved.

.EXAMPLE
.\fn_CaptureFilesToCSV.ps1 -p_InputPath "C:\Test" -p_OutputCSV "C:\Output\FileDetails.csv"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$p_InputPath,

    [Parameter(Mandatory = $true)]
    [string]$p_OutputCSV
)

# Ensure the input directory exists
if (-not (Test-Path -Path $p_InputPath)) {
    Write-Host "Error: The specified input directory does not exist." -ForegroundColor Red
    return
}

# Create an empty array to store file details
$fn_IF_FileDetails = @()

# Get all files in the directory and subdirectories
Get-ChildItem -Path $p_InputPath -Recurse -File | ForEach-Object {
    $fn_IF_FileDetails += [PSCustomObject]@{
        FileName       = $_.Name
        FilePath       = $_.FullName
        FileSize       = $_.Length
        CreationTime   = $_.CreationTime
        LastAccessTime = $_.LastAccessTime
        LastWriteTime  = $_.LastWriteTime
    }
}

# Export to CSV
try {
    $fn_IF_FileDetails | Export-Csv -Path $p_OutputCSV -NoTypeInformation -Encoding UTF8
    Write-Host "File details exported successfully to $p_OutputCSV." -ForegroundColor Green
} catch {
    Write-Host "Error exporting to CSV: $_" -ForegroundColor Red
}
