
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



##===----------------------------------------------------------------------===
##  ScriptVersionDef.ps1 - PowerShell -- script version class definition --
##
##  ScriptVersionData is a class containing the version information for a   
##  powershell script file. It also provides useful serialization/deserialization
##  functions for different file format:
##    - json
##    - xml (clixml is powershell-specific xml serialization)
##    - pure xml
##
##  In order to facilitate the class tests the LoadTestData() function is 
##  provided to generate random data and load the internal structure.
##
##  Guillaume Plante <guillaumeplante.qc@gmail.com>
##  Copyright(c) All rights reserved.
##===----------------------------------------------------------------------===
 
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
            # -- RANDOM FILENAME -- Generate a new file, with a random filename, for testing purposes...
            #    Generate a random filename using the GUID CmdLet
            [string]$NewName = (New-Guid).Guid
            $NewName = $NewName + ".txt"
            [string]$TestFilename = Join-Path "$ENV:TEMP" $NewName

            Write-Verbose "LoadTestData -> Generating file `"$TestFilename`""

            # Now create this new test file: Make sure that the file is not present. Then use New-Item to create the file and the 
            # complete path, if it doesn't Exists..
            $Null = Remove-Item -Path $TestFilename -Recurse -Force -ErrorAction Ignore
            $Null = New-Item -Path $TestFilename -ItemType 'file' -Force -ErrorAction Ignore
            Write-Verbose "LoadTestData -> Remove and New item on `"$TestFilename`""


            # Last step, add some content in this test file...
            $tmpdate = (Get-Date).GetDateTimeFormats()[9]
            $tmpname = $ENV:COMPUTERNAME
            [string]$tmpfilecontent = [string]::Format("`t == SCRIPT VERSION SYSTEM == `n`t ===========================`n`n This file was generated on {0} thinks that {1}!",$tmpdate,$tmpname)
            [int]$tmpcontentlen = $tmpfilecontent.Length
            Write-Verbose "LoadTestData -> Adding file content. Content lenght $tmpcontentlen."

            $Null = Set-Content -Path $TestFilename -Value $tmpfilecontent

            $fi = Get-Item -Path "$TestFilename"
           

    
            $this.ver   = '9.9.8.8'
            $this.name  = $fi.Name
            $this.relpath = Resolve-Path -Relative $fi.DirectoryName
            $hd = Get-FileHash -Path $fi.Fullname
            $this.algo = $hd.Algorithm
            $this.hash = $hd.Hash
            $this.updated = (get-date).GetDateTimeFormats()[9]
        }

        [void] DbgLog( [string]$message ) {
            
            $timestr = '{0}' -f ([system.string]::format('{0:HH.mm.ss}',(Get-Date))) 
            [string]$logcnt = [string]::Format("{0} - {1}",$timestr,$message)
            Write-Host -n -f DarkCyan "[ScriptVersionData] " ; Write-Host "$logcnt"
        }
}
