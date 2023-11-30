#-------------------------------------------------------------------------------------------------------------------------------------------
function fn_ChangeLine {
<#
.Synopsis

.Description
This function reads a specified CSV or TXT file line by line, searches for a specified string, 
and replaces it with another specified string. If a line is changed, it will display the change to the console. 
After processing all lines, it will provide a summary of the total number of changes or state that no changes were found. 
The entire file, including any changed lines, is then written to the specified output file.

Note: It is important to note that special characters are supported 

Usage:
fn_ChangeLine -p_InputFile "path_to_inputfile.csv" -p_b4Change "old_value" -p_AfterChange "new_value" -p_OutputFile "path_to_outputfile.csv"
fn_ChangeLine -p_InputFile "path_to_inputfile.txt" -p_b4Change "old_value" -p_AfterChange "new_value" -p_OutputFile "path_to_outputfile.txt"
fn_ChangeLine -p_InputFile "path_to_inputfile.ini" -p_b4Change "old_value" -p_AfterChange "new_value" -p_OutputFile "path_to_outputfile.ini"
fn_ChangeLine -p_InputFile "path_to_inputfile.ini" -p_b4Change "`myspecialchar" -p_AfterChange "`" -p_OutputFile "path_to_outputfile.ini"

--------------------------------------------
Modification History:
Date    | Initials-Description of change
--------------------------------------------
20231023| Maker - TFR


#>

    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if (-not ($_ | Test-Path)) {
                throw "File $_ does not exist."
            } # end of if not test-path to see if input file exists.

            return $true
        })]
        [string]$p_InputFile,

        [Parameter(Mandatory=$true)]
        [string]$p_b4Change,

        [Parameter(Mandatory=$true)]
        [string]$p_AfterChange,

        [Parameter(Mandatory=$true)]
        [string]$p_OutputFile
    )

    $changeCount = 0
    $output = @()

    # Read the content of the file
    $content = Get-Content -Path $p_InputFile

    foreach ($line in $content) {
        if ($line -like "*$p_b4Change*") {
            $changedLine = $line -replace [regex]::Escape($p_b4Change), $p_AfterChange
            $output += $changedLine
            Write-Output "Changed: $line -> $changedLine"
            $changeCount++
        } else {
            $output += $line
        } # end of if line like ...
    } # end of foreach line in content

    # Write the output to the specified file
    $output | Set-Content -Path $p_OutputFile

    if ($changeCount -gt 0) {
        Write-Output "Total lines changed: $changeCount"
    } else {
        Write-Output "There were not any lines to change found. Zero lines were changed."
    } # end of changecount gt 0

} # End of fn_ChangeLine
#-------------------------------------------------------------------------------------------------------------------------------------------



