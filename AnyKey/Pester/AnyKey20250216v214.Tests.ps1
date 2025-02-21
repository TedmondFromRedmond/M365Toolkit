<#
###############################################################################
 Purpose:
 To execute tests using pester for the function
 Anykey and provide Test results in a csv file from variable $script:pstrcsvFile
 Note: This script returns a Pester object to the caller script.

 How to use:
 Phase I: Environment Setup
 0. This script should be called by Check[ScriptNametobeTested].tests.ps1 - aka the caller script
 The script will execute on its own, but a return code of the Pester object is not available.
 Hence, the caller script sets a variable equal to this script.
 
 1. Modify the variables under MAIN heading
        $MyTestDir = The directory this script, the source and the pester files are in.
        e.g. Functions and Pester.Tests.ps1, 
        1. Install Pester module on server/workstation with: 
 2. Install-module Pester
 3. Execute Reader proc script to call this script

 Phase II:
 Use Passthru parameter to allow tracking of 1 or more tests. if script is called by another script, then set object = calling this script.
 Calling script syntax execution should be similar to $myTests = .\fn_Changline.Tests.ps1

 Since the imports Import-Module Pester -PassThru, there is no need to import the Pester module twice

 Phase III:
In the caller script Check[scriptName.tests.ps1] export the returned object of the pester script to csv

# Flow of script
# Test script name is designated a test script in vscode with .Tests in the name,
e.g. scriptname.Tests.ps1 
# First, import the Pester module.
# Second, check input file existence, if not then fail.
# Executes the tests


#>
###############################################################################

#----
. .\Functions.tests.ps1
#----

    ### End of Functions ###
###############################################################################
#######
# Main
#######
# Setup default date and time
$script:scr_DateandTimeStamp = fn_DateandTimeStamp # Date and time format 

# Import Pester Module
Import-Module Pester -PassThru
$myTestDir = "C:\Users\TedmondFromRedmond\OneDrive - StartOS.com LLC\Documents\PowerShell\Projects\RefactorGithubtools\SourceFirstTransformationToStandards\AnyKey\Pester"


# Change into testing directory
Set-Location $myTestDir


start-sleep -seconds 2
# write-host 



#---------------------
# Pester overview
# Hierarchy: Describe -> Context -> 1 or many It(Test cases) 
# -> Have to use Try catch and throw writes the message to pester object
# Describe is the top level
# Context is a classification
# IT is the actual test case
# Beforeall executes can be in Describe, Context and IT. Can exist in IT for ea. test case.
# AFterall executes after all the tests. Can be in Describe, Context and IT. Can exist in IT for ea. test case.
# Note: 
# Variables are scoped at different levels in Pester. Be careful and test accordingly.
 
Import-Module Pester -PassThru

#----
# Import Test Cases 
# Contains Describe, Context and It
. '.\Pester.Tests.ps1'
#----


#################################################



#########
# The END
#########



