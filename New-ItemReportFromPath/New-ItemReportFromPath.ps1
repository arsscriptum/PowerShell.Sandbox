<#̷#̷\
#̷\ 
#̷\   ⼕ㄚ乃㠪尺⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\    
#̷\   𝘗𝘰𝘸𝘦𝘳𝘴𝘩𝘦𝘭𝘭 𝘚𝘤𝘳𝘪𝘱𝘵 (𝘤) 𝘣𝘺 <𝘮𝘰𝘤.𝘥𝘶𝘰𝘭𝘤𝘪@𝘳𝘰𝘵𝘴𝘢𝘤𝘳𝘦𝘣𝘺𝘤>
#̷\ 
#̷##>

<#
    .SYNOPSIS
        New-ItemReportFromPath
             
    .DESCRIPTION
        Create an HTML report from the items located in the path specified by the user, can be certificates, files, anything that will be compatible with (Get-Item)

    .EXAMPLE
        .\New-ReportFromPath.ps1 -Path 'Cert:\LocalMachine\TrustedPublisher' -Name 'scriptsdata' -Online
 #>




[CmdletBinding(SupportsShouldProcess)]
Param
(
    [Parameter(Mandatory=$true,Position=0)]
    [string]$Path,
    [Parameter(Mandatory=$true,Position=1)]
    [string]$Name,
    [Parameter(Mandatory=$false,Position=2)]
    [string]$OutputPath="",
    [Parameter(Mandatory=$false)]
    [switch]$Recurse,
    [Parameter(Mandatory=$false)]
    [switch]$Online
)   


if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript")
 { $ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition }
 else
 { $ScriptPath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0]) 
     if (!$ScriptPath){ $ScriptPath = "." } }

$ThisScript = $MyInvocation.MyCommand.Name
Set-Variable -Name 'ThisScript' -Scope Script -Value $ThisScript


$FGcolors = [enum]::GetValues([System.ConsoleColor])
function Log([string]$Message,[switch]$IsError,[switch]$IsWarning,[switch]$IsSuccess){
    [System.ConsoleColor]$cl = $FGcolors[9]
    if($IsError) { $cl = $FGcolors[4] } elseif ($IsWarning) { $cl = $FGcolors[6] } elseif ($IsSuccess) { $cl = $FGcolors[10] }
    Write-Host "[$Script:ThisScript] " -f DarkCyan -NoNewLine
    Write-Host "$Message" -f $cl
}


try{

    if($OutputPath -eq ""){
        [string]$TempStr = (New-Guid).Guid
        $OutputPath = "$ENV:Temp\$TempStr"
        New-Item -Path $OutputPath -ItemType Directory -Force | Out-null
    }

    $header = @'
<style>

    h1 {

        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 28px;

    } 
</style>

'@

    if($Online){
        Log " ONLINE MODE " -IsWarning
        $hfile = Join-Path $ScriptPath 'OnlineHeader.html'
        $header = Get-Content -Path $hfile
    }


    $Group = (gci -Path $Path -Recurse:$Recurse)
    $GroupLen = $Group.Length
    Log "Found $GroupLen items to compile."
    $Body = ""
    $OutputPath = Join-Path $OutputPath $Name
    Remove-Item -Path $OutputPath -Recurse -Force -ErrorAction Ignore | Out-null
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-null
    $CList = [System.Collections.ArrayList]::new();  $Index = 0 ;
    ForEach ($crt in $Group){ 
        
        $itemname = $crt.Name
        $ItemTitle = "<h2>Item No $Index $itemname</h2>"; $Index = $Index + 1; 
        $Data = ($crt | select * | ConvertTo-Html -As List -Head $header) ; 
        
        
        if($Online){
            $Body += $ItemTitle + '<table><tbody><tr><td class="code"><pre class="wp_syntax" style="font-family: monospace;">' + $Data + '</pre></td></tr></tbody></table>' + "`n`n<br><br><br><br>"; 
        }else {
            $Body += $ItemTitle + '<table><tbody><tr><td>' + $Data + '</td></tr></tbody></table>' + "`n`n<br><br><br><br>"; 
        }
        $null=$CList.Add($Data) ; 
    }
    $Index = 0 ; $Filename = '$Name{0}.html' ;
    ForEach($d in $CList){ $nm = $Filename -f $Index ; Set-Content -Path "$OutputPath\$nm" -Value $d ; $Index = $Index + 1; }


    #The command below will combine all the information gathered into a single HTML report
    $Report = ConvertTo-HTML -Head $header -Body $Body -Title "$Name Report" -PostContent "<p>Creation Date: $(Get-Date)<p>"

    Set-Content -Path "$OutputPath\Report$Name.html" -Value $Report
    Log "Done. File: $OutputPath\Report$Name.html" -IsSuccess
    &"explorer" "$OutputPath\Report$Name.html"
    Sleep 5
    Remove-Item -Path $OutputPath -Recurse -Force -ErrorAction Ignore | Out-null

}
catch{
    Write-Warning $_.Exception
    Write-Warning " Caught an Exception Error: $_"
}




