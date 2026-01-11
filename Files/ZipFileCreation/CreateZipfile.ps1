#---------------------------------------------------------------------------
# Function: fn_CreateZipSimpleCounter
#
# .SYNOPSIS
# Adds files to a zip archive, displaying only an incrementing counter.
#
# .DESCRIPTION
# Uses .NET compression to add one file at a time to a new ZIP archive. If the target
# ZIP file already exists, it will be deleted before the archive creation starts.
#
# .EXAMPLE
# fn_CreateZipSimpleCounter -p_SourceDir "C:\Input" -p_DestDir "C:\Zips" -p_ZipFileName "MyFiles.zip"
#
# .REVISION HISTORY
# ----------------------------------------------------------------------------------------------------
# Date        | Initials | Description
# ------------|----------|---------------------------------------------------------------------------
# 20260110    | POSH     | Initial creation of function to zip files with simple counter output
# 20260110    | POSH     | Added logic to delete existing ZIP file before continuing
# ----------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------

function fn_CreateZipSimpleCounter {
    param (
        [Parameter(Mandatory = $true)]
        [string]$p_SourceDir,

        [Parameter(Mandatory = $true)]
        [string]$p_DestDir,

        [Parameter(Mandatory = $true)]
        [string]$p_ZipFileName
    )

    # Validate input directories
    if (-not (Test-Path $p_SourceDir)) {
        Write-Host "`nError: Source directory does not exist."
        return
    }

    if (-not (Test-Path $p_DestDir)) {
        Write-Host "`nError: Destination directory does not exist."
        return
    }

    # Ensure ZIP extension
    if ($p_ZipFileName -notmatch "\.zip$") {
        $p_ZipFileName += ".zip"
    }

    $fn_IF_ZipPath = Join-Path -Path $p_DestDir -ChildPath $p_ZipFileName

    # Check if ZIP file already exists and delete it
    if (Test-Path $fn_IF_ZipPath) {
        Write-Host "`nNote: ZIP file $fn_IF_ZipPath already exists. Deleting before proceeding..."
        Remove-Item -Path $fn_IF_ZipPath -Force
    }

    # Load .NET compression assembly
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    # Open file stream and archive for writing
    $fn_IF_Stream = [System.IO.File]::Open($fn_IF_ZipPath, [System.IO.FileMode]::CreateNew)
    $fn_IF_Archive = New-Object System.IO.Compression.ZipArchive(
        $fn_IF_Stream,
        [System.IO.Compression.ZipArchiveMode]::Update
    )

    $fn_IF_FileList = Get-ChildItem -Path $p_SourceDir -File -Recurse
    $fn_IF_Counter = 0

    foreach ($fn_IF_File in $fn_IF_FileList) {
        $fn_IF_Counter++

        $fn_IF_Relative = $fn_IF_File.FullName.Substring($p_SourceDir.Length).TrimStart('\')

        $fn_IF_Entry = $fn_IF_Archive.CreateEntry($fn_IF_Relative)
        $fn_IF_FileStream = $fn_IF_Entry.Open()
        $fn_IF_SourceStream = [System.IO.File]::OpenRead($fn_IF_File.FullName)
        $fn_IF_SourceStream.CopyTo($fn_IF_FileStream)
        $fn_IF_SourceStream.Dispose()
        $fn_IF_FileStream.Dispose()

        Write-Host $fn_IF_Counter
    }

    $fn_IF_Archive.Dispose()
    $fn_IF_Stream.Dispose()

    Write-Host "`nCompression complete. Total files added: $fn_IF_Counter"
}
#-----------------------------------------------------------

fn_CreateZipSimpleCounter

