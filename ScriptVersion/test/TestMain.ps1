
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

<#
.SYNOPSIS
    
.DESCRIPTION
   
#> 





################################################################################################
# PATHS VARIABLES and DEFAULTS VALUES
################################################################################################

[string]$Script:CurrPath                        = (Get-Location).Path
[string]$Script:RootPath                        = (Resolve-Path ..).Path
[string]$Script:SrcRoot                         = Join-Path $Script:RootPath 'src'
[string]$Script:TestRoot                        = Join-Path $Script:RootPath 'test'


[string]$Script:ScriptVersionDef                = Join-Path $Script:SrcRoot 'ScriptVersionDef.ps1'
[string]$Script:ScriptVersionApi                = Join-Path $Script:SrcRoot 'ScriptVersionApi.ps1'

[string]$Script:TestMain                        = Join-Path $Script:TestRoot 'TestMain.ps1'
[string]$Script:TestImpl                        = Join-Path $Script:TestRoot 'TestImpl.ps1'
[string]$Script:NetConnectionVerbosity          = 'Quiet'

[string]$script:UNKNOWN_VERSION                 = '99.99.99.99'
[string]$script:DEFAULT_VERSION                 = '1.0.0.0'



# BASIC INCLUSION OF SCRIPT VERSION CLASS

. "$Script:ScriptVersionDef"


[bool]$Global:ScriptVersionStatus               = $False
[int]$Global:ScriptVersionMemberCount           = 0
[int]$Global:ScriptVersionActivationtime        = 0
$Global:ScriptVersionObject  = $Null
#[ScriptVersionData]



#==============================================================================================================================================================
#                                             --------------  SYSTEM INITIALIZATION AND UNINITIALIZATION  --------------
#==============================================================================================================================================================



function Get-ScriptVersionSystemStatus{
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-Verbose "Get-ScriptVersionSystemStatus -- status $Global:ScriptVersionStatus"
    return $Global:ScriptVersionStatus
}

function Get-ScriptVersionSystemObject{
    [CmdletBinding(SupportsShouldProcess)]
    param() 
    Write-Verbose "Get-ScriptVersionSystemObject Trying stored global, readonly variable named `"ScriptVersionSystem_OBJECT`"..."
    $StoredValue = Get-Variable -Name 'ScriptVersionSystem_OBJECT' -ValueOnly 
    if( $StoredValue -ne $Null ){
        Write-Verbose "Get-ScriptVersionSystemObject variable named `"ScriptVersionSystem_OBJECT`" exists and valid "
        return $StoredValue
    }

    Write-Verbose "Get-ScriptVersionSystemObject  Will use script global variable..."
    if( $Global:ScriptVersionObject -ne $Null ){
        Write-Verbose "  `$Global:ScriptVersionObject variable is not null"
    }else{
        Write-Verbose "  `$Global:ScriptVersionObject variable is null"   
    }

    return $Global:ScriptVersionObject 
}


