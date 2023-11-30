Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "User Information"
$form.Size = New-Object System.Drawing.Size(300, 200)
$form.StartPosition = "CenterScreen"

# Terminated User label and text box
$terminatedUserLabel = New-Object System.Windows.Forms.Label
$terminatedUserLabel.Location = New-Object System.Drawing.Point(10, 20)
$terminatedUserLabel.Size = New-Object System.Drawing.Size(100, 20)
$terminatedUserLabel.Text = "Terminated User:"
$form.Controls.Add($terminatedUserLabel)

$terminatedUserTextBox = New-Object System.Windows.Forms.TextBox
$terminatedUserTextBox.Location = New-Object System.Drawing.Point(120, 20)
$terminatedUserTextBox.Size = New-Object System.Drawing.Size(150, 20)
$form.Controls.Add($terminatedUserTextBox)

# Manager Name label and text box
$managerNameLabel = New-Object System.Windows.Forms.Label
$managerNameLabel.Location = New-Object System.Drawing.Point(10, 50)
$managerNameLabel.Size = New-Object System.Drawing.Size(100, 20)
$managerNameLabel.Text = "Manager Name:"
$form.Controls.Add($managerNameLabel)

$managerNameTextBox = New-Object System.Windows.Forms.TextBox
$managerNameTextBox.Location = New-Object System.Drawing.Point(120, 50)
$managerNameTextBox.Size = New-Object System.Drawing.Size(150, 20)
$form.Controls.Add($managerNameTextBox)

# Your Email label and text box
$yourEmailLabel = New-Object System.Windows.Forms.Label
$yourEmailLabel.Location = New-Object System.Drawing.Point(10, 80)
$yourEmailLabel.Size = New-Object System.Drawing.Size(100, 20)
$yourEmailLabel.Text = "Your Email:"
$form.Controls.Add($yourEmailLabel)

$yourEmailTextBox = New-Object System.Windows.Forms.TextBox
$yourEmailTextBox.Location = New-Object System.Drawing.Point(120, 80)
$yourEmailTextBox.Size = New-Object System.Drawing.Size(150, 20)
$form.Controls.Add($yourEmailTextBox)

# OK button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(120, 120)
$okButton.Size = New-Object System.Drawing.Size(75, 23)
$okButton.Text = "OK"
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

# Show the form
$result = $form.ShowDialog()

# Check if the form was submitted
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    # Retrieve the entered values
    $terminatedUser = $terminatedUserTextBox.Text
    $managerName = $managerNameTextBox.Text
    $yourEmail = $yourEmailTextBox.Text

    # Output the entered values
    Write-Host "Terminated User: $terminatedUser"
    Write-Host "Manager Name: $managerName"
    Write-Host "Your Email: $yourEmail"
}
