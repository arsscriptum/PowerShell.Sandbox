<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$false)]
    [switch]$Quiet,
    [Parameter(Mandatory=$false)]
    [switch]$NoProgress
)

function AutoUpdateProgress {   # NOEXPORT
    $Len = $Global:Channel.Length
    $Diff = 50 - $Len
    For($i = 0 ; $i -lt $Diff ; $i++){ $Global:Channel += '.'}
    $Global:ProgressMessage = "Clearing $Global:Channel... ( $Global:StepNumber on $Global:TotalSteps) ERRORS $Global:ErrorCount"
    Write-Progress -Activity $Global:ProgressTitle -Status $Global:ProgressMessage -PercentComplete (($Global:StepNumber / $Global:TotalSteps) * 100)

}

function CheckAdmin {
    #This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
        return $False
    }
    return $True
}


function Clear-EventEntries {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$Quiet,
        [Parameter(Mandatory=$false)]
        [switch]$NoProgress
    )

    if(-not (CheckAdmin)){
        throw "You needs to be run an Administrator in order to clear event entries"
        return
    }
    $wev=(get-command wevtutil.exe).Source
    [string]$WorkingDir = Split-Path $script:MyInvocation.MyCommand.Path
    $List=&"$wev" el
    $Global:ProgressTitle = 'LOGS CLEANUP'
    $Global:StepNumber = 0
    $Global:TotalSteps = $List.Count
    $Global:ErrorList = [System.Collections.ArrayList]::new()
    $Global:ErrorCount = 0
    Write-Host "Clear-EventEntries: will reset $Global:TotalSteps event sources" -ForegroundColor DarkGray
    $TmpFile=(New-TemporaryFile).Fullname
    Foreach( $c in $List ){
        #--trace --verbose --debug
        $Global:Channel = $c
        try{

            if($Quiet){
                &"$wev" 'cl' "$c" 2>1 |out-null
            }else{
                &"$wev" 'cl' "$c" 
            }
            
            if($?){
                $Global:StepNumber++    
            }else{

                $Global:ErrorCount++
            }
            
            if($Global:ErrorCount -gt 5){
                write-error "Maybe you fucked up mate, just maybe. Use -ShowErrors"
                return
            }
        }catch{
            [System.Management.Automation.ErrorRecord]$Record = $_
            $formatstring = "{0}`n{1}"
            $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
            $ExceptMsg=($formatstring -f $fields)  
          
            $null=$Global:ErrorList.Add($ExceptMsg) 
            $Global:ErrorCount++
        }
        
        if( $NoProgress -eq $False ) { AutoUpdateProgress }
    }
    if( $NoProgress -eq $False ) { 
        Write-Progress -Activity $Global:ProgressTitle -Status Completed 
    }
    
    if($ErrorCount -eq 0){
        Write-Host "[DONE] " -NoNewLine -ForegroundColor DarkGreen; 
        Write-Host "Clear-EventEntries completed without errors" -ForegroundColor DarkGray
    }else{
        Write-Host "[WARNING] " -NoNewLine -ForegroundColor DarkRed; 
        Write-Host "Clear-EventEntries completed with $ErrorCount errors" -ForegroundColor DarkYellow
        $ErrorList | % { 
            Write-Host "[ERROR] " -NoNewLine -ForegroundColor DarkRed; 
            Write-Host "$_" -ForegroundColor DarkYellow
        }
    }
}



Clear-EventEntries