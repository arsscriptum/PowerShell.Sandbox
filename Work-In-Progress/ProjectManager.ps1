

$ScriptsRoot = $env:ScriptsRoot
if(!(Test-Path $ScriptsRoot))
{
    exit -1
}

$GuiScript = Join-Path $env:ScriptsRoot 'PowerShell\GUI\New-WPFMessageBox.ps1'

. $GuiScript


$MainColor = 'Magenta'
$SpecialColor = 'Red'
$ScriptsPath = $env:ScriptsRoot
$ModulePath = Join-Path $ScriptsPath "PowerShell\Invoke-MsBuild\src\Invoke-MsBuild\Invoke-MsBuild.psm1"

Clear-Host
Write-Host "Importing Module Invoke-MsBuild..." -f $MainColor
Import-Module -Name $ModulePath

$SolutionPath="D:\LatestCode\service.station.mgr"
$ServiceProject = "bccmhost-srv.vcxproj"
$ServiceTesterProject = "bccmhost-srv-runner.vcxproj"

$SolutionFilePath = Join-Path $SolutionPath "bccmhost-srv-runner.sln"
$MainBuildProjectsPath = Join-Path $SolutionPath "build"
$ExternalPath = Join-Path $SolutionPath "external"
$NetlibPath = Join-Path $ExternalPath "netlib"

$ClientProjectPath = Join-Path $NetlibPath "examples\netclient.vcxproj"

$ServiceProjectFilePath = Join-Path $MainBuildProjectsPath $ServiceProject


$Configurations = @('Clean','Debug','Release')
$Platforms = @('x86','x64')

$BuildCleaned = $false

Function CleanAll
{
    Write-Host "============================================"  -f $MainColor
    Write-Host "Cleaning previous build files..."  -f $MainColor
    $Platforms | ForEach-Object {
        Write-Host "Clean " -Nonewline -f $MainColor
        Write-Host "$PSItem"  -Nonewline -f $SpecialColor
         Write-Host " .... " -f $MainColor
        $Parameters = "/target:Clean /property:Configuration=Debug;Platform=$PSItem;BuildInParallel=true /verbosity:Normal /maxcpucount"
        Invoke-MsBuild -Path $SolutionFilePath -MsBuildParameters $Parameters > $null
    }
    $BuildCleaned = $true
}

Function BuildAll
{
param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Configuration = 'Debug',
        [string]$Platform = 'x86'
    )

    $Parameters = "/target:Build /property:Configuration=Debug;Platform=x86;BuildInParallel=true /verbosity:Normal /maxcpucount"
    Invoke-MsBuild -Path $SolutionFilePath -ShowBuildOutputInNewWindow -PromptForInputBeforeClosing -MsBuildParameters $Parameters
}

Function WarningMessage
{
    $Image = New-Object System.Windows.Controls.Image
  $Image.Source = "http://www.asistosgb.com/wp-content/uploads/2017/05/attent.png"
  $Image.Height = 50
  $Image.Width = 50
  $Image.Margin = 5
   
  $TextBlock = New-Object System.Windows.Controls.TextBlock
  $TextBlock.Text = "The file could not be deleted at this time!"
  $TextBlock.Padding = 10
  $TextBlock.FontFamily = "Verdana"
  $TextBlock.FontSize = 16
  $TextBlock.VerticalAlignment = "Center"
   
  $StackPanel = New-Object System.Windows.Controls.StackPanel
  $StackPanel.Orientation = "Horizontal"
  $StackPanel.AddChild($Image)
  $StackPanel.AddChild($TextBlock)
   
  New-WPFMessageBox -Content $StackPanel -Title "WARNING" -TitleFontSize 28 -TitleBackground Orange 
}

Function RoundMessage
{
    $Params = @{
      Title = "QUESTION"
      TitleBackground ='Navy'
      TitleTextForeground = 'White'
      ButtonType = 'Yes-No'
      CornerRadius = 80
      ShadowDepth = 5
      BlurRadius = 5
      BorderThickness = 1
      BorderBrush = 'Navy'
   
  }
  New-WPFMessageBox @Params -Content "The server is not online.
  Do you wish to proceed?"
}

Function FuImageBox
{
    $Source = "D:\Data\finger-1.jpg"
  $Image = New-Object System.Windows.Controls.Image
  $Image.Source = $Source
  $Image.Height = [System.Drawing.Image]::FromFile($Source).Height / 4
  $Image.Width = [System.Drawing.Image]::FromFile($Source).Width / 4
   
  New-WPFMessageBox -Content $Image -Title "Minions Rock!" -TitleBackground LightSeaGreen -TitleTextForeground Black

}
Function ErrorMessage
{
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
  $ComputerName = "DoesntExist"
  Try
  {
      New-PSSession -ComputerName $ComputerName -ErrorAction Stop
  }
  Catch
  {
      New-WPFMessageBox @ErrorMsgParams -Content "$_" -Title "PSSession Error!"
  }
}
Function Build-Netlib
{
    $Configuration = 'Debug'
    $Platform = 'x86'
    $Parameters = "/target:netlib /property:Configuration=Debug;Platform=x86;BuildInParallel=true /verbosity:Normal /maxcpucount"
    Invoke-MsBuild -Path $SolutionFilePath -MsBuildParameters $Parameters
}