function Initialize-ScriptVersionSystem{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$Force
    ) 


    if( $Global:ScriptVersionStatus -eq $True ){        
        if( $Force -eq $False){
            Write-Verbose "Initialize-ScriptVersionSystem called but status is already initialized"
            return $True
        }else {
            Write-Verbose "Initialize-ScriptVersionSystem FORCE Re-Initialization"
        }
    }

    $InitializationErrorOccured = $False

     # Validate the declaration of the ScriptVersion object
    try{
        # New Select-Object
        $Global:ScriptVersionObject = New-Object -TypeName ScriptVersionData -ErrorAction Stop

        $ObjMembers = $Global:ScriptVersionObject | gm
        $Global:ScriptVersionMemberCount = $ObjMembers.Count

        # Set the instanciation time...
        $Global:ScriptVersionActivationtime = Get-Date -UFormat %s

        $ActivationPrettyTime = Get-Date
        $TimeStr = $ActivationPrettyTime.ToLocalTime().ToString("yyyy-MM-dd HH.mm.ss")
        Write-Verbose "Initialize-ScriptVersionSystem SUCCESS. ActivationTime is $TimeStr"
        Write-Verbose "Initialize-ScriptVersionSystem SUCCESS. Detected $Global:ScriptVersionMemberCount members in object"
        
        $Global:ScriptVersionStatus = $True



        

    }catch{
        $InitializationErrorOccured = $True

        [System.Management.Automation.ErrorRecord]$Record = $_
        $formatstring = "{0}`n{1}"
        $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
        $ExceptMsg=($formatstring -f $fields)
        Write-Verbose "Initialize-ScriptVersionSystem FAILURE. Last Error message is $ExceptMsg"
    }

    if( $InitializationErrorOccured -eq $True ){

        Write-Verbose "Initialize-ScriptVersionSystem FAILURE. Reset flags"
        $Global:ScriptVersionStatus               = $False
        $Global:ScriptVersionMemberCount           = 0
        $Global:ScriptVersionActivationtime        = 0
        $Global:ScriptVersionObject  = $Null
    }

    if (  $InitializationErrorOccured -eq $False ){
        try{
           Write-Verbose "Setting Variable named`"ScriptVersionSystem_OBJECT`" in memory using Set-Variable"
           Set-Variable -Name 'ScriptVersionSystem_OBJECT' -Value $Global:ScriptVersionObject -Scope Global -Force -Visibility Public -ErrorAction Stop -Option allscope, readonly 
        }catch{
            Write-ErrorMessage $_
        }
        
    }

    return $Global:ScriptVersionStatus
}

function Destroy-ScriptVersionSystem{

    [CmdletBinding(SupportsShouldProcess)]
    param()   


    if( $Global:ScriptVersionStatus -eq $True ){

        $DestroyNowTime = Get-Date
        $TimeStr = $DestroyNowTime.ToLocalTime().ToString("yyyy-MM-dd HH.mm.ss")

        $ScriptVersionUninitTime = Get-Date -UFormat %s
        $AliveTime = $ScriptVersionUninitTime - $Global:ScriptVersionActivationtime
        
        Write-Verbose "Destroy-ScriptVersionSystem called on $TimeStr. System was active for $AliveTime seconds in total."

        $Global:ScriptVersionStatus               = $False
        $Global:ScriptVersionMemberCount           = 0
        $Global:ScriptVersionActivationtime        = 0
        $Global:ScriptVersionObject  = $Null
    }else{
        Write-Warning "Destroy-ScriptVersionSystem called on INACTIVE system. No action taken."
    }  
}




. "$Script:TestImpl"

syslog "===== TestMain.ps1 ===== "
syslog "test script is starting."


syslog "============================================================"
syslog "          -------------- PREPARATION --------------         "
syslog "============================================================"



syslog "`t`t -- Initialization..."

$Result = Initialize-ScriptVersionSystem -Verbose

syslog "`t`t -- > done. Result $$Result"



syslog "============================================================"
syslog "       -------------- LOAD TEST DATA --------------         "
syslog "============================================================"


$tmpObj = Get-ScriptVersionSystemObject
$tmpObj.LoadTestData( )


syslog "`t`t -- LoadTestData..."

[string]$DataStr = $tmpObj.ToString()

[string]$DataHash = $tmpObj.ToHash()

syslog "============================================================"
syslog "       -------------- VISUALIZE DATA --------------         "
syslog "============================================================"


syslog "`t`t -- Object as String --"
syslog -i "$DataStr"
syslog "`t`t -- Object as SHA1 Hash --"
syslog -i "$DataHash"




syslog "============================================================"
syslog "       -------------- SERIALIZATION --------------         "
syslog "============================================================"

[string]$DataHash = $tmpObj.ToHash()

syslog "Object before serialization"
syslog -i "$DataHash"
[string]$jfile = $tmpObj.ToCliXml()

syslog "saved to json file `"$jfile`""
$TmpObject = New-Object -TypeName ScriptVersionData -ErrorAction Stop

syslog "loading from json file `"$jfile`" in new object"
$TmpObject.LoadFromCliXml($jfile)

[string]$DataHash = $TmpObject.ToHash()

syslog "Object after serialization"
syslog -i "$DataHash"

[string]$DataStr = $tmpObj.ToString()

syslog "`t`t -- Object 1 as String --"
syslog -i "$DataStr"



[string]$DataStr = $TmpObject.ToString()

syslog "`t`t -- Object 2 as String --"
syslog -i "$DataStr"