
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



class ScriptVersionData {
        [string]$ver=""
        [string]$name=""
        [string]$relpath=""
        [string]$algo=""
        [string]$hash=""
        
        [System.DateTime]$updated
        ScriptVersionData ([string]$v,[string]$n,[string]$p,[string]$a,[string]$h) {
            $this.ver = $v
            $this.name = $n
            $this.relpath = $p
            $this.algo = $a
            $this.hash = $h
            $this.updated = (get-date).GetDateTimeFormats()[9]
        }
        ScriptVersionData ([string]$name) {
            $this.ver = '1.0.0.0'
            $this.name = $name
            $this.relpath = ''
            $this.algo = ''
            $this.hash = ''
            $this.updated = (get-date).GetDateTimeFormats()[9]
        }
        ScriptVersionData () {
            $this.ver = ''
            $this.name = ''
            $this.relpath = ''
            $this.algo = ''
            $this.hash = ''
            $this.updated = (get-date).GetDateTimeFormats()[9]
        }
        [string] ToString( ) {
            return ("Version = `"{0}`"`nFileName = `"{1}`"`nRelativePath = `"{2}`"`nHash = `"{3}`"`nAlgo = `"{4}`"`n" -f $this.ver,$this.name,$this.relpath,$this.hash,$this.algo)
        }
        [string] ToCode( ) {
            return ("`$Script:D_Version = `"{0}`"`n`$Script:D_FileName = `"{1}`"`n`$Script:D_RelativePath = `"{2}`"`n`$Script:D_Hash = `"{3}`"`n`$Script:D_Algo = `"{4}`"`n" -f $this.ver,$this.name,$this.relpath,$this.hash,$this.algo)
        }

        [string] UpdateDate( ) {
            $this.updated = (get-date).GetDateTimeFormats()[9]
            [string]$ret = $($this.updated).ToString()
            return $ret
        }
        [string] ToPureXml( ) {
            [string]$rnd = (new-Guid).Guid
            $rnd =  $rnd.Substring(24)
            $file = "$($this.name)" + '_' + "$rnd" + '.xml'
            $xmlpath = Join-Path  "$ENV:TEMP" "$file"
           
            $this | convertto-xml
            $this | ConvertTo-Xml -As Stream
            $this | ConvertTo-Xml -As Stream | set-content -path $xmlpath
            return $xmlpath
        }
        [string] ToCliXml( ) {
            [string]$rnd = (new-Guid).Guid
            $rnd =  $rnd.Substring(24)
            $file = "$($this.name)" + '_' + "$rnd" + '.xml'
            $xmlpath = Join-Path  "$ENV:TEMP" "$file"
            Export-Clixml -InputObject $this -Path "$xmlpath"
            return $xmlpath
        }
        [string] ToJson( ) {
            $data = ConvertTo-Json -InputObject $this
            return $data
        }
        [string] ToJsonFile( ) {
            [string]$rnd = (new-Guid).Guid
            $rnd =  $rnd.Substring(24)
            $file = "$($this.name)" + '_' + "$rnd" + '.json'
            $jsonpath = Join-Path  "$ENV:TEMP" "$file"
            $data = ConvertTo-Json -InputObject $this
            set-content -Path $jsonpath -Value $data 
            return $jsonpath
        }
        [void] LoadFromPureXml( [string]$xmlpath ) {
            $Exists = Test-Path -Path $xmlpath -PathType Leaf -ErrorAction Ignore
            if(-not($Exists)) { throw "no such file" } 
            [xml]$xmldocument = get-content -path $xmlpath
            $xmldocument | gm
        }
        [void] LoadFromCliXml( [string]$xmlpath ) {
            $Exists = Test-Path -Path $xmlpath -PathType Leaf -ErrorAction Ignore
            if(-not($Exists)) { throw "no such file" } 
            $obj = Import-Clixml -Path $xmlpath
            $obj | gm
        }
        [void] LoadFromJson( [string]$jsonpath ) {
            $Exists = Test-Path -Path $jsonpath -PathType Leaf -ErrorAction Ignore
            if(-not($Exists)) { throw "no such file" } 
            $importedJson = [ScriptVersionData]::ConvertFromSerialization((get-content -path $jsonpath | convertfrom-json))
            $importedJson | gm
        }
        [void] LoadTestData(  ) {
            $d = Get-Item -Path "c:\DOCUMENTS\PowerShell\Microsoft.PowerShell_profile.ps1"
            $this.ver   = '9.9.8.8'
            $this.name  = $d.Name
            $this.relpath = Resolve-Path -Relative $d.DirectoryName
            $hd = Get-FileHash -Path $d.Fullname
            $this.algo = $hd.Algorithm
            $this.hash = $hd.Hash
            $this.updated = (get-date).GetDateTimeFormats()[9]
        }
}

function mylog{
    [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="text", Position=0)]
            [Alias('t')]
            [string]$Text
        )
    Write-Host '[Update-VersionFile] ' -f DarkRed -NoNewLine
    Write-Host "$Text" -f Yellow    
}

<#
.SYNOPSIS
   Call this function to get the current, local script version.
.NOTES   
#>
function Update-VersionFile{
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
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="script file path", Position=0)]
        [Alias('p')]
        [string]$Path,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="override of the version file path")]
        [string]$VersionFilePath,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="option")]
        [string]$NewVersion,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="force")]
        [switch]$Force       
    )

        [string]$script:UNKNOWN_VERSION                 = '99.99.99.99'
        [string]$script:DEFAULT_VERSION                 = '1.0.0.0'

        [string]$Script:RootPath                        = (Get-Location).Path
        [string]$Script:ScriptFile                      = Join-Path $PSScriptRoot 'Update-VersionFile.ps1'
        
        [string]$Script:NewVersionString                = $script:DEFAULT_VERSION
        [version]$Script:NewVersion                     = $Script:NewVersionString
        [string]$Script:ScriptRoot                      = (Get-Item -Path $Path).DirectoryName
        [string]$Script:ScriptFilename                  = (Get-Item -Path $Path).Name

        [string]$Script:HashAlgo                        = (Get-FileHash -Path $Path).Algorithm
        [string]$Script:ScriptHash                      = (Get-FileHash -Path $Path).Hash


        [ScriptVersionData]$Script:VersionObject        = new-object ScriptVersionData($Script:ScriptFilename)

        Write-Verbose "=========================== Update-VersionFile ==========================="
        Write-Verbose "RootPath      $Script:RootPath"
        Write-Verbose "ScriptFile    $Script:ScriptFile"
        Write-Verbose "ScriptRoot    $Script:ScriptRoot"
        Write-Verbose "VersionFile   $Script:VersionFile"
        Write-Verbose "RootPath      $Script:RootPath"
        Write-Verbose "HashAlgo      $Script:HashAlgo"
        Write-Verbose "ScriptHash     $Script:ScriptHash"


        [string]$Script:VersionFile                     = Join-Path $ScriptRoot 'Version.nfo'
        $Exists = Test-Path -Path $Script:VersionFile -PathType Leaf -ErrorAction Ignore

        
        if(-not($Exists)) { $Null = New-Item -Path $Script:VersionFile  -ItemType File -Force -ErrorAction Ignore } 


        if ($PSBoundParameters.ContainsKey('VersionFilePath')) {

            Write-Verbose "VersionFilePath Overridden to $VersionFilePath"

            $Exists = Test-Path -Path $VersionFilePath -PathType Leaf -ErrorAction Ignore
            if(-not($Exists)) { 
                if($Force) { 
                    $Null = New-Item -Path $VersionFilePath -ItemType File -Force -ErrorAction Ignore 
                    Write-Verbose "Create new file at $VersionFilePath"
                }else{
                    throw "You specified a file that does not exists. $VersionFilePath, Use -Force" 
                }
            } 
            mylog "Override version file path with $VersionFilePath"                
        }


        
        if ($PSBoundParameters.ContainsKey('NewVersion')) {
            Write-Verbose "NewVersion Overridden to $NewVersion"

            try{
                [version]$VerData = $NewVersion
            }catch{
                Write-Error "Version Format Error: Error while parsing version that was specified: $NewVersion"
                return
            }

            mylog "New Version Value (user-specified)            $NewVersion"
        }else{
            Write-Verbose "Will use defalutversion file. In $Script:VersionFile."
            $Exists = Test-Path -Path $Script:VersionFile -PathType Leaf -ErrorAction Ignore
            if(-not($Exists)) { 
                Write-Verbose "Create new file at $Script:VersionFile"
                $Null = New-Item -Path $Script:VersionFile  -ItemType File -Force -ErrorAction Ignore
                [string]$Script:NewVersionString                = $script:DEFAULT_VERSION
                [version]$Script:NewVersion                     = $Script:NewVersionString
                mylog "New Version Value (default, from null)   $script:DEFAULT_VERSION "
            }else{
                Write-Verbose "Including version file from $Script:VersionFile"
                Write-Verbose "================= VERSION FILE DATA ================="
                . "$Script:VersionFile"
                
                Write-Verbose "D_Version        $Script:D_Version"
                Write-Verbose "D_FileName       $Script:D_FileName"
                Write-Verbose "D_RelativePath   $Script:D_RelativePath"
                Write-Verbose "D_Checksum       $Script:D_Checksum"

                $Script:NewVersionString        = $Script:D_Version
                try{
                    [version]$Script:NewVersion     = $Script:NewVersionString
                }catch{
                    Write-Error "Version Format Error: Error while parsing version  $Script:D_Version"
                    return
                }
                [int]$vm = $Script:NewVersion.Major
                [int]$mn = $Script:NewVersion.Minor
                [int]$rv = $Script:NewVersion.Revision
                [int]$_vm = $vm # major stays the same
                [int]$_mn = $mn++ # increment the Minor
                [int]$_rv = $rm++ # increment the rev
                Write-Verbose "Auto incrementing version number. Minor ++ and Revision ++"
                Write-Verbose " ========== Version Data ========== "
                Write-Verbose "     Major $vm --> $_vm"
                Write-Verbose "     Minor $mn --> $_mn"
                Write-Verbose "     Rev   $rv --> $_rv"
                [string]$Script:NewVersionString  = "$_vm" + '.' + "$_mn" + '.' + "$_rv"
                try{
                    [version]$Script:NewVersion     = $Script:NewVersionString
                }catch{
                    Write-Error "Version Format Error: Error while parsing version  $Script:D_Version"
                    return
                }
               
                mylog "New Version Value (auto-incremented)     $Script:NewVersionString "
            } 
        }

        
}

