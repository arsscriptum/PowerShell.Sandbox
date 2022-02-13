




<############################################################################
 ############################################################################
 Powershell Profile Script. Profil locations are described below:
	%windir%\system32\WindowsPowerShell\v1.0\profile.ps1
	This profile applies to all users and all shells.

	%windir%\system32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1
	This profile applies to all users, but only to the Microsoft.PowerShell shell.

	%UserProfile%\My Documents\WindowsPowerShell\profile.ps1
	This profile applies only to the current user, but affects all shells.

	%UserProfile%\My Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
	This profile applies only to the current user and the Microsoft.PowerShell shell.

############################################################################
############################################################################>

$default_script_path="C:\Scripts\Powershell"
$computer_name = $env:computername
$script_path_env='POWERSHELL_SCRIPTS_PATH'
$home_path = [Environment]::GetEnvironmentVariable('USERPROFILE', 'Process')
$app_data_path = "$env:appdata"
$default_path = "C:\Scripts\Powershell"


# GetEnvironmentVariable takes the target, which will either be Machine, Process or User
$script_path_var = [Environment]::GetEnvironmentVariable($script_path_env, 'Machine')

" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
"Starting Powershell on $computer_name"
"The script data folder on computer is $script_path_env"
" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
Set-Location -Path $script_path_var

