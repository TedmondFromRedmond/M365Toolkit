<# 
M365 pester Testing Framework

Uses pester
e.g.
Checkfn_ChangeLine.tests.ps1 calls actual pester script -> fn_ChangeLine.Tests.ps1 -> fn_ChangeLine.Tests.ps1 imports the individual tests from PesterTests.ps1
Based upon the results returned to Checkfn_ChangeLine.tests.ps1, the tests specified in the PesterTests.ps1 are designated as Passed or Failed.

How to modify Test Cases
- Edit PesterTests.ps1






#>