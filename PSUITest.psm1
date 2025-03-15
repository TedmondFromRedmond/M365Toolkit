<#
.SYNOPSIS
PowerShell UI Testing Framework - Core module
#>

# Define framework version and metadata
$script:FrameworkVersion = "1.0.0"
$script:FrameworkName = "PSUITest"

#region Core Types

# Add necessary types for UI automation
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class UIAutomation {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    
    [DllImport("user32.dll")]
    public static extern bool IsWindow(IntPtr hWnd);
    
    [DllImport("user32.dll")]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    
    [DllImport("user32.dll")]
    public static extern int GetWindowThreadProcessId(IntPtr hWnd, out int lpdwProcessId);
}
"@

# Add SendInput capability for reliable key sending
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class KeyboardInput {
    [DllImport("user32.dll")]
    public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

    public struct INPUT {
        public uint type;
        public INPUTUNION union;
    }

    [StructLayout(LayoutKind.Explicit)]
    public struct INPUTUNION {
        [FieldOffset(0)] public MOUSEINPUT mi;
        [FieldOffset(0)] public KEYBDINPUT ki;
        [FieldOffset(0)] public HARDWAREINPUT hi;
    }

    public struct MOUSEINPUT {
        public int dx;
        public int dy;
        public uint mouseData;
        public uint dwFlags;
        public uint time;
        public IntPtr dwExtraInfo;
    }

    public struct KEYBDINPUT {
        public ushort wVk;
        public ushort wScan;
        public uint dwFlags;
        public uint time;
        public IntPtr dwExtraInfo;
    }

    public struct HARDWAREINPUT {
        public uint uMsg;
        public ushort wParamL;
        public ushort wParamH;
    }

    // Constants for keyboard input
    public const uint INPUT_KEYBOARD = 1;
    public const uint KEYEVENTF_KEYDOWN = 0x0000;
    public const uint KEYEVENTF_KEYUP = 0x0002;
}
"@

#endregion

#region Test Case Management

class UITestCase {
    [string]$Name
    [string]$Description
    [ScriptBlock]$Setup
    [ScriptBlock]$Test
    [ScriptBlock]$Cleanup
    [bool]$Passed
    [string]$ErrorMessage
    [System.Collections.ArrayList]$Steps
    [DateTime]$StartTime
    [DateTime]$EndTime
    [TimeSpan]$Duration

    UITestCase([string]$name) {
        $this.Name = $name
        $this.Steps = [System.Collections.ArrayList]::new()
        $this.Passed = $false
    }

    [void]AddStep([string]$description, [ScriptBlock]$action) {
        $step = [PSCustomObject]@{
            Description = $description
            Action = $action
            Result = $null
            Passed = $false
            ErrorMessage = $null
        }
        $this.Steps.Add($step) | Out-Null
    }

    [bool]Run() {
        $this.StartTime = Get-Date
        
        try {
            # Run setup
            if ($this.Setup) {
                & $this.Setup
            }
            
            # Run test
            if ($this.Test) {
                & $this.Test
            }
            
            # Run all steps in sequence
            foreach ($step in $this.Steps) {
                try {
                    $step.Result = & $step.Action
                    $step.Passed = $true
                }
                catch {
                    $step.ErrorMessage = $_.Exception.Message
                    $step.Passed = $false
                    throw
                }
            }
            
            $this.Passed = $true
        }
        catch {
            $this.ErrorMessage = $_.Exception.Message
            $this.Passed = $false
        }
        finally {
            # Always run cleanup
            if ($this.Cleanup) {
                try {
                    & $this.Cleanup
                }
                catch {
                    Write-Warning "Cleanup failed: $($_.Exception.Message)"
                }
            }
            
            $this.EndTime = Get-Date
            $this.Duration = $this.EndTime - $this.StartTime
        }
        
        return $this.Passed
    }
}

