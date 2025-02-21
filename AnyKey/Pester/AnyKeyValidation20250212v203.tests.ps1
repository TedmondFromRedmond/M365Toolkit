#----
# Function to check if a window handle (hWnd) is still valid
function Windo-Exsts {
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
        Write-Host "❌ Window handle $hWnd no longer exists. The window may have been closed."
        return
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
        Write-Host "✅ Sent keys: '$Keys' to window handle: $hWnd"
    } else {
        Write-Host "❌ Failed to bring window with handle $hWnd to the foreground."
    }
} # End of Send-KeysToWindow

#-----

# Functions end here
####################################################################################################

#####
# MAIN
#####

# Set the custom window title
$windowTitle = "My Custom Stuff"

# Start PowerShell with the custom title
$proc = Start-Process -FilePath "powershell.exe" `
    -ArgumentList "-NoExit", "-Command `"`$host.UI.RawUI.WindowTitle='$windowTitle'`"" `
    -PassThru

# Wait for the window to open
Start-Sleep -Seconds 2

# Get the window handle (hWnd) for the process
$hWnd = Get-WindowHandleByProcessId -ProcessId $proc.Id

if ($hWnd -ne 0) {
    Write-Host "Found window handle: $hWnd"
    # Send keystrokes to the window
    $myTestDir = "C:\Users\TedmondFromRedmond\OneDrive - StartOS.com LLC\Documents\PowerShell\Projects\RefactorGithubtools\SourceFirstTransformationToStandards\AnyKey"
    
    # Change into testing directory
    Set-Location $myTestDir

    Start-sleep -seconds 2
    Send-KeysToWindow -hWnd $hWnd -Keys ".\AnyKey.ps1"
    Start-sleep -seconds 2

    Send-KeysToWindow -hWnd $hWnd -Keys "{Enter}"
    Start-sleep -seconds 3
    Send-KeysToWindow -hWnd $hWnd -Keys "Exit"

    start-sleep -seconds 2
    Send-KeysToWindow -hWnd $hWnd -Keys "{ENTER}"

} else {
    Write-Host "Failed to retrieve window handle for process ID: $($proc.Id)"
}

Write-Host

start-sleep -seconds 2
write-host 
# $hWnd
# Note: if a window closes, the hwnd is still reserved.
# if the program attempts to send a key to a closed hwnd window, the following error appears
# Failed to bring window with handle 12191640 to the foreground

# Solution: 
# Check to see if window exists with a second user32name otherwise error is duplicate for user32

$h=Windo-Exsts -hWnd $hwnd
Write-Host
$h
Write-Host

# Example Usage: Ensure window is still open before sending keys
if ($hWnd -and (Windo-Exsts -hWnd $hWnd)) {
    Send-KeysToWindow -hWnd $hWnd -Keys "I am still here!{ENTER}"
} else {
    Write-Host "The PowerShell window has been closed. Cannot send keys."
}

