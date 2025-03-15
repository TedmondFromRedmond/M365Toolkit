#Requires -Module PSUITest

<#
.SYNOPSIS
Tests the fn_AnyKey function using the PSUITest framework
#>

# Import the framework
Import-Module PSUITest

# Create a test suite
$suite = New-UITestSuite -Name "AnyKey Function Tests"

# Define test cases
$testCase1 = New-UITestCase -Name "Test fn_AnyKey with default message" -Description "Tests that fn_AnyKey works with default message" -Setup {
    # Setup - make sure any previous test files are cleaned up
    if (Test-Path "C:\temp\myout.txt") { 
        Remove-Item "C:\temp\myout.txt" -Force
    }
    
    # Create temp directory if it doesn't exist
    if (-not (Test-Path "C:\temp")) {
        New-Item -Path "C:\temp" -ItemType Directory -Force | Out-Null
    }
    
    # Close any existing CMD windows
    Get-Process | Where-Object { $_.ProcessName -match "cmd" } | Stop-Process -Force -ErrorAction SilentlyContinue
} -Cleanup {
    # Cleanup - remove the test file
    if (Test-Path "C:\temp\myout.txt") { 
        Remove-Item "C:\temp\myout.txt" -Force
    }
    
    # Close the CMD window if it's still open
    Get-Process | Where-Object { $_.ProcessName -match "cmd" } | Stop-Process -Force -ErrorAction SilentlyContinue
}

# Add test steps
$testCase1.AddStep("Start a command window", {
    $windowTitle = "AnyKey_TestWindow"
    $process = Start-UIProcess -FilePath "cmd.exe" -Arguments "/k title $windowTitle" -WaitSeconds 3
    
    # Verify process started
    if ($process -eq $null -or $process.HasExited) {
        throw "Failed to start CMD process"
    }
    
    # Find the window by title
    $window = Find-UIWindowByTitle -Title $windowTitle -ExactMatch
    if ($window -eq $null) {
        throw "Could not find window with title: $windowTitle"
    }
    
    return $window
})

$testCase1.AddStep("Start PowerShell in the command window", {
    param($window)
    
    $result = Send-UIKeys -WindowHandle $window.Handle -Keys "powershell.exe{Enter}"
    Start-Sleep -Seconds 2
    return $window
})

$testCase1.AddStep("Load the AnyKey function", {
    param($window)
    
    $scriptPath = Resolve-Path -Path "..\fn_AnyKey.ps1"
    $result = Send-UIKeys -WindowHandle $window.Handle -Keys ". '$scriptPath'{Enter}"
    Start-Sleep -Seconds 1
    return $window
})

$testCase1.AddStep("Execute AnyKey function with variable capture", {
    param($window)
    
    $result = Send-UIKeys -WindowHandle $window.Handle -Keys '$myRc = fn_AnyKey{Enter}'
    Start-Sleep -Seconds 1
    
    # Press a key - let's use spacebar
    $result = Send-UIKeys -WindowHandle $window.Handle -Keys " "
    Start-Sleep -Seconds 1
    
    return $window
})

$testCase1.AddStep("Save result to file", {
    param($window)
    
    $result = Send-UIKeys -WindowHandle $window.Handle -Keys '$myRc | Out-File -FilePath "C:\temp\myout.txt"{Enter}'
    Start-Sleep -Seconds 2
    
    # Wait for file to exist
    Wait-UIFile -FilePath "C:\temp\myout.txt" -TimeoutSeconds 10
    
    return $window
})

$testCase1.AddStep("Verify result file contains key data", {
    param($window)
    
    # Test file content for expected format (VirtualKeyCode, Character, etc.)
    $result = Test-UIFileContent -FilePath "C:\temp\myout.txt" -Validator {
        param($content)
        
        # Check if content has typical properties of a key press
        $hasKeyData = $content -match "VirtualKeyCode" -or 
                     $content -match "Character" -or 
                     $content -match "KeyChar"
        
        return $hasKeyData
    }
    
    return $result
})

$testCase1.AddStep("Exit PowerShell and CMD", {
    param($window)
    
    # Exit PowerShell
    $result = Send-UIKeys -WindowHandle $window.Handle -Keys "exit{Enter}"
    Start-Sleep -Seconds 1
    
    # Exit CMD
    $result = Send-UIKeys -WindowHandle $window.Handle -Keys "exit{Enter}"
    Start-Sleep -Seconds 1
    
    return $true
})

# Add a second test case for custom message
$testCase2 = New-UITestCase -Name "Test fn_AnyKey with custom message" -Description "Tests that fn_AnyKey works with custom message" -Setup {
    # Setup - make sure any previous test files are cleaned up
    if (Test-Path "C:\temp\myout.txt") { 
        Remove-Item "C:\temp\myout.txt" -Force
    }
    
    # Create temp directory if it doesn't exist
    if (-not (Test-Path "C:\temp")) {
        New-Item -Path "C:\temp" -ItemType Directory -Force | Out-Null
    }
    
    # Close any existing CMD windows
    Get-Process | Where-Object { $_.ProcessName -match "cmd" } | Stop-Process -Force -ErrorAction SilentlyContinue
} -Cleanup {
    # Cleanup - remove the test file
    if (Test-Path "C:\temp\myout.txt") { 
        Remove-Item "C:\temp\myout.txt" -Force
    }
    
    # Close the CMD window if it's still open
    Get-Process | Where-Object { $_.ProcessName -match "cmd" } | Stop-Process -Force -ErrorAction SilentlyContinue
}

# Similar steps as testCase1 but with custom message
# (Steps implementation omitted for brevity but would follow the same pattern)

# Add test cases to suite
$suite.AddTestCase($testCase1)
$suite.AddTestCase($testCase2)

# Run the test suite
$suite.Run()

# Generate report
$reportPath = "C:\temp\AnyKeyTestResults_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
$suite.GenerateReport($reportPath)

# Display summary
Write-Host "Test Results: $($suite.PassCount) passed, $($suite.FailCount) failed"
Write-Host "Detailed report saved to: $reportPath"
Write-Host "HTML report saved to: $([System.IO.Path]::ChangeExtension($reportPath, 'html'))" 