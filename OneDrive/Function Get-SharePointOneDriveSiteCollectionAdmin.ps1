function Get-SharePointOneDriveSiteCollectionAdmins {
    param (
        [Parameter(Mandatory = $true)]
        [string]$UPN,

        [Parameter(Mandatory = $true)]
        [string]$SiteURL
    )
<#
.Synopsis
When disabling accounts it is good for one to know how to change the ownership of the Onedrive sharepoint site and validate
the change was successful with this function.

.Description
 Obtain the admins of a sharepoint onedrive site collection for a users Onedrive sharepoint site

# Usage:
# Get-SharePointOneDriveSiteCollectionAdmins -UPN "TFR" -SiteURL "https://thinkahead-my.sharepoint.com/personal/TFR"

#>
    try {
        # Get the site collection administrators
        $admins = Get-SPOUser -Site $SiteURL | Where-Object { $_.IsSiteAdmin -eq $true }

        if ($admins -ne $null) {
            $adminEmails = $admins | Select-Object -ExpandProperty LoginName
            # Write-Host "Site Collection Administrators for $SiteURL:"
            $adminEmails
        }
        else {
            Write-Host "No Site Collection Administrators found for $SiteURL."
        }
    }
    catch {
        # Display error message
        Write-Host "An error occurred while retrieving the Site Collection Administrators: $($_.Exception.Message)"
    }
}
