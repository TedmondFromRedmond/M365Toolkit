####################################
# Purpose:
# To create an m365 group that is mail enabled and have the group act as a 
# Disribution list for EXO.
# 
# The code works with the following module versions:
# microsoft.graph.authentication 1.28
# microsoft.graph.groups 1.28
#
# Note: 
# If you do not use this code, there will be errors 
# with the Access token and connecting to mggraph.
# 
# 
# Ref(s):
# https://ourcloudnetwork.com/how-to-create-groups-with-microsoft-graph-powershell/
# 
# Modification History
# --------------------
# 20230901 | TFR - maker
# 20230907 | TFR - added history table, suppressed graph message, added script name to main execution message,trimmed user input, added ending program message
# 20230908 | TFR - added if check for externalSenders. The property is set after the group is created.
####################################


[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Title,

    [Parameter(Mandatory=$false)]
    [string]$EmailAddressofNewGroup,

     [Parameter(Mandatory=$false)]
    [string]$Owners

)




#################################################################################################
# Main Execution
#################################################################################################

Disconnect-mggraph -erroraction silentlycontinue


# Start by importing library
Import-Module Microsoft.Graph.Groups
Import-Module microsoft.graph.authentication

# Display variables input by user
$out_msg="Main;MainExecution;UGCreation.ps1 begins here"
$out_msg

$EmailAddress
$ExternalSenderAllowedToSendEmail
$Owners
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

# View the token value if you wanted to, otherwise delete line 20
# uncomment for debugging
# $accessToken

#Connect to the Graph API with the access token.
Connect-MgGraph -Accesstoken $accessToken

# Map script vars to parameters
# Define the Microsoft 365 group details
# $EmailAddress
# $ExternalSenderAllowedToSendEmail should be no by default
# $Owners
# $Title
$s_groupMailNickname = $EmailAddressofNewGroup # Note:  nickname must be all lower case and cannot contain any special chars or spaces
$s_ExternalSenderAllowedToSendEmail = $ExternalSenderAllowedToSendEmail
$s_Title = $Title
$s_groupDescription = " "
$s_Owners = $Owners

$s_Title2="DL-" + $s_Title
$s_TitleNickname=""
# $s_TitleNickname="dl" + ($s_title.trim()).ToLower()
$s_TitleNickname=($s_title.trim()).ToLower()
$s_TitleNickname=$s_TitleNickname.replace(' ','')



# Body parms
$params = @{
    description = $s_Title2
	displayName = $s_Title2
	groupTypes = @(
		"Unified"
	)
	mailEnabled = $true
	mailNickname = $s_TitleNickname
	resourceBehaviorOptions = @(
        "WelcomeEmailDisabled"
        "SubscribeNewGroupMembers"
    )
	securityEnabled = $true
	Visibility="Private"
}
$out_msg="Displaying params to send to new-mggroup"
$out_msg
$params


$out_msg="Start of creating group"
$out_msg
# Create group syntax for Graph
# $group=New-MgGroup -DisplayName $s_Title2 -MailEnabled:$False -GroupTypes Unified -SecurityEnabled -MailNickname $s_TitleNickname -Visibility "Private"
$params
$group=New-MgGroup -BodyParameter $params

$out_msg="End of creating group and displaying group"
$out_msg
$group

$out_msg="group.id after creation"
$out_msg
$group.id


#-------------------------------------------------
# Validate the group was created and obtain the groupid
#

$out_msg="Start of validating group ID was created"
$out_msg

$ObtainedGroupID=get-mggroup -Filter "DisplayName eq '$s_Title2'"
$out_msg="After obtaining value of obtained group id value of obtainedgroupid.id"
$out_msg
$ObtainedGroupID.id
$out_msg="End of obtaining group ID"
$out_msg

#######################################################################
# ck if externalsenderallowedtosendemail and if so, set it appropriately

