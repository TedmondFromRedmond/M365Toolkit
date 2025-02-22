function fn_CreateSequentialFiles {
    <#
    #--------------------------------------------------------------
    # Function: fn_CreateSequentialFiles
    #--------------------------------------------------------------
    .SYNOPSIS
        Creates sequentially numbered text files in a specified directory.
    
    .DESCRIPTION
        This function generates a user-defined number of empty text files.
        The files will be named sequentially from File1.txt to FileX.txt.
        It ensures the specified directory exists before creating the files.
    
    .PARAMETER p_DirectoryPath
        The directory where the files will be created. If not specified, the files will be created in the current directory.
    
    .PARAMETER p_FileCount
        The number of files to create. Must be greater than zero.
    
    .EXAMPLE
        fn_CreateSequentialFiles -p_DirectoryPath "C:\MyFiles" -p_FileCount 50
    
    .NOTES
        Author: TedmondFromRedmond
    #>
    
    param (
            [string]$p_DirectoryPath = ".",
            [int]$p_FileCount
        )
    
        # Validate that p_FileCount is greater than zero
        if ($p_FileCount -le 0) {
            Write-Host "Error: The file count must be greater than zero."
            return "Invalid file count."
        }
    
        # Ensure the directory exists
        if (-not (Test-Path -Path $p_DirectoryPath)) {
            Write-Host "Directory not found. Creating directory: $p_DirectoryPath"
            New-Item -Path $p_DirectoryPath -ItemType Directory | Out-Null
        }
    
        # Create specified number of files
        1..$p_FileCount | ForEach-Object {
            $fn_IF_FileName = "File$_.txt"
            $fn_IF_FullPath = Join-Path $p_DirectoryPath $fn_IF_FileName
            New-Item -Path $fn_IF_FullPath -ItemType File -Force | Out-Null
            Write-Host "Created file: $fn_IF_FullPath"
        }
    
        Write-Host "Successfully created $p_FileCount files in '$p_DirectoryPath'."
        return "File creation completed."
    }
    #--------------------------------------------------------------
    
