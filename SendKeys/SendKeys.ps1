
# Codename: DOTS
#
# Purpose:
# Send a key into a window every few seconds so as to curb scrsvr
#
# Maker - TFR

param($minutes=3480)
$myshell=new-object -comobject "wscript.shell"
for($i=0; $i -lt $minutes;$i++) {
					start-sleep -seconds 50
					$myshell.sendkeys(".")

				}



