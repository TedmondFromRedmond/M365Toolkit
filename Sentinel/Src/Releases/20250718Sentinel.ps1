<#
.SYNOPSIS
    Transforms a user input list of items delimited by Carriage Returns into comma-separated, semicolon-separated values or Custom Delimeter and copies concatenated string to clipboard.

.DESCRIPTION
    This script creates a Windows form with a multiline textbox for user input. It includes two checkboxes to select the delimiter (commas or semicolons). 
    Upon clicking the 'Apply' button, the script concatenates the input text with the selected delimiter and copies the result to the clipboard.

.NOTES
    Author: 2023-09-12 TFR - TedmondFromRedmond https://www.github.com/TedmondFromRedmond
    Note: Special credit is given to dtammam, Dean Tammam. https://github.com/dtammam/
    2024-05-27 - TFR Updated script to work with hotkeys such as Alt+C for Comma separated, Alt+S for Semicolons; Alt+A for Apply, Alt+X for Exit 
    2024-05-27 - TFR Updated script to not add a zero length value and removed extraneous delimiters if necessary; moved buttons and checkboxes to left of screen
    2024-05-28 - TFR added custom values on form; added hotkeys with alt button accessible in upper and lowercase
               - ; moved buttons to top of form ; tested and remediated incorrect operator input and selection of semicolons, commas, custom
    2025-07-18 - TFR added Reset button, Merge checkbox, removed function call due to variable scripting and wrapped form in custom object for extendability.
               - It is possible for one to use the custom object named $ui as a parm when calling a function or script.
               - Tested every option and passed.
    #>


#--------------------------------



###############################################################################################
# MAIN
###############################################################################################
# Sometimes forms can have the same name as form and be in memory.
# Clear out form variable so as not to conflict with other programs
$form=$null

# Load necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


# >>>>>>>>>>>>>>>>>>>
# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Delimiter Tool"
$form.Size = New-Object System.Drawing.Size(600, 500)
$form.StartPosition = "CenterScreen"

# Add keypreview method
$form.KeyPreview = $true  # Ensure the form receives key events before the focused control


# Merge checkbox
$mergeCheckbox = New-Object System.Windows.Forms.CheckBox
$mergeCheckbox.Text = "&Merge"
$mergeCheckbox.Location = New-Object System.Drawing.Point(15, -5)  # Adjusted to sit above Commas
$form.Controls.Add($mergeCheckbox)




# Create Split checkbox (default: unchecked)
$splitCheckbox = New-Object System.Windows.Forms.CheckBox
$splitCheckbox.Text = "S&plit"
$splitCheckbox.Checked = $false
$splitCheckbox.Location = New-Object System.Drawing.Point(119, -5)  # Aligned to right of Merge
$form.Controls.Add($splitCheckbox)



# Comma checkbox
$commaCheckbox = New-Object System.Windows.Forms.CheckBox
$commaCheckbox.Text = "Commas"
$commaCheckbox.Location = New-Object System.Drawing.Point(15, 15)
$form.Controls.Add($commaCheckbox)



# Semicolons checkbox
$semicolonCheckbox = New-Object System.Windows.Forms.CheckBox
$semicolonCheckbox.Text = "Semicolons"
$semicolonCheckbox.Location = New-Object System.Drawing.Point(119, 15)
$form.Controls.Add($semicolonCheckbox)


# Add small text box to the right of the semicolon checkbox
$customDelimiterTextBox = New-Object System.Windows.Forms.TextBox
$customDelimiterTextBox.Size = New-Object System.Drawing.Size(50, 20)
$customDelimiterTextBox.Location = New-Object System.Drawing.Point(220, 20)
$form.Controls.Add($customDelimiterTextBox)


# Add "Custom" label to the right of the text box
$customLabel = New-Object System.Windows.Forms.Label
$customLabel.Text = "Cus&tom"
$customLabel.Location = New-Object System.Drawing.Point(280, 20)
$customLabel.AutoSize = $true
$form.Controls.Add($customLabel)


# Add Apply button
$applyButton = New-Object System.Windows.Forms.Button
$applyButton.Text = "&Apply"
$applyButton.Location = New-Object System.Drawing.Point(340, 15)
# << DO NOT add the .Add_Click block here
$form.Controls.Add($applyButton)




$form.Controls.Add($applyButton)


# Add Exit button
$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Text = "E&xit"  # The & character enables the Alt+X shortcut
# $exitButton.Location = New-Object System.Drawing.Point(420, 15)
$exitButton.Location = New-Object System.Drawing.Point(500, 15)
$exitButton.Add_Click({ $form.Close() })
$form.Controls.Add($exitButton)


# Add Reset button
$btnFormReset = New-Object System.Windows.Forms.Button
$btnFormReset.Text = "&Reset"  # Alt+R enabled via ampersand
# $btnFormReset.Location = New-Object System.Drawing.Point(500, 15)
$btnFormReset.Location = New-Object System.Drawing.Point(420, 15)
$form.Controls.Add($btnFormReset)
# Reset button click handler
$btnFormReset.Add_Click({
    $ui.MergeCheckbox.Checked          = $false
    $ui.SplitCheckbox.Checked          = $false
    $ui.CommaCheckbox.Checked          = $false
    $ui.SemicolonCheckbox.Checked      = $false
    $ui.CustomDelimiterTextBox.Text    = ""
    $ui.TextBox.Clear()
    $ui.TextBox.Focus()
}) # End of btnFormReset.Add_Click


