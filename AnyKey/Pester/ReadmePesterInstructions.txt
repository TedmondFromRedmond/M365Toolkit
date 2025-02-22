How to use Pester with fn_AnyKey.ps1

Tip: VSCode Admin mode is required for the system objects the code accesses.

Required files:
1. fn_AnyKeyCheck.tests.ps1 - Outputs a csv report to the diretory the script was executed in.
2. fn_AnyKey.Tests.ps1
3. fn_AnyKeyfunctions.tests.ps1

The sequence of execution is the following:
fn_AnyKeyCheck.tests.ps1 -> fn_AnyKey.Tests.ps1 -> ..\fn_Anykey.ps1 -> fn_AnyKeyfunctions.tests.ps1
(Caller Script)             (Pester Tests)         (OG function file)  (Imported into fn_AnyKey.Tests.ps1)

1.Pester Environment Setup:
	a. Open PowerShell in an admin prompt
	b. Install-module -Name Pester -Force -SkipPublisherCheck # from the PowerShell Gallery and use use skip if already installed
	c. Once installed, one can use the command Import-Module Pester -PassThru to make the module available
See the code for more examples.

2. Modify the required variables in each of the scripts below:
a. fn_AnyKeyCheck.tests.ps1 - $MyTestDirectory
b. fn_AnyKey.Tests.ps1 - $myTestDir

3. One can also just execute the Pester Tests from fn_AnyKeyCheck.tests.ps1 if they want to see how it works.

The pester test for this function closes all command windows before starting.
It is important to NOT touch the computer during the test.






