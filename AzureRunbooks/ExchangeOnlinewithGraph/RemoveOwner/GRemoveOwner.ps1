####################################
# Purpose:
# To remove an owner of m365/unified group using mggraph 
# 
# The code works with the following module versions:
# microsoft.graph.authentication 1.28
# microsoft.groups.groups 1.28
#
# Note: 
# If you do not use this code, there will be errors 
# with the Access token and connecting to mggraph.
# 
# 
# Ref(s):
# Refs: https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.groups/remove-mggroupownerbyref?view=graph-powershell-1.0
#
# Once owners are assigned to a group, the last owner (a user object) of the group cannot be removed.
#
# Usage:
# .\UGRemoveOwner.ps1 -Title "Displayname of m365 group" -EmailAddress "UPN"
#
#
# Modification History
# --------------------
# 20230901 | TFR - maker
# 20230907 | TFR - added history table, suppressed graph message, added script name to main execution message,trimmed user input, added ending program message
#
####################################


[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Title,

    [Parameter(Mandatory=$true)]
    [string]$EmailAddress

)


#################################################################################################
# Main Execution
#################################################################################################

Disconnect-mggraph -erroraction silentlycontinue
Import-module microsoft.graph.authentication
Import-module microsoft.graph.groups

# Display variables input by user
$out_msg="Main;MainExecution UGRemoveOwner begins here"
$out_msg


# Setup vars for graph
$tenant_id =  '<Replace with yourvalues>'
$client_id =  '<Replace with yourvalues>'
$client_secret_value =  '<Replace with yourvalues>'

 
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
#$accessToken

#Connect to the Graph API with the access token.
Connect-MgGraph -Accesstoken $accessToken

# Map script vars to parameters
# Define the Microsoft 365 group details
$s_EmailAddress = $EmailAddress
$s_Title = $Title

#$s_EmailAddress
#$s_Title

$s_Emailaddress=$s_Emailaddress -split ','


# Retreive guid for group
$ObtainedGroupID=$null
$ObtainedGroupID=get-mggroup -Filter "DisplayName eq '$s_Title'"
#$out_msg="After Title"
#$out_msg
#$ObtainedGroupID.id

# error check groupid ! found
if($ObtainedGroupID){
write-host "Group Found!!!"
}else
{
$out_msg="Error, group display name not found. Resubmit correct group display name. Ending program."
$out_msg
Exit
}# End of if obtainedgroupid


foreach($t_Emailaddress in $s_Emailaddress){
            $t_Emailaddress=$t_Emailaddress.trim()
            $GMUID=$null
            # Retreive the guid for user
            $GMUID=(Get-MgUser -Filter "mail eq '$t_EmailAddress'")
            #$out_msg="After GMUID"
            #$out_msg
            #$GMUID.id

# Error ck gmuid value
            if($GMUID){
            $out_msg="Removed groupowner with values"
            $out_msg
            $t_Emailaddress
            $obtainedgroupid.id
            
            # Remove an owner of a group
            Remove-MgGroupOwnerByRef -GroupId $ObtainedGroupID.id -DirectoryObjectId $GMUID.id

            }else
            {
            $out_msg="UPN not found in AAD. bypassing processing for UPN:"
            $out_msg
            $t_Emailaddress    
                }# End of if gmuid


                                            } # End of foreach t_emailaddress


# Disconnect
Disconnect-mggraph -erroraction silentlycontinue
