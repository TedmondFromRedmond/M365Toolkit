
Purpose:
Programmatic UI Testing Pattern (PUITP)

Author:
TFR

Date:
20250727

References:
https://chatgpt.com/g/g-kfI0rzkKC-professor-powershell-posh/c/688699fa-fa18-8329-ac84-3bd3baf69908

Description:
To get started, 

1. Log into GitHub.com/TedmondFromRedmond/M365Toolkit
2. Navigate to M365Toolkit/Sentinel
3. Download Sentinel.ps1 to a working directory
4. Open up PowerShell cmd prompt in working directory
5. execute .\Sentinel.ps1


########################################################

To make changes and test programmatically:
1. log into github
2. Create working directory
3. Open up powershell in working directory
git clone https://Github.com/TedmondFromRedmond/M365Toolkit/Sentinel


4. If you are changing the test functions or adding to ProgrammaticUITestingPattern.xlsx, you will need to use GPT to prompt and regenerate the 


file named GeneratedSentinelTestFunctions_AUTOMATED.ps1 you will need to perform the following:
4.a Obtain prompt from top of GeneratedTestFunctions_Automated.ps1 file at top in comments
4.b Log into GPT 
4.c Navigate browser to
https://chatgpt.com/g/g-kfI0rzkKC-professor-powershell-posh

4.d Paste the prompt obtained in 4.a
4.e Attach the file
Sentinel.ps1
4.f Attach the file 
ProgrammaticUITestingPattern.xlsx
4.e You will see a file for download generated with the programmatic testing powershell functions created. Download the file and place in the same directory as Sentinel.ps1

5. Execute Sentinel.ps1 with appropriate parameter.
. .\Sentinel.ps1 -DevMode $true

You will see a series of modal dialogue boxes providing informational messages.

6. A logfile named LogSentinel.csv will be created if it does not exst in the directory of the script.

7. Review the Log file created.



############################################

