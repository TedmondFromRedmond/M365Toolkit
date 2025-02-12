
<#
To execute tests for fn_Changeline, perform the following:
1. Ensure Pester version 5.7.1 is installed
2. get-Module -Name Pester -ListAvailable
2.1 create a test dir such as c:\temp\test to copy source files to with git commands
3. clone this repo into a directory.
3.1 if you need to install GIT 
3.2 install-Module posh-git -Scope CurrentUser
3.3 import-Module PSGitHub
3.4 obtain Get 
winget install Git-Credential-Manager-Core
winget install GitHub.cli
3.5 close Powershell Repository
3.6 open Powershell in Admin
3.7 clone repo
git clone https://github.com/TedmondFromRedmond/M365Toolkit.git
3.8 To filter for a specific folder in the clone
Cd into the directory created when you cloned it.
e.g. cd c:\temp\test\M365 Toolkit\
3.9 git sparse-checkout set [FolderName]
e.g. git sparse-checkout set fn_Changeline
4.0 move the subdirectory files to a testing directory, including the pester subdirectory into a separate folder
4.1 Open VSCode in Admin mode
4.2 Open Checkfn_ChangeLine.tests.ps1
4.3 Modify script according to instructions at AcquireTokenByUsernamePassword
4.4 Modify fn-ChangeLine.Tests.ps1 according to directions at top of script
4.5 Modify the PesterTests.ps1 file for your tests and then regression test with original file
fn_ChangeLine.Tests.ps1 reads teh Pestertests.ps1 file for known tests. Modify this file if you need to execute more tests. 

How to commit changes to repo
1. Copy separate directory files back to directory you created the cloned repo to and replace.
2. Open PowerShell in admin prompt
3. sl into the temp directory you created in step 2.1
4. git add .\[DirectoryName]\[ScriptName.ps1]
5. commit your changes with git commit -m "changed code and tested"
6. git push
7. Visually validate changes in Github

#>