class UITestSuite {
    [string]$Name
    [System.Collections.ArrayList]$TestCases
    [int]$PassCount
    [int]$FailCount
    [DateTime]$StartTime
    [DateTime]$EndTime
    [TimeSpan]$Duration

    UITestSuite([string]$name) {
        $this.Name = $name
        $this.TestCases = [System.Collections.ArrayList]::new()
        $this.PassCount = 0
        $this.FailCount = 0
    }

    [void]AddTestCase([UITestCase]$testCase) {
        $this.TestCases.Add($testCase) | Out-Null
    }

    [void]Run() {
        $this.StartTime = Get-Date
        
        foreach ($testCase in $this.TestCases) {
            $result = $testCase.Run()
            if ($result) {
                $this.PassCount++
            }
            else {
                $this.FailCount++
            }
        }
        
        $this.EndTime = Get-Date
        $this.Duration = $this.EndTime - $this.StartTime
    }

    [void]GenerateReport([string]$outputPath) {
        $reportData = [PSCustomObject]@{
            SuiteName = $this.Name
            TotalTests = $this.TestCases.Count
            PassedTests = $this.PassCount
            FailedTests = $this.FailCount
            StartTime = $this.StartTime
            EndTime = $this.EndTime
            Duration = $this.Duration
            TestResults = $this.TestCases | ForEach-Object {
                [PSCustomObject]@{
                    Name = $_.Name
                    Description = $_.Description
                    Passed = $_.Passed
                    ErrorMessage = $_.ErrorMessage
                    Duration = $_.Duration
                    Steps = $_.Steps | ForEach-Object {
                        [PSCustomObject]@{
                            Description = $_.Description
                            Passed = $_.Passed
                            ErrorMessage = $_.ErrorMessage
                        }
                    }
                }
            }
        }
        
        $reportData | ConvertTo-Json -Depth 5 | Out-File -FilePath $outputPath
        
        # Generate HTML report
        $htmlPath = [System.IO.Path]::ChangeExtension($outputPath, "html")
        $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>UI Test Results: $($this.Name)</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #2c3e50; }
        .summary { background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .success { color: #28a745; }
        .failure { color: #dc3545; }
        .test-case { border: 1px solid #dee2e6; padding: 15px; margin-bottom: 10px; border-radius: 5px; }
        .step { margin-left: 20px; padding: 5px; }
    </style>
</head>
<body>
    <h1>Test Results: $($this.Name)</h1>
    <div class="summary">
        <p>Total Tests: $($this.TestCases.Count)</p>
        <p>Passed Tests: <span class="success">$($this.PassCount)</span></p>
        <p>Failed Tests: <span class="failure">$($this.FailCount)</span></p>
        <p>Duration: $($this.Duration.ToString())</p>
    </div>
    
    <h2>Test Cases</h2>
"@

        foreach ($testCase in $this.TestCases) {
            $statusClass = if ($testCase.Passed) { "success" } else { "failure" }
            $status = if ($testCase.Passed) { "PASSED" } else { "FAILED" }
            
            $html += @"
    <div class="test-case">
        <h3>$($testCase.Name) - <span class="$statusClass">$status</span></h3>
        <p>$($testCase.Description)</p>
        <p>Duration: $($testCase.Duration.ToString())</p>
"@
            if (-not $testCase.Passed) {
                $html += @"
        <p class="failure">Error: $($testCase.ErrorMessage)</p>
"@
            }
            
            if ($testCase.Steps.Count -gt 0) {
                $html += @"
        <h4>Steps:</h4>
"@
                foreach ($step in $testCase.Steps) {
                    $stepStatusClass = if ($step.Passed) { "success" } else { "failure" }
                    $stepStatus = if ($step.Passed) { "PASSED" } else { "FAILED" }
                    $html += @"
        <div class="step">
            <p>$($step.Description) - <span class="$stepStatusClass">$stepStatus</span></p>
"@
                    if (-not $step.Passed) {
                        $html += @"
            <p class="failure">Error: $($step.ErrorMessage)</p>
"@
                    }
                    $html += @"
        </div>
"@
                }
            }
            
            $html += @"
    </div>
"@
        }
        
        $html += @"
</body>
</html>
"@
        
        $html | Out-File -FilePath $htmlPath
    }
}

#endregion

#region UI Automation Functions

function New-UITestSuite {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    
    return [UITestSuite]::new($Name)
}

function New-UITestCase {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [Parameter()]
        [string]$Description,
        
        [Parameter()]
        [ScriptBlock]$Setup,
        
        [Parameter()]
        [ScriptBlock]$Test,
        
        [Parameter()]
        [ScriptBlock]$Cleanup
    )
    
    $testCase = [UITestCase]::new($Name)
    $testCase.Description = $Description
    $testCase.Setup = $Setup
    $testCase.Test = $Test
    $testCase.Cleanup = $Cleanup
    
    return $testCase
}

function Start-UIProcess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        
        [Parameter()]
        [string]$Arguments,
        
        [Parameter()]
        [string]$WindowTitle,
        
        [Parameter()]
        [int]$WaitSeconds = 5
    )
    
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $FilePath
    if ($Arguments) {
        $startInfo.Arguments = $Arguments
    }
    $startInfo.UseShellExecute = $true
    
    $process = [System.Diagnostics.Process]::Start($startInfo)
    
    if ($WaitSeconds -gt 0) {
        Start-Sleep -Seconds $WaitSeconds
    }
    
    if ($WindowTitle) {
        $process.WaitForInputIdle() | Out-Null
        Start-Sleep -Seconds 1  # Additional time for window title to update
        $process.Refresh()
        
        # Find window by title if process doesn't have it
        if ($process.MainWindowHandle -eq 0 -or $process.MainWindowTitle -ne $WindowTitle) {
            $hWnd = [UIAutomation]::FindWindow($null, $WindowTitle)
            if ($hWnd -ne 0) {
                $processId = 0
                [UIAutomation]::GetWindowThreadProcessId($hWnd, [ref]$processId) | Out-Null
                $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
            }
        }
    }
    
    return $process
}

function Invoke-UIWindowActivate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$WindowHandle
    )
    
    if (-not [UIAutomation]::IsWindow([IntPtr]$WindowHandle)) {
        throw "Invalid window handle: $WindowHandle"
    }
    
    $result = [UIAutomation]::SetForegroundWindow([IntPtr]$WindowHandle)
    if (-not $result) {
        throw "Failed to activate window: $WindowHandle"
    }
    
    Start-Sleep -Milliseconds 500  # Give window time to activate
    return $result
}