# Create a multiline textbox
$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Multiline = $true
$textbox.Size = New-Object System.Drawing.Size(550, 400)
$textbox.Location = New-Object System.Drawing.Point(15, 50)
$form.Controls.Add($textbox)




# Wrap all UI components in a single custom object
$ui = [PSCustomObject]@{
    ApplyButton            = $applyButton
    CommaCheckbox          = $commaCheckbox
    CustomDelimiterTextBox = $customDelimiterTextBox
    ExitButton             = $exitButton
    Form                   = $form
    MergeCheckbox          = $mergeCheckbox
    ResetButton            = $btnFormReset
    SemicolonCheckbox      = $semicolonCheckbox
    SplitCheckbox          = $splitCheckbox
    TextBox                = $textbox
}

$ui.ApplyButton.Add_Click({
    #------------------------------------------
    # Initialize variables
    #------------------------------------------
    $fn_delimiter        = $null
    $fn_escapedDelimiter = $null
    $fn_rawValues        = $null
    $fn_filteredLines    = $null
    $fn_merged           = $null
    $fn_lines            = $null
    #------------------------------------------

    # Determine delimiter from checkboxes or custom entry
    $fn_delimiter = if ($ui.CommaCheckbox.Checked) {
        ","
    } elseif ($ui.SemicolonCheckbox.Checked) {
        ";"
    } elseif (-not [string]::IsNullOrWhiteSpace($ui.CustomDelimiterTextBox.Text)) {
        $ui.CustomDelimiterTextBox.Text
    } else {
        $null
    }

    # Validate delimiter
    if (-not $fn_delimiter) {
        [System.Windows.Forms.MessageBox]::Show("Please select a delimiter: Commas, Semicolons, or enter a Custom delimiter.")
        return
    }

    # Escape the delimiter for regex safety
    $fn_escapedDelimiter = [regex]::Escape($fn_delimiter)

    # Split Mode
    if ($ui.SplitCheckbox.Checked) {
        $fn_rawValues = $ui.TextBox.Text -split $fn_escapedDelimiter
        $fn_filteredLines = $fn_rawValues | ForEach-Object { $_.Trim() } | Where-Object { $_.Length -gt 0 }

        foreach ($line in $fn_filteredLines) {
            # Set-Clipboard -Value $line
            Set-Clipboard -Value ($fn_filteredLines -join "`r`n")
            Start-Sleep -Milliseconds 100
        }

        [System.Windows.Forms.MessageBox]::Show("Professor POSH says Thank You and your Text was split and copied line-by-line to the clipboard!")
        return
    }

    # Merge Mode
    if ($ui.MergeCheckbox.Checked) {
        $fn_lines = $ui.TextBox.Text -split "`r`n"
        $fn_filteredLines = $fn_lines | ForEach-Object { $_.Trim() } | Where-Object { $_.Length -gt 0 }
        $fn_merged = $fn_filteredLines -join $fn_delimiter
        Set-Clipboard -Value $fn_merged
        [System.Windows.Forms.MessageBox]::Show("Professor POSH says Thank You and your Text was concatenated and copied to clipboard!")
        return
    }

    # If neither Split nor Merge is selected
    [System.Windows.Forms.MessageBox]::Show("Please select Split or Merge to transform your text.")
})
# End of if $ui.applybutton.add_click

# Present the form
$form.Add_Shown({
    $textbox.Focus()
})
#<<<<<<<<<<< End of form creation


# Enable keyboard shortcuts for Apply, Exit, and checkboxes
$form.KeyPreview = $true

$form.Add_KeyDown({
    param ($sender, $e)
    if ($e.Modifiers -eq [System.Windows.Forms.Keys]::Alt) {
        switch ($e.KeyCode) {

# The apply and exit buttons are handled in forms by default since the button is associated with a click event and the text includes ampersand
#            'A' { $applyButton.PerformClick() }
#            'a' { $applyButton.PerformClick() }
#            'X' { $exitButton.PerformClick() }
#            'x' { $exitButton.PerformClick() }
            'C' { $commaCheckbox.Checked = $true } # Commas
            'c' { $commaCheckbox.Checked = $true }
            'M' { $mergeCheckbox.Checked = $true } # Merge
            'm' { $mergeCheckbox.Checked = $true }
            'S' { $semicolonCheckbox.Checked = $true } # Semicolons
            's' { $semicolonCheckbox.Checked = $true }
            'P' { $splitCheckbox.Checked = $true } # Split
            'R' { $btnFormReset.PerformClick() }
            'r' { $btnFormReset.PerformClick() }
            'T' { $customDelimiterTextBox.focus() } # Custom Delimiter
            't' { $customDelimiterTextBox.focus() }
        }
    }
}) # End of $form.Add_KeyDown({



# Display the form
$form.ShowDialog()