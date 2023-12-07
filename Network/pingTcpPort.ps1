#============================================================================
#
# Author: TFR
# File:		.\pingTcpPort.ps1
# Description:	Try to connect to a TCP port, an
# Parameters:	$server - servername or IP address
#				$port - port number to ping
#
# Examples:		
# PS c:\Temp\PowershellScripts\Networking> .\pingTcpPort.ps1 192.168.150.21 8888
# Succeeded: 192.168.150.21:8888
# PS c:\Temp\PowershellScripts\Networking> .\pingTcpPort.ps1 148.94.142.21 8888
# Succeeded: 148.94.142.21:8888
#============================================================================
param
(
	$server
	,$port
)

$script:succeeded=$true
$script:detail=""

trap
{
	$script:succeeded=$false
	$script:detail=$error[0].ToString()
}


$ip=[Net.Dns]::GetHostEntry($server).AddressList[0].IPAddressToString


# Try to connect to the port
$x = new-object Net.Sockets.TcpClient($server,$port)
$x.Close()

if ($script:succeeded)
{
	"Succeeded: "+$ip+":"+$port
}
else
{
	"Failed: "+$ip+":"+$port
}