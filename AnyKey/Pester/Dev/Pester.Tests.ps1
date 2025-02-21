#
# How to use this file:
# Insert the tests for each test scenario.
# Per the framework, this file is imported into your .Tests.ps1 script
# 

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


Context 'Test fn_AnyKey and return codes sent to file.' {

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
} # End of Context 


} # End of Describe