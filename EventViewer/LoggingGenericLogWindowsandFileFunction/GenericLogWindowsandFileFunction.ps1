function fn_Log {
    <#
    .SYNOPSIS
    Generic logging to Windows Event Log or a text file.
    
    .DESCRIPTION
    Writes an event to a classic Windows Event Log (Application/System/Setup) or appends
    a timestamped line to a UTF-8 text log file. Automatically creates the event source
    (if missing) when run elevated. Designed for use in scripts and functions.
    
    .PARAMETER fn_LLogType
    Target: 'Windows' or 'File'.
    
    .PARAMETER fn_file
    Full path to a log file when fn_LLogType is 'File'. Directory is created if needed.
    
    .PARAMETER fn_LLevel
    Log level/entry type. For Windows: Error, Warning, Information, SuccessAudit, FailureAudit.
    For File: same values, written as text.
    
    .PARAMETER fn_LMessage
    The message/body to log.
    
    .PARAMETER fn_LWindowsLog
    Windows classic log name (Application, System, Setup). Default: Application.
    
    .PARAMETER fn_LSource
    Event Source name (e.g. 'MyApp'). Required for Windows logging.
    
    .PARAMETER fn_LEventID
    Numeric Event ID. Default: 1000.
    
    .PARAMETER fn_LTaskCategory
    Numeric category. Optional; used only for Windows logging.
    
    .EXAMPLE
    fn_Log -fn_LLogType "Windows" -fn_LLevel "Information" -fn_LMessage "Started" -fn_LWindowsLog "Application" -fn_LSource MyApp -fn_LEventID "1001"
    
    .EXAMPLE
    fn_Log -fn_LLogType "File" -fn_LLevel "Error" -fn_LMessage "Something broke" -fn_file "C:\Logs\MyApp.log" -fn_LSource "MyApp"
    
    .NOTES
    Requires elevation to create a new Event Source. Writing to 'Security' is not supported by this function.
    #------------------------
    # Modification History
    #------------------------
    20250809 - TFR - refactored to Professor PowerShell standards
    20231016 - Maker - TedmondFromRedmond
    #>

    [CmdletBinding(SupportsShouldProcess = $false)]
        param(
            [Parameter(Mandatory)]
            [ValidateSet('Windows','File')]
            [string]$fn_LLogType,
    
            [Parameter(Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$fn_file,
    
            [Parameter(Mandatory)]
            [ValidateSet('Error','Warning','Information','SuccessAudit','FailureAudit')]
            [string]$fn_LLevel,
    
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$fn_LMessage,
    
            [Parameter(Mandatory = $false)]
            [ValidateSet('Application','System','Setup')]
            [string]$fn_LWindowsLog = 'Application',
    
            [Parameter(Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$fn_LSource = 'MyApp',
    
            [Parameter(Mandatory = $false)]
            [ValidateRange(1,65535)]
            [int]$fn_LEventID = 1000,
    
            [Parameter(Mandatory = $false)]
            [ValidateRange(0,32767)]
            [int]$fn_LTaskCategory = 0
        )
    
        try {
            switch ($fn_LLogType) {
                'Windows' {
                    # Ensure the Source exists and is bound to the requested log
                    $sourceExists = [System.Diagnostics.EventLog]::SourceExists($fn_LSource)
                    if (-not $sourceExists) {
                        # Creating a source requires elevation and a mapping to a specific log
                        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
                                 ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
                            throw "Event Source $fn_LSource does not exist and cannot be created without elevation. Run as Administrator once to register the source."
                        }
                        New-EventLog -LogName $fn_LWindowsLog -Source $fn_LSource
                    } else {
                        # Validate the existing source is mapped to the intended log (best-effort)
                        $srcLog = [System.Diagnostics.EventLog]::LogNameFromSourceName($fn_LSource, '.')
                        if ($srcLog -ne $fn_LWindowsLog) {
                            throw "Existing source $fn_LSource is mapped to $srcLog, not $fn_LWindowsLog. Use a different source or re-register it."
                        }
                    }
    
                    $params = @{
                        LogName   = $fn_LWindowsLog
                        Source    = $fn_LSource
                        EntryType = $fn_LLevel
                        EventId   = $fn_LEventID
                        Message   = $fn_LMessage
                    }
                    if ($PSBoundParameters.ContainsKey('fn_LTaskCategory')) {
                        $params['Category'] = [int16]$fn_LTaskCategory
                    }
                    Write-EventLog @params
                    Write-Verbose "Wrote event $($fn_LEventID) to $fn_LWindowsLog from $fn_LSource with level $fn_LLevel"
                }
    
                'File' {
                    if (-not $fn_file) {
                        throw "File path is required when fn_LLogType is 'File'."
                    }
                    $dir = Split-Path -Path $fn_file -Parent
                    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
                        New-Item -ItemType Directory -Path $dir -Force | Out-Null
                    }
    
                    $timestamp = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss.fffK')
                    $line = "$timestamp;$fn_LSource;$fn_LLevel;$fn_LMessage"
                    # Use UTF8 w/o BOM for broad compatibility
                    Add-Content -LiteralPath $fn_file -Value $line -Encoding utf8
                    Write-Verbose "Appended to $fn_file"
                }
            }
            return 0
        }
        catch {
            Write-Error $_.Exception.Message
            return -1
        }
    }
    