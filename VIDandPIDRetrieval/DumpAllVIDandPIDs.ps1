#---------------------------------------------------------------------------
function fn_GetConnectedPnPDevices {
    <#
    .SYNOPSIS
    Retrieves a list of connected Plug and Play devices along with their Vendor ID (VID) and Product ID (PID).
    
    .DESCRIPTION
    This function uses Get-PnpDevice to extract device details from the system. It collects the FriendlyName, VID, and PID.
    It filters out any device lacking VID or PID, sorts by FriendlyName, and returns the result to console.
    If the optional boolean parameter is set, the output is returned as a CSV-formatted object as listed in the example section.
    One use case for this is to dump before and after pids and vids.

    
    .EXAMPLE
    # Output to console
    $results = fn_GetConnectedPnPDevices
    $results | ForEach-Object { Write-Host "$($_.FriendlyName): VID=$($_.VID), PID=$($_.PID)" }
    
    .EXAMPLE
    # output to csv
    $objects = fn_GetConnectedPnPDevices
    $objects | Export-Csv .\test.csv -NoTypeInformation

    
    .REVISION HISTORY
    ------------------------------------------------------------------------------------------------
    Date        | Author | Change Description
    ------------------------------------------------------------------------------------------------
    2025-07-29  | TFR    | Initial function creation per POSH standards
    2025-07-29  | TFR    | Added optional CSV output as string array (no file written)
    2025-07-29  | TFR    | Added full doc block with revision history
    ------------------------------------------------------------------------------------------------
    #>
    
        param (
            [Parameter(Mandatory=$false)]
            [bool]$p_OutputCSVObject = $false
        )
    
        # Retrieve and process PnP device data
        $fn_IF_DeviceList = Get-PnpDevice | 
            Select-Object `
                FriendlyName, `
                @{Name='VID';Expression={
                    if ($_.InstanceId -match 'VID_([0-9A-F]{4})') { $Matches[1] }
                    else { $null }
                }}, `
                @{Name='PID';Expression={
                    if ($_.InstanceId -match 'PID_([0-9A-F]{4})') { $Matches[1] }
                    else { $null }
                }} |
            Where-Object { $_.VID -or $_.PID } |
            Sort-Object FriendlyName |
            Select-Object FriendlyName, VID, PID
    
        # Return CSV string array if requested
        if ($p_OutputCSVObject -eq $true) {
            $fn_IF_CsvString = $fn_IF_DeviceList | ConvertTo-Csv -NoTypeInformation
            return $fn_IF_CsvString
        }
    
        return $fn_IF_DeviceList
    }
    #---------------------------------------------------------------------------
    