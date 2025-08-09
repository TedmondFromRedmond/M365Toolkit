<#
.SYNOPSIS
    Programmatic tests for fn_ChangeLine using the new -p_ReturnObject parameter
    
.DESCRIPTION
    This file contains Pester tests that demonstrate how to use fn_ChangeLine
    with the -p_ReturnObject parameter for programmatic testing and validation.
    
.NOTES
    Created: 2025-01-27
    Purpose: Demonstrate programmatic testing capabilities
#>

# Import the function
. "$PSScriptRoot\..\fn_Changeline.ps1"

Describe "fn_ChangeLine Programmatic Tests" {
    
    BeforeAll {
        # Create test files
        $script:testInputFile = "$PSScriptRoot\TestInput_Programmatic.txt"
        $script:testOutputFile = "$PSScriptRoot\TestOutput_Programmatic.txt"
        
        # Create test content
        @"
Line 1: This is a test with ~
Line 2: Another line with `TheReplacements for backtick.
Line 3: This line contains a ~ (tilde).
Line 4: This line has ~TheTildeReplacement to be replaced
Line 5: A backslash \ in this line.
Line 6: This is a \ThisisaBackslashTest to be
Line 7: Pyracantha
Line 8: Stuff should remain or
"@ | Set-Content -Path $script:testInputFile
    }
    
    AfterAll {
        # Clean up test files
        if (Test-Path $script:testInputFile) { Remove-Item $script:testInputFile -Force }
        if (Test-Path $script:testOutputFile) { Remove-Item $script:testOutputFile -Force }
    }
    
    Context "Basic Functionality with Return Object" {
        It "Should return structured object when -p_ReturnObject is specified" {
            $result = fn_ChangeLine -p_InputFile $script:testInputFile `
                                   -p_b4Change '~' `
                                   -p_AfterChange '#' `
                                   -p_OutputFile $script:testOutputFile `
                                   -p_ReturnObject
            
            $result | Should -Not -BeNullOrEmpty
            $result.Success | Should -Be $true
            $result.InputFile | Should -Be $script:testInputFile
            $result.OutputFile | Should -Be $script:testOutputFile
            $result.SearchString | Should -Be '~'
            $result.ReplacementString | Should -Be '#'
            $result.CaseSensitive | Should -Be $false
            $result.TotalLines | Should -Be 8
            $result.ChangesCount | Should -BeGreaterThan 0
            $result.Changes | Should -Not -BeNullOrEmpty
            $result.Timestamp | Should -Not -BeNullOrEmpty
        }
        
        It "Should return correct change details" {
            $result = fn_ChangeLine -p_InputFile $script:testInputFile `
                                   -p_b4Change '~' `
                                   -p_AfterChange '#' `
                                   -p_OutputFile $script:testOutputFile `
                                   -p_ReturnObject
            
            $result.Changes.Count | Should -Be 3  # Should find 3 tildes
            
            # Check first change
            $firstChange = $result.Changes[0]
            $firstChange.LineNumber | Should -Be 1
            $firstChange.OriginalLine | Should -Be "Line 1: This is a test with ~"
            $firstChange.ChangedLine | Should -Be "Line 1: This is a test with #"
            $firstChange.SearchString | Should -Be '~'
            $firstChange.ReplacementString | Should -Be '#'
        }
    }
    
    Context "Case Sensitivity Testing" {
        It "Should handle case-sensitive replacements correctly" {
            $result = fn_ChangeLine -p_InputFile $script:testInputFile `
                                   -p_b4Change 'Pyracantha' `
                                   -p_AfterChange 'pyracantha' `
                                   -p_OutputFile $script:testOutputFile `
                                   -p_CaseSensitive $true `
                                   -p_ReturnObject
            
            $result.Success | Should -Be $true
            $result.CaseSensitive | Should -Be $true
            $result.ChangesCount | Should -Be 1
            
            $change = $result.Changes[0]
            $change.OriginalLine | Should -Be "Line 7: Pyracantha"
            $change.ChangedLine | Should -Be "Line 7: pyracantha"
        }
        
        It "Should handle case-insensitive replacements correctly" {
            $result = fn_ChangeLine -p_InputFile $script:testInputFile `
                                   -p_b4Change 'pyracantha' `
                                   -p_AfterChange 'PYRACANTHA' `
                                   -p_OutputFile $script:testOutputFile `
                                   -p_CaseSensitive $false `
                                   -p_ReturnObject
            
            $result.Success | Should -Be $true
            $result.CaseSensitive | Should -Be $false
            $result.ChangesCount | Should -Be 1
            
            $change = $result.Changes[0]
            $change.OriginalLine | Should -Be "Line 7: Pyracantha"
            $change.ChangedLine | Should -Be "Line 7: PYRACANTHA"
        }
    }
    
    Context "Error Handling" {
        It "Should return error object when file doesn't exist" {
            $result = fn_ChangeLine -p_InputFile "NonExistentFile.txt" `
                                   -p_b4Change 'test' `
                                   -p_AfterChange 'new' `
                                   -p_OutputFile $script:testOutputFile `
                                   -p_ReturnObject
            
            $result.Success | Should -Be $false
            $result.Error | Should -Not -BeNullOrEmpty
            $result.ChangesCount | Should -Be 0
            $result.Changes | Should -BeNullOrEmpty
        }
    }
    
    Context "No Changes Scenario" {
        It "Should return success with zero changes when no matches found" {
            $result = fn_ChangeLine -p_InputFile $script:testInputFile `
                                   -p_b4Change 'XYZ123' `
                                   -p_AfterChange 'ABC456' `
                                   -p_OutputFile $script:testOutputFile `
                                   -p_ReturnObject
            
            $result.Success | Should -Be $true
            $result.ChangesCount | Should -Be 0
            $result.Changes | Should -BeNullOrEmpty
            $result.TotalLines | Should -Be 8
        }
    }
    
    Context "Special Characters" {
        It "Should handle backtick characters correctly" {
            $result = fn_ChangeLine -p_InputFile $script:testInputFile `
                                   -p_b4Change '`TheReplacements' `
                                   -p_AfterChange '~TheReplacements' `
                                   -p_OutputFile $script:testOutputFile `
                                   -p_ReturnObject
            
            $result.Success | Should -Be $true
            $result.ChangesCount | Should -Be 1
            
            $change = $result.Changes[0]
            $change.OriginalLine | Should -Be "Line 2: Another line with `TheReplacements for backtick."
            $change.ChangedLine | Should -Be "Line 2: Another line with ~TheReplacements for backtick."
        }
        
        It "Should handle backslash characters correctly" {
            $result = fn_ChangeLine -p_InputFile $script:testInputFile `
                                   -p_b4Change '\' `
                                   -p_AfterChange '!' `
                                   -p_OutputFile $script:testOutputFile `
                                   -p_ReturnObject
            
            $result.Success | Should -Be $true
            $result.ChangesCount | Should -Be 2  # Should find 2 backslashes
            
            # Check first backslash change
            $firstChange = $result.Changes[0]
            $firstChange.OriginalLine | Should -Be "Line 5: A backslash \ in this line."
            $firstChange.ChangedLine | Should -Be "Line 5: A backslash ! in this line."
        }
    }
    
    Context "Integration Testing" {
        It "Should validate output file content matches expected changes" {
            $result = fn_ChangeLine -p_InputFile $script:testInputFile `
                                   -p_b4Change 'Stuff' `
                                   -p_AfterChange 'Trump' `
                                   -p_OutputFile $script:testOutputFile `
                                   -p_ReturnObject
            
            $result.Success | Should -Be $true
            $result.ChangesCount | Should -Be 1
            
            # Verify the output file was created and contains expected content
            Test-Path $script:testOutputFile | Should -Be $true
            
            $outputContent = Get-Content $script:testOutputFile
            $outputContent[7] | Should -Be "Line 8: Trump should remain or"
        }
    }
} 