####################################
# Purpose:
# To Remove M365/Unified Group using MgGraph
# 
# The code works with the following module versions:
# microsoft.graph.authentication 1.28
# microsoft.groups.groups 1.28
#
# Note: 
# As of 8/25/2023, if you do not use these libraries code, there will be errors 
# with the Access token and connecting to mggraph.
# 
# 
# Ref(s):
# https://ourcloudnetwork.com/how-to-create-groups-with-microsoft-graph-powershell/
# 
#
# Usage:
# .\UGRemoveGroup.ps1 -GroupName "Name of M365 group"
#
#
# Modification History
# --------------------
# 20230901 | TFR - maker
# 20230907 | TFR - added history table, suppressed graph message, added script name to main execution message,trimmed user input, added ending program message
####################################


[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$GroupName
)



####################################
#
# Main Execution Begins Here
#
####################################
Disconnect-mggraph -erroraction silentlycontinue

Import-module microsoft.graph.authentication
Import-module microsoft.graph.groups

$out_msg="Main;MainExecution UGRemoveGroup.ps1 begins here"
$out_msg

# Display variables input by user
$out_msg="GroupName"
$out_msg


# Map Parms to script vars
$s_GroupName=$GroupName.trim() -split ','
$s_GroupName


# Setup vars to connect to graph
$tenant_id = '<Replace with yourvalues>'
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
$AccessToken = (Invoke-RestMethod @request).access_token

# View the token value if you wanted to, otherwise delete line 20
# uncomment for debugging
# $accessToken

# Connect to the Graph API with the access token.
Connect-MgGraph -Accesstoken $accessToken


foreach ($t_GroupName in $s_GroupName){
    $t_GroupName=$t_GroupName.trim()

    $ObtainedGroupID=$null

    $ObtainedGroupID=get-mggroup -Filter "DisplayName eq '$t_groupname'"

# Err check
    if($ObtainedGroupID){

    #$out_msg="after ObtainedGroupIDGroup ID for: $t_groupname"
    #$out_msg
    #$ObtainedGroupID.ID

    # Remove the group
    $out_msg="Removed the Group: " + $t_groupname
    $out_msg

    Remove-MgGroup -GroupId $ObtainedGroupID.id


    }Else
    {
    $out_msg="Error. Group not found or Does Not Exist, skipping remove for Group Name:"
    $out_msg
    $t_groupname

    } # End of if ObtainedGroupID

} # End of foreach t_GroupName


# Disconnect mggraph
Disconnect-mggraph -erroraction silentlycontinue


$out_msg="Ending UGRemoveGroup.ps1"
$out_msg
