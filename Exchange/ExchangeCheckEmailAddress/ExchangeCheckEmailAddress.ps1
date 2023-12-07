
# Purpose:
# To check existence of email address
# Maker: TFR 
#
# Usage:
# Check-EmailAddressExist -fn_email "user@somedomain.com"

function Check-EmailAddressExist {

    param (
        [Parameter(Mandatory = $true)]
        [string]$fn_email
    )

    [string]$out_msg = $null

    try {
        $mailbox = Get-Mailbox -Identity $fn_email -ErrorAction Stop
        if ($mailbox) {
            $out_msg = "The email address $fn_email exists."
        } else {
            $out_msg = "The email address $fn_email does not exist."
        }
    }
    catch {
        $out_msg = "An error occurred: $_"
    }

    return $out_msg
}
