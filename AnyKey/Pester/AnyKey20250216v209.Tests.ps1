write-host "t1.ps1"

<#
###############################################################################
 Purpose:
 To execute tests using pester for the function
 Anykey and provide Test results in a csv file from variable $script:pstrcsvFile

 How to use:
 Phase I: Environment Setup
 0. Modify the variables under MAIN heading
        $MyTestDir = The directory this script resides in
        $script:scr_DateandTimeStamp = fn_DateandTimeStamp # Date and time format 
        $script:pstrcsvFile = ".\fn_ChangeLine_pstrTestResults.csv" # Log file for script
        $script:pstrTestInputFile = ".\TestInput.txt" # Source input file is not overwritten
        $script:pstrTestOutputFile = ".\TestOutput.txt" # Changed source file output
        $script:pstrTestResults = @() # Array to hold custom objects for output to csv file aka $script:pstrcsvFile

 1. Install Pester module on server/workstation with: 
 2. Install-module Pester
 3. Execute Reader proc script to call this script

 Phase II:
 Use Passthru parameter to allow tracking of 1 or more tests. if script is called by another script, then set object = calling this script.
 Calling script syntax execution should be similar to $myTests = .\fn_Changline.Tests.ps1

 Since the imports Import-Module Pester -PassThru, there is no need to import the Pester module twice

 Phase III:
 Use a separate script to call this script as shown below
 Pester invocation to call a script and store in variable
 $myPesterOutcome = Invoke-Pester -Path .\fn_ChangeLine.Tests.ps1 -passthru

# Flow of script
# Test script name is designated a test script in vscode with .Tests in the name,
e.g. scriptname.Tests.ps1 
# First, import the Pester module.
# Second, check input file existence, if not then fail.
# Executes the tests

# Monitor Test results in csv file named
- Review file specified in variable $script:pstrcsvFile

###############################################################################
#>
#----
# Functions begin here


# Function to check if a window handle (hWnd) is still valid
function Windo-Exsts {
    # Windows handle can be enumerated with user32.dll
    # See templates.

    param ([int]$hWnd)

    # Ensure we don't redefine the type
    if (-not ([System.Management.Automation.PSTypeName]'User32_IsWindow').Type) {
        Add-Type @"
        using System;
        using System.Runtime.InteropServices;

        public class User32_IsWindow {
            [DllImport("user32.dll")]
            public static extern bool IsWindow(IntPtr hWnd);
        }
"@
    }

    # Return False if window is not available and True if window does exist
        return [User32_IsWindow]::IsWindow([IntPtr]$hWnd)
} #end of Windo-Exsts
#---

#---
# Function to send keys to a specified window handle (hWnd)
function Send-KeysToWindow {
    param (
        [int]$hWnd,
        [string]$Keys
    )

    # Validate if the window still exists before sending keys
    if (-not (Windo-Exsts -hWnd $hWnd)) {
        Write-Host "Window handle $hWnd no longer exists. The window may have been closed."
        return -1
    }

    # Activate the specified window and send keystrokes
    Add-Type -AssemblyName System.Windows.Forms
    $wshell = New-Object -ComObject WScript.Shell

    # Ensure we don't redefine the type
    if (-not ([System.Management.Automation.PSTypeName]'ActivateWindow').Type) {
        Add-Type @"
        using System;
        using System.Runtime.InteropServices;

        public class ActivateWindow {
            [DllImport("user32.dll")]
            public static extern bool SetForegroundWindow(IntPtr hWnd);
        }
"@
    }

    $success = [ActivateWindow]::SetForegroundWindow([IntPtr]$hWnd)
    if ($success) {
        Start-Sleep -Milliseconds 500  # Small delay before sending keys
        $wshell.SendKeys($Keys)
        Write-Host "Sent keys: '$Keys' to window handle: $hWnd"
    } else {
        Write-Host "Failed to bring window with handle $hWnd to the foreground."
    }
} # End of Send-KeysToWindow
#-----

