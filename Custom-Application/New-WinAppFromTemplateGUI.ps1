


Function ReplaceStrings($DestinationPath)
{
        $NewGuid = (new-guid).Guid
        $AnchorQt5 = 'xxxUSINGQT5xxx'
        $AnchorWinsock = 'xxxUSINGWINSOCKxxx'
        $AnchorSubSystem = 'xxxTEMPLATESUBSYSTEMxxx'
        $AnchorGuid = 'xxxPROJECTGUIDxxx'
        $AnchorCharSet = 'xxxCHARACTERSETxxx'
        $AnchorProjectName = 'xxxPROJECTNAMExxx'

        $FileList = [System.Collections.ArrayList]::new()

       
        $FileList.Add("$DestinationPath\vs\app.vcxproj") | Out-null
        $FileList.Add("$DestinationPath\vs\cfg\app.props") | Out-null
        ForEach($File in $FileList)
        {
            if(-not(Test-Path $File)){
                Write-Error "could not find file $File"
                return
            }
            $FileContent = Get-Content $File
            Write-Output "Updating $File..."
            # File Content is replaced by the correct values 
            $FileContent = ($FileContent -replace $AnchorGuid, $NewGuid)
            $FileContent = ($FileContent -replace $AnchorQt5, $Opt_UseQT)
            $FileContent = ($FileContent  -Replace $AnchorWinsock, $Opt_UseWinSock)    
            $FileContent = ($FileContent -replace $AnchorCharSet, $Opt_Charset) 
            $FileContent = ($FileContent -replace $AnchorSubSystem, $Opt_Subsystem) 
            $FileContent = ($FileContent -replace $AnchorProjectName, $Opt_ProjectName)

            Set-Content -Path $File -Value $FileContent 
        }
}
Function Get-Folder($initialDirectory="$Env:DevelopmentRoot")
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a destination folder..."
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory
    $folder = ""
    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

Function Show-MsgWarning($message="")
{
    $Image = New-Object System.Windows.Controls.Image
    $Image.Source = $ImageWarning
    $Image.Height = 50
    $Image.Width = 50
    $Image.Margin = 5
     
    $TextBlock = New-Object System.Windows.Controls.TextBlock
    $TextBlock.Text = $message
    $TextBlock.Padding = 10
    $TextBlock.FontFamily = "Verdana"
    $TextBlock.FontSize = 16
    $TextBlock.VerticalAlignment = "Center"
     
    $StackPanel = New-Object System.Windows.Controls.StackPanel
    $StackPanel.Orientation = "Horizontal"
    $StackPanel.AddChild($Image)
    $StackPanel.AddChild($TextBlock)
    Show-MessageBox -Content $StackPanel -Title "WARNING" -TitleFontSize 28 -TitleBackground Orange
}


function PopupBanner([script]$BannerImagePath)
{
        $Code = {
            Write-Verbose 'Loaded'
        }
        $Source = $BannerImagePath
        $Image = New-Object System.Windows.Controls.Image
        $Image.Source = $Source
        $Image.Height = [System.Drawing.Image]::FromFile($Source).Height
        $Image.Width = [System.Drawing.Image]::FromFile($Source).Width
        $Params = @{
   
            Content = $Image
            TitleBackground ='Navy'
            TitleTextForeground = 'Navy'
            FontFamily = 'Lucida Console'
            ButtonType = 'None'
            Timeout = 5
            CornerRadius = 40
            ShadowDepth = 0
            BlurRadius = 0
            BorderThickness = 0
            BorderBrush = 'Navy'
            ContentBackground = "Navy"
            #Sound = 'Windows Message Nudge'
            OnLoaded = $Code
        }       
        Show-MessageBox @Params
}

