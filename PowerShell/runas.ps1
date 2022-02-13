Write-Host "Checking for elevation... " 
$CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
if (($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) -eq $false)
{
	$ArgumentList = "-noprofile -noexit -file `"{0}`" -Path `"$Path`" -MaxStage $MaxStage"
	If ($ValidateOnly) { $ArgumentList = $ArgumentList + " -ValidateOnly" }
	If ($SkipValidation) { $ArgumentList = $ArgumentList + " -SkipValidation $SkipValidation" }
	If ($Mode) { $ArgumentList = $ArgumentList + " -Mode $Mode" }
	Write-Host "elevating"
	Start-Process powershell.exe -Verb RunAs -ArgumentList ($ArgumentList -f ($myinvocation.MyCommand.Definition)) -Wait
	Exit
} 
write-host "in admin mode.."
