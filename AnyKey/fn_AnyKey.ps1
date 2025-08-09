#---
<#
.SYNOPSIS
Waits for a single key press and returns detailed key information.

.DESCRIPTION
fn_AnyKey displays a message (customizable, with a sensible default),
waits for a key press, and returns a structured PSCustomObject with
character, virtual key code, modifier keys, and a timestamp.

Supports:
- Optional timeout (returns a TimedOut flag if exceeded).

.PARAMETER Message
Custom prompt message. If null/empty/whitespace, defaults to:
"Press any key to continue..."

.PARAMETER TimeoutSeconds
Number of seconds to wait before timing out. If not specified, waits indefinitely.

.OUTPUTS
[pscustomobject]
Character, Key, VirtualKey, ShiftPressed, AltPressed, CtrlPressed, Modifiers, Timestamp, TimedOut

.EXAMPLE
fn_AnyKey
# Displays default message and waits indefinitely.

.EXAMPLE
fn_AnyKey -Message "Press Y to confirm..." -TimeoutSeconds 200
# Displays custom message.

.NOTES
Revision History:
-----------------
2025-08-09 | Added default message and timeoutseconds
2025-02-16 | Added message para-meter to prompt user for input and return output in form of object. Biddy biddy biddy.
2025-02-12 | Added doctype and changed text to Press Enter to continue
2015-02-14 | Maker - TedmondFromRedmond
#>
Function fn_AnyKey {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [string]$Message,
        [int]$TimeoutSeconds
    )

    # Use default message if null/empty/whitespace
    if ([string]::IsNullOrWhiteSpace($Message)) {
        $Message = "Press any key to continue..."
    }

    Write-Host $Message



    # === Real keypress mode ===
    if ($PSBoundParameters.ContainsKey('TimeoutSeconds') -and $TimeoutSeconds -gt 0) {
        $deadline = ((Get-Date)).AddSeconds($TimeoutSeconds)
        while (-not [Console]::KeyAvailable) {
            if ((Get-Date) -ge $deadline) {
                return [pscustomobject]@{
                    Character     = $null
                    Key           = $null
                    VirtualKey    = $null
                    ShiftPressed  = $false
                    AltPressed    = $false
                    CtrlPressed   = $false
                    Modifiers     = $null
                    Timestamp     = Get-Date
                    TimedOut      = $true
                }
            }
            Start-Sleep -Milliseconds 50
        }
        $keyInfo = [Console]::ReadKey($true)
    }
    else {
        $keyInfo = [Console]::ReadKey($true)
    }

    # === Return result object ===
    return [pscustomobject]@{
        Character     = $keyInfo.KeyChar
        Key           = $keyInfo.Key
        VirtualKey    = [int]$keyInfo.Key
        ShiftPressed  = $keyInfo.Modifiers.HasFlag([ConsoleModifiers]::Shift)
        AltPressed    = $keyInfo.Modifiers.HasFlag([ConsoleModifiers]::Alt)
        CtrlPressed   = $keyInfo.Modifiers.HasFlag([ConsoleModifiers]::Control)
        Modifiers     = $keyInfo.Modifiers
        Timestamp     = Get-Date
        TimedOut      = $false
    }
}
#---

