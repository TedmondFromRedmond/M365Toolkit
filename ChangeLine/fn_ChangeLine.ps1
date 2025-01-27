function fn_ChangeLine {
    <#
    .SYNOPSIS
        Changes specific values in a file, useful for pipelines with dev and prod configurations.
    
    .DESCRIPTION
        Reads a specified CSV, TXT, or INI file line by line, searches for a given string, and replaces it with another string.
        Supports case sensitivity based on an optional parameter.
        Displays changes made to the console and writes the updated content to a specified output file.
        Provides a summary of the total changes or indicates no changes were found.
    
    .PARAMETER p_InputFile
        Path to the input file to be processed.
    
    .PARAMETER p_b4Change
        String to search for in the input file.
    
    .PARAMETER p_AfterChange
        String to replace the search string with.
    
    .PARAMETER p_OutputFile
        Path to the output file where updated content will be written.
    
    .PARAMETER p_CaseSensitive
        Optional. Indicates whether the replacement should be case-sensitive. Default is `$false` (case-insensitive).
    
    .EXAMPLE
        fn_ChangeLine -p_InputFile "path_to_inputfile.csv" -p_b4Change "Dev" -p_AfterChange "Prod" -p_OutputFile "path_to_outputfile.csv" -p_CaseSensitive $true
        This replaces "Dev" with "Prod" in a case-sensitive manner.
    
    .EXAMPLE
        fn_ChangeLine -p_InputFile "path_to_inputfile.csv" -p_b4Change "dev" -p_AfterChange "prod" -p_OutputFile "path_to_outputfile.csv"
        This replaces "dev" with "prod" in a case-insensitive manner.
 
    .EXAMPLE
        fn_ChangeLine -p_InputFile '.\SampleInputwithspecialchars.txt' -p_b4Change 'sunny' -p_AfterChange "SUNNY" -p_OutputFile ".\SampleOutputWithSpecialCharacters.txt"
        finds the lowercase sunny and replaces it with capitlized SUNNY

    .EXAMPLE
        fn_ChangeLine -p_InputFile '.\SampleInputwithspecialchars.txt' -p_b4Change '`' -p_AfterChange "~" -p_OutputFile ".\SampleOutputWithSpecialCharacters.txt"
        fn_ChangeLine -p_InputFile '.\SampleInputwithspecialchars.txt' -p_b4Change 'It`s' -p_AfterChange "~MRSunnydays" -p_OutputFile ".\SampleOutputWithSpecialCharacters.txt"
        finds Backtick and replaces

    .EXAMPLE
        fn_ChangeLine -p_InputFile '.\SampleInputwithspecialchars.txt' -p_b4Change '\' -p_AfterChange 'ALLATHITS AND THAT' -p_OutputFile ".\SampleOutputWithSpecialCharacters.txt"
        fn_ChangeLine -p_InputFile '.\SampleInputwithspecialchars.txt' -p_b4Change '\t' -p_AfterChange 'ALLATHITS AND THAT' -p_OutputFile ".\SampleOutputWithSpecialCharacters.txt"
        fn_ChangeLine -p_InputFile '.\SampleInputwithspecialchars.txt' -p_b4Change 'n\tun' -p_AfterChange 'ALMOST SUPERBOWL TIME!!' -p_OutputFile ".\SampleOutputWithSpecialCharacters.txt"
        finds \ and other escape characters and replaces

    .EXAMPLE
        fn_ChangeLine -p_InputFile '.\SampleInputwithspecialchars.txt' -p_b4Change '~n' -p_AfterChange '42' ".\SampleOutputWithSpecialCharacters.txt"
        fn_ChangeLine -p_InputFile '.\SampleInputwithspecialchars.txt' -p_b4Change '~n ' -p_AfterChange "42 " ".\SampleOutputWithSpecialCharacters.txt"
        Replace a ~n with a trailing space. Notice the space in the before and after parameters.


.NOTES
    Maker: TFR
    Refactored: Professor POSH

    Modification History:
    Date       | Initials  | Description
    -----------|-----------|-------------------------------------
    20231023   | TFR       | Initial creation
    20231112   | POSH      | Refactored to align with standards
    20250126   | TFR       | Added case sensitivity and special chars `, \, ~    
    #>
    
        param (
            [Parameter(Mandatory = $true)]
            [ValidateScript({
                if (-not (Test-Path $_)) {
                    throw "File $_ does not exist."
                }
                return $true
            })]
            [string]$p_InputFile,
    
            [Parameter(Mandatory = $true)]
            [string]$p_b4Change,
    
            [Parameter(Mandatory = $true)]
            [string]$p_AfterChange,
    
            [Parameter(Mandatory = $true)]
            [string]$p_OutputFile,
    
            [Parameter(Mandatory = $false)]
            [bool]$p_CaseSensitive = $false
        )
    
        # Initialize counters and output array
        $changeCount = 0
        $lineNumber = 1
        $outputContent = @()
    
        try {
            # Read the content of the input file
            $content = Get-Content -Path $p_InputFile
    
            # Process each line
            foreach ($line in $content) {
                # Check case sensitivity
                if ($p_CaseSensitive) {
                    # Case-sensitive replacement
                    if ($line.Contains($p_b4Change)) {
                        $changedLine = $line -replace "$p_b4Change", $p_AfterChange
                        $outputContent += $changedLine
                        Write-Output "Line $lineNumber Changed '$line' -> '$changedLine'" -ForegroundColor Yellow
                        $changeCount++
                    } else {
                        $outputContent += $line
                    }
                } else {
                    # Case-insensitive replacement using (?i)
                    $regex_b4Change = "(?i)" + [regex]::Escape($p_b4Change)
                    if ($line -match $regex_b4Change) {
                        $changedLine = $line -replace $regex_b4Change, $p_AfterChange
                        $outputContent += $changedLine
                        Write-Output "Line $lineNumber Changed '$line' -> '$changedLine'" -ForegroundColor Yellow
                        $changeCount++
                    } else {
                        $outputContent += $line
                    }
                }
                $lineNumber++
            }
    
            # Write the updated content to the output file
            $outputContent | Set-Content -Path $p_OutputFile
    
            # Display summary of changes
            if ($changeCount -gt 0) {
                Write-Host "Total lines changed: $changeCount" -ForegroundColor Green
            } else {
                Write-Host "No lines were changed." -ForegroundColor Cyan
            }
        }
        catch {
            Write-Error "Error processing the file: $_"
        }
    }
    #---- End of fn_ChangeLine ----
    



