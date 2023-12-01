####################################
# Purpose:
# To list all owners of m365/unified group using mggraph 
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
# Maker: TFR
####################################


[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Title
)


#################################################################################################
# Main Execution
#################################################################################################
Disconnect-mggraph
Import-module microsoft.graph.authentication
Import-module microsoft.graph.groups

# Display variables input by user
$out_msg="Main;MainExecution begins here"
$out_msg

# Disconnect
Disconnect-mggraph

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
#$accessToken

#Connect to the Graph API with the access token.
Connect-MgGraph -Accesstoken $accessToken

# Map script vars to parameters
# Define the Microsoft 365 group details
$s_Title = $Title
#$s_Title

# Retreive the guid for the group
$ObtainedGroupID=get-mggroup -Filter "DisplayName eq '$s_Title'"

#$out_msg="After Title"
#$out_msg
#$ObtainedGroupID.id


$out_msg="All owners for Group: " + $s_title
$out_msg
$out_msg="-------------------------------"
$out_msg

# List all group owners
Get-MgGroupOwner -GroupId $ObtainedGroupID.id | ForEach {Get-MgUser -UserId $_.Id}|select Displayname,userprincipalName


# Disconnect
Disconnect-mggraph|out-null


