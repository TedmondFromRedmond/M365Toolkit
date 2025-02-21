<#
###############################################################################
 Purpose:
 To execute tests using pester for the function
 Anykey and provide Test results in a csv file from variable $script:pstrcsvFile

 How to use:
 Phase I: Environment Setup
 0. Modify the variables under MAIN heading
        $MyTestDir = The directory this script resides in


 1. Install Pester module on server/workstation with: 
 2. Install-module Pester
 3. Execute Reader proc script to call this script

 Phase II:
 Use Passthru parameter to allow tracking of 1 or more tests. if script is called by another script, then set object = calling this script.
 Calling script syntax execution should be similar to $myTests = .\fn_Changline.Tests.ps1

 Since the imports Import-Module Pester -PassThru, there is no need to import the Pester module twice

 Phase III:
In the caller script Check[scriptName.tests.ps1] export the returned object of the pester script to csv

# Flow of script
# Test script name is designated a test script in vscode with .Tests in the name,
e.g. scriptname.Tests.ps1 
# First, import the Pester module.
# Second, check input file existence, if not then fail.
# Executes the tests


#>
###############################################################################

#----
. .\Functions.tests.ps1
#----

    ### End of Functions ###
###############################################################################
#######
# Main
#######
# Setup default date and time
$script:scr_DateandTimeStamp = fn_DateandTimeStamp # Date and time format 

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



#----
# Contains Describe, Context and It
# '..\Pester.Tests.ps1'
#----


#-----
Describe 'fn_AnyKey Tests' {
    BeforeAll {
        # Dot source the function into memory
        # . '..\AnyKey.ps1'
        # remove-item $env:temp\myout.txt -force|out-null
        if (Test-Path "$env:temp\myout.txt") { Remove-Item "$env:temp\myout.txt" }

    }

    AfterAll {
        remove-item $env:temp\myout.txt -force|out-null   
    
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
    # $myreturn=Send-KeysToWindow -hWnd $hWnd -Keys "..\AnyKey.ps1"

    $checkWindow = Send-KeysToWindow -hWnd $hWnd -Keys "sl '$mytestdir'{Enter}"
    # $checkWindow = Send-KeysToWindow -hWnd $hWnd -Keys "cd..{Enter}"
    $checkWindow = Send-KeysToWindow -hWnd $hWnd -Keys ". '..\Anykey.ps1'{Enter}"
    Send-KeysToWindow -hWnd $hWnd -Keys '$myRc = fn_AnyKey -Message ''The Right Stuff''{Enter}'
    Sleep 1
    Send-KeysToWindow -hWnd $hWnd -Keys '$myRc|Out-File $env:temp\myout.txt{Enter}'

    write-host

    Start-sleep -seconds 4

    # Exit powershell window
    Start-sleep -seconds 3;Send-KeysToWindow -hWnd $hWnd -Keys "Exit{ENTER}"

    #!@# pester should be
    # Should check for existence of file
    $mycheck = $null
    $mycheck = gc $env:temp\myout.txt

#    Get-Content "$env:temp\myout.txt" | Should -Not BeNullOrEmpty
    
    $mycheck.Length | Should -BeGreaterThan 0


} catch {
    Throw "output file not found or empty at $env:temp\myout.txt"

} # End of try catch in IT

} # end of IT
#----

} # End of Describe
#################################################



#########
# The END
#########



