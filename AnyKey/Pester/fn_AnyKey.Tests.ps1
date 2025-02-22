<#
###############################################################################
 Purpose:
 To execute tests using pester for the function
 Anykey and provide Test results in a csv file from variable $script:pstrcsvFile
 Note: This script returns a Pester object to the caller script.

 How to use:
 TIP OF THE CENTURY: VSCODE MUST BE EXECUTED IN ADMIN MODE FOR SCRIPT TO WORK.


 Revision History
---------------------------------------------------------------------------------------------
 Date      | Comments
---------------------------------------------------------------------------------------------
 20250222  | Script must be executed in admin mode to get all properties from system objects.
           | Added 2 test cases.
           | Created caller script.
           | Functions file is imported and must reside in same directory as this script.
 20230601  | Author: TedmondFromRedmond


#>
###############################################################################
param(
    [string]$p_MyTestDir  # Optional parameter for the directory path
)
#----
. .\fn_AnyKeyFunctions.tests.ps1
#----

### End of Functions ###
###############################################################################
#######
# Main
#######

# If the parameter is null or empty, set a default value
if ([string]::IsNullOrEmpty($p_MyTestDir)) {
$myTestDir = "C:\Users\TedmondFromRedmond\OneDrive - StartOS.com LLC\Documents\PowerShell\Projects\RefactorGithubtools\SourceFirstTransformationToStandards\AnyKey\Pester"
}

# Setup default date and time
$script:scr_DateandTimeStamp = fn_DateandTimeStamp # Date and time format 

# Import Pester Module
Import-Module Pester -PassThru

# Change into testing directory
Set-Location $myTestDir

start-sleep -seconds 2
# write-host 


#---------------------
# Pester overview
# Hierarchy: Describe -> Context -> 1 or many It(Test cases) 
# -> Have to use Try catch and throw writes the message to pester object
# Describe is the top level
# Context is a classification
# IT is the actual test case
# Beforeall executes can be in Describe, Context and IT. Can exist in IT for ea. test case.
# AFterall executes after all the tests. Can be in Describe, Context and IT. Can exist in IT for ea. test case.
# Note: 
# Variables are scoped at different levels in Pester. Be careful and test accordingly.
 

