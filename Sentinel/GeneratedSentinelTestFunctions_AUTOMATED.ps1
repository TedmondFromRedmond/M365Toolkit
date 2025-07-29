<#
🔁 Reusable Prompt for PowerShell Function Generation — Extended Version
Professor PowerShell, I am uploading an Excel file and a PowerShell function template.
Please perform the following tasks exactly as described below:

🔧 Inputs:
The Excel file contains the following relevant columns:

TestIndex  
Synopsis  
Textbox  
MergeCheckbox=$true  
SplitCheckbox=$true  
CommasCheckbox=$true  
SemicolonsCheckbox=$true  
CustomDelimiterTextBox  
ExpectedClipboardValue   ⬅️ (new)  
ExpectedReturnValue      ⬅️ (new)

The PowerShell function template I am using is:

#################################
function Template creation

function Test_1_Merge_commas {
    fn_LogThatMessage -pOutMessage "Starting [Insert TestIndex row Value here] and [Insert Synopsis row value here]" -ploglevel Info

    write-host
    Write-Host "[Insert Synopsis column here]..."
    write-host

    $ui = [PSCustomObject]@{
        CommaCheckbox          = fn_New-MockCheckBox -checked $true
        CustomDelimiterTextBox = [PSCustomObject]@{ Text = '' }
        MergeCheckbox          = fn_New-MockCheckBox -checked $true
        SemicolonCheckbox      = fn_New-MockCheckBox -checked $false
        SplitCheckbox          = fn_New-MockCheckBox -checked $false
        TextBox                = [PSCustomObject]@{ Text = "[insert from Textbox column]"; Lines = @("[insert from Textbox column]") }
    }

    $result = fn_Invoke-SentinelApplyTransformation -ui $ui

    Write-Host "[RESULT] Test Index 1, Expected: [Insert ExpectedClipboardValue column], Returned: $result"
    "`n"

    fn_LogThatMessage -pOutMessage "Ending [Insert TestIndex row Value here] and [Insert Synopsis row value here]" -ploglevel Info
}
#################################

🛠️ Instructions:
For each row in the Excel file, generate a separate PowerShell function using the template.

Replace the following placeholders in the template:
- [Insert TestIndex row Value here]
- [Insert Synopsis row value here]
- [Insert from Textbox column]
- [Insert ExpectedClipboardValue column]
- Update the `-checked` state of checkboxes based on corresponding boolean columns

Function name format must be:
Test_<TestIndex>_<SanitizedSynopsis>

Where:
- Sanitize `Synopsis` by converting to lowercase,
- Remove commas,
- Replace spaces with underscores

DO NOT add, remove, or modify any logic outside of the placeholders. No assumptions — use only the template as-is.

Generate all functions and place them in a single downloadable .ps1 file.

#>


#################################
function Test_1_merge_commas {
    fn_LogThatMessage -pOutMessage "Starting 1 and Merge, commas" -ploglevel Info

    write-host
    Write-Host "Merge, commas..."
    write-host

    $ui = [PSCustomObject]@{
        CommaCheckbox          = fn_New-MockCheckBox -checked $true
        CustomDelimiterTextBox = [PSCustomObject]@{ Text = '' }
        MergeCheckbox          = fn_New-MockCheckBox -checked $true
        SemicolonCheckbox      = fn_New-MockCheckBox -checked $false
        SplitCheckbox          = fn_New-MockCheckBox -checked $false
        TextBox                = [PSCustomObject]@{ Text = "1 2 3"; Lines = @("1", "2", "3") }
    }

    $result = fn_Invoke-SentinelApplyTransformation -ui $ui

    Write-Host "[RESULT] Test Index 1, Expected: 1,2,3,4,5, Returned: $result"
    "`n"

    fn_LogThatMessage -pOutMessage "Ending 1 and Merge, commas" -ploglevel Info
}
#################################