Function Build-Service
{
    $Configuration = 'Debug'
    $Platform = 'x86'
    $Parameters = "/target:bccmhost-srv /property:Configuration=Debug;Platform=x86;BuildInParallel=true /verbosity:Normal /maxcpucount"
    Invoke-MsBuild -Path $SolutionFilePath -MsBuildParameters $Parameters
}

Function Build-Service-Runner
{
    $Configuration = 'Debug'
    $Platform = 'x86'
    $Parameters = "/target:bccmhost-srv-runner /property:Configuration=Debug;Platform=x86;BuildInParallel=true /verbosity:Normal /maxcpucount"
    Invoke-MsBuild -Path $SolutionFilePath -MsBuildParameters $Parameters
}

Function BuildClient
{

    $Parameters = "/target:Build /property:Configuration=Debug;Platform=x86;BuildInParallel=true /verbosity:Normal /maxcpucount"
    Invoke-MsBuild -Path $ClientProjectPath -ShowBuildOutputInNewWindow -PromptForInputBeforeClosing -MsBuildParameters $Parameters
}


#---------------------------------------------------------[Initialisations]--------------------------------------------------------
# Init PowerShell Gui
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


#---------------------------------------------------------[Form]--------------------------------------------------------

[System.Windows.Forms.Application]::EnableVisualStyles()

$ProjectManagerForm                    = New-Object system.Windows.Forms.Form
$ProjectManagerForm.ClientSize         = '480,300'
$ProjectManagerForm.text               = "Projects"
$ProjectManagerForm.BackColor          = "#2F2F2F"
$ProjectManagerForm.TopMost            = $false
$Icon                                = New-Object system.drawing.icon ("\\radical-portable\Public\Icons\arnaud.ico")
$ProjectManagerForm.Icon               = $Icon

$Titel                           = New-Object system.Windows.Forms.Label
$Titel.text                      = "Guillaume's Custom Project Build System"
$Titel.AutoSize                  = $true
$Titel.width                     = 25
$Titel.height                    = 10
$Titel.location                  = New-Object System.Drawing.Point(20,20)
$Titel.Font                      = 'Consolas,13'

$Description                     = New-Object system.Windows.Forms.Label
$Description.text                = "Build a project or test it, just use the buttoms below..."
$Description.AutoSize            = $false
$Description.width               = 450
$Description.height              = 50
$Description.location            = New-Object System.Drawing.Point(20,50)
$Description.Font                = 'Consolas,10'

$BuildStatus_01                   = New-Object system.Windows.Forms.Label
$BuildStatus_01.text              = "Status:"
$BuildStatus_01.AutoSize          = $true
$BuildStatus_01.width             = 25
$BuildStatus_01.height            = 10
$BuildStatus_01.location          = New-Object System.Drawing.Point(20,115)
$BuildStatus_01.Font              = 'Consolas,10,style=Bold'

$Status_01                    = New-Object system.Windows.Forms.Label
$Status_01.text               = "Loading..."
$Status_01.AutoSize           = $true
$Status_01.width              = 25
$Status_01.height             = 10
$Status_01.location           = New-Object System.Drawing.Point(100,115)
$Status_01.Font               = 'Consolas,10'

$ProjectDetails                  = New-Object system.Windows.Forms.Label
$ProjectDetails.text             = "Project details"
$ProjectDetails.AutoSize         = $true
$ProjectDetails.width            = 25
$ProjectDetails.height           = 10
$ProjectDetails.location         = New-Object System.Drawing.Point(20,150)
$ProjectDetails.Font             = 'Consolas,12'
$ProjectDetails.Visible          = $false

$PrinterNameLabel                = New-Object system.Windows.Forms.Label
$PrinterNameLabel.text           = "Name:"
$PrinterNameLabel.AutoSize       = $true
$PrinterNameLabel.width          = 25
$PrinterNameLabel.height         = 20
$PrinterNameLabel.location       = New-Object System.Drawing.Point(20,180)
$PrinterNameLabel.Font           = 'Consolas,10,style=Bold'
$PrinterNameLabel.Visible        = $false

$PrinterName                     = New-Object system.Windows.Forms.TextBox
$PrinterName.multiline           = $false
$PrinterName.width               = 314
$PrinterName.height              = 20
$PrinterName.location            = New-Object System.Drawing.Point(100,180)
$PrinterName.Font                = 'Consolas,10'
$PrinterName.Visible             = $false

$ProjectConfigurationLabel                = New-Object system.Windows.Forms.Label
$ProjectConfigurationLabel.text           = "Configuration:"
$ProjectConfigurationLabel.AutoSize       = $true
$ProjectConfigurationLabel.width          = 25
$ProjectConfigurationLabel.height         = 20
$ProjectConfigurationLabel.location       = New-Object System.Drawing.Point(20,210)
$ProjectConfigurationLabel.Font           = 'Consolas,10,style=Bold'
$ProjectConfigurationLabel.Visible        = $false

