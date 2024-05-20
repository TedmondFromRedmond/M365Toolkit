<#

 .SYNOPSIS
   Controller Program to ensure the latest modules.psm1 file is imported.

 .DESCRIPTION
    The Controller Program ensures the latest module is imported by using PSDrive and starting the Webclient service to do so.
    The need for extra libraries, add-ins and software is unnecessary to accomplish this task. e.g. SharePoint PnP.    

 .EXAMPLE
   .\PSdrivetoSharepoint.ps1
   .\PSdrivetoSharepoint.ps1 -p_LibraryPath "\\CompanyName.sharepoint.com@SSL\DavwwwRoot\sites\20200903DSTS3\Shared Documents" -p_PSM1ToImport "MostAwesomeModules.psm1" -PSDriveName "MostAwesomePowerShell"

###################
# Revision History
###################
# 20240518 - Author: TFR - https://www.github.com/TedmondFromRedmond 
# 20240520 - TFR - Added parameters to script for future use if necessary
#
####################

#>

####################################################################################################################################
# Script Parameters
####################################################################################################################################
param (
    [string]$p_LibraryPath = $null,
    [string]$p_PSM1ToImport = $null,
    [string]$PSDriveName = $null
)

function fn_StartmyService {
    param (
        [Parameter(Mandatory=$true)]
        [string]$p_ServicetoStart
    )
<#

 .SYNOPSIS
    Function to start a specified service if it is not already running

 .DESCRIPTION
    This function checks the status of a specified service. If the service is not running, it starts the service and waits until the service status is 'Running'.

 .PARAMETER p_ServicetoStart
    The name of the service to be started.

 .EXAMPLE
   fn_StartmyService -p_ServicetoStart "WebClient"
    This command starts the Print Spooler service if it is not already running.

#>

    try {
        # Get the service object
        $fn_IF_service = Get-Service -Name $p_ServicetoStart -ErrorAction Continue

        # Check if the service is not running and start it
        if ($fn_IF_service.Status -ne 'Running') {
            write-host "[Inf],Service not in Running status..."
            Write-Host "[Inf],Starting service: $p_ServicetoStart"
            Start-Service -Name $p_ServicetoStart -ErrorAction Stop

            # Wait for the service to be fully started
            while ($fn_IF_service.Status -ne 'Running') {
                Write-Host "[Inf],Service is starting. Waiting for 10 seconds..."
                Start-Sleep -Seconds 10
                $fn_IF_service = Get-Service -Name $p_ServicetoStart -ErrorAction Stop
            }

            Write-Host "[Inf],Service started successfully: $p_ServicetoStart"
        } else {
            Write-Host "[Inf],Service is already running: $p_ServicetoStart"
        } # end of if fn_if_service.status ne running
    }
    catch {
        Write-Host "[Error],An error occurred: $_" -ForegroundColor Red
    } # End of try catch

} # End of fn_StartmyService
#-----------------------------------------------------------
################################################################################
#### END OF FUNCTIONS ####
################################################################################


################################################################################
# Main Execution
################################################################################
# variable clear
$LibraryPath=$null 
$rc=$null

# variable declarations
$LibraryPath = "\\startos.sharepoint.com@SSL\DavwwwRoot\sites\20200903DSTS3\Shared Documents" # Change to match customer requirements

# Global Variables

# Map parameters to script variables


################
# Overrides
#
#
#
# End of Overrides
################

# Start the service that is required
$ErrorActionPreference = "Continue"

# Call function to start service
fn_StartmyService -p_ServicetoStart "WebClient"

$LibraryPath = "\\startos.sharepoint.com@SSL\DavwwwRoot\sites\20200903DSTS3\Shared Documents"

# Check for existence of PSDrive
# if exists, do nothing, if not, then create
$rc=get-psdrive -name "MostAwesomePowerShell"

if ($rc){
    write-host "[INF],SharePoint Connection is setup"
    Continue
} else 
{
    New-PSDrive -name "MostAwesomePowerShell" -Root $LibraryPath -PSProvider filesystem -Scope Global # Global makes the drive accessible to everyone
    gci MostAwesomePowerShell:
    write-host "[Inf],Setup PSDrive"
} end of if $rc


# !@# May not need and can just import with force
# Copy file from Library Path to PowerShell modules area and import. 
#
# Copy-Item -Path "MostAwesomePowerShell:\MostAwesomeModule.psm1" -Destination "C:\Program Files\WindowsPowerShell\Modules" -Force
# 
# !@# May not need and can just import with force

# If wanted, check version and import later version according to manifest file

#!@#
# Import the module with the force.
Import-module MostAwesomePowerShell:MostAwesomeModule.psm1 -Force
$!@#

write-host
write-host "[Inf],Main,Sleeping for 60 seconds while updating Module."
Start-Sleep -Seconds 60
write-host "[Inf],Main,Rumplestilsken is done sleeping while updating Module."

# Get-Module -name "MostAwesomeModule.psm1"

write-host
Write-host "[INF],The end"


