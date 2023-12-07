#------------------------------------------------------------------------------------------------------------------------
function fnReadLogs {
<#
.Synopsis
To obtain data from Windows event logs by filtering or not filtering with provided parameters.
For examples, review the Usage section below.

.Description
Searches the Windows event viewer log of machine where the script is executed.

One can call the script with only 1 minimum parameter, -fnRLLogName "Application"
For example, if one wanted all of the logs from a particular log filename of Security, the syntax would be:
$fnReadLogsResults=fnReadLogs -fnRLLogName Security

Keep in mind, that one and only 1 parameter are required, -fnRLLogName


If the function fnReadLogs is to return only event ids of 1001 from a specified log, 
$fnReadLogsResults=fnReadLogs -fnRLLogName Security -fnRLEventID "1001"

For example, to retreive log data from the last 30 days, enter (Get-Date).AddDays(-30) for the -fnRLDate parameter
$fnReadLogsResults = fnReadLogs -fnRLLogName "Application" -fnRLLogText "some error text" -fnRLDate (Get-Date).AddDays(-30) 

# Note: The example below only obtains logs within the last 7 days from today's date. 
$fnReadLogsResults = fnReadLogs -fnRLLogName "Application" -fnRLLogText "some error text" -fnRLDate (Get-Date).AddDays(-7) 

# Additionally, it is important to note that it is not possible to retreive log data from the future unless you purchase a modified DeLorian automobile, 
# adjust the time on the dashboard to be in the future and  utilize the flux capacitor. (No Roads) ;)

#  To format a table with the results,
$fnReadLogsResults | Format-Table -Property Id, TimeCreated, Message -AutoSize

# To Export output of the function to a CSV file after calling function
$fnReadLogsResults | export-csv .\stuff.csv


#------------------------
# Modification History
#------------------------
20231016 - Maker - TedmondFromRedmond
20231017 - TedmondFromRedmond; added date to retreive data from log within a specified date range


How to use:
There are multiple ways to use this function:
- Copy and paste function into current script
- Include script into existing script - .\FinalEventViewerReaderWithDate.ps1
- Execute the script as a .ps1 and call the script from memory - e.g. fnReadLogs ...

One can use the get-help fnReadLogs after the script is loaded into memory to see the synopsis, description, modification history and more...

.Example
Read last 7 days of Application log file
$fnReadLogsResults = fnReadLogs -fnRLLogName "Application" -fnRLLogText "Text to search for" -fnRLDate (Get-Date).AddDays(-7) 


#>


    param (
        [Parameter(Mandatory=$true)]
        [string] $fnRLLogName,

        [Parameter(Mandatory=$false)]
        [string] $fnRLLevel,

        [Parameter(Mandatory=$false)]
        [string] $fnRLSource,

        [Parameter(Mandatory=$false)]
        [int] $fnRLEventID,

        [Parameter(Mandatory=$false)]
        [string] $fnRLLogText,

        [Parameter(Mandatory=$false)]
        [datetime] $fnRLDate
    )

    # Check if fnRLLogName is provided
    if (-not $fnRLLogName -or $fnRLLogName -eq "") {
        Write-Host "The required parameter for fnRLLogName is not present. Please supply Windows Log Name such as Application."
        return -1
    }

    # Construct the filter hashtable based on the parameters provided
    $filterHashTable = @{
        LogName = $fnRLLogName
    }

    if ($fnRLLevel) { $filterHashTable.Level = $fnRLLevel }
    if ($fnRLSource) { $filterHashTable.ProviderName = $fnRLSource }
    if ($fnRLEventID) { $filterHashTable.Id = $fnRLEventID }
    if ($fnRLDate) { $filterHashTable.StartTime = $fnRLDate }

    # Query the event log with the constructed filter
    $events = Get-WinEvent -FilterHashtable $filterHashTable -ErrorAction SilentlyContinue

    # If fnRLLogText is provided, filter the results further based on message content
    if ($fnRLLogText) {
        $events = $events | Where-Object { $_.Message -like "*$fnRLLogText*" }
    }

    # Return the filtered events
    return $events
} # end fo fnReadLogs
#------------------------------------------------------------------------------------------------------------------------