function Send-UIKeys {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$WindowHandle,
        
        [Parameter(Mandatory = $true)]
        [string]$Keys,
        
        [Parameter()]
        [switch]$UseNative,
        
        [Parameter()]
        [int]$DelayMilliseconds = 50
    )
    
    if (-not [UIAutomation]::IsWindow([IntPtr]$WindowHandle)) {
        throw "Invalid window handle: $WindowHandle"
    }
    
    # Activate window first
    $activated = Invoke-UIWindowActivate -WindowHandle $WindowHandle
    if (-not $activated) {
        throw "Failed to activate window before sending keys"
    }
    
    if ($UseNative) {
        # Use low-level SendInput for more reliable key sending
        # This is a simplified implementation - a full one would map all keys
        $inputs = @()
        
        foreach ($char in $Keys.ToCharArray()) {
            $vKey = [int][System.Windows.Forms.Keys]::$char
            
            # Key down
            $keyDown = New-Object KeyboardInput+INPUT
            $keyDown.type = [KeyboardInput]::INPUT_KEYBOARD
            $keyDown.union.ki.wVk = $vKey
            $keyDown.union.ki.dwFlags = [KeyboardInput]::KEYEVENTF_KEYDOWN
            $inputs += $keyDown
            
            # Key up
            $keyUp = New-Object KeyboardInput+INPUT
            $keyUp.type = [KeyboardInput]::INPUT_KEYBOARD
            $keyUp.union.ki.wVk = $vKey
            $keyUp.union.ki.dwFlags = [KeyboardInput]::KEYEVENTF_KEYUP
            $inputs += $keyUp
            
            if ($DelayMilliseconds -gt 0) {
                Start-Sleep -Milliseconds $DelayMilliseconds
            }
        }
        
        $inputSize = [System.Runtime.InteropServices.Marshal]::SizeOf([KeyboardInput+INPUT]::new())
        [KeyboardInput]::SendInput($inputs.Length, $inputs, $inputSize)
    }
    else {
        # Use SendKeys for more complex key sequences
        Add-Type -AssemblyName System.Windows.Forms
        $wshell = New-Object -ComObject WScript.Shell
        
        # Break the string into smaller chunks to help reliability
        $chunks = [regex]::Matches($Keys, '.{1,10}|.+$')
        foreach ($chunk in $chunks) {
            $wshell.SendKeys($chunk.Value)
            
            if ($DelayMilliseconds -gt 0) {
                Start-Sleep -Milliseconds $DelayMilliseconds
            }
        }
    }
    
    return $true
}

