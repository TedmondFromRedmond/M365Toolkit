###############################################################################
# Purpose:
# To show how to use a function to press any key on the keyboard and pause
# a PowerShell.
#
#
#
# Inputs:
#
#
#
# Outputs:
#
#
# Usage:
# .\Anykey.ps1
#
#-----------------------------------------------------------------------------------------------------------
# Revision History:
# Date               | Description
#-----------------------------------------------------------------------------------------------------------
# 2015-02-14         | Maker - TFR
#
#-----------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------#
Function fn_AnyKey {
#
# Purpose: To ask the user to press any key to continue and wait until 
# any key is pressed to continue
#
# Usage: fn_AnyKey
#
                        write-host "Press any key to continue ..."
                        
                        
                        # NOTE: HOST.UI does not work in ISE by design. 
                        # Special thanks to the developers at MSFT who 
                        # take away the useful features in exchange for the 
                        # desire to fulfill their own needs instead of listen to customers.

                        $fn_x=$HOST.UI.RawUI.ReadKey(“NoEcho,IncludeKeyDown”) | OUT-NULL
                        
                    }
#-------------------------------------------------------------#

# Main Execution section
fn_AnyKey