#################################
function Test_2_split_commas {
    fn_LogThatMessage -pOutMessage "Starting 2 and Split, commas" -ploglevel Info

    write-host
    Write-Host "Split, commas..."
    write-host

    $ui = [PSCustomObject]@{
        CommaCheckbox          = fn_New-MockCheckBox -checked $true
        CustomDelimiterTextBox = [PSCustomObject]@{ Text = '' }
        MergeCheckbox          = fn_New-MockCheckBox -checked $false
        SemicolonCheckbox      = fn_New-MockCheckBox -checked $false
        SplitCheckbox          = fn_New-MockCheckBox -checked $true
        TextBox                = [PSCustomObject]@{ Text = "1,2,3,4,5"; Lines = @("1,2,3,4,5") }
    }

    $result = fn_Invoke-SentinelApplyTransformation -ui $ui

    Write-Host "[RESULT] Test Index 2, Expected: 1,2,3,4,5, Returned: $result"
    "`n"

    fn_LogThatMessage -pOutMessage "Ending 2 and Split, commas" -ploglevel Info
}
#################################


#################################
function Test_3_merge_semicolons {
    fn_LogThatMessage -pOutMessage "Starting 3 and Merge, Semicolons" -ploglevel Info

    write-host
    Write-Host "Merge, Semicolons..."
    write-host

    $ui = [PSCustomObject]@{
        CommaCheckbox          = fn_New-MockCheckBox -checked $false
        CustomDelimiterTextBox = [PSCustomObject]@{ Text = '' }
        MergeCheckbox          = fn_New-MockCheckBox -checked $true
        SemicolonCheckbox      = fn_New-MockCheckBox -checked $true
        SplitCheckbox          = fn_New-MockCheckBox -checked $false
        TextBox                = [PSCustomObject]@{ Text = "1 2 3 4 5"; Lines = @("1", "2", "3", "4", "5") }
    }

    $result = fn_Invoke-SentinelApplyTransformation -ui $ui

    Write-Host "[RESULT] Test Index 3, Expected: 1,2,3,4,5, Returned: $result"
    "`n"

    fn_LogThatMessage -pOutMessage "Ending 3 and Merge, Semicolons" -ploglevel Info
}
#################################


#################################
function Test_4_split_semicolons {
    fn_LogThatMessage -pOutMessage "Starting 4 and Split, Semicolons" -ploglevel Info

    write-host
    Write-Host "Split, Semicolons..."
    write-host

    $ui = [PSCustomObject]@{
        CommaCheckbox          = fn_New-MockCheckBox -checked $false
        CustomDelimiterTextBox = [PSCustomObject]@{ Text = '' }
        MergeCheckbox          = fn_New-MockCheckBox -checked $false
        SemicolonCheckbox      = fn_New-MockCheckBox -checked $true
        SplitCheckbox          = fn_New-MockCheckBox -checked $true
        TextBox                = [PSCustomObject]@{ Text = "1;2;3;4;5"; Lines = @("1;2;3;4;5") }
    }

    $result = fn_Invoke-SentinelApplyTransformation -ui $ui

    Write-Host "[RESULT] Test Index 4, Expected: 1,2,3,4,5, Returned: $result"
    "`n"

    fn_LogThatMessage -pOutMessage "Ending 4 and Split, Semicolons" -ploglevel Info
}
#################################


#################################
function Test_5_merge_custom {
    fn_LogThatMessage -pOutMessage "Starting 5 and Merge, Custom" -ploglevel Info

    write-host
    Write-Host "Merge, Custom..."
    write-host

    $ui = [PSCustomObject]@{
        CommaCheckbox          = fn_New-MockCheckBox -checked $false
        CustomDelimiterTextBox = [PSCustomObject]@{ Text = '!' }
        MergeCheckbox          = fn_New-MockCheckBox -checked $true
        SemicolonCheckbox      = fn_New-MockCheckBox -checked $false
        SplitCheckbox          = fn_New-MockCheckBox -checked $false
        TextBox                = [PSCustomObject]@{ Text = "1 2 3 4 5 "; Lines = @("1 2 3 4 5 ") }
    }

    $result = fn_Invoke-SentinelApplyTransformation -ui $ui

    Write-Host "[RESULT] Test Index 5, Expected: 1,2,3,4,5, Returned: $result"
    "`n"

    fn_LogThatMessage -pOutMessage "Ending 5 and Merge, Custom" -ploglevel Info
}
#################################


