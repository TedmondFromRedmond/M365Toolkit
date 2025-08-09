<#
.SYNOPSIS
    Example script demonstrating programmatic testing with fn_ChangeLine
    
.DESCRIPTION
    This script shows how to use fn_ChangeLine with the -p_ReturnObject parameter
    for automated testing and validation in CI/CD pipelines.
    
.EXAMPLE
    .\ProgrammaticTestingExample.ps1
    
.NOTES
    Created: 2025-01-27
    Purpose: Demonstrate programmatic testing capabilities
#>

# Import the function
. "$PSScriptRoot\fn_Changeline.ps1"

Write-Host "=== fn_ChangeLine Programmatic Testing Example ===" -ForegroundColor Cyan

# Create test files
$testInputFile = "$PSScriptRoot\ExampleInput.txt"
$testOutputFile = "$PSScriptRoot\ExampleOutput.txt"

# Create sample input file
@"
# Configuration file
ServerName=dev-server-01
DatabaseName=dev-database
ConnectionString=Server=dev-server-01;Database=dev-database
Environment=Development
LogLevel=Debug
"@ | Set-Content -Path $testInputFile

Write-Host "Created test input file: $testInputFile" -ForegroundColor Green

# Example 1: Basic replacement with return object
Write-Host "`n=== Example 1: Basic Replacement ===" -ForegroundColor Yellow
$result1 = fn_ChangeLine -p_InputFile $testInputFile `
                        -p_b4Change "dev" `
                        -p_AfterChange "prod" `
                        -p_OutputFile $testOutputFile `
                        -p_ReturnObject

if ($result1.Success) {
    Write-Host "✓ Successfully processed file" -ForegroundColor Green
    Write-Host "  Total lines: $($result1.TotalLines)" -ForegroundColor White
    Write-Host "  Changes made: $($result1.ChangesCount)" -ForegroundColor White
    
    foreach ($change in $result1.Changes) {
        Write-Host "  Line $($change.LineNumber): '$($change.OriginalLine)' → '$($change.ChangedLine)'" -ForegroundColor Gray
    }
} else {
    Write-Host "✗ Failed to process file: $($result1.Error)" -ForegroundColor Red
}

# Example 2: Case-sensitive replacement
Write-Host "`n=== Example 2: Case-Sensitive Replacement ===" -ForegroundColor Yellow
$result2 = fn_ChangeLine -p_InputFile $testInputFile `
                        -p_b4Change "Development" `
                        -p_AfterChange "Production" `
                        -p_OutputFile $testOutputFile `
                        -p_CaseSensitive $true `
                        -p_ReturnObject

if ($result2.Success) {
    Write-Host "✓ Case-sensitive replacement completed" -ForegroundColor Green
    Write-Host "  Changes made: $($result2.ChangesCount)" -ForegroundColor White
} else {
    Write-Host "✗ Case-sensitive replacement failed: $($result2.Error)" -ForegroundColor Red
}

# Example 3: Validation and decision making
Write-Host "`n=== Example 3: Validation and Decision Making ===" -ForegroundColor Yellow
$result3 = fn_ChangeLine -p_InputFile $testInputFile `
                        -p_b4Change "Debug" `
                        -p_AfterChange "Info" `
                        -p_OutputFile $testOutputFile `
                        -p_ReturnObject

# Simulate CI/CD pipeline decision making
if ($result3.Success) {
    if ($result3.ChangesCount -gt 0) {
        Write-Host "✓ Changes detected - proceeding with deployment" -ForegroundColor Green
        Write-Host "  Modified $($result3.ChangesCount) line(s)" -ForegroundColor White
        
        # In a real scenario, you might:
        # - Commit changes to version control
        # - Trigger deployment pipeline
        # - Send notifications
        # - Update audit logs
        
    } else {
        Write-Host "ℹ No changes required - skipping deployment" -ForegroundColor Cyan
    }
} else {
    Write-Host "✗ Processing failed - stopping deployment" -ForegroundColor Red
    Write-Host "  Error: $($result3.Error)" -ForegroundColor Red
}

# Example 4: Batch processing multiple files
Write-Host "`n=== Example 4: Batch Processing ===" -ForegroundColor Yellow

# Create multiple test files
$testFiles = @(
    @{ Name = "config1.txt"; Content = "Server=dev1`nDatabase=devdb1" },
    @{ Name = "config2.txt"; Content = "Server=dev2`nDatabase=devdb2" },
    @{ Name = "config3.txt"; Content = "Server=dev3`nDatabase=devdb3" }
)

$batchResults = @()

foreach ($file in $testFiles) {
    $inputPath = "$PSScriptRoot\$($file.Name)"
    $outputPath = "$PSScriptRoot\output_$($file.Name)"
    
    # Create input file
    $file.Content | Set-Content -Path $inputPath
    
    # Process file
    $result = fn_ChangeLine -p_InputFile $inputPath `
                           -p_b4Change "dev" `
                           -p_AfterChange "prod" `
                           -p_OutputFile $outputPath `
                           -p_ReturnObject
    
    $batchResults += [PSCustomObject]@{
        FileName = $file.Name
        Success = $result.Success
        ChangesCount = $result.ChangesCount
        Error = $result.Error
    }
    
    # Clean up input file
    Remove-Item $inputPath -Force -ErrorAction SilentlyContinue
}

Write-Host "Batch processing results:" -ForegroundColor White
foreach ($batchResult in $batchResults) {
    $status = if ($batchResult.Success) { "✓" } else { "✗" }
    $color = if ($batchResult.Success) { "Green" } else { "Red" }
    Write-Host "  $status $($batchResult.FileName): $($batchResult.ChangesCount) changes" -ForegroundColor $color
}

# Example 5: Error handling demonstration
Write-Host "`n=== Example 5: Error Handling ===" -ForegroundColor Yellow
$errorResult = fn_ChangeLine -p_InputFile "NonExistentFile.txt" `
                            -p_b4Change "test" `
                            -p_AfterChange "new" `
                            -p_OutputFile "output.txt" `
                            -p_ReturnObject

if (-not $errorResult.Success) {
    Write-Host "✓ Error handling works correctly" -ForegroundColor Green
    Write-Host "  Error: $($errorResult.Error)" -ForegroundColor Gray
}

# Clean up
Write-Host "`n=== Cleanup ===" -ForegroundColor Yellow
if (Test-Path $testInputFile) { Remove-Item $testInputFile -Force }
if (Test-Path $testOutputFile) { Remove-Item $testOutputFile -Force }

# Clean up batch output files
Get-ChildItem -Path $PSScriptRoot -Filter "output_*.txt" | Remove-Item -Force

Write-Host "✓ Cleanup completed" -ForegroundColor Green
Write-Host "`n=== Programmatic Testing Example Complete ===" -ForegroundColor Cyan 