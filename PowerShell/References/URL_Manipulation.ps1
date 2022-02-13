<#
	.SYNOPSIS
		Encoding and Decoding URL

	.DESCRIPTION
		This script will encode and decode the give URL

	.EXAMPLE
		PS C:\> .\URL_Manipulation.PS1

	.INPUTS
		Eg: http://www.google.com
		Eg: http://www.hotmail.com

	.OUTPUTS
		Encoded URL - Http%3a%2f%2fwww.hotmail.com for http://www.hotmail.com

	.NOTES
		If you have PowerGUI (Press CTRL+I and Insert VBScript and Choose Unescape
		You can modify the code as per your requirement

	.LINK
		help .\URL_Manipulation.ps1 -Showwindow

	.LINK
		http://social.technet.microsoft.com/profile/chen%20v/?ws=usercard-inline

#>


[Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null
$URL = Read-Host "Enter URL to Decode"
$Encode = [System.Web.HttpUtility]::UrlEncode($URL)
Start-Sleep 3
Write-Host "This is the Encoded URL" $Encode -ForegroundColor Green
Start-Sleep 3
$Decode = [System.Web.HttpUtility]::UrlDecode($Encode)
Start-Sleep 3
Write-Host "This is the Decoded URL" $Decode -ForegroundColor Green