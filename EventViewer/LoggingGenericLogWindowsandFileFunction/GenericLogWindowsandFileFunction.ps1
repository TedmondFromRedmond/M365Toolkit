function fn_Log {
.Synopsis
Generic logging for windows powershell

.Description
To be used as a generic function for writing to Microsoft Windows Event Viewer Logs on a server or workstation use the code below.
The function can also be used for writing to a text log file.
Be sure to review the usage area:

#------------------------
# Modification History
#------------------------
20231016 - Maker - TedmondFromRedmond


How to use:
There are multiple ways to use this function:
- Copy and paste function into current script
- Include script into existing script - e.g.  .\FinalEventViewerReaderWithDate.ps1
- Load function to memory and execute from memory


One can use the get-help fn_Log after the script is loaded into memory to see the synopsis, description, modification history and more... (aka doctype)

# Usage:
# Logging to a windows event log
# fn_Log -fn_LLogType "Windows" -fn_LLevel "Information" -fn_LMessage "Test message" -fn_LWindowsLog "Application" -fn_LSource "MyApp" -fn_LEventID 1001

# Logging to a file example
# fn_Log -fn_LLogType "File" -fn_LLevel "Error" -fn_LMessage "Error occurred" -fn_file "C:\path\to\log.txt" -fn_LSource "MyApp"
#>


    param (
        [string]$fn_LLogType,
        [string]$fn_file,
        [string]$fn_LLevel,
        [string]$fn_LMessage,
        [string]$fn_LWindowsLog,
        [string]$fn_LSource,
        [string]$fn_LEventID,
        [string]$fn_LTaskCategory
    )
    # Validate Level
    $validLevels = @("Error", "Warning", "Information", "Verbose")
    if ($fn_LLevel -notin $validLevels) {
        Write-Host "Error: Type passed to function is invalid. Exiting function"
        return -1
    }

    # Validate Message
    if (-not $fn_LMessage) {
        Write-Host "Error: Message is empty"
        return -1
    }

    # Validate Log Type
    if (-not $fn_LLogType) {
        Write-Host "Error: Log Type is empty"
        return -1
    }

    # Processing based on Log Type
    try {
        switch ($fn_LLogType) {
            "Windows" {
                if ($fn_LWindowsLog -notin @("Application", "Security", "Setup", "System")) {
                    throw "Specified Windows log is not valid."
                }
                Write-EventLog -LogName $fn_LWindowsLog -Source $fn_LSource -EntryType $fn_LLevel -EventID $fn_LEventID -Message $fn_LMessage
            }
            "File" {
                if (-not $fn_file) {
                    throw "File path is not provided for file logging."
                }
                $logMessage = "${fn_LSource};${fn_LLevel};${fn_LMessage}"
                Add-Content -Path $fn_file -Value $logMessage
            }
            default {
                throw "Invalid Log Type specified."
            }
        }
        return 0
    } catch {
        Write-Host "Error: $($_.Exception.Message)"
        return -1
    }
}


