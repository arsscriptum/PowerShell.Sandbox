 




function Export-FileSegment
{
 <#
    .Synopsis
        Writes a segment of a file to a new file
    .Description
        Writes a segment of a file to a new file. The source file will not be changed.
        The length of the segment can be determined via block size or end position.
        If no segment length is specified the rest of the file is written as segment.
    .Parameter Path
        Path to source file
    .Parameter Target
        Path to target file
    .Parameter Start
        Starting point of segment in source file
    .Parameter End
        Ending point of segment in source file (is preferred before specifying -Size)
    .Parameter Size
        Size of the segment in the file (specification of -End is preferred)
    .Inputs
        None
    .Outputs
        None
    .Example
        Export-FileSegment LargeFile.dat Extract.dat 0x1000000 0x1001000

        Extracts 4096 bytes from LargeFile.dat starting at position 16777216 and writes them to file Extract.dat
    .Example
        Export-FileSegment -Path "C:\Users\He\Pictures\sample.jpg" -Target ".\Header.dat" -Start 0 -Size 11
#>
    Param 
    (
        [Parameter(Mandatory = $TRUE)][STRING] 
        $Path, 
        [Parameter(Mandatory = $TRUE)]
        [STRING] $Target, 
        [int] $Start = 0, 
        [int] $End = -1, 
        [int] $Size = -1
    )

    if ($Start -lt 0)
    {
        Write-Error "Start position in file must be greater than or equal to 0"
        return
    }
    if ($End -ge 0)
    {
        if ($Start -gt $End)
        {
            Write-Error "End position in file must be greater than or equal to start position"
            return
        }
        $Size = $End - $Start
    }

    Write-Output "Processing file '$Path'"
    try {
        $ObjReader = New-Object System.IO.BinaryReader([System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read))
    }
    catch {
        Write-Error "Error opening '$Path'"
        return
    }
    if ($Start -gt [int]$ObjReader.BaseStream.Length)
    {
        $ObjReader.Close()
        Write-Error "Start position must not be larger than file size"
        return
    }

    if ($Size -lt 0) { $Size = [int]$ObjReader.BaseStream.Length - $Start   }

    [Byte[]]$TemporaryBuffer = New-Object Byte[] $Size
    [int]$BYTESREAD = 0

    if ($Start -gt 0) { $ObjReader.BaseStream.Seek($Start, [System.IO.SeekOrigin]::Begin) | Out-Null }

    Write-Output "Reading $Size bytes at position $Start"
    if (($BYTESREAD = $ObjReader.Read($TemporaryBuffer, 0, $TemporaryBuffer.Length)) -ge 0)
    {
        Write-Output "Read $BYTESREAD bytes from '$Path'"
        Write-Output "Writing file '$Target'"
        try {
            $ObjWriter = New-Object System.IO.BinaryWriter([System.IO.File]::Create($Target))
            $ObjWriter.Write($TemporaryBuffer, 0, $BYTESREAD)
            $ObjWriter.Close()
        }
        catch {
            Write-Error "Error writing '$Target'"
        }
    }
    $ObjReader.Close()
}




function Create-RandomString($Length)
{
    $GuidLen=((New-Guid).Guid).Length
    $NumGuid=$Length/$GuidLen
    $NumGuid=[math]::ceiling($NumGuid)
    $RandomString=""
    for($i = 0 ; $i -le $NumGuid ; $i++){
        $New=(New-Guid).Guid
        $New= $New -replace "-","$i"
        $RandomString += $New
    }
    $RandomString=$RandomString.SubString(0,$Length)
    return $RandomString
}