function Wait-UIWindowProperty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$WindowHandle,
        
        [Parameter(Mandatory = $true)]
        [string]$PropertyName,
        
        [Parameter(Mandatory = $true)]
        [string]$PropertyValue,
        
        [Parameter()]
        [int]$TimeoutSeconds = 30,
        
        [Parameter()]
        [int]$PollIntervalMilliseconds = 500
    )
    
    $startTime = Get-Date
    $endTime = $startTime.AddSeconds($TimeoutSeconds)
    
    while ((Get-Date) -lt $endTime) {
        if (-not [UIAutomation]::IsWindow([IntPtr]$WindowHandle)) {
            throw "Window handle is no longer valid"
        }
        
        # Get the current property value
        $process = $null
        $processId = 0
        [UIAutomation]::GetWindowThreadProcessId([IntPtr]$WindowHandle, [ref]$processId) | Out-Null
        if ($processId -gt 0) {
            $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
        }
        
        if ($process) {
            $currentValue = $process.$PropertyName
            if ($currentValue -eq $PropertyValue) {
                return $true
            }
        }
        
        Start-Sleep -Milliseconds $PollIntervalMilliseconds
    }
    
    throw "Timed out waiting for window property '$PropertyName' to be '$PropertyValue'"
}

function Wait-UIFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        
        [Parameter()]
        [int]$TimeoutSeconds = 30,
        
        [Parameter()]
        [int]$PollIntervalMilliseconds = 500
    )
    
    $startTime = Get-Date
    $endTime = $startTime.AddSeconds($TimeoutSeconds)
    
    while ((Get-Date) -lt $endTime) {
        if (Test-Path -Path $FilePath) {
            return $true
        }
        
        Start-Sleep -Milliseconds $PollIntervalMilliseconds
    }
    
    throw "Timed out waiting for file to exist: $FilePath"
}

function Test-UIFileContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        
        [Parameter()]
        [string]$Contains,
        
        [Parameter()]
        [string]$Matches,
        
        [Parameter()]
        [scriptblock]$Validator
    )
    
    if (-not (Test-Path -Path $FilePath)) {
        throw "File does not exist: $FilePath"
    }
    
    $content = Get-Content -Path $FilePath -Raw
    
    if ($Contains -and $content -notlike "*$Contains*") {
        throw "File content does not contain: $Contains"
    }
    
    if ($Matches -and $content -notmatch $Matches) {
        throw "File content does not match pattern: $Matches"
    }
    
    if ($Validator) {
        $result = $content | ForEach-Object -Process $Validator
        if (-not $result) {
            throw "File content failed custom validation"
        }
    }
    
    return $true
}

