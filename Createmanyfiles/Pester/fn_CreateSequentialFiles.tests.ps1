<#
# Purpose:
# Called by Checkfn_...tests.ps1 and executes 1 or many tests as defined in Pester.Tests.ps1

# Pester Scripts and hierarchy:
# Checkfn_CreateSequentialFiles.ps1.tests.ps1 -> fn_CreateSequentialFiles.ps1.tests.ps1; imports functions and pester.tests.ps1

# How To use:
# 1. In Main, modify varaiable $myTestDirectory to point to Test directory specified in step 2. 

#>


#######
# Functions begin here
#
# Import Functions
. '.\fn_CreateSequentialFilesFunctions.ps1'

#-----------------------------------------------------------------------------------------------------------
function fn_DateandTimeStamp {
    <#
    .SYNOPSIS
    Generates a date and time stamp in a concatenated format.
    
    .DESCRIPTION
    This function retrieves the current date and time, formatting it as "yyyyMMdd_HHmmss" for use in logs, filenames, or other timestamp needs.
    
    .Inputs
    A file with characters to replace.

    .Outputs
    Returns Date and time in object format.

    .EXAMPLE
    $My_DateAndTime = fn_DateandTimeStamp
    Write-Host "Date and time concatenation is $GBL_DateAndTime"
    # Output format example: 20250208_124532
    #>
    
        # Get the current date and time
        $fn_IF_CurrentDateTime = Get-Date -Format "yyyyMMdd_HHmmss"
         
        # Return the date and time stamp
        # Write-Host "Date and Time Stamp Generated: $fn_IF_CurrentDateTime"
        
        Return $fn_IF_CurrentDateTime
    } 
#----


# End of functions
#########
#########
# MAIN
#########
# Setup default date and time
$script:scr_DateandTimeStamp = fn_DateandTimeStamp # Date and time format 

# Import Pester Module
Import-Module Pester -PassThru
$Global:myTestDir = "C:\Temp\test\M365Toolkit\Createmanyfiles\Pester"

# Change into testing directory
Set-Location $Global:myTestDir

# Wait for the window to open
Start-Sleep -Seconds 2


#----
# Import Test Cases 
# Contains Describe, Context and It
. '.\fn_CreateSequentialFilesPester.Tests.ps1'
#----

return

