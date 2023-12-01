####################################
# Purpose:
# To list all members of m365/unified group using mggraph 
# 
# The code works with the following module versions:
# microsoft.graph.authentication 1.28
# microsoft.groups.groups 1.28
#
# Note(s): 
# Owners who are not listed as members do not show in the list.
# If you do not use this code, there will be errors 
# with the Access token and connecting to mggraph.
# 
# 
# Usage:
# .\UGListAllMembers.ps1 -Title "DL-BadNewsBears theyare"
#
#
#
# Ref(s):
# https://office365itpros.com/2022/03/29/azure-ad-group-management/
# 
# Make: 20231112- TFR
####################################


[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Title
)


#################################################################################################
# Main Execution
#################################################################################################

# Disconnect
Disconnect-mggraph -erroraction silentlycontinue

Import-Module Microsoft.Graph.Groups
Import-Module microsoft.graph.authentication

# Display variables input by user
$out_msg="Main;MainExecution UGListAllmembers.ps1 begins here"
$out_msg


# Setup vars for graph
$tenant_id =  '<Replace with yourvalues>'
$client_id = '<Replace with yourvalues>'
$client_secret_value = '<Replace with yourvalues>'

 
# DO NOT CHANGE ANYTHING BELOW THIS LINE
$request = @{
        Method = 'POST'
        URI    = "https://login.microsoftonline.com/$tenant_id/oauth2/v2.0/token"
        body   = @{
            grant_type    = "client_credentials"
            scope         = "https://graph.microsoft.com/.default"
            client_id     = $client_id
            client_secret = $client_secret_value
        }
    }

 

# Get the access token
$accessToken = (Invoke-RestMethod @request).access_token

# view the token value if you wanted to, otherwise delete line 20
# uncomment for debugging
# $accessToken

#Connect to the Graph API with the access token.
Connect-MgGraph -Accesstoken $accessToken

# Map script vars to parameters
# Define the Microsoft 365 group details
$s_Title = $Title
# remove any leading or trailing spaces
$s_title=$s_title.trim()
#$s_Title

# Retreive the guid for the group
$ObtainedGroupID=$null
$ObtainedGroupID=get-mggroup -Filter "DisplayName eq '$s_Title'"

# Determine if group id was obtained and if not then alert user to change to display name and resubmit
if ($ObtainedGroupID.length -eq 0){

$out_msg=""
$out_msg
$out_msg="Error; Unable to locate M365 group by Display Name of: " + $s_title
$out_msg
$out_msg=""
$out_msg
$out_msg="Please resubmit with a valid Display Name. Display names are availabe from https://Portal.azure.com"
$out_msg
$out_msg=""
$out_msg
$out_msg="Ending program."
$out_msg

# Disconnect Graph
Disconnect-mggraph -erroraction silentlycontinue

Exit

}Else
{

$out_msg="Listing of all members in Group with Display Name of: " + $s_title
$out_msg
$out_msg="-------------------------------"
$out_msg

# List all members of the group
Get-MgGroupMember -GroupId $ObtainedGroupID.id -All | ForEach {Get-MgUser -UserId $_.Id}|select Displayname,userprincipalName

#$out_msg="ObtainedGroupID Object ID Value is:"
#$out_msg
#$ObtainedGroupID.id


}# End of if ObtainedGroupID


# Catch all for fall thru logic Disconnect
Disconnect-mggraph -erroraction silentlycontinue


$out_msg="End of UGListAllMembers"
$out_msg