#################################
function Test_6_reset_button_clears_checkboxes_and_text_area_and_does_not_affect_clipboard {
    fn_LogThatMessage -pOutMessage "Starting 6 and Reset button clears checkboxes and text area and does not affect clipboard" -ploglevel Info

    write-host
    Write-Host "Reset button clears checkboxes and text area and does not affect clipboard..."
    write-host

    $ui = [PSCustomObject]@{
        CommaCheckbox          = fn_New-MockCheckBox -checked $true
        CustomDelimiterTextBox = [PSCustomObject]@{ Text = '' }
        MergeCheckbox          = fn_New-MockCheckBox -checked $true
        SemicolonCheckbox      = fn_New-MockCheckBox -checked $true
        SplitCheckbox          = fn_New-MockCheckBox -checked $true
        TextBox                = [PSCustomObject]@{ Text = "12345"; Lines = @("12345") }
    }

    $result = fn_Invoke-SentinelApplyTransformation -ui $ui

    Write-Host "[RESULT] Test Index 6, Expected: 1,2,3,4,5, Returned: $result"
    "`n"

    fn_LogThatMessage -pOutMessage "Ending 6 and Reset button clears checkboxes and text area and does not affect clipboard" -ploglevel Info
}
#################################


#################################
function Test_7_apply_fails_w/err_msg_when_sentinel_is_not_selected {
    fn_LogThatMessage -pOutMessage "Starting 7 and Apply fails w/err msg when Sentinel is not selected" -ploglevel Info

    write-host
    Write-Host "Apply fails w/err msg when Sentinel is not selected..."
    write-host

    $ui = [PSCustomObject]@{
        CommaCheckbox          = fn_New-MockCheckBox -checked $false
        CustomDelimiterTextBox = [PSCustomObject]@{ Text = '' }
        MergeCheckbox          = fn_New-MockCheckBox -checked $true
        SemicolonCheckbox      = fn_New-MockCheckBox -checked $false
        SplitCheckbox          = fn_New-MockCheckBox -checked $false
        TextBox                = [PSCustomObject]@{ Text = "1 2 3"; Lines = @("1", "2", "3") }
    }

    $result = fn_Invoke-SentinelApplyTransformation -ui $ui

    Write-Host "[RESULT] Test Index 7, Expected: 1,2,3,4,5, Returned: $result"
    "`n"

    fn_LogThatMessage -pOutMessage "Ending 7 and Apply fails w/err msg when Sentinel is not selected" -ploglevel Info
}
#################################


#################################
function Test_8_help_button_clicked_and_message_displayed {
    fn_LogThatMessage -pOutMessage "Starting 8 and Help button clicked and message displayed" -ploglevel Info

    write-host
    Write-Host "Help button clicked and message displayed..."
    write-host

    $ui = [PSCustomObject]@{
        CommaCheckbox          = fn_New-MockCheckBox -checked $false
        CustomDelimiterTextBox = [PSCustomObject]@{ Text = '' }
        MergeCheckbox          = fn_New-MockCheckBox -checked $false
        SemicolonCheckbox      = fn_New-MockCheckBox -checked $false
        SplitCheckbox          = fn_New-MockCheckBox -checked $true
        TextBox                = [PSCustomObject]@{ Text = ""; Lines = @() }
    }

    $result = fn_Invoke-SentinelApplyTransformation -ui $ui

    Write-Host "[RESULT] Test Index 8, Expected: 1,2,3,4,5, Returned: $result"
    "`n"

    fn_LogThatMessage -pOutMessage "Ending 8 and Help button clicked and message displayed" -ploglevel Info
}
#################################


#################################
function Test_9_when_a_sentinel_is_not_found_but_selected_to_split {
    fn_LogThatMessage -pOutMessage "Starting 9 and When a sentinel is not found, but selected to split" -ploglevel Info

    write-host
    Write-Host "When a sentinel is not found, but selected to split..."
    write-host

    $ui = [PSCustomObject]@{
        CommaCheckbox          = fn_New-MockCheckBox -checked $false
        CustomDelimiterTextBox = [PSCustomObject]@{ Text = '' }
        MergeCheckbox          = fn_New-MockCheckBox -checked $false
        SemicolonCheckbox      = fn_New-MockCheckBox -checked $false
        SplitCheckbox          = fn_New-MockCheckBox -checked $false
        TextBox                = [PSCustomObject]@{ Text = "x y x"; Lines = @("x y x") }
    }

    $result = fn_Invoke-SentinelApplyTransformation -ui $ui

    Write-Host "[RESULT] Test Index 9, Expected: 1,2,3,4,5, Returned: $result"
    "`n"

    fn_LogThatMessage -pOutMessage "Ending 9 and When a sentinel is not found, but selected to split" -ploglevel Info
}
#################################


