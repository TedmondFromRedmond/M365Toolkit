####################################
# Purpose:
# To add an owner to M365Group/Unified Group with MgGraph cmdlets
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
#
# Usage:
# .\UGAddowner.ps -Title TheDisplayNameoftheM365Group -OwnerEmailAddress Owneremailtoadd@ahead.com
#
# Modification History
# --------------------
# 20230901 | TFR - maker
# 20230907 | TFR - added history table, suppressed graph message, added script name to main execution message,trimmed user input, added ending program message
# 20230907 | TFR - added ability to process multiple users
#
####################################
[CmdletBinding()]
param(

       
    [Parameter(Mandatory=$true)]
    [string]$Title,

    [Parameter(Mandatory=$true)]
    [string]$OwnerEmailAddress
)

#################################################################################################
# Main Execution
#################################################################################################
# Disconnect Graph
Disconnect-mggraph -erroraction silentlycontinue
Import-Module Microsoft.Graph.Groups
Import-Module microsoft.graph.authentication


# Display variables input by user
$out_msg="Main;MainExecution;UGAddowner.ps1 begins here"
$out_msg


$Title
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
# $accessToken

# Connect to the Graph API with the access token.
Connect-MgGraph -Accesstoken $accessToken

# Map script vars to parameters
# Define the Microsoft 365 group details
#$out_msg="mapping script vars; both should show below"
#$out_msg
$s_Title = $Title.trim()
$s_OwnerEmailAddress = $OwnerEmailAddress.trim()

#$s_Title
#$s_OwnerEmailAddress

# Separate multiple entries by comma
$s_OwnerEmailAddress=$s_OwnerEmailAddress -split ','

# Obtain guid for group
$ObtainedGroupID=$null
$ObtainedGroupID=get-mggroup -Filter "DisplayName eq '$s_Title'"

#$out_msg="After obtaining value of obtained group id of s_title / displayname of m365 group"
#$out_msg
#$ObtainedGroupID.id

# error check for valid group name
if($ObtainedGroupID){
                    write-host ""
                    }else 
                    {
                        $out_msg="Error, unable to obtain group ID. check Group ID and resubmit. Ending program"
                        $out_msg
                        $s_Title
                        Exit
                        }# end of if check for a value in obtainedgroupid
#################################
# Loop thru multiple owner email addresses or 1
#
foreach($t_OwnerEmailAddress in $s_OwnerEmailAddress){
                                                        $t_owneremailaddress=$t_owneremailaddress.trim()
                                                        $gmuid=$null
                                                        # Obtain the objectid in AAD for the s_owneremailaddress
                                                        # xform s_owneremailaddress into format used with get-mguser
                                                        $MGUsername="'$t_OwnerEmailAddress'"
                                                        $GMUID=(Get-MgUser -Filter "mail eq $MGUsername").id

#                                                        $out_msg="Value of GMUID after obtaining the object id for s_owneremailaddress"
#                                                        $out_msg
                                                        $GMUID
                                                            if ($gmuid){
 #                                                                       $out_msg="Value of GMUID after obtaining the object id for t_owneremailaddress"
 #                                                                       $out_msg
 #                                                                       $GMUID
                                                                        # xform myurl to add AAD object id to hashtable
                                                                        # the url is added to the owners group via hashtable
                                                                        $myurl="https://graph.microsoft.com/v1.0/users/"
                                                                        $myurl=$myurl + $GMUID
                                                                        #$out_msg="values: gmuid and myurl"
                                                                        #$out_msg
                                                                        #$GMUID
                                                                        #$myurl

                                                                        $myhash=@{}
                                                                        $myhash.add('@odata.id',$myurl)
                                                                        
                                                                        #$out_msg="After building myhash"
                                                                        #$out_msg
                                                                        #$myhash

                                                                        # New-MgGroupOwnerByRef -GroupId $ObtainedGroupID.id -AdditionalProperties @{"@odata.id"="https://graph.microsoft.com/v1.0/users/2a3b60f2-b36b-4758-8533-77180031f3d4"}
                                                                        New-MgGroupOwnerByRef -GroupId $ObtainedGroupID.id -AdditionalProperties $myhash

                                                                        $out_msg="Added Member to group"
                                                                        $out_msg
                                                            }else
                                                            {
                                                                        $out_msg="no guid found for user. bypassing processing: " + $MGUsername
                                                                        $out_msg
                                                                        
                                                            }# End of if gmuid


                                                        }# End of foreach $t_owneremailaddress



# Disconnect Graph
DisConnect-MgGraph

$out_msg="End of UGAddOwner.ps1"
$out_msg