function Get-UIProcessWindows {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ProcessId
    )
    
    Add-Type @"
    using System;
    using System.Text;
    using System.Runtime.InteropServices;
    using System.Collections.Generic;
    
    public class WindowFinder {
        [DllImport("user32.dll")]
        public static extern bool EnumWindows(EnumWindowsProc enumProc, IntPtr lParam);
        
        [DllImport("user32.dll")]
        public static extern int GetWindowThreadProcessId(IntPtr hWnd, out int lpdwProcessId);
        
        [DllImport("user32.dll")]
        public static extern bool IsWindowVisible(IntPtr hWnd);
        
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
        
        public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
        
        public static List<WindowInfo> GetProcessWindows(int processId) {
            var result = new List<WindowInfo>();
            EnumWindows(delegate(IntPtr hWnd, IntPtr lParam) {
                int pid;
                GetWindowThreadProcessId(hWnd, out pid);
                if (pid == processId && IsWindowVisible(hWnd)) {
                    StringBuilder sb = new StringBuilder(256);
                    GetWindowText(hWnd, sb, 256);
                    result.Add(new WindowInfo { 
                        Handle = hWnd.ToInt32(), 
                        Title = sb.ToString(),
                        ProcessId = pid
                    });
                }
                return true;
            }, IntPtr.Zero);
            return result;
        }
    }
    
    public class WindowInfo {
        public int Handle { get; set; }
        public string Title { get; set; }
        public int ProcessId { get; set; }
    }
"@
    
    $windows = [WindowFinder]::GetProcessWindows($ProcessId)
    return $windows
}

function Find-UIWindowByTitle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,
        
        [Parameter()]
        [switch]$ExactMatch
    )
    
    Add-Type @"
    using System;
    using System.Text;
    using System.Runtime.InteropServices;
    
    public class WindowSearch {
        [DllImport("user32.dll")]
        public static extern bool EnumWindows(EnumWindowsProc enumProc, IntPtr lParam);
        
        [DllImport("user32.dll")]
        public static extern bool IsWindowVisible(IntPtr hWnd);
        
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
        
        [DllImport("user32.dll")]
        public static extern int GetWindowThreadProcessId(IntPtr hWnd, out int lpdwProcessId);
        
        public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
        
        public static WindowInfo FindWindow(string title, bool exactMatch) {
            WindowInfo result = null;
            
            EnumWindows(delegate(IntPtr hWnd, IntPtr lParam) {
                if (IsWindowVisible(hWnd)) {
                    StringBuilder sb = new StringBuilder(256);
                    GetWindowText(hWnd, sb, 256);
                    string windowTitle = sb.ToString();
                    
                    bool match = exactMatch ? 
                        windowTitle.Equals(title) : 
                        windowTitle.Contains(title);
                        
                    if (match) {
                        int pid = 0;
                        GetWindowThreadProcessId(hWnd, out pid);
                        result = new WindowInfo { 
                            Handle = hWnd.ToInt32(), 
                            Title = windowTitle,
                            ProcessId = pid
                        };
                        return false; // Stop enumeration
                    }
                }
                return true; // Continue enumeration
            }, IntPtr.Zero);
            
            return result;
        }
    }
    
    public class WindowInfo {
        public int Handle { get; set; }
        public string Title { get; set; }
        public int ProcessId { get; set; }
    }
"@
    
    $window = [WindowSearch]::FindWindow($Title, $ExactMatch)
    return $window
}

#endregion

# Export functions
Export-ModuleMember -Function New-UITestSuite, New-UITestCase, Start-UIProcess, Invoke-UIWindowActivate, 
    Send-UIKeys, Wait-UIWindowProperty, Wait-UIFile, Test-UIFileContent, 
    Get-UIProcessWindows, Find-UIWindowByTitle 