#################################
function Test_10_split_with_a_space {
    fn_LogThatMessage -pOutMessage "Starting 10 and Split with a space" -ploglevel Info

    write-host
    Write-Host "Split with a space..."
    write-host

    $ui = [PSCustomObject]@{
        CommaCheckbox          = fn_New-MockCheckBox -checked $false
        CustomDelimiterTextBox = [PSCustomObject]@{ Text = ' ' }
        MergeCheckbox          = fn_New-MockCheckBox -checked $false
        SemicolonCheckbox      = fn_New-MockCheckBox -checked $false
        SplitCheckbox          = fn_New-MockCheckBox -checked $true
        TextBox                = [PSCustomObject]@{ Text = "a b c d e"; Lines = @("a b c d e") }
    }

    $result = fn_Invoke-SentinelApplyTransformation -ui $ui

    Write-Host "[RESULT] Test Index 10, Expected: 1,2,3,4,5, Returned: $result"
    "`n"

    fn_LogThatMessage -pOutMessage "Ending 10 and Split with a space" -ploglevel Info
}
#################################


#################################
function Test_11_merge_with_one_line_should_fail_and_display_error_to_operator {
    fn_LogThatMessage -pOutMessage "Starting 11 and Merge with one line should fail and display error to operator" -ploglevel Info

    write-host
    Write-Host "Merge with one line should fail and display error to operator..."
    write-host

    $ui = [PSCustomObject]@{
        CommaCheckbox          = fn_New-MockCheckBox -checked $true
        CustomDelimiterTextBox = [PSCustomObject]@{ Text = '' }
        MergeCheckbox          = fn_New-MockCheckBox -checked $true
        SemicolonCheckbox      = fn_New-MockCheckBox -checked $false
        SplitCheckbox          = fn_New-MockCheckBox -checked $false
        TextBox                = [PSCustomObject]@{ Text = "Ted was here"; Lines = @("Ted was here") }
    }

    $result = fn_Invoke-SentinelApplyTransformation -ui $ui

    Write-Host "[RESULT] Test Index 11, Expected: 1,2,3,4,5, Returned: $result"
    "`n"

    fn_LogThatMessage -pOutMessage "Ending 11 and Merge with one line should fail and display error to operator" -ploglevel Info
}
#################################


#################################
function Test_12_error_check_for_empty_text_box {
    fn_LogThatMessage -pOutMessage "Starting 12 and Error check for empty text box" -ploglevel Info

    write-host
    Write-Host "Error check for empty text box..."
    write-host

    $ui = [PSCustomObject]@{
        CommaCheckbox          = fn_New-MockCheckBox -checked $true
        CustomDelimiterTextBox = [PSCustomObject]@{ Text = '' }
        MergeCheckbox          = fn_New-MockCheckBox -checked $false
        SemicolonCheckbox      = fn_New-MockCheckBox -checked $false
        SplitCheckbox          = fn_New-MockCheckBox -checked $true
        TextBox                = [PSCustomObject]@{ Text = ""; Lines = @() }
    }

    $result = fn_Invoke-SentinelApplyTransformation -ui $ui

    Write-Host "[RESULT] Test Index 12, Expected: 1,2,3,4,5, Returned: $result"
    "`n"

    fn_LogThatMessage -pOutMessage "Ending 12 and Error check for empty text box" -ploglevel Info
}
#################################


# Execute all generated functions
Test_1_merge_commas
Test_2_split_commas
Test_3_merge_semicolons
Test_4_split_semicolons
Test_5_merge_custom
Test_6_reset_button_clears_checkboxes_and_text_area_and_does_not_affect_clipboard
Test_7_apply_fails_w/err_msg_when_sentinel_is_not_selected
Test_8_help_button_clicked_and_message_displayed
Test_9_when_a_sentinel_is_not_found_but_selected_to_split
Test_10_split_with_a_space
Test_11_merge_with_one_line_should_fail_and_display_error_to_operator
Test_12_error_check_for_empty_text_box