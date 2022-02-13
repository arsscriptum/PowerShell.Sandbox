
$ScriptsRoot = $env:ScriptsRoot
if(!(Test-Path $ScriptsRoot))
{
    exit -1
}

$GuiScript = Join-Path $env:ScriptsRoot 'PowerShell\GUI\New-WPFMessageBox.ps1'

. $GuiScript

$ProcessScript = Join-Path $env:ScriptsRoot 'PowerShell\Processes\Invoke-Process.ps1'

. $ProcessScript

Add-Type -AssemblyName System.Windows.Forms
$TextWindow = new-object System.Windows.Forms.TextBox

function Start-Parallel {
    param(
        [ScriptBlock[]]
        [Parameter(Position = 0)]
        $ScriptBlock,

        [Object[]]
        [Alias("arguments")]
        $parameters
    )

    $jobs = $ScriptBlock | ForEach-Object { Start-Job -ScriptBlock $_ -ArgumentList $parameters }
    $colors = "Blue", "Red", "Cyan", "Green", "Magenta"
    $colorCount = $colors.Length

    try {
        while (($jobs | Where-Object { $_.State -ieq "running" } | Measure-Object).Count -gt 0) {
            $jobs | ForEach-Object { $i = 1 } {
                $fgColor = $colors[($i - 1) % $colorCount]
                $out = $_ | Receive-Job
                $out = $out -split [System.Environment]::NewLine
                $out | ForEach-Object {
                    Write-Host "$i> "-NoNewline -ForegroundColor $fgColor
                    Write-Host $_
                }
                
                $i++
            }
        }
    } finally {
        Write-Host "Stopping Parallel Jobs ..." -NoNewline
        $jobs | Stop-Job
        $jobs | Remove-Job -Force
        Write-Host " done."
    }
}


function call_Clean 
{


}




function call_CreateTestLabConfig 
{
    $ScriptBlock = {
      param($pipelinePassIn) 
      Push-Location "D:\Code\Work\Bodycad\ShellScripts"
      $ProcessScript = Join-Path $env:ScriptsRoot 'PowerShell\Processes\Invoke-Process.ps1'
      . $ProcessScript
      $Arguments = @('/c','D:\Code\set-env.bat')
      Invoke-Process 'c:\Windows\System32\cmd.exe' $Arguments
      $Arguments = @('/c','D:\Code\Work\Bodycad\ShellScripts\BuildTests.bat')
      $Ret = Invoke-Process 'c:\Windows\System32\cmd.exe' $Arguments
       Pop-Location
     }

    $ScriptBlockTwo = {
      param($pipelinePassIn) 
      $MyTmpWorkSpace = Join-Path $env:LOCALAPPDATA "Scripts"
      $TmpFile = Join-Path $MyTmpWorkSpace "stdOutTempFile.txt"
      $OutFile = Get-Content -Path $TmpFile
      #Get-Content $OutFile -Wait

      

     }



     Start-Parallel $ScriptBlock

     Start-Parallel $ScriptBlockTwo  
}
<#

       
$sb = [scriptblock] {param($system) gwmi win32_operatingsystem -ComputerName $system | select csname,caption} 

$servers = Get-Content servers.txt 

$rtn = Invoke-Async -Set $server -SetParam system  -ScriptBlock $sb

#>

function call_LocalDeploy 
{
      # Here the path to call your script
      . "C:\Scripts\Script3.ps1"     
}


function CreateFormButton ( $locationheight, $locationwidth, $sizeheight, $sizewidth, $fieldname, $functionname ) {
  $Button = New-Object System.Windows.Forms.Button 
  $Button.Location = New-Object System.Drawing.Size($locationheight, $locationwidth) 
  $Button.Size = New-Object System.Drawing.Size($sizeheight, $sizewidth) 
  $Button.Text = $fieldname 
  $Button.Add_Click( $functionname ) 
  $Form.Controls.Add($Button) 
}

function CreateStartPosition ( $FormSize, $FormLocation ) {
 $Form.Size = New-Object System.Drawing.Size ($varFrmMSizeWidth, $varFrmMSizeHeight)
 $Form.Location = New-Object System.Drawing.Point($varFrmMLocationX, $varFrmMLocationY)
 $Form.Controls.Add($TextWindow) 
}


function CreateTextWindow ( $locationHeight, $LocationWidth, $TextBoxHeight, $TextBoxWidth, $name) {
  
  $TextWindow.Size = New-Object System.Drawing.Size($textBoxHeight,$textBoxWidth)
  $TextWindow.location = new-object system.drawing.point($locationHeight,$LocationWidth)
  $TextWindow.Name = $name
  $TextWindow.Multiline = $true
  $TextWindow.Font                   = 'Microsoft Sans Serif,10'
  $TextWindow.Text                   = "testtest"
  $Form.Controls.Add($TextWindow) 
}


$Form = New-Object system.Windows.Forms.Form
$Form.Text = "Test Lab Tool"
#$Form.TopMost = $true
$Form.Size = New-Object System.Drawing.Size (475, 600)
$Form.Location = New-Object System.Drawing.Point(4000, 300)


CreateFormButton 20 100 120 40 'Clean' ${function:call_Clean}
CreateFormButton 170 100 120 40 'Create TestLab Config' ${function:call_CreateTestLabConfig}
CreateFormButton 315 100 120 40 'Local Deploy'
CreateTextWindow 20 160 415 375 'TestTextBox'

$Form.ShowDialog()