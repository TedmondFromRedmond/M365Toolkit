####################################
# Purpose:
# To add members to m365/unified group using mggraph 
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
# https://office365itpros.com/2022/03/29/azure-ad-group-management/
# 
# Usage:
# .\UGAddMember.ps1 -Title "DisplayNameofGroup" -EmailAddress "UPN to add to group"
# 
#
# Modification History
#----------------------
# 20230901 | TFR - Maker
# 20230907 | TFR- Added multiple emailaddresses that could be added by separating with a comma
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
Import-Module Microsoft.Graph.Groups
Import-Module microsoft.graph.authentication

# Display variables input by user
$out_msg="Main;MainExecution;UGAddMember.ps1 begins here"
$out_msg

# Setup vars for graph
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
$accessToken = (Invoke-RestMethod @request).access_token

# view the token value if you wanted to, otherwise delete line 20
# uncomment for debugging
# $accessToken

#Connect to the Graph API with the access token.
Connect-MgGraph -Accesstoken $accessToken

# Map script vars to parameters
# Define the Microsoft 365 group details
$s_EmailAddress = $EmailAddress
$s_Title = $Title

<# Debug
$out_msg="show parms passed in"
$out_msg
$s_EmailAddress
$s_Title
$out_msg="End of show parms passed in"
$out_msg
#>


$s_EmailAddress=$s_EmailAddress -split ','

# Retreive the guid for group to add to group
$ObtainedGroupID=$null
$ObtainedGroupID=get-mggroup -Filter "DisplayName eq '$s_Title'"
# debug
# $out_msg="After Title guid obtained"
# $out_msg
# $ObtainedGroupID.id


# error check for invalid group name
if($ObtainedGroupID){ write-host ""
                    }else
                    {
                    $out_msg="Did not find title/group display name. Ending program"
                    $out_msg 
                    $s_title
                    Exit
                    } #End of if obtainedgroupid.id.length -eq 0

#############################################
# Loop thru emailaddresses to add in bulk
# obtain guid for each user and add to group with guid from above


Foreach($t_member in $s_emailaddress){
                                    $t_member=$t_member.trim()
                                    
                                    # check for invalid username
                                    $GMUID=(Get-MgUser -Filter "mail eq '$t_member'")
                                    #$out_msg="After GMUID"
                                    #$out_msg
                                    #$GMUID.id

                                    if ($gmuid){
                                                # Add the member to the group
                                                $out_msg="Starting Add member to group"
                                                $out_msg
                                                New-MgGroupMember -GroupId $ObtainedGroupID.id -DirectoryObjectId $GMUID.id
                                                $out_msg="Added member to group. To see all members added to a group, execute the UGListAllMembers runbook."
                                                $out_msg

                                                $out_msg="Please hold....Validating membership by displaying all members inthe DL: " + $s_title
                                                $out_msg


                                                .\UGListAllMembers.ps1 -Title $s_title


                                                }Else
                                                {
                                                $out_msg= "Did not find UPN, skipping add user to DL."
                                                $out_msg 
                                                $t_member
                                                sleep -seconds 5

                                               } # End of if gmuid.id.length -eq 0

                                        } # end of foreach $t_owners in $s_emailaddress


# Disconnect
Disconnect-mggraph

$out_msg="Ending UGAddmember.ps1"
$out_msg
