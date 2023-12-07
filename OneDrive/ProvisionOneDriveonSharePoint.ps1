<#
# Maker: 20230512 - TedmondFromRedmond
To provision a site for an active user only

$myUpn="sally.strutter@startos.onmicrosoft.com"
request-spopersonalsite -useremails $myUpn

$myUpn="joe.keyboard@startos.onmicrosoft.com"
request-spopersonalsite -useremails $myUpn

# To list all onedrive mysites
get-sposite -includepersonalsite $true -limit all -filter "URL -like '-my.sharepoint.com/personal'"

#>
