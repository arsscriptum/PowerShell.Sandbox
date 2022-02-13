If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) #Check is user starting script administrator


{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

$ServerIdomena = Read-Host -Prompt 'Enter domain and user information, example: Domain\SQLUser or Server\SQLUser' 


if( [string]::IsNullOrEmpty($ServerIdomena) ) {      #Error return if no data entered
	Write-Host "Computer name is not entered"
	exit
}

$sidstr = $null
try {
	$ntprincipal = new-object System.Security.Principal.NTAccount "$ServerIdomena"
	$sid = $ntprincipal.Translate([System.Security.Principal.SecurityIdentifier])
	$sidstr = $sid.Value.ToString()
} catch {
	$sidstr = $null
}

Write-Host "Account: $($ServerIdomena)" -ForegroundColor DarkCyan

if( [string]::IsNullOrEmpty($sidstr) ) {
	Write-Host "Unknown user!NOT FOUND!" -ForegroundColor Red
	exit -1
}

Write-Host "Account SID: $($sidstr)" -ForegroundColor DarkCyan

$tmp = [System.IO.Path]::GetTempFileName()

Write-Host "Checking security logon right" -ForegroundColor DarkCyan
secedit.exe /export /cfg "$($tmp)" 

$c = Get-Content -Path $tmp 

$currentSetting = ""

foreach($s in $c) {
	if( $s -like "SeServiceLogonRight*") {
		$x = $s.split("=",[System.StringSplitOptions]::RemoveEmptyEntries)
		$currentSetting = $x[1].Trim()
	}
}

if( $currentSetting -notlike "*$($sidstr)*" ) {
	Write-Host "Setting ""Logon as a Service rights""" -ForegroundColor DarkCyan
	
	if( [string]::IsNullOrEmpty($currentSetting) ) {
		$currentSetting = "*$($sidstr)"
	} else {
		$currentSetting = "*$($sidstr),$($currentSetting)"
	}
	
	Write-Host "$currentSetting"
	
	$outfile = @"
[Unicode]
Unicode=yes
[Version]
signature="`$StBejbe`$"
Revision=1
[Privilege Rights]
SeServiceLogonRight = $($currentSetting)
"@

	$tmp2 = [System.IO.Path]::GetTempFileName()
	
	
	Write-Host "Writing Local Security Policy" -ForegroundColor DarkCyan
	$outfile | Set-Content -Path $tmp2 -Encoding Unicode -Force

	#notepad.exe $tmp2
	Push-Location (Split-Path $tmp2)
	
	try {
		secedit.exe /configure /db "secedit.sdb" /cfg "$($tmp2)" /areas USER_RIGHTS 
		#write-host "secedit.exe /configure /db ""secedit.sdb"" /cfg ""$($tmp2)"" /areas USER_RIGHTS "
	} finally {	
		Pop-Location
	}
} else {
	Write-Host "ALREADY EXISTING! Account is already set as ""Logon as a Service""" -ForegroundColor DarkCyan

then 

PS C:\> remove-item C:\Windows\System32\LogonAsService.ps1
}

Write-Host "Done." -ForegroundColor DarkCyan
Write-Host -NoNewLine "Press any key to continue...";
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");