
##===----------------------------------------------------------------------===
##  ┌─┐┬ ┬┌┐ ┌─┐┬─┐┌─┐┌─┐┌─┐┌┬┐┌─┐┬─┐ 
##  │  └┬┘├┴┐├┤ ├┬┘│  ├─┤└─┐ │ │ │├┬┘ 
##  └─┘ ┴ └─┘└─┘┴└─└─┘┴ ┴└─┘ ┴ └─┘┴└─ 
##  ┌┬┐┌─┐┬  ┬┌─┐┬  ┌─┐┌─┐┌┬┐┌─┐┌┐┌┌┬┐
##   ││├┤ └┐┌┘├┤ │  │ │├─┘│││├┤ │││ │ 
##  ─┴┘└─┘ └┘ └─┘┴─┘└─┘┴  ┴ ┴└─┘┘└┘ ┴ 
##
##  Powershell Script (c) by <cybercastor@icloud.com> 
##===----------------------------------------------------------------------===


$ProcessDejaInsight='DejaInsight'
$ProcessDejaLauncher='DejaLauncher'
# get current list off processes...


$processes=(Get-Process | select name -Unique)
$numprocesses=$processes.length
    $Code = {
            $MessageEnDeja='Heads up! You should launch the Trace application'
    Add-Type -AssemblyName System.speech -ErrorAction Stop
    $voix = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $voix.SpeakAsync($MessageEnDeja)       
        }

Write-Host "======================================================================" -f Cyan
Write-Host "Processes: $numprocesses uniques" -f Cyan

if ($processes -match $ProcessDejaInsight -Or $processes -match $ProcessDejaLauncher)
{ 
    Write-Host "Deja is already running...." -f Cyan
}
else
{
     Write-Host  -f Red
     $Content = "Process $dejaprocessname is NOT running! Launch it ?"
     $Params = @{
        Content = "$Content"
        Title = "WARNING"
        ContentBackground = "WhiteSmoke"
        FontFamily = "Tahoma"
        TitleFontWeight = "Heavy"
        TitleBackground = "Red"
        TitleTextForeground = "Yellow"
        Sound = "Windows Message Nudge"
        ButtonType = "Yes-No"
        OnLoaded = $Code
    }

    Show-MessageBox @Params
    $ret=(Get-Variable -Name 'PWSHMessageBoxOutput')
    if($ret -eq 'Yes'){
        $Deja = $env:DEJAINSIGHT;
        $Deja += '\\bin\x64\\DejaLauncher.exe' 
        Start-Process -FilePath $Deja -NoNewWindow;
    }
}