#-----------------------------------------------------------------------------------------------------------
function fn_DateandTimeStamp {
    <#
    .SYNOPSIS
    Generates a date and time stamp in a concatenated format.
    
    .DESCRIPTION
    This function retrieves the current date and time, formatting it as "yyyyMMdd_HHmmss" for use in logs, filenames, or other timestamp needs.
    
    .Inputs
    A file with characters to replace.
    # $script:pstrTestInputFile = ".\TestInput.txt" # Source input file for changeline fn.

    .Outputs
    # $script:pstrcsvFile = ".\fn_ChangeLine_pstrTestResults.csv" # CSV Log file for script
    # $script:pstrTestOutputFile = ".\TestOutput.txt" # Output file for changeline fn.
    # $script:pstrTestResults = @() # Array to hold custom objects for output to CSV log file for script

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

#----
# .\Functions.tests.ps1
#----

    ### End of Functions ###
###############################################################################
#######
# Main
#######
# Import Pester Module
Import-Module Pester -PassThru
$myTestDir = "C:\Users\TedmondFromRedmond\OneDrive - StartOS.com LLC\Documents\PowerShell\Projects\RefactorGithubtools\SourceFirstTransformationToStandards\AnyKey\Pester"

# Change into testing directory
Set-Location $myTestDir


<#!@#
# Set the custom window title
$windowTitle = "Anykey.Tests.ps1"

$proc=$null
# Start PowerShell window with custom title
$proc = Start-Process -FilePath "powershell.exe" `
    -ArgumentList "-NoExit", "-Command `"`$host.UI.RawUI.WindowTitle='$windowTitle'`"" `
    -PassThru

# Wait for the window to open
Start-Sleep -Seconds 2

# Get the window handle (hWnd) for the process
$hWnd = $null
$hWnd = Get-WindowHandleByProcessId -ProcessId $proc.Id

if ($hWnd -ne 0) {
    Start-Sleep -Seconds 2

    Write-Host "Found window handle: $hWnd"
    
    $myReturn = $null
    Start-sleep -seconds 2
    $myreturn=Send-KeysToWindow -hWnd $hWnd -Keys "..\AnyKey.ps1"
    Start-sleep -seconds 2

    #!@# pester should be
    if($myReturn -eq '-1'){
        write-host 'Fatal Error. Unable to find Window. Ending program'
        Exit
    }
    #!@#


    $checkWindow = Send-KeysToWindow -hWnd $hWnd -Keys "{Enter}";Start-sleep -seconds 3;Send-KeysToWindow -hWnd $hWnd -Keys "Exit";start-sleep -seconds 2;Send-KeysToWindow -hWnd $hWnd -Keys "{ENTER}"
    write-host
    $checkWindow
    write-host

} else {
    Write-Host "Failed to retrieve window handle for process ID: $($proc.Id)"

} 

start-sleep -seconds 2
# write-host 


# Note: if a window closes, the hwnd is still reserved.
# if the program attempts to send a key to a closed hwnd window, the following error appears
# Failed to bring window with handle 12191640 to the foreground

# Solution: 
# Check to see if window exists with a second user32name otherwise error is duplicate for user32

# Example Usage: Ensure window is still open before sending keys
if ($hWnd -and (Windo-Exsts -hWnd $hWnd)) {
    Send-KeysToWindow -hWnd $hWnd -Keys "Window exists $hwnd {ENTER}"
} else {
    Write-Host "The PowerShell window has been closed. Cannot send keys."
}

#> # End of comments with sendkeys


#---------------------
# Pester overview
# Describe is the top level
# It is the actual test case
# Beforeall executes before the It tests
# AFterall executes after all the tests
# Note: 
# Variables are scoped at different levels in Pester. Be careful and test accordingly.
# Test Cases Start Here with Describe

# Describe "AnyKey Automated Tests" {
# 
# ----------------
write-host "...Entering Mytest function"

 
Import-Module Pester -PassThru

# To Do:
# Finish the sendkeys to test the anykey window
# place tests into pesterTests.ps1 file
# Place functions into functions file
# Enable functions to return objects
# e.g. fn_AnyKey, Windoexist and other functions in the script
# Insert Data Report with export to csv in Afterall y enumerating testresults returned to reader proc
# # Test beforeall and afterall inside of context in pester tests
# Revise documentation
# - consider word doc for Pester documentation and standards 
# -> include the functions file and pestertests file
# -> finclude objects returned from functions
# Create templates for Pester Framework


#----
# Contains Describe, Context and It
# '..\Pester.Tests.ps1'
#----


#-----
Describe 'fn_AnyKey Tests' {
    BeforeAll {
        # Dot source the function into memory
        # . '..\AnyKey.ps1'
    }

    AfterAll {
       

    }

    # Describe -> Context -> 1 or many It(Test cases) -> Have to use Try catch and throw writes the message to pester object
# Context 'SendKeys to window' {

#-----
# Test Case 1
It 'Prompts the user and returns the key pressed' {
    # Check that the function returned our mock key press
#        $keyPressed | Should -Not -BeNullOrWhiteSpace
# Set the custom window title
Try{
$windowTitle = "Anykey.Tests.ps1"
$proc=$null
# Start PowerShell window with custom title
$proc = Start-Process -FilePath "powershell.exe" `
-ArgumentList "-NoExit", "-Command `"`$host.UI.RawUI.WindowTitle='$windowTitle'`"" `
-PassThru

# Wait for the window to open
Start-Sleep -Seconds 2

# Get the window handle (hWnd) for the process
$hWnd = $null
$hWnd = Get-WindowHandleByProcessId -ProcessId $proc.Id
Start-Sleep -Seconds 2

Write-Host "Found window handle: $hWnd"


Start-sleep -seconds 2
# $myReturn = $null
#    $myreturn=Send-KeysToWindow -hWnd $hWnd -Keys "..\AnyKey.ps1"

$checkWindow = Send-KeysToWindow -hWnd $hWnd -Keys "sl '$mytestdir'{Enter}"
$checkWindow = Send-KeysToWindow -hWnd $hWnd -Keys "cd..{Enter}"
$checkWindow = Send-KeysToWindow -hWnd $hWnd -Keys ". .\Anykey.ps1{Enter}"
Send-KeysToWindow -hWnd $hWnd -Keys '$myRc = fn_AnyKey -Message ''Go Horns!''{Enter}'
Sleep 1
# $checkWindow = Send-KeysToWindow -hWnd $hWnd -Keys '$myRc|out-file .\pester\myout.txt{Enter}'
# $checkWindow = Send-KeysToWindow -hWnd $hWnd -Keys '$myRc|Out-File $env:\temp\myout.txt{Enter}'
$checkWindow = Send-KeysToWindow -hWnd $hWnd -Keys '$myRc|Out-File $env:temp\myout.txt{Enter}'

#fn_AnyKey -Message "Go Horns!"

write-host

# Create posh script to execute fn

# Create posh file
$myout=@'
sl $mytestdir
$myLocation = get-location
$myscript=$myLocation.ToString()

$myScript = ". '$myscript + "\" + "AnyKey.ps1'"
$myscript

#. '..\Anykey.ps1'
. '$myscript'

fn_Anykey -message "The Right Stuff"
'@ | Out-File .\mytestofAnyKey.ps1 -force

# End of myout

# $checkWindow = Send-KeysToWindow -hWnd $hWnd -Keys "$myout"
$checkWindow = Send-KeysToWindow -hWnd $hWnd -Keys $myout
# $myresult = fn_Anykey -message "The Right Stuff"

Start-sleep -seconds 2
Send-KeysToWindow -hWnd $hWnd -Keys "$myScript"
Send-KeysToWindow -hWnd $hWnd -Keys $myScript

Send-KeysToWindow -hWnd $hWnd -Keys "{Enter}"

Start-sleep -seconds 3;Send-KeysToWindow -hWnd $hWnd -Keys "Exit";start-sleep -seconds 2;Send-KeysToWindow -hWnd $hWnd -Keys "{ENTER}"

# $myTestDir
#!@# pester should be

# $checkWindow = Send-KeysToWindow -hWnd $hWnd -Keys "cd.."

} catch {



} # End of try catch in IT

} # end of IT
#----

} # End of Describe
#################################################
<#
Describe 'fn_AnyKey Tests' {

    # Dot-source the script so the function is available in this session
    BeforeAll {
        . '..\AnyKey.ps1'
    } # End of Beforeall

    # Script block executed after all test cases
    AfterAll {
        # Clean up the output file after tests
        Write-Host "Entering After All... Log file is located at: $script:pstrcsvFile"

        <#
        # Export the table with objects created during processing
        $script:pstrTestResults | Export-Csv -Path $script:pstrcsvFile -Append -NoTypeInformation        
        
        Write-Output ""
        Write-Output "Test results saved to: $script:pstrcsvFile"
        Write-host ""
        # Get-Content $script:pstrcsvFile
        # notepad.exe $script:pstrcsvFile
        # notepad.exe $script:pstrTestOutputFile
        

    } # End of afterall

#>
#----



