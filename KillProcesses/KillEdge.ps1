

# Purpose:
# To find all MSEdge processes and stop them
# 
# Maker - TFR


# Developed to kill all msedge.exe processes as they seem to ghost on my system

# Find all processes with the name 'msedge'
$edgeProcesses = Get-Process -Name msedge -ErrorAction SilentlyContinue

# If any processes are found, stop them
if ($edgeProcesses) {
    $edgeProcesses | Stop-Process -Force
    Write-Output "All instances of msedge.exe have been stopped."
} else {
    Write-Output "No instances of msedge.exe were found running."
}

