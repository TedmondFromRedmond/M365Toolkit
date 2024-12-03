function fn_ParseOneDriveHealthData {
# Maker: 20231105 - TFR
    param (
        [Parameter(Mandatory=$true)]
        [string]$pmyInputFile,
        [Parameter(Mandatory=$true)]
        [string]$pmyOutputCSV
    )

    # Ensure the input file exists before proceeding
    if (!(Test-Path $pmyInputFile)) {
        Write-Error "File $pmyInputFile does not exist."
        return
    }

    # Initialize line counter
    $lineCount = 0
    $myAggregator = @()
    $tempList = @()

    # Read the file line by line
    Get-Content $pmyInputFile | ForEach-Object {
        # Add line to temporary list
        $tempList += $_

        # Increment line counter
        $lineCount++

        # If this is the 10th line, process it and reset the counter
        if ($lineCount -eq 10) {
            # Create an object for the current line and add it to the aggregator
            $obj = New-Object -TypeName PSObject
            $obj | Add-Member -MemberType NoteProperty -Name "User" -Value $tempList[0]
            $obj | Add-Member -MemberType NoteProperty -Name "UserEmail" -Value $tempList[1]
            $obj | Add-Member -MemberType NoteProperty -Name "DeviceName" -Value $tempList[2]
            $obj | Add-Member -MemberType NoteProperty -Name "Errors" -Value $tempList[4]
            $obj | Add-Member -MemberType NoteProperty -Name "KnownFolders" -Value $tempList[5]
            $obj | Add-Member -MemberType NoteProperty -Name "AppVersion" -Value $tempList[6]
            $obj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $tempList[7]
            $obj | Add-Member -MemberType NoteProperty -Name "LastSynced" -Value $tempList[8]
            $obj | Add-Member -MemberType NoteProperty -Name "LastStatusReported" -Value $tempList[9]

            $myAggregator += $obj

            # Reset line counter and temporary list
            $lineCount = 0
            $tempList = @()
        }
    }

    # Output the aggregated data to the specified CSV file
    # The file will be created if it doesn't exist, and -NoTypeInformation prevents outputting type information
    $myAggregator | Export-Csv -Path $pmyOutputCSV -NoTypeInformation -Append
}

########### 
# Main execution
##


$myTextFile="C:\temp\myinput.txt"
$myOutputCSV="C:\temp\stuff.csv"
fn_ParseOneDriveHealthData -pmyInputFile $myTextFile -pmyOutputCSV $myOutputCSV

