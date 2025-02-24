

How to setup:
- Note: If using VSCode, you must run in admin mode.

- Open VSCode

- if you do not have one, create a working directory for the GitHub source code.
mkdir C:\Temp\test\M365Toolkit\Createmanyfiles\Pester

- At a command prompt, or in VSCode, switch into the directory you created.
sl C:\Temp\test\M365Toolkit\Createmanyfiles\Pester

- git clone https://github.com/TedmondFromRedmond/M365Toolkit.git

Pester continually experienced issues with . Dot sourcing functions and
the returns from functions were the correct type, but unpredictable.
The fix was to copy paste the functions beyond the function being tested 
into the program.


Ver: 
2


Files in this release:
fn_CreateSequentialFiles.ps1
fn_CreateSequentialFilesCheck.tests.ps1
fn_CreateSequentialFiles.tests.ps1
fn_CreateSequentialFilesFunctions.tests.ps1

Note: Some files are intentionally left blank because they failed to be imported when pester tests were executed. Was repeatable in vscode admin mode and non-admin mode. Types were correct, but values returned were not.
Possible bug in Pester with importing functions with Dot notation.