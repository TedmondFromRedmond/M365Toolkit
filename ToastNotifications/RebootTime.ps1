# Ensure the BurntToast module is installed
if (-not (Get-Module -ListAvailable -Name BurntToast)) {
    Install-Module BurntToast -Scope CurrentUser
}

$rebootScriptPath="C:\temp\myreboot.ps1"

# Import the BurntToast module
Import-Module BurntToast

# Define the button for the toast

# $Button = New-BTButton -Content 'Ribbot Time?' -Arguments "ms-powershell:$rebootScriptPath"
#$Button = New-BTButton -Content 'Ribbot Time?' -Arguments "Start-Process -FilePath 'c:\windows\system32\shutdown.exe `/r `/f `/t 0"
# $Button = New-BTButton -Content 'Ribbot Time?' -Arguments "Start-Process -FilePath 'cmd.exe"
# $button1 = New-BTButton -Content "Yes" -Arguments "powershell.exe -Command { Set-Content -Path 'c:\temp\myreboot.ps1' -Value 'Button1 was clicked' }"
$button1 = New-BTButton -Content "Yes" -Arguments "c:\windows\system\notepad.exe"

# Display the toast notification with the button
New-BurntToastNotification -Text 'Do you want to restart?' -Button $Button

# Pause the script for 10 seconds to give the user time to interact with the toast
Start-Sleep -Seconds 10
