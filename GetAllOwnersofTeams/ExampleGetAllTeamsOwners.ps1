

# Sample code
# Maker: TedmondFromRedmond


$credentials=Get-Credential  
 
# Connect to Microsoft Teams  
Connect-MicrosoftTeams -Credential $credentials  
 
# Get all the teams from tenant  
$teamColl=Get-Team  
 
# Loop through the teams  
foreach($team in $teamColl)  
{  
    Write-Host -ForegroundColor Magenta "Getting all the owners from Team: " $team.DisplayName  
 
    # Get the team owners  
    $ownerColl= Get-TeamUser -GroupId $team.GroupId -Role Owner  
 
    #Loop through the owners  
    foreach($owner in $ownerColl)  
    {  
        Write-Host -ForegroundColor Yellow "User ID: " $owner.UserId "   User: " $owner.User  "   Name: " $owner.Name  
    }      
}