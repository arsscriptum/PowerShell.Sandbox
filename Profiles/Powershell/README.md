# Powershell Profile

This folder contains the profiles scripts for this computer's users.
Different scripts are to be copied at different directories depending on
the users and host scopes.

I don't need more than 2 profile scripts:
 - A common profile for all users on my machine (public).
 - A profile for the current user (private).

Usefull documentation: 
https://devblogs.microsoft.com/scripting/understanding-the-six-powershell-profiles/

## Private Profile - PrivateProfile.ps1

Location: *$Home\[My]Documents\WindowsPowerShell\Profile.ps1*
Change the file PrivateProfile.ps1 and the export script will copy it to the 
correct name / location.

## Public Profile - PublicProfile.ps1

Location: *$PsHome\Profile.ps1*
Change the file PublicProfile.ps1 and the export script will copy it to the 
correct name / location.


## List of PowerShell's Profiles locations

-------------------------------------		--------------------------------------------------------------------------
Description									Path
-------------------------------------		--------------------------------------------------------------------------
**Current User, Current Host – console______$Home\[My]Documents\WindowsPowerShell\Profile.ps1**
**Current User, All Hosts___________________$Home\[My]Documents\Profile.ps1**
**All Users, Current Host – console_________$PsHome\Microsoft.PowerShell_profile.ps1**
**All Users, All Hosts______________________$PsHome\Profile.ps1**
Current user, Current Host – ISE____________$Home\[My ]Documents\WindowsPowerShell\Microsoft.P owerShellISE_profile.ps1
All users, Current Host – ISE_______________$PsHome\Microsoft.PowerShellISE_profile.ps1

