#################################3
#
# Purpose:
# To xform a user input list of 
# items delineated by Carriage Returns,
# xform the list into comma separated values
# and copy to the clipboard.
#
# History:
# --------
# 20230912 - TFR
#
#################################3

# Load necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create a new form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Concatenate Text"
$form.Size = New-Object System.Drawing.Size(400, 300)

# Create a multiline textbox
$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Multiline = $true
$textbox.Size = New-Object System.Drawing.Size(350, 200)
$textbox.Location = New-Object System.Drawing.Point(15, 15)
$form.Controls.Add($textbox)

# Function to execute when the Xform button is clicked
$xformButton_Click = {
    $concatenatedText = ($textbox.Text -split "`r`n" -join ",")
    Set-Clipboard -Value $concatenatedText
    [System.Windows.Forms.MessageBox]::Show("Text concatenated and copied to clipboard!")
}

# Add Xform button
$xformButton = New-Object System.Windows.Forms.Button
$xformButton.Text = "Xform"
$xformButton.Location = New-Object System.Drawing.Point(50, 225)
$xformButton.Add_Click($xformButton_Click)
$form.Controls.Add($xformButton)

# Add Exit button
$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Text = "Exit"
$exitButton.Location = New-Object System.Drawing.Point(250, 225)
$exitButton.Add_Click({$form.Close()})
$form.Controls.Add($exitButton)

# Display the form
$form.ShowDialog()
