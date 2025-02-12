#
# How to use this file:
# Insert the tests for each test scenario.
# Per the framework, this file is imported into your .Tests.ps1 script
# 

# Test Case 1 - Replaces tilde with sharp

It "Replaces tilde with sharp" {
    $myTest=fn_ChangelineTest -InputFile $script:pstrTestInputFile `
                              -OutputFile $script:pstrTestOutputFile `
                              -BeforeChange '~' -AfterChange '#' -ExpectedOutput 'Line 1: This is a test with #' `
                              -TestCaseName 'Test 1 - Replace Tilde with #' -Description 'Replaced ~ with # in Line 1' `
                              -ErrorMessage 'Test 1 Failed: Tilde was not replaced with #'

        try {

        $myTest.Status|should -Be "Passed"

        } catch {
        throw "Test 1 - Replace Tilde with #' -Description 'Replaced ~ with # in Line 1" 

        } # End of try catch

     
} # End of test case 1
#----


#----
# Test Case 2 Replaces BacktickTheReplacements with TildeTheReplacements
It "Replaces BacktickTheReplacements with TildeTheReplacements" {
    $myTest=fn_ChangelineTest -InputFile $script:pstrTestInputFile `
                          -OutputFile $script:pstrTestOutputFile `
                          -BeforeChange '`TheReplacements' -AfterChange '~TheReplacements' `
                          -ExpectedOutput 'Line 2: Another line with ~TheReplacements for backtick.' `
                          -TestCaseName 'Test 2 - Replace Backtick with Tilde' `
                          -Description 'Replaced `TheReplacements with ~TheReplacements in Line 2' `
                          -ErrorMessage 'Test 2 Failed: Backtick was not replaced with Tilde'
try {

$myTest.Status|should -Be "Passed"

} catch {
throw "Test 2 failed - Replace Backtick with Tilde" 

} # End of try catch


} # End of test case 2
#----


#----
# Test case 3 - Replaces tilde with ChangedTilde
It "Replaces tilde with ChangedTilde" {
    $myTest=fn_ChangelineTest -InputFile $script:pstrTestInputFile `
                            -OutputFile $script:pstrTestOutputFile `
                          -BeforeChange '~' -AfterChange 'ChangedTilde' `
                          -ExpectedOutput 'Line 3: This line contains a ChangedTilde (tilde).' `
                          -TestCaseName 'Test 3 - Replace Tilde with ChangedTilde' `
                          -Description 'Replaced ~ with ChangedTilde in Line 3' `
                          -ErrorMessage 'Test 3 Failed: Tilde was not replaced with ChangedTilde'

try {

$myTest.Status|should -Be "Passed"

} catch {
throw "Test case 3 Failed - Replaces tilde with ChangedTilde" 

} # End of try catch

} # End of test case 3



#----



#----
# Test Case 4


It "Test 4 Replace tilde with text behind it" {
$myTest=
    fn_ChangelineTest -InputFile ".\TestInput.txt" `
    -OutputFile ".\TestOutput.txt" `
    -BeforeChange '~TheTildeReplacement' `
    -AfterChange '!@#TILDREPLACEMENTWASHERE' `
    -ExpectedOutput 'Line 4: This line has !@#TILDREPLACEMENTWASHERE to be replaced' `
    -TestCaseName 'Test 4 Replace tilde with text behind it' `
    -Description 'Test 4 Replaces the tilde while retaining the text behind it' `
    -ErrorMessage 'Test 4 Failed: Tilde was not replaced correctly in line 4'`
    
    try {
        # Pester test with Should be
        # Remember to put throw in catch for pester to see it, otherwise it is assumed past even if there is an err
        $myTest.Status|should -Be "Passed"
    }
    catch {
        # dont forget, you have to throw the err for pester
        Throw "Failed Test 4 Replace tilde with text behind it"
        # Mytest failed to return a passed so pester failed
        write-host "Test 4 failed"
    }
    

} # End of Test 4
#----


#----
# Test Case 5
It "Test 5 Replace the backslash on line 5" {
    $mytest=fn_ChangelineTest -InputFile ".\TestInput.txt" `
    -OutputFile '.\TestOutput.txt' `
    -BeforeChange 'Line 5: A backslash \ in this line' `
    -AfterChange 'Line 5: A backslash !@# in this line.' `
    -ExpectedOutput 'Line 5: A backslash !@# in this line.' `
    -TestCaseName 'Test 5 Replace the backslash on line 5' `
    -Description 'Test 5 Replaces the backslash with !@#' `
    -ErrorMessage 'Test 5 Failed: Backslash was not replaced correctly'`

try {

$myTest.Status|should -Be "Passed"

} catch {
throw "Test 5 failed - Replace the backslash on line 5" 

}

    } # End of test case 5
#---

#----
# Test Case 6
It "Test 6 Replace Backslash with text" {
    $mytest=fn_ChangelineTest -InputFile ".\TestInput.txt" `
    -OutputFile '.\TestOutput.txt' `
    -BeforeChange 'Line 6: This is a \ThisisaBackslashTest to be' `
    -AfterChange 'Line 6: This is a  ThisisaBackslashTest to be' `
    -ExpectedOutput 'Line 6: This is a  ThisisaBackslashTest to be' `
    -TestCaseName 'Test 6 Line 6: This is a  ThisisaBackslashTest to be' `
    -Description 'Test 6 Replaces the backslash on Line 6' `
    -ErrorMessage 'Test 6 Failed: Backslash with trailing text was not replaced correctly'`

try {

$myTest.Status|should -Be "Passed"

} catch {
throw "Test 6 failed - Replaced backslash with a space on line 6" 

}

    } # End of test case 6

#----

#----
# Test 7 
It "Test 7Replaces the upper case word Pyracantha with the lower case p on Line 7" {
    $mytest=fn_ChangelineTest -InputFile ".\TestInput.txt" `
    -OutputFile '.\TestOutput.txt' `
    -BeforeChange 'Line 7: Pyracantha' `
    -AfterChange 'Line 7: pyracantha' `
    -ExpectedOutput 'Line 7: pyracantha' `
    -TestCaseName 'Test 7 Line 7: Change case of Pyracantha' `
    -Description 'Test 7 Replaces the upper case word Pyracantha with the lower case p on Line 7' `
    -ErrorMessage 'Test 7 Failed: lowercase p failed to replace upper case P in Pyracantha'`

try {
$myTest.Status|should -Be "Passed"
} catch {
throw "Test 7 failed - Replace p in Pyracantha with lowercase p" 
}
    } # End of test case 7

#----


#----
# Test 8
It "Test 8 - Replace Stuff with OrangeTrump" {
    $mytest=fn_ChangelineTest -InputFile ".\TestInput.txt" `
    -OutputFile '.\TestOutput.txt' `
    -BeforeChange 'Line 8: Stuff should remain or' `
    -AfterChange 'Line 8: Trump should remain' `
    -ExpectedOutput 'Line 8: Trump should remain' `
    -TestCaseName 'Test 8 - Replace Stuff with OrangeTrump' `
    -Description 'Test 8 - Replace Stuff with OrangeTrump' `
    -ErrorMessage 'Test 8 Failed: Test 8 - Replace Stuff with OrangeTrump' `

try {
$myTest.Status|should -Be "Passed"
} catch {
throw "Test 8 failed - Stuff was not replaced with OrangeTrump" 
}
    } # End of test case 8

