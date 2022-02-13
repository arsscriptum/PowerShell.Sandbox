#region Synchronized Collections
$uiHash = [hashtable]::Synchronized(@{})
$runspaceHash = [hashtable]::Synchronized(@{})
$jobs = [system.collections.arraylist]::Synchronized((New-Object System.Collections.ArrayList))
$jobCleanup = [hashtable]::Synchronized(@{})

#Ensure that we are running the GUI from the correct location
Set-Location $(Split-Path $MyInvocation.MyCommand.Path)
$Global:Path = $(Split-Path $MyInvocation.MyCommand.Path)
Write-Debug "Current location: $Path"


#Determine if this instance of PowerShell can run WPF 
Write-Verbose "Checking the apartment state"
If ($host.Runspace.ApartmentState -ne "STA") {
    Write-Warning "This script must be run in PowerShell started using -STA switch!`nScript will attempt to open PowerShell in STA and run re-run script."
    Start-Process -File PowerShell.exe -Argument "-STA -noprofile -WindowStyle hidden -file $($myinvocation.mycommand.definition)"
    Break
}

#Load Required Assemblies
Add-Type –assemblyName PresentationFramework
Add-Type –assemblyName PresentationCore
Add-Type –assemblyName WindowsBase
Add-Type –assemblyName Microsoft.VisualBasic
Add-Type –assemblyName System.Windows.Forms

#Build the GUI
[xml]$xaml = @"
<Window>
   
  
        <ProgressBar x:Name = 'ProgressBar' Grid.Row = '3' Height = '20' ToolTip = 'Displays progress of current action via a graphical progress bar.'/>   
        <TextBox x:Name = 'StatusTextBox' Grid.Row = '4' ToolTip = 'Displays current status of operation'> Waiting for Action... </TextBox>                           
    </Grid>   
</Window>
"@ 




#region Load XAML into PowerShell
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$uiHash.Window=[Windows.Markup.XamlReader]::Load( $reader )
#endregion
 