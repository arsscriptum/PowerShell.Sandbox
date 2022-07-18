


<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



######################################################################################################################
#
# TOOLS : BELOW, YOU WILL FIND MISC TOOLS RELATED TO THE PSAUTOUPDATE SCRIPT. WHEN IN THE GUI YOU ARE CALLING 
#         FUNCTION, IT WILL BE ASSOCIATED TO A FUNCTION HERE.
#
# FUNCTIONS:  
#             - ConvertTo-HeaderBlock
#             - ConvertFrom-HeaderBlock
#             - Convert-ToSmallerArray
#
######################################################################################################################



################################################################################################
# PATHS VARIABLES and DEFAULTS VALUES
################################################################################################

$Global:StartTag = "=== BEGIN FILE VERSION HEADER ==="
$Global:EndTag  = "=== END FILE VERSION HEADER ==="
$Global:HeaderStart = "<# $Global:StartTag `n"
$Global:HeaderEnd = "`n$Global:EndTag #>"



function Convert-ToSmallerArray {
<#
    .Synopsis
        Convert an array in a group of smaller arrays
    .Description
        Convert an array in a group of smaller arrays, with the user specifying number of parts and parts size
    .Parameter BigArray
        The array to convert
    .Parameter NumParts
        number of parts
    .Parameter RequestedSize
        Requested Size
#>
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory=$true,Position=0)]
            [Array]$BigArray,
            [Parameter(Mandatory=$false)]
            [int]$NumParts,
            [Parameter(Mandatory=$false)]
            [int]$RequestedSize
        )


    if ($NumParts) {
        $PartSize = [Math]::Ceiling($BigArray.count / $NumParts)
        Write-Verbose "ToSmallerArray => NumParts is $NumParts"
    }
    if ($RequestedSize) {
        $PartSize = $RequestedSize
        $NumParts = [Math]::Ceiling($BigArray.count / $RequestedSize)
        Write-Verbose "ToSmallerArray => RequestedSize is $RequestedSize"
        Write-Verbose "ToSmallerArray => NumParts is $NumParts"
    }

    $ReturnedArray = @()
    for ($i=1; $i -le $NumParts; $i++) {
        $start = (($i-1)*$PartSize)
        $end = (($i)*$PartSize) - 1
        if ($end -ge $BigArray.count) {$end = $BigArray.count}
        $ReturnedArray+=,@($BigArray[$start..$end])
    }
    return ,$ReturnedArray
}



function ConvertFrom-HeaderBlock {

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
        [String]$Path
        
    )
    $CompleteString = ''
    $FileData = Get-Content -Path $Path -Raw -Encoding 'UTF8'
    $index = $FileData.IndexOf($Global:StartTag)
    $endindex = $FileData.IndexOf($Global:EndTag)
    $index += 34

    [char[]] $CArray = $FileData.ToCharArray() 
    $iMax = $CArray.Count

    Write-Verbose "index $index "
    Write-Verbose "endindex $endindex "
    Write-Verbose "iMax $iMax "


    For($i = $index ; $i -lt $endindex ; $i++){
        #$CompleteString += $CArray[$i]
        if(($CArray[$i] -ne ' ') -and ($CArray[$i])){
            [char]$c = $CArray[$i]
            $CompleteString += $c
        }
        #Write-Verbose "$CArray[$i]"
    }

 #   $CompleteString = [string]::join("",($CompleteString.Split("`n")))
   

    $ScriptBlockCompressed = [System.Convert]::FromBase64String($CompleteString)

    # Decompress data
    $InputStream = New-Object System.IO.MemoryStream(, $ScriptBlockCompressed)
    $MemoryStream = New-Object System.IO.MemoryStream
    $GzipStream = New-Object System.IO.Compression.GzipStream $InputStream, ([System.IO.Compression.CompressionMode]::Decompress)
    $GzipStream.CopyTo($MemoryStream)
    $GzipStream.Close()
    $MemoryStream.Close()
    $InputStream.Close()
    [Byte[]] $ScriptBlockEncoded = $MemoryStream.ToArray()

    # Byte array to String
    [System.Text.Encoding] $Encoding = [System.Text.Encoding]::UTF8
    [string]$s = $Encoding.GetString($ScriptBlockEncoded)

    return $s
}


function ConvertTo-HeaderBlock {

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
        [String]$Path
        
    )

    $FileData = Get-Content -Path $Path -Raw -Encoding 'UTF8'
    # Script block as String to Byte array
    [System.Text.Encoding] $Encoding = [System.Text.Encoding]::UTF8
    [Byte[]] $ScriptBlockEncoded = $Encoding.GetBytes($FileData)

    # Compress Byte array (gzip)
    [System.IO.MemoryStream] $MemoryStream = New-Object System.IO.MemoryStream
    $GzipStream = New-Object System.IO.Compression.GzipStream $MemoryStream, ([System.IO.Compression.CompressionMode]::Compress)
    $GzipStream.Write($ScriptBlockEncoded, 0, $ScriptBlockEncoded.Length)
    $GzipStream.Close()
    $MemoryStream.Close()
    $ScriptBlockCompressed = $MemoryStream.ToArray()

    [string]$HeaderData =  $Global:HeaderStart
    # Byte array to Base64
    $B64String = [System.Convert]::ToBase64String($ScriptBlockCompressed)
    [char[]] $CArray = $B64String.ToCharArray() 
    $Parts = Convert-ToSmallerArray $CArray -NumParts 30
    $Parts | % { $HeaderData += "$_" }
    $HeaderData += $Global:HeaderEnd

    #Set-Content -Path "c:\Tmp\Header.txt" -Value $HeaderData

    return $HeaderData
}

