

<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



######################################################################################################################
#
# TOOLS : BELOW, YOU WILL FIND MISC TOOLS RELATED TO THE PSAUTOUPDATE SCRIPT. WHEN IN THE GUI YOU ARE CALLING 
#         FUNCTION, IT WILL BE ASSOCIATED TO A FUNCTION HERE.
#
# FUNCTIONS:  - Get-CurrentScriptVersion
#             - Get-LatestScriptVersion
#             - Update-ScriptVersion
#
######################################################################################################################



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
    $StoredValue = Get-Variable -Name 'ScriptVersionSystem_OBJECT' -ValueOnly -ErrorAction Ignore
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



function Create-ScriptVersionFile{

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
                throw "The Path argument must be a file. Directory paths are not allowed."
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [String]$ScriptPath,
        [Parameter(Mandatory=$false)]
        [String]$ScriptVersion = '1.0.0.0'
    ) 


  
    [ScriptVersionData]$NewVer = New-Object -TypeName ScriptVersionData -ErrorAction Stop

     # Validate the declaration of the ScriptVersion object
    try{
        $VersionFilePath = $NewVer.Create($ScriptPath,$ScriptVersion)
        Write-Verbose "Create-ScriptVersionFile results $VersionFilePath"
        return $VersionFilePath
    }catch{

        [System.Management.Automation.ErrorRecord]$Record = $_
        $formatstring = "{0}`n{1}"
        $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
        $ExceptMsg=($formatstring -f $fields)
        Write-Verbose "Create-ScriptVersionFile FAILURE. Last Error message is $ExceptMsg"
    }

 
}

function Get-ScriptVersion {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [String]$ScriptPath,
        [Parameter(Mandatory=$false)]
        [String]$VersionFilePath
    )


    try{
        if ($PSBoundParameters.ContainsKey('ScriptPath')) {
            $ext = (Get-Item -Path "$ScriptPath").Extension
            if($ext -ne '.ps1'){
                throw "invalid file type"
            }
            $fi = Get-Item -Path "$ScriptPath"
            $tmpObj = Get-ScriptVersionSystemObject
            $VersionFilePath = Join-Path $fi.DirectoryName $fi.BaseName
            $VersionFilePath += '.ver'
            Write-Verbose "Looking for $VersionFilePath"
        }elseif($PSBoundParameters.ContainsKey('VersionFilePath')) {
            Write-Verbose "Looking for $VersionFilePath"
            $ext = (Get-Item -Path "$VersionFilePath").Extension
            if($ext -ne '.ver'){
                throw "invalid file type"
            }
        }
        else{
            throw "must specify VersionFilePath or ScirpPath "
        }


        
        if(Test-Path -Path $VersionFilePath -PathType Leaf){
             Write-Verbose "LoadFromCliXml $VersionFilePath"
            $tmpObj.LoadFromCliXml( $VersionFilePath )
        }else{
            throw "missing  $VersionFilePath "
        }

        [ScriptVersionData]$obj = Import-Clixml $VersionFilePath
        $v = $obj.GetVersion()
        return $v
    }
    catch{
         Write-Host -n -f DarkYellow "[ERROR] "; Write-Host -f DarkRed " $_";
    }

}