$ProjectConfiguration                     = New-Object system.Windows.Forms.ComboBox
$ProjectConfiguration.text                = ""
$ProjectConfiguration.width               = 170
$ProjectConfiguration.height              = 20

$Configurations  | ForEach-Object {[void] $ProjectConfiguration.Items.Add($_)}
$ProjectConfiguration.SelectedIndex       = 0
$ProjectConfiguration.location            = New-Object System.Drawing.Point(100,210)
$ProjectConfiguration.Font                = 'Consolas,10'
$ProjectConfiguration.Visible             = $false

$BuildAction_01                   = New-Object system.Windows.Forms.Button
$BuildAction_01.BackColor         = "#ff7b00"
$BuildAction_01.text              = "Go"
$BuildAction_01.width             = 90
$BuildAction_01.height            = 30
$BuildAction_01.location          = New-Object System.Drawing.Point(370,250)
$BuildAction_01.Font              = 'Consolas,10'
$BuildAction_01.ForeColor         = "#ffffff"
$BuildAction_01.Visible           = $false

$cancelBtn                       = New-Object system.Windows.Forms.Button
$cancelBtn.BackColor             = "#ffffff"
$cancelBtn.text                  = "Cancel"
$cancelBtn.width                 = 90
$cancelBtn.height                = 30
$cancelBtn.location              = New-Object System.Drawing.Point(260,250)
$cancelBtn.Font                  = 'Consolas,10'
$cancelBtn.ForeColor             = "#000"
$cancelBtn.DialogResult          = [System.Windows.Forms.DialogResult]::Cancel
$ProjectManagerForm.CancelButton   = $cancelBtn
$ProjectManagerForm.Controls.Add($cancelBtn)

$ProjectManagerForm.controls.AddRange(@($Titel,$Description,$BuildStatus_01,$Status_01,$PrinterName,$PrinterNameLabel,$ProjectConfiguration,$BuildAction_01,$cancelBtn,$ProjectConfigurationLabel,$ProjectDetails))

#-----------------------------------------------------------[Functions]------------------------------------------------------------


Function SetStatus
{
  param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
        [int]$Status = 0
    )
    if ($Status -eq 0) 
    {
      $Status_01.ForeColor = "#00FF51"
      $Status_01.Text = $Message
    }
    if ($Status -eq 1) 
    {
      $Status_01.ForeColor = "#EE0055"
      $Status_01.Text = $Message
    }
    if ($Status -eq 2) 
    {
      $Status_01.ForeColor = "#0F8AAA"
      $Status_01.Text = $Message
    }
    else 
    {
      $Status_01.ForeColor = "#EEFF00"
      $Status_01.Text = $Message
    }
}

function CleanBuildProjects { 

  SetStatus 'Cleaning ...' 0
  #$Status_01.ForeColor = "#7ed321"
  CleanAll

  SetStatus 'Building network ...' 1
  #$Status_01.ForeColor = "#D0021B"
  Build-Netlib

  SetStatus 'Building service ...' 2
  #$Status_01.ForeColor = "#D0021B"
  Build-Service

  SetStatus 'Building service runner...' 3
  #$Status_01.ForeColor = "#D0021B"
  Build-Service-Runner

  SetStatus 'OK' 2
  #$Status_01.ForeColor = "#7ed321"
}

function DoShit { 
  
  $PrinterNameLabel.Visible = $false
  $PrinterName.Visible = $false
  $ProjectConfiguration.Visible = $false
  $BuildAction_01.Visible = $false
  $ProjectDetails.Visible = $false
  $ProjectConfigurationLabel.Visible = $false
  $cancelBtn.text = "Close"
}

#---------------------------------------------------------[Script]--------------------------------------------------------
# Get printers IP Address
$clientIP = (
    Get-NetIPConfiguration |
    Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.Status -ne "Disconnected"
    }
).IPv4Address.IPAddress

$networkAddress = $clientIP.Split('.')
$networkAddress = $networkAddress[0]+"."+$networkAddress[1]+"."+$networkAddress[2]

# Check if printer is online
$printerIp =  $networkAddress + ".31" 
$showBuildCommand = $true

If ($showBuildCommand) {
  $Status_01.text = "Ready!"
  $Status_01.ForeColor = "#7ed321"
  $PrinterNameLabel.Visible = $true
  $PrinterName.Visible = $true
  $ProjectConfiguration.Visible = $true
  $BuildAction_01.Visible = $true
  $ProjectDetails.Visible = $true
  $ProjectConfigurationLabel.Visible = $true
}else{
  $Status_01.text = "No printers found"
  $Status_01.ForeColor = "#D0021B"
  $cancelBtn.text = "Cancel"
}

$BuildAction_01.Add_Click({ FuImageBox })

[void]$ProjectManagerForm.ShowDialog()