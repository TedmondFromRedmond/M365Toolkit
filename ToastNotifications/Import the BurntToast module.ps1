# Define the XML for the toast notification
$ToastXML = @"
<toast activationType="foreground" launch="args">
    <visual>
        <binding template="ToastGeneric">
            <text>Notification Title</text>
            <text>This is the notification content.</text>
        </binding>
    </visual>
    <actions>
        <action activationType="foreground" content="Button 1" arguments="button1"/>
        <action activationType="foreground" content="Button 2" arguments="button2"/>
    </actions>
</toast>
"@

# Load the necessary types and assemblies
Add-Type -TypeDefinition @"
using System;
using Windows.Data.Xml.Dom;
using Windows.UI.Notifications;
"@ -Language CSharp

# Convert the XML to a usable format
$ToastXMLDoc = New-Object Windows.Data.Xml.Dom.XmlDocument
$ToastXMLDoc.LoadXml($ToastXML)

# Display the toast notification
$ToastNotification = [Windows.UI.Notifications.ToastNotification]::new($ToastXMLDoc)
$ToastNotifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PSToast")
$ToastNotifier.Show($ToastNotification)

