#----
#
# Functions begin here
#

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
    #
    # Returns:
    # -1 means window not found

    param (
        [int]$hWnd,
        [string]$Keys
    )

    # Validate if the window still exists before sending keys
    if (-not (Windo-Exsts -hWnd $hWnd)) {
        Write-Host "Window handle $hWnd no longer exists. The window may have been closed."
        return "Failed"
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
        Return "Success"
    } else {
        Write-Host "Failed to bring window with handle $hWnd to the foreground."
        Return "Failed"
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


    .Outputs

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