# The default value for AllowExternalSenders is $false.
# Ergo, if the property is not specified, then senders will not be able to send email from external sources.
if ($s_ExternalSenderAllowedToSendEmail -eq 'y') {
#$out_msg="Start of if s_ExternalSenderAllowedToSendEmail equal y"
#$out_msg



$out_msg="Start of defining uri and headers"
$out_msg

# Define your API endpoint, token, and other parameters
$uri = "https://graph.microsoft.com/v1.0/groups/" + $ObtainedGroupID.id
$out_msg="URI value"
$out_msg
$uri

# $token = "YOUR_ACCESS_TOKEN"  # You'd typically get this from Azure AD OAuth flow
$headers = @{
    'Authorization' = "Bearer $accessToken"
    'Content-Type'  = "application/json"
            } # end of heders

$out_msg="End of defining uri and headers"
$out_msg

$out_msg="setting up parms for allowexternalsenders"
$out_msg
$patchparams=@{
                AllowExternalSenders = $true
                }

# $uri
# $headers
# $patchparams

# Use Invoke-RestMethod to make the PATCH request
# $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Patch -Body (ConvertTo-Json $patchparams)
# API call to update group property
Invoke-RestMethod -Uri $uri -Headers $headers -Method Patch -Body (ConvertTo-Json $patchparams)
$out_msg="End of invoke-restmethod"
$out_msg

$out_msg="Start of Update-MgGroup"
$out_msg
Update-MgGroup -GroupId $ObtainedGroupID.id -BodyParameter ($patchparams|ConvertTo-Json)
$out_msg="End of Update-MgGroup"
$out_msg



} # End of if  allowexternalsenders eq y

###################################################################################################


# 
#----
 
# Define your API endpoint, token, and other parameters
# $uri = "https://graph.microsoft.com/v1.0/groups/" + $Group.id
$uri = "https://graph.microsoft.com/v1.0/groups/" + $ObtainedGroupID.id

# $token = "YOUR_ACCESS_TOKEN"  # You'd typically get this from Azure AD OAuth flow
$headers = @{
    'Authorization' = "Bearer $accessToken"
    'Content-Type'  = "application/json"
            } # end of headers


# $out_msg="Sleeping for seconds 120"
# $out_msg
# start-sleep -seconds 120
# $out_msg="End of Sleeping for seconds 120"
# $out_msg

$out_msg="start of Update-mggroup HideFromAddressLists true"
$out_msg
$patchparams=@{
 HideFromAddressLists = $false
} # end of $patchparams
Update-MgGroup -GroupId $ObtainedGroupID.id -BodyParameter ($patchparams|convertto-json)
$out_msg="End of Update-mggroup HideFromAddressLists true"
$out_msg


#$out_msg="Start of REST api HideFromAddressLists"
#$out_msg
#$patchparams=@{
# HideFromAddressLists = $true
#  }
# $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Patch -Body (ConvertTo-Json $patchparams)
#Invoke-RestMethod -Uri $uri -Headers $headers -Method Patch -Body (ConvertTo-Json $patchparams)
#$out_msg="End of REST api HideFromAddressLists"
#$out_msg



$out_msg="Start of HideFromOutlookClients"
$out_msg
$patchparams=@{
 HideFromOutlookClients = $true
} # end of $patchparams
Update-MgGroup -GroupId $ObtainedGroupID.id -BodyParameter ($patchparams|convertto-json)
$out_msg="End of HideFromOutlookClients"
$out_msg


# already covered above
#$out_msg="Start of mailenabled"
#$out_msg
#$patchparams=@{
#             mailEnabled = $true
#            } # end of $patchparams
#Update-MgGroup -GroupId $ObtainedGroupID.id -BodyParameter ($patchparams|convertto-json)
#$out_msg="End of mailenabled"
#$out_msg


$out_msg="Start of AutoSubscribenewmembers=true"
$out_msg
$patchparams=@{
 AutoSubscribeNewMembers = $true
} # end of $patchparams
Update-MgGroup -GroupId $ObtainedGroupID.id -BodyParameter ($patchparams|convertto-json)
$out_msg = "End of AutoSubscribenewmembers=true"
$out_msg

#-------------------------------------------------
# call UGAddowner to add to the owner list

$out_msg="Starting Call .\UGAddowner.ps1"
$out_msg
# Attempt to add owner
# Get the ID of the user
$out_msg="# Get the ID of the user"
$out_msg
$OMGUserNameownerUser = Get-MgUser -Filter "mail eq '$s_Owners'"
$out_msg="values of Title, Ownermail and guid of s_owners before calling UGAddowner: "
$out_msg
$s_Title2
$s_Owners
$OMGUserNameownerUser.id


# Call UGAddowner as a child call and wait for runbook to finish
.\UGAddowner.ps1 -Title $s_Title2 -OwnerEmailAddress $s_Owners 

$out_msg="End of call UGAddowner. "
$out_msg

############################################################################
#---
# Call the subprogram to update the properties if the original program is blocked.
$out_msg="Start Testing of updating properties after owner is assigned"
$out_msg

Disconnect-mggraph

$out_msg="Starting Calling tg to set properties"
$out_msg
.\tg.ps1 -title $s_title2
$out_msg="End of calling tg to set properties"
$out_msg

$out_msg="End of Testing of updating properties after owner is assigned"
$out_msg
#---

