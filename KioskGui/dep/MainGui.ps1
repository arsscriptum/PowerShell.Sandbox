Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$currPath = $PWD.Path
$depPath = Join-Path $currPath 'dep'

$regScript = Join-Path $depPath 'registry.ps1'

# where is the XAML file?
$xamlFile = Join-Path "$currPath\xml" "ui.xaml" 


. "$regScript"



$Script:RegistryRootPath= "$ENV:OrganizationHKCU\Kiosk"


 if(-not(Test-Path $Script:RegistryRootPath)){
    New-Item -Path $Script:RegistryRootPath -Force  -ErrorAction ignore | Out-null
}


#create window
$inputXML = Get-Content $xamlFile -Raw
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[XML]$XAML = $inputXML

#Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $window = [Windows.Markup.XamlReader]::Load( $reader )
} catch {
    Write-Warning $_.Exception
    throw
}

# Create variables based on form control names.
# Variable will be named as 'var_<control name>'

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)"
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    } catch {
        throw
    }
}
Get-Variable var_*

function Get-File($initialDirectory = $home) {   
    [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    if ($initialDirectory) { $OpenFileDialog.initialDirectory = $initialDirectory }
    $OpenFileDialog.filter = 'All files (*.*)|*.*'
    [void] $OpenFileDialog.ShowDialog()
    return $OpenFileDialog.FileName
}

function SaveSettings{
    Set-RegistryValue "$Script:RegistryRootPath" "ChromePath" "$($var_ChromeAppPath.Text)"
    Set-RegistryValue "$Script:RegistryRootPath" "EdgePath" "$($var_EdgeAppPath.Text)"
    Set-RegistryValue "$Script:RegistryRootPath" "FirefoxPath" "$($var_FirefoxAppPath.Text)"
}

function LoadSettings{
    $var_ChromeAppPath.Text = Get-RegistryValue "$Script:RegistryRootPath" "ChromePath" 
    $var_EdgeAppPath.Text = Get-RegistryValue "$Script:RegistryRootPath" "EdgePath" 
    $var_FirefoxAppPath.Text = Get-RegistryValue "$Script:RegistryRootPath" "FirefoxPath" 
}


function CheckPaths{
  
    $rootPath = Join-Path $PWD.Path 'img'
    if(Test-Path "$($var_EdgeAppPath.Text)" -PathType 'Leaf'){
        $var_Img1.Source = "$rootPath\check.png"
    }else{
       $var_Img1.Source = "$rootPath\cross.png"
    }
    if(Test-Path "$($var_ChromeAppPath.Text)" -PathType 'Leaf'){
        $var_Img2.Source = "$rootPath\check.png"
    }else{
       $var_Img2.Source = "$rootPath\cross.png"
    }
    if(Test-Path "$($var_FirefoxAppPath.Text)" -PathType 'Leaf'){
        $var_Img3.Source = "$rootPath\check.png"
    }else{
       $var_Img3.Source = "$rootPath\cross.png"
    }
}

LoadSettings
CheckPaths

$Browsers = @('Chrome', 'Edge', 'Firefox')


Foreach ($browser in $Browsers)
{
    $var_ComboCharSet.Items.Add($browser);
}

$var_BtnCancel.Add_Click({$window.Close()})
$var_BtnGenerate.Add_Click({CheckPaths;SaveSettings})

$var_BtnBrowseEdge.Add_Click({

    $path = Get-File
    $var_EdgeAppPath.Text = $path
    })
$var_BtnBrowseChrome.Add_Click({
 $path = Get-File
    $var_ChromeAppPath.Text = $path
    })
$var_BtnBrowseFirefox.Add_Click({
 $path = Get-File
    $var_FirefoxAppPath.Text = $path
    })



$Null = $window.ShowDialog()