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

    #>


#--------------------------------

#########################################################
# Function to execute when the Apply button is clicked
function Apply-Transformation {
    if ([string]::IsNullOrWhiteSpace($textbox.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Textbox is empty. Please enter text to transform.")
        Return
    }

    # Validation check
    # Check if customlabel text box contains anything and if comma or semicolon appearing at same time
    if ($customDelimiterTextBox.Text.Length -gt 0){

                                        if($commaCheckbox.checked -or $semicolonCheckbox.checked){
                                            [System.Windows.Forms.MessageBox]::Show("Please select Commas, Semicolons or Custom. Only select 1.")
                                            Return
                                        } #end of if commacheckbox.checked
                                      } #end of customlabel.length > and comma or semicolon checked with Custom 
        

    $delimiter = if ($commaCheckbox.Checked) { "," 
                                            } elseif ($semicolonCheckbox.Checked) 
                                             { ";" } else
                                              { $null }

    if (-not [string]::IsNullOrWhiteSpace($customDelimiterTextBox.Text)) {
        $delimiter = $customDelimiterTextBox.Text
    }

    if (-not $delimiter) {
        [System.Windows.Forms.MessageBox]::Show("Please select a delimiter Commas or Semicolons or enter a Custom delimiter.")
        return
    } 

    # Filter out zero-length values and concatenate
    $lines = $textbox.Text -split "`r`n"
    $filteredLines = $lines | Where-Object { $_.Trim().Length -gt 0 }
    $concatenatedText = $filteredLines -join $delimiter
    Set-Clipboard -Value $concatenatedText
    [System.Windows.Forms.MessageBox]::Show("Professor POSH says Thank You and your Text was concatenated and copied to clipboard!")
}
#----------------------


###############################################################################################
# MAIN
###############################################################################################
# Sometimes forms can have the same name as form and be in memory.
# Clear out form variable so as not to conflict with other programs
$form=$null

# Load necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing




# Create a new form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Concatenate Text"
$form.Size = New-Object System.Drawing.Size(600, 500)
$form.StartPosition = "CenterScreen"

# Add keypreview method
$form.KeyPreview = $true  # Ensure the form receives key events before the focused control


# Add Apply button
$applyButton = New-Object System.Windows.Forms.Button
$applyButton.Text = "&Apply"  # The & character enables the Alt+A shortcut
$applyButton.Location = New-Object System.Drawing.Point(340, 15)
$applyButton.Add_Click({ Apply-Transformation })
$form.Controls.Add($applyButton)

# Add Exit button
$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Text = "E&xit"  # The & character enables the Alt+X shortcut
$exitButton.Location = New-Object System.Drawing.Point(420, 15)
$exitButton.Add_Click({ $form.Close() })
$form.Controls.Add($exitButton)

# Create a multiline textbox
$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Multiline = $true
$textbox.Size = New-Object System.Drawing.Size(550, 400)
$textbox.Location = New-Object System.Drawing.Point(15, 50)
$form.Controls.Add($textbox)

# Create checkboxes
$commaCheckbox = New-Object System.Windows.Forms.CheckBox
$commaCheckbox.Text = "Commas"
$commaCheckbox.Location = New-Object System.Drawing.Point(15, 15)
$form.Controls.Add($commaCheckbox)

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

# Set focus to the textbox when the form is shown
$form.Add_Shown({
    $textbox.Focus()
})



# Ensure only one checkbox can be selected at a time
$commaCheckbox.Add_CheckedChanged({
    if ($commaCheckbox.Checked) {
        $semicolonCheckbox.Checked = $false
    }
})

$semicolonCheckbox.Add_CheckedChanged({
    if ($semicolonCheckbox.Checked) {
        $commaCheckbox.Checked = $false
    }
})



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
            'C' { $commaCheckbox.Checked = $true }
            'c' { $commaCheckbox.Checked = $true }
            'S' { $semicolonCheckbox.Checked = $true }
            'T' { $customDelimiterTextBox.focus() }
            't' { $customDelimiterTextBox.focus() }
        }
    }
}) # End of $form.Add_KeyDown({



# Display the form
$form.ShowDialog()

