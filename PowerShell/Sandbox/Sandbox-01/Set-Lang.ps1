# example: Set-PowerShellUICulture -Name "en-US"

function Set-PowerShellUICulture {
    param([Parameter(Mandatory=$true)]
          [string]$Name)

    process {
        $culture = [System.Globalization.CultureInfo]::CreateSpecificCulture($Name)

        $assembly = [System.Reflection.Assembly]::Load("System.Management.Automation")
        $type = $assembly.GetType("Microsoft.PowerShell.NativeCultureResolver")
        $field = $type.GetField("m_uiCulture", [Reflection.BindingFlags]::NonPublic -bor [Reflection.BindingFlags]::Static)
        $field.SetValue($null, $culture)
    }
}

$forcechange=$True
$officiallanguage='en-US'
$currentname=(Get-UICulture).DisplayName
$currenttag=(Get-UICulture).Name

$message="Official Language " + $officiallanguage
Write-Host $message -ForegroundColor Green

$message="Current Language " + $currenttag
Write-Host $message -ForegroundColor Yellow

if($forcechange -eq $True)
{
    Set-PowerShellUICulture -Name $officiallanguage
	
	Set-WinUILanguageOverride -Language $officiallanguage
	[int]$lcid=(Get-UICulture).LCID
	[cultureinfo]::CurrentCulture = $officiallanguage; Get-Date
	$culture = new-object "System.Globalization.CultureInfo" $lcid
	[System.Threading.Thread]::CurrentThread.CurrentUICulture = $culture
}

$check1=(Get-UICulture).DisplayName
$check2=([System.Threading.Thread]::CurrentThread.CurrentUICulture).DisplayName
$check3=[CultureInfo]::CurrentUICulture.DisplayName

Write-Host "Check No 1 --> " -ForegroundColor Yellow -NoNewLine
Write-Host $check1 -ForegroundColor Green

Write-Host "Check No 2 --> " -ForegroundColor Yellow -NoNewLine
Write-Host $check2 -ForegroundColor Green

Write-Host "Check No 3 --> " -ForegroundColor Yellow -NoNewLine
Write-Host $check3 -ForegroundColor Green