try
{
    $ScriptReturnValue = 0
    $OrigError = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"

    $CurrentPath = (Get-Location).Path
    Write-Verbose "Looked up Ui files in path $CurrentPath"



    # where is the XAML file?
    $xamlFile = "$CurrentPath\ui.xaml"
    Write-Output "Loading $xamlFile..."
    if(-not(Test-Path -Path $xamlFile))
    {
        throw [System.IO.FileNotFoundException]::new("Could not find path: $xamlFile")
    }

    Write-Verbose "Loading xaml file: $xamlFile"


    #create window
    $inputXML = Get-Content $xamlFile -Raw
    $inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
    [XML]$XAML = $inputXML

    #Read XAML
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $window = [Windows.Markup.XamlReader]::Load( $reader )

    # Create variables based on form control names.
    # Variable will be named as 'var_<control name>'

    $xaml.SelectNodes("//*[@Name]") | ForEach-Object {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    }
    Get-Variable var_*

<#

Name                           Value
----                           -----
var_BtnBrowse                  System.Windows.Controls.Button : Browse...
var_BtnCancel                  System.Windows.Controls.Button : Cancel
var_BtnGenerate                System.Windows.Controls.Button : Generate
var_CheckQt                    System.Windows.Controls.CheckBox Content:Use QT IsChecked:False
var_CheckWinsock               System.Windows.Controls.CheckBox Content:Use Winsock IsChecked:False
var_ComboCharSet               System.Windows.Controls.ComboBox Items.Count:0
var_ComboSubSystem             System.Windows.Controls.ComboBox Items.Count:0
var_label                      System.Windows.Controls.Label : Character Set
var_label1                     System.Windows.Controls.Label : C++ Project Settings
var_label2                     System.Windows.Controls.Label : Sub System
var_label3                     System.Windows.Controls.Label : Path
var_label4                     System.Windows.Controls.Label : Name
var_TextName                   System.Windows.Controls.TextBox
var_TextPath                   System.Windows.Controls.TextBox


    var_BtnGenerate.Add_Click( {
       #clear the result box
       
       })

#>
$var_ComboSubSystem.Text = ""
$var_ComboSubSystem.Items.Add("Console");
$var_ComboSubSystem.Items.Add("Windows");
$var_ComboCharSet.Text = ""
$var_ComboCharSet.Items.Add("Unicode");
$var_ComboCharSet.Items.Add("Multibyte");
$var_ComboCharSet.Items.Add("NotSet");

    $var_BtnBrowse.Add_Click( {
       #clear the result box
       # & $MsgBox17
       $var_TextPath.Text = Get-Folder
       
       })
    $var_BtnCancel.Add_Click( {
        $window.CLose()
       })

    $var_BtnGenerate.Add_Click( {
        if($var_TextName.Text -eq ""){
            Show-MsgWarning "Please Specify Project Name"
            return;
        }
        if($var_TextPath.Text -eq ""){
            Show-MsgWarning "Please Specify Project Path"
            return;
        }
        if($var_ComboCharSet.Text -eq ""){
            Show-MsgWarning "Please Specify Character Set"
            return;
        }
        if($var_ComboSubSystem.Text -eq ""){
            Show-MsgWarning "Please Specify a Sub System"
            return;
        }
        $Opt_ProjectName = $var_TextName.Text
        $SourcePath = Resolve-Path ..
        $DestinationPath =  $var_TextPath.Text
        if($DestinationPath[-1] -ne "\") {$DestinationPath += "\"}
        $DestinationPath = $DestinationPath + $Opt_ProjectName
        if(Test-Path -Path $DestinationPath){
            Show-MsgWarning "Destination Folder Already Exists! $DestinationPath"
            return;
        }
        $Opt_Charset = $var_ComboCharSet.Text
        $Opt_Subsystem = $var_ComboSubSystem.Text
        $Opt_UseQT = 0
        $Opt_UseWinSock = 0
        
        If ($var_CheckQt.Checked)
        {
            $Opt_UseQT = 1
        }
        If ($var_CheckWinsock.Checked)
        {
            $Opt_UseWinSock = 1
        }
        New-Item -Path $DestinationPath -ItemType Directory -Force
        & "xcopy" /d /e /s /y $SourcePath $DestinationPath
        ReplaceStrings $DestinationPath
        Show-Success $DestinationPath

       })

    $P = split-Path $script:MyInvocation.MyCommand.Path
    $window.Title = "Visual Studio Project Generator"
    #$PopupBanner = Join-Path $P 'img\banner.jpg'
    #PopupBanner $PopupBanner

    $Null = $window.ShowDialog()

    $ErrorActionPreference = $OrigError
    return $true
              
     
}
catch{
    Write-Warning $_.Exception
    Write-Warning " Caught an Exception Error: $_"
    return $false
}