# Test Cases begin here
Describe 'Test Case 1 - fn_AnyKey Tests' {
    BeforeAll {
        # Dot source the function into memory
        # . '..\AnyKey.ps1'
        # remove-item $env:temp\myout.txt -force|out-null
        
        if (Test-Path "c:\temp\myout.txt") { Remove-Item "c:\temp\myout.txt" }

        # if c:\temp directory dne, then create it with your "Big Boy Pants on... I could remember the 4th of July....Hound Dog Barking..."
        If (Test-Path "c:\temp") { write-host Temp directory found...continuing}else{new-item c:\temp}

        # Close all CMD windows before continuing
        Get-Process | Where-Object { $_.ProcessName -match "cmd" } | Stop-Process -Force
    }

    AfterAll {
        # remove-item $env:temp\myout.txt -force|out-null   
        if (Test-Path "c:\temp\myout.txt") { Remove-Item "c:\temp\myout.txt" }
    
    }

    # Describe -> Context -> 1 or many It(Test cases) -> Have to use Try catch and throw writes the message to pester object


Context 'Test fn_AnyKey and return codes sent to file.' {

#-----
# Test Case 1
It 'Stop all command.exe or cmd.exe process and windows' {
Try {
    $myrc=$null
    $myrc=Get-Process | Where-Object { $_.ProcessName -match "cmd" } | Stop-Process -Force
    $myrc=$null
    $myrc=Get-Process | Where-Object { $_.ProcessName -match "cmd" }
    $myrc|should -be $null
} catch{
    Throw "Test Case 1 - Failed to close all command windows."
} # End of Try catch stop all command.exe or cmd.exe

}# End of IT Test Case 1
#--------------------
# Test Case 2
It 'Open command window - start powershell - start Anykey.ps1 - Press a key - store to file ' {
    # Check that the function returned our mock key press
    # $keyPressed | Should -Not -BeNullOrWhiteSpace
# Set the custom window title
Try{
$mytestcasereturn = $null
$windowTitle = "Anykey.Tests.ps1"
$proc=$null
# Start PowerShell window with custom title

#!@#
#$proc = Start-Process -FilePath "cmd.exe" `
#-ArgumentList "-NoExit", "-Command `"`$host.UI.RawUI.WindowTitle='$windowTitle'`"" `
#-PassThru
#!@#
$proc = Start-Process -FilePath "cmd.exe" `
    -ArgumentList "-NoExit", "-Command `"`$host.UI.RawUI.WindowTitle='$windowTitle'`"" `
    -PassThru

# Wait for the window to open
Start-Sleep -Seconds 7
# $proc.Id
# $proc.MainWindowHandle
# $proc.MainWindowTitle
Write-Host "DEBUG: Process ID: $($proc.Id)"
Write-Host "DEBUG: MainWindowHandle: $($proc.MainWindowHandle)"


# Get the window handle (hWnd) for the process
$mytestcasereturn = "Test Case 2 - Windows handle not found after Get-WindowHandleByProcessId"
$script:hWnd = $null

# $script:hWnd = Get-WindowHandleByProcessId -ProcessId $proc.Id
# $script:hWnd = Get-WindowHandleByProcessId -ProcessId $proc.MainWindowHandle

$script:hWnd = $proc.MainWindowHandle
$script:hWnd | Should -Not -Be 0
Start-Sleep -Seconds 3
#
$mytestcasereturn = "Test Case 2 - in cmd prompt - change to mytest variable"
# $checkWindow = Send-KeysToWindow -hWnd $script:hWnd -Keys "cd '$mytestdir'{Enter}"
$checkWindow = Send-KeysToWindow -hWnd $script:hWnd -Keys "cd `"$mytestdir`"{Enter}"
Start-sleep -seconds 3

$mytestcasereturn = "Test Case 2 - send keys failed on cd mytestdir"
$checkWindow = Send-KeysToWindow -hWnd $script:hWnd -Keys "powershell.exe{Enter}"
$checkwindow | Should -Not -Be "Failed"
start-sleep -Seconds 3

# $checkWindow = Send-KeysToWindow -hWnd $hWnd -Keys "cd..{Enter}"

# Start the function script, set the mytestcasereturn value for the throw in catch
# Uses Dot notation to insert the function being tested.
$mytestcasereturn = "Test Case 2 - Unable to send keys to $script:hwnd"
$checkWindow = Send-KeysToWindow -hWnd $script:hWnd -Keys ". '..\fn_Anykey.ps1'{Enter}"
$checkwindow | Should -Not -Be "Failed"
start-Sleep 2

# Store return from Anykey function into $myrc
$mytestcasereturn="Test Case 2 - Failed to send keys to window. Attempting to send the Right Stuff"
$checkWindow = Send-KeysToWindow -hWnd $script:hWnd -Keys '$myRc = fn_AnyKey -Message ''The Right Stuff''{Enter}'
$checkwindow | Should -Not -Be "Failed"
start-Sleep 2

# store $myrc object returned from anykey above into file
$mytestcasereturn="Test Case 2 - Failed to send keys to create out file c:\temp\myout.txt"
# Generate the outfile
$checkWindow = Send-KeysToWindow -hWnd $script:hWnd -Keys '$myRc|Out-File c:\temp\myout.txt{Enter}'
$checkwindow | Should -Not -Be "Failed"
Start-sleep -seconds 3

# Double Exit powershell window
# once for posh and a second for the cmd prompt
$mytestcasereturn="Test Case 2 - Failed to exit PowerShell window"
Start-sleep -seconds 3
$checkwindow=Send-KeysToWindow -hWnd $script:hWnd -Keys "Exit{ENTER}"
$checkwindow | Should -Not -Be "Failed"
Start-sleep -seconds 3

$mytestcasereturn="Test Case 2 - Failed to exit CMD window"
Start-sleep -seconds 3
$checkwindow=Send-KeysToWindow -hWnd $script:hWnd -Keys "Exit{ENTER}"
$checkwindow| Should -Not -Be "Failed"
Start-sleep -seconds 3

$mytestcasereturn="Test Case 2 - Failed to create file."
# Should check for existence of file
$mycheck = $null
# Ck for existence of output file
$mycheck=test-path "c:\temp\myout.txt"
$mycheck=test-path "c:\temp\myout.txt";$mycheck
start-sleep 1
$mycheck|Should -Be True
write-host 
} catch {
Throw $mytestcasereturn
} # End of Try Catch for Test Case 2

} # End of IT Test Case 2
#---

#----
} # End of Context 
#---


} # End of Describe
#---

#################################################

#########
# The END
#########



