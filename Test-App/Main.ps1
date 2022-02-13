

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

$TreeView = New-Object System.Windows.Controls.TreeView
$TreeView.MaxHeight = 500
$TreeView.Height = 400
$TreeView.Width = 400
$TreeView.BorderThickness = 0
"Running","Stopped" | foreach {
    $Item = New-Object System.Windows.Controls.TreeViewItem
    $Item.Padding = 5
    $Item.FontSize = 16
    $Item.Header = $_
    [void]$TreeView.Items.Add($Item)
}
$TreeView.Items[0].ItemsSource = Get-Service | Where {$_.Status -eq "Running"} | Select -ExpandProperty DisplayName
$TreeView.Items[1].ItemsSource = Get-Service | Where {$_.Status -eq "Stopped"} | Select -ExpandProperty DisplayName
 
New-WPFMessageBox -Content $TreeView -Title "Services by Status" -TitleBackground "LightSteelBlue"
