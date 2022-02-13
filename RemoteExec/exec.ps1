

$ScriptsRoot = $env:ScriptsRoot
if(!(Test-Path $ScriptsRoot))
{
    exit -1
}


$EmailScript = Join-Path $env:ScriptsRoot 'PowerShell\Send-Email-Func.ps1'
$GuiScript = Join-Path $env:ScriptsRoot 'PowerShell\GUI\New-WPFMessageBox.ps1'
$ProcessScript = Join-Path $env:ScriptsRoot 'PowerShell\Processes\Invoke-Process.ps1'


. $GuiScript
. $ProcessScript
. $EmailScript

Clear-Host


Function MessageToSend
{
    $Source = "https://www.shutterstock.com/blog/wp-content/uploads/sites/5/2019/07/Man-Silhouette.jpg"
    $Image = New-Object System.Windows.Controls.Image
    $Image.Source = $Source
    $Image.Height = [System.Drawing.Image]::FromFile($Source).Height / 2
    $Image.Width = [System.Drawing.Image]::FromFile($Source).Width / 2
     
    $TextBlock = New-Object System.Windows.Controls.TextBlock
    $TextBlock.Text = ""
    $TextBlock.FontSize = "28"
    $TextBlock.HorizontalAlignment = "Center"
     
    $StackPanel = New-Object System.Windows.Controls.StackPanel
    $StackPanel.AddChild($Image)
    $StackPanel.AddChild($TextBlock)
     
    New-WPFMessageBox -Content $StackPanel -Title "yes" -TitleBackground LightSeaGreen -TitleTextForeground Black -ContentBackground LightSeaGreen
}

Function Log
{
    param(
            [string] $Str,
            [string] $Color = 'White'
        )

    Write-Host $Str -BackgroundColor Blue -ForegroundColor $Color
}

Clear-Host
$ErrorMsgParams = @{
    TitleBackground = "Red"
    TitleTextForeground = "Yellow"
    TitleFontWeight = "UltraBold"
    TitleFontSize = 28
    ContentBackground = 'Red'
    ContentFontSize = 18
    ContentTextForeground = 'White'
    ButtonTextForeground = 'White'
    Sound = 'Windows Hardware Fail'
}

$EmailMessageBody = "Remote Reboot"
New-WPFMessageBox @ErrorMsgParams -Content "THIS COMPUTER WILL RESTART - PLEASE BE PATIENT" -Title "A REMOTE COMMNAND WAS ACTIVATED"


Set-Item -Path Env:MESSAGEBODY -Value $EmailMessageBody
$env:MESSAGEBODY = $EmailMessageBody

Send-Notification

MessageToSend

