<#
Written by Professor POSH - https://gptsdex.com/g/professor-powershell-posh (TFR)

CHATgpt Requirements to Professor POSH

hey Professor POSH, can you create a PowerShell with the following requirements:
1. Create a function named AAD_checkuser
2. Next, create a parameter for a UPN named myUPN
3. Check Azure Active Directory for the UPN and use the below requirements 
4. If the UPN is not in Azure Active Directory return a code from function of -1
5. If the UPN is in Azure Active Directory and disabled return a code from function of 0
6. If the UPN is not in Azure Active Directory and the account is enabled, return a code from function of 1
7. Use the uploaded standards when writing the powershell code


#>

function fn_AAD_checkuser {
<#
.Synopsis
Checks for the presence and status of a user in Azure Active Directory based on a User Principal Name (UPN).

.Description
This function queries Azure Active Directory to check if a UPN exists.
It returns different codes based on the UPN's status:
- -1 if the UPN is not found in Azure Active Directory.
- 0 if the UPN exists but the account is disabled.
- 1 if the UPN exists and the account is enabled.

.Parameter myUPN
The User Principal Name to be checked in Azure Active Directory.

.Example
$statusCode = fn_AAD_checkuser -myUPN "user@example.com"

# Maker - TFR

#>

    param (
        [Parameter(Mandatory=$true)]
        [string] $fn_IF_myUPN
    )

    # Azure AD query logic here (actual Azure AD query commands required)
    # $user = Get-AzureADUser -ObjectId $fn_IF_myUPN

    # Check user status in Azure AD
    if ($null -eq $user) {
        return -1  # User not found in Azure AD
    } elseif ($user.AccountEnabled -eq $false) {
        return 0  # User is found but disabled
    } else {
        return 1  # User is found and enabled
    }

    # Error handling if needed
} # End of fn_AAD_checkuser