function ConvertTo-PhaseShift {
    
<#
    .SYNOPSIS
            Cmdlet to execute a mysql script
    .DESCRIPTION
            Cmdlet to execute a mysql script
    .PARAMETER Path

#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [string[]]$Path,
        [Parameter(Mandatory=$True,Position=1)]
        [psobject]$PhaseShiftOptions,
        [Parameter(Mandatory=$False)]
        [string[]]$Exclude,
        [Parameter(Mandatory=$False)]
        [string]$Recurse,
        [Parameter(Mandatory=$False)]
        [string]$WhatIf,
        [Parameter(Mandatory=$False)]
        [string]$Output
    )

    if(-not(Test-Path($Output))){
        New-Item -Path $Output -ItemType Directory -Force | Out-Null
    }
    else {
        $NumChilds=(Get-ChildItem -Path $Output).Length
        if($NumChilds -gt 0){
            throw "Output folder is not empty.  $Output"
        }
    }


    #$ArchiveFileReader=$Output + "\ArchiveReader.zip"
    $ArchiveFileSource=$Output + "\ArchiveSource.zip"
    $CompressionLevel=$Opts.CompressionLevel

    ### 1: Regroup the files that are to be processed (Compress-Archive). Include Path and Exclude
    $CompressionLevel="NoCompression" # NoCompression | Optimal | Fastest
    Compress-Archive -Path $Path -DestinationPath $ArchiveFileSource -CompressionLevel $CompressionLevel


    ### This will be require for the output object

    $HashResult=Get-FileHash $ArchiveFileSource
    $ArchiveHashAlgorithm=$HashResult.Algorithm
    $ArchiveHash=$HashResult.Hash


    #Copy-Item $ArchiveFileReader $ArchiveFileSource
    ### 2: Divide the file in multiple parts and export each part to BASE64
    Write-Output "ArchiveFileSource file '$ArchiveFileSource'"
    try {
        $ObjReader = New-Object System.IO.BinaryReader([System.IO.File]::Open($ArchiveFileSource, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read))
    }
    catch {
        Write-Error "Error opening '$ArchiveFileSource'"
        return
    }

    # Whish: 
    $WishN = $Opts.NumFiles
    $RealArchiveSize = $ObjReader.BaseStream.Length
    $RoundedArchiveSize = [math]::Round($ObjReader.BaseStream.Length)
    $ObjReader.Close()
    Write-Output "Archive is $RealArchiveSize bytes. User wants to have $WishN files from that"
    $RealPartsSize= $RealArchiveSize / $WishN
    $RoundedPartsSize= $RoundedArchiveSize / $WishN
    $RoundedPartsSize=[math]::Round($RoundedPartsSize)
    

    Write-Host "RoundedPartsSize = $RoundedPartsSize   RealPartsSize=$RealPartsSize RealArchiveSize=$RealArchiveSize WishN=$WishN" -f DarkCyan


    $PartsFolder=$Output + '\Parts'
    New-Item -Path $PartsFolder -ItemType Directory -Force | Out-Null
    
    $FilePos=0
    $RemainSize=$RealArchiveSize
    $ExportSize=$RealPartsSize
    $FilesExported=0
    For ($i=0; $i -le $WishN; $i++) {

        if($RemainSize -le 0){
            Write-Host "No more data to write. Exported a total of $FilesExported files." -f Red -b DarkYellow ;
            break;
        }
        $PartFilename=$PartsFolder + "\Part-$i.bin"

        if($RemainSize -lt $ExportSize){ $ExportSize = $RemainSize;  Write-Host "ExportSize $ExportSize is greater than RemainSize $RemainSize. Ressting ExportSize" -f Red -b DarkYellow ; }

        # Rounding up the export size
        $ExportSize = [math]::Round($ExportSize)
        Write-Host "Exporting part $i. $PartFilename. RemainSize=$RemainSize. ExportSize=$ExportSize."
        Export-FileSegment -Path $ArchiveFileSource -Target $PartFilename -Start $FilePos -Size $ExportSize
        $RemainSize -= $ExportSize
        $FilePos += $ExportSize
        $FilesExported++
    }


    $TotalRawSize=0
    $TotalB64Size=0
    $Childs = Get-ChildItem -Path $PartsFolder
    $Childs | % { 
        $TotalRawSize += $_.Length
        $Filename=$_.Fullname
        $base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($Filename))
        [IO.File]::WriteAllBytes($FileName, [Convert]::FromBase64String($base64string))
    }
    $Childs = Get-ChildItem -Path $PartsFolder
    $n=$Childs.Length
    $n=$n*15
    $RandomString=Create-RandomString $n
    $i=0
    $Childs | % { 
        $index=$i+10
        $NewName=$RandomString.SubString($index,5)
        $PartFilename=$PartsFolder + "\$NewName.cpp"        
        $Filename=$_.Fullname
        $TotalB64Size += $_.Length
        Rename-Item -Path $Filename -NewName $PartFilename
        $i++
    }
    


    ### Step 3: Loop though all the generated files and rename them based on the required file extensions

<#
    $Opts = [PSCustomObject]@{
        NumFiles          = 10
        FileSize          = 0
        Extensions        = @('cpp','h','txt','hpp','c')
        CompressionLevel  = "NoCompression"
    }

#>

    $Result = [PSCustomObject]@{
        ArchiveHashAlgorithm    =   $ArchiveHashAlgorithm
        ArchiveHash             =   $ArchiveHash
        OutputIndexFile         =   ""
        OutputFiles             =   @('','')
        SizeBefore              =   $RealArchiveSize
        NumFilesBefore          =   -1
        SizeAfter               =   -1
        NumFilesAfter           =   $FilesExported
        ExitCode                =   0
        StdOut                  =   ""
        StdErr                  =   ""
        StopWatch               =   -1
    }

    $ArchiveHashAlgorithm=$HashResult.Algorithm
    $ArchiveHash=$HashResult.Hash

    return $Result
    
}


$Opts = [PSCustomObject]@{
    NumFiles          = 45
    FileSize          = 0
    Extensions        = @('cpp','h','txt','hpp','c')
    CompressionLevel  = "NoCompression"
}


$TotalSize=0
$OutPath="D:\Development\cybercastor\Data-PhaseShifter\Out\Parts"


$MediaPath = @('C:\Users\gplante\Pictures\ninjacastor','C:\Users\gplante\Pictures\cybercastor')
$Outpath="D:\Development\cybercastor\Data-PhaseShifter\Out"
$res = ConvertTo-PhaseShift -Path $MediaPath -PhaseShiftOptions $Opts -Output $Outpath
$Childs = Get-ChildItem -Path $OutPath
 $Childs | % { $TotalSize += $_.Length }
$r1=$res.ArchiveHash
$r2=$res.ArchiveHashAlgorithm
$r3=$res.SizeBefore
$r4=$res.NumFilesAfter

$tab=[char]9

Write-Host "ConvertTo-PhaseShift results"
Write-Host "$tab hash data: $r1 ($r2)"
Write-Host "$tab SizeBefore: $r3" 
Write-Host "$tab SizeBefore: $TotalSize"
Write-Host "$tab NumFilesAfter: $r4"