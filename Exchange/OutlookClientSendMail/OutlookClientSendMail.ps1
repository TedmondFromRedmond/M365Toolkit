
# Create an Outlook Application object
$outlook = New-Object -ComObject Outlook.Application

# Create a new mail item
$mail = $outlook.CreateItem(0)

# Set the properties of the mail item
$mail.To = $to
$mail.Subject = $subject
$mail.Body = $body

# Send the mail item
$mail.Send()

# Release the Outlook COM objects
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($mail) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($outlook) | Out-Null
Remove-Variable outlook
Remove-Variable mail

