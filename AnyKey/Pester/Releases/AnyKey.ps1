<#
.SYNOPSIS
Prompts the user to press a key and waits until it is pressed.

.DESCRIPTION
fn_AnyKey writes a user-defined or default message to the console, reads a single
keypress from the host RawUI (in a non-echoing mode), and returns information about
the key pressed. For example, pressing capital “M” might return something like:
16,,ShiftPressed,True

.PARAM Message
Allows the user to specify a custom message to display. If left blank, the default
message "Press any key to continue ..." is used.

.OUTPUTS
System.Object
fn_AnyKey returns an object describing the key press. For instance, 

.EXAMPLE
fn_AnyKey -Message 'Press Y to answer yes and N for Nojueno.'

.EXAMPLE
fn_AnyKey - without a Message parameter defaults to press any key to continue.


.NOTES
Revision History:
-----------------
2025-02-16 | Added message para-meter to prompt user for input and return output in form of object. Biddy biddy biddy.
2025-02-12 | Added doctype and changed text to Press Enter to continue
2015-02-14 | Maker - TedmondFromRedmond
#>
Function fn_AnyKey {
    [CmdletBinding()]
    param(
        [string]$Message
    )

    
    #  map parm to con message
    if ($Message) {
        $fn_Message = $Message
    } else {
        $fn_Message = "Press any key to continue ..."
    } # End of if fn_message

    Write-Host $fn_Message
    
    # NOTE: $Host.UI.RawUI.ReadKey() doesn't work in PowerShell ISE.
    $fn_x = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    

    Return $fn_x
} # End of fn_anykey


# Uncomment for Testing
# Remove function from memory for testing
# Remove-item Function:\fn_AnyKey -Force
# $fn_result = fn_AnyKey -fn_message "Press any key to continue ..."
# write-host "testing..."
# $fn_result = fn_AnyKey
# $fn_result = fn_AnyKey -Message "asdfasdfasdf"

