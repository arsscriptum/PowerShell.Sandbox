<#̷#̷\
#̷\ 
#̷\   ⼕ㄚ乃㠪尺⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\    
#̷\   𝘗𝘰𝘸𝘦𝘳𝘴𝘩𝘦𝘭𝘭 𝘚𝘤𝘳𝘪𝘱𝘵 (𝘤) 𝘣𝘺 <𝘮𝘰𝘤.𝘥𝘶𝘰𝘭𝘤𝘪@𝘳𝘰𝘵𝘴𝘢𝘤𝘳𝘦𝘣𝘺𝘤>
#̷\ 
#̷##>





[CmdletBinding(SupportsShouldProcess)]
Param
()  


function BuildException{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.ErrorRecord]$Record,
        [Parameter(Mandatory=$false)]
        [switch]$ShowStack
    )       
    $formatstring = "{0}`n{1}"
    $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
    $ExceptMsg=($formatstring -f $fields)
    $Stack=$Record.ScriptStackTrace
    Write-Host "`n[ERROR] -> " -NoNewLine -ForegroundColor DarkRed; 
    Write-Host "$ExceptMsg`n`n" -ForegroundColor DarkYellow
    if($ShowStack){
        Write-Host "--stack begin--" -ForegroundColor DarkGreen
        Write-Host "$Stack" -ForegroundColor Gray  
        Write-Host "--stack end--`n" -ForegroundColor DarkGreen       
    }
}  $


function Invoke-InstallFeatures{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true)]
        [System.Collections.ArrayList]$Capabilities
    )
    try{
        Write-Host "===============================================================================" -f DarkRed
        Write-Host "WINDOWS FEATURES INSTALLATION" -f DarkYellow;
        Write-Host "===============================================================================" -f DarkRed  
        Write-Host "`nListing..." -f DarkYellow;
        
        $CapabilitiesCount = $Capabilities.Count
        Write-Host ">> $CapabilitiesCount uninstalled features" -f DarkYellow;
        $always=$false
        ForEach($feat in $Capabilities){
            Write-Host "[NOT INSTALLED]`t" -f DarkRed -NoNewLine
            Write-Host "WindowsCapability $feat" -f DarkGray 
        }
        ForEach($feat in $Capabilities){
            if($always -eq $false){
                write-host "Install $feat" -f Red -NoNewLine ; 
                $a=Read-Host -Prompt "(Y)es (N)o (All) ?" ; 
                if($a -match "n") {
                    continue;
                }elseif($a -match "a") {
                    $always=$true
                }
            }
            Write-Host "[OK]`t" -f DarkGreen -NoNewLine
            Write-Host "WindowsCapability $feat Added" -f DarkGray 
            Add-WindowsCapability -Online -Name $feat
        }
    } catch{
            BuildException($_)
    } 


}


$Capabilities = [System.Collections.ArrayList]::new()

# Get Language
$Capabilities = (Get-WindowsCapability -Online | Where-Object State -notlike 'Installed' | Where-Object Name -like '*Language*en*US*').Name

Invoke-InstallFeatures $Capabilities