#
# How to use this file:
# Insert the tests for each test scenario.
# Per the framework, this file is imported into your .Tests.ps1 script
#
# Hierarchy is:
# Describe -> Context -> IT (Test Cases)
# Each section can contain none or all of beforeall and afterall
# Only Describe and IT are required
# 
# Author: TedmondFromRedmond
#

Import-Module Pester -PassThru

Describe 'fn_CreateSequentialFiles Tests' {
    BeforeAll {
    # Remove the path, files and any subdirs that exist
    if (Test-Path "C:\Temp\PesterCreateManyFiles") { Remove-Item -Path "C:\Temp\PesterCreateManyFiles" -Recurse -Force }
    }
    AfterAll {
    # Remove the path, files and any subdirs that exist
    # Remove-Item -Path "C:\Temp\PesterCreateManyFiles" -Recurse -Force
    if (Test-Path "C:\Temp\PesterCreateManyFiles") { Remove-Item -Path "C:\Temp\PesterCreateManyFiles" -Recurse -Force }
    } # End of beforeall and afterall



# Note:
# Describe -> Context -> 1 or many It(Test cases) -> Have to use Try catch and throw writes the message to pester object

Context 'Test fn_CreateSequentialFiles' {

#-----

It 'Test Case 1 - Call fn and create files then ck return' {
# Check that the function returned our mock key press
# $keyPressed | Should -Not -BeNullOrWhiteSpace
# Set the custom window title
Try{
    $myrc=$null
    # $myrc = fn_CreateSequentialFiles -p_DirectoryPath "C:\temp\PesterCreateManyFiles"
    $myrc = fn_CreateSequentialFiles -p_DirectoryPath "C:\temp\PesterCreateManyFiles" -p_FileCount 101

    $myrc|should -Be "File creation completed."
} catch {
    # write-host "$myrc"
    Throw $myrc
} # End of try catch in IT
   
} # End of IT Test Case 1

 
# Test Case 2
It 'Test Case 2 - Test fn_ListFilesAndValidateCount for incorrect number of files and it should error' {
    # Set the custom window title
    Try{
        $myrc=$null
        $myrc =  fn_ListFilesAndValidateCount -p_DirectoryPath "C:\Temp\PesterCreateManyFiles" -p_ExpectedFileCount 100
          $myrc|should -Be 'File count mismatch.'
        
    } catch {
        # write-host "Errrrrrrrrrrrrrr: $myrc"
        Throw $myrc
        
    } # End of try catch
       
    } # end of IT Test Case 2

# Test Case 3
It 'Test Case 3 - Test fn_ListFilesAndValidateCount for CORRECT number of files and it should COMPLETE WITHOUT ERROR' {
    # Set the custom window title
    Try{
        $myrc=$null
        $myrc =  fn_ListFilesAndValidateCount -p_DirectoryPath "C:\Temp\PesterCreateManyFiles" -p_ExpectedFileCount 101
        $myrc|should -Be "File count matches."
    } catch {
        # write-host "Errrrrrrrrrrrrrr: $myrc"
        Throw $myrc
    } # End of try catch
       
    } # end of IT Test Case 3

# Test Case 4
It 'Test Case 4 - Test invalid file count passed. should have returned and failed.' {
    # Set the custom window title
    Try{
        $myrc=$null
        $myrc =  fn_ListFilesAndValidateCount -p_DirectoryPath "C:\Temp\PesterCreateManyFiles" -p_ExpectedFileCount 0
        $myrc|should -Be "File Count Mismatch."
    } catch {
        # write-host "Errrrrrrrrrrrrrr: $myrc"
        Throw $myrc
    
    } # End of try catch
       
    } # end of IT Test Case 4

# Test Case 5
It 'Test Case 5 - Test of invalid parameter passed to function or null or blank.' {
    # Set the custom window title
    Try{
        $myrc=$null
        $myrc =  fn_ListFilesAndValidateCount -p_DirectoryPath "C:\Temp\PesterCreateManyFiles"
        $myrc|should -Be "File Count Mismatch."
    } catch {
        # write-host "Errrrrrrrrrrrrrr: $myrc"
        Throw $myrc
    
    } # End of try catch
       
    } # end of IT Test Case 4


#----
} # End of Context 


} # End of Describe