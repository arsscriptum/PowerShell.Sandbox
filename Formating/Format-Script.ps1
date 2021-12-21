<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║                                                                                      
  ║   FormatScript.𝗽𝘀𝟭                                                                     
  ║   Format a powershell script                   ║
  ║                                                                                      
  ║   𝗖𝗼𝗽𝘆𝗿𝗶𝗴𝗵𝘁 (𝗰) 𝟮𝟬𝟮𝟬, 𝗰𝘆𝗯𝗲𝗿𝗰𝗮𝘀𝘁𝗼𝗿 <𝗰𝘆𝗯𝗲𝗿𝗰𝗮𝘀𝘁𝗼𝗿@𝗶𝗰𝗹𝗼𝘂𝗱.𝗰𝗼𝗺>                               
  ║   𝗔𝗹𝗹 𝗿𝗶𝗴𝗵𝘁𝘀 𝗿𝗲𝘀𝗲𝗿𝘃𝗲𝗱.                                                                  
  ║                                                                                      
  ║   𝗩𝗲𝗿𝘀𝗶𝗼𝗻 𝟭.𝟬.𝟬                                                                      
  ║   𝗵𝘁𝘁𝗽𝘀://𝗰𝘆𝗯𝗲𝗿𝗰𝗮𝘀𝘁𝗼𝗿.𝗴𝗶𝘁𝗵𝘂𝗯.𝗶𝗼/𝗽𝗿𝗼𝗷𝗲𝗰𝘁𝘀/FormatScript.𝗵𝘁𝗺𝗹                                
  ║                                                                                      
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>
  [CmdletBinding(SupportsShouldProcess)]
 param(
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
                throw "The Path argument must be a File. Directory paths are not allowed."
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path,
        [Parameter(Mandatory=$false)]
        [String]$FormatedFilePath="",        
        [Parameter(Mandatory=$false)]
        [switch]$WriteIterativeResult,
        [Parameter(Mandatory=$false)]
        [switch]$CompareIterativeResult,
        [Parameter(Mandatory=$false)]
        [switch]$ListMethods,
        [Parameter(Mandatory=$false)]
        [switch]$Setup,
        [Parameter(Mandatory=$false)]
        [switch]$InstallModule,
        [Parameter(Mandatory=$false)]
        [switch]$CompareResults
)
function Get-ModulesPath{
     $VarModPath=$env:PSModulePath
     $Index=$VarModPath.IndexOf(';')
      if($Index -ne -1) { $ModulesPath=$VarModPath.Substring(0,$Index) ; return $ModulesPath }
      else{ $ModulesPath=$VarModPath ; return $ModulesPath }
}
function Script:PrintScriptException{
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
    Write-Host "[ERROR] -> " -NoNewLine -ForegroundColor Red; 
    Write-Host "$ExceptMsg" -ForegroundColor Yellow
    if($ShowStack){
        Write-Host "--stack begin--" -ForegroundColor Green
        Write-Host "$Stack" -ForegroundColor Gray  
        Write-Host "--stack end--`n" -ForegroundColor Green       
    }
}   
function Script:AutoUpdateProgress {
    $Script:ProgressMessage = "Formating file... (Method $Script:StepNumber on $Script:TotalSteps)"
    Write-Progress -Activity $Script:ProgressTitle -Status $Script:ProgressMessage -PercentComplete (($Script:StepNumber / $Script:TotalSteps) * 100)
    $Script:StepNumber++
}
function Script:CheckConfig([string]$name) {
    if((Get-RegistryValue "HKCU:\Software\cybercastor\pwsh-formater" "$name") -eq 1){
      return $true
    }
    return $false
}
try{

  $Module=(Get-Module FormatPowerShellCode)
  if($Module -eq $null){
    if($InstallModule -eq $true){
      $m=Get-ModulesPath
      Install-ModuleToDirectory FormatPowerShellCode $m | Out-Null
      Import-Module FormatPowerShellCode -Scope Global | Out-Null
      write-host "[OK]`t" -f DarkGreen -NoNewLine 
      write-host "Installed FormatPowerShellCode module to $m" -f Gray  
      }else{
        throw "Module FormatPowerShellCode NOT INSTALLED! Use the -InstallModule argument"
      }
  }else{
    if($InstallModule -eq $true){ throw "Module already Installed!"}
  }

  if($Setup -eq $true){
    ForEach($command in (Get-Command -Module FormatPowerShellCode)){ 
      $cn= $command.Name
      $cn = $cn.Substring(7)
      $a=Read-Host -Prompt "Use $cn (Y/n)?"
      if($a -match 'n'){
        write-host "[no]`t" -f DarkRed -NoNewLine 
        write-host " $cn" -f Gray  
        New-RegistryValue "HKCU:\Software\cybercastor\pwsh-formater" "$cn" 0 DWORD
      }else{
        write-host "[yes]`t" -f DarkGreen -NoNewLine 
        write-host " $cn" -f Gray
        New-RegistryValue "HKCU:\Software\cybercastor\pwsh-formater" "$cn" 1 DWORD
      }
    } 
  }
  $CmdNames = @()
  ForEach($command in (Get-Command -Module FormatPowerShellCode)){ $CmdNames += $command.Name }

  if($ListMethods -eq $true){
     Get-Command -Module FormatPowerShellCode | select Name
     return
  }

  $CreateOutputDirectory = $true
  $CurrentPath = (Get-Location).Path

  if(($FormatedFilePath -ne $null) -And ($FormatedFilePath -ne '')){
    if(Test-Path $FormatedFilePath -PathType Container){
      throw "Argument FormatedFilePath must be a file"
    }elseif(Test-Path $FormatedFilePath -PathType Leaf){
      throw "File $FormatedFilePath already exists!"
    }
    # This will create the directory structure
    New-Item -Path $FormatedFilePath -ItemType File -Force -ErrorAction Ignore | Out-Null
    Remove-Item -Path $FormatedFilePath -Recurse -Force -ErrorAction Ignore | Out-Null

    $OutputFile = $FormatedFilePath
  }else{
    $Dirname = (Get-Item -Path $Path).DirectoryName
    $BaseName = (Get-Item -Path $Path).BaseName
    $Out = "$BaseName-Reformated" + (Get-Item -Path $Path).Extension
    $OutputFile = Join-Path $Dirname $Out
    $OutputPath = Join-Path $Dirname 'Reformated'
    Remove-Item -Path $OutputPath -Recurse -Force -ErrorAction Ignore | Out-Null
    New-Item -Path $OutputPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null 
    if($CreateOutputDirectory){
        $OutputFile = Join-Path $OutputPath $Out
    }
  }

  Write-Host "[START]`t" -f Cyan -NoNewLine
  Write-Host "Process started for $Path "  -f Gray

  $COMPAREEXE='C:\Programs\Shims\compare.exe'

  $TmpFile=New-TemporaryFile
  $TmpFilePath = $TmpFile.Fullname
  $Index = 0
  $Data = Get-Content -Path $Path 
  Set-Content -Path $TmpFilePath -Value $Data
  $Script:ProgressTitle = 'STATE: FORMATING'
  $Script:StepNumber = 0
  $Script:TotalSteps = $CmdNames.Count
  $NumDiffs=0
  $NumOps=0
  if(CheckConfig("ScriptCondenseEnclosures") -eq $true)     { $NumOps++ ; $DiffsDetected=$false ; $Filename = Join-Path $OutputPath "ScriptCondenseEnclosures.ps1"      ; $Data1 = Get-Content -Path $TmpFilePath ; $Data2 = Format-ScriptCondenseEnclosures $Data1;      $comp=(Compare-Object $Data1 $Data2) ; if(($comp -ne $null)-And($comp -ne "")){ $NumDiffs++ ; $DiffsDetected=$true; write-host "[diff]`t" -f Yellow -NoNewLine ; write-host "Format-ScriptCondenseEnclosures" -f DarkGray;};      Set-Content -Path $TmpFilePath -Value $Data2 ;$Data1=$Data2 ; if(($WriteIterativeResult -eq $true) -And ($DiffsDetected -eq $true)) { Copy-Item $TmpFilePath $Filename ; write-host "[wrote]`t" -f DarkGreen -NoNewLine ; write-host " $Filename" -f DarkGray; if($CompareIterativeResult){ &$COMPAREEXE $Path $Filename; } ; }  ; AutoUpdateProgress ; }
  if(CheckConfig("ScriptExpandFunctionBlocks") -eq $true)   { $NumOps++ ; $DiffsDetected=$false ; $Filename = Join-Path $OutputPath "ScriptExpandFunctionBlocks.ps1"    ; $Data1 = Get-Content -Path $TmpFilePath ; $Data2 = Format-ScriptExpandFunctionBlocks $Data1;    $comp=(Compare-Object $Data1 $Data2) ; if(($comp -ne $null)-And($comp -ne "")){ $NumDiffs++ ; $DiffsDetected=$true; write-host "[diff]`t" -f Yellow -NoNewLine ; write-host "Format-ScriptExpandFunctionBlocks" -f DarkGray;};    Set-Content -Path $TmpFilePath -Value $Data2 ;$Data1=$Data2 ; if(($WriteIterativeResult -eq $true) -And ($DiffsDetected -eq $true)) { Copy-Item $TmpFilePath $Filename ; write-host "[wrote]`t" -f DarkGreen -NoNewLine ; write-host " $Filename" -f DarkGray; if($CompareIterativeResult){ &$COMPAREEXE $Path $Filename; } ; }  ; AutoUpdateProgress ; }
  if(CheckConfig("ScriptExpandNamedBlocks") -eq $true)      { $NumOps++ ; $DiffsDetected=$false ; $Filename = Join-Path $OutputPath "ScriptExpandNamedBlocks.ps1"       ; $Data1 = Get-Content -Path $TmpFilePath ; $Data2 = Format-ScriptExpandNamedBlocks $Data1;       $comp=(Compare-Object $Data1 $Data2) ; if(($comp -ne $null)-And($comp -ne "")){ $NumDiffs++ ; $DiffsDetected=$true; write-host "[diff]`t" -f Yellow -NoNewLine ; write-host "Format-ScriptExpandNamedBlocks" -f DarkGray;};       Set-Content -Path $TmpFilePath -Value $Data2 ;$Data1=$Data2 ; if(($WriteIterativeResult -eq $true) -And ($DiffsDetected -eq $true)) { Copy-Item $TmpFilePath $Filename ; write-host "[wrote]`t" -f DarkGreen -NoNewLine ; write-host " $Filename" -f DarkGray; if($CompareIterativeResult){ &$COMPAREEXE $Path $Filename; } ; }  ; AutoUpdateProgress ; }
  if(CheckConfig("ScriptExpandParameterBlocks") -eq $true)  { $NumOps++ ; $DiffsDetected=$false ; $Filename = Join-Path $OutputPath "ScriptExpandParameterBlocks.ps1"   ; $Data1 = Get-Content -Path $TmpFilePath ; $Data2 = Format-ScriptExpandParameterBlocks $Data1;   $comp=(Compare-Object $Data1 $Data2) ; if(($comp -ne $null)-And($comp -ne "")){ $NumDiffs++ ; $DiffsDetected=$true; write-host "[diff]`t" -f Yellow -NoNewLine ; write-host "Format-ScriptExpandParameterBlocks" -f DarkGray;};   Set-Content -Path $TmpFilePath -Value $Data2 ;$Data1=$Data2 ; if(($WriteIterativeResult -eq $true) -And ($DiffsDetected -eq $true)) { Copy-Item $TmpFilePath $Filename ; write-host "[wrote]`t" -f DarkGreen -NoNewLine ; write-host " $Filename" -f DarkGray; if($CompareIterativeResult){ &$COMPAREEXE $Path $Filename; } ; }  ; AutoUpdateProgress ; }
  if(CheckConfig("ScriptExpandStatementBlocks") -eq $true)  { $NumOps++ ; $DiffsDetected=$false ; $Filename = Join-Path $OutputPath "ScriptExpandStatementBlocks.ps1"   ; $Data1 = Get-Content -Path $TmpFilePath ; $Data2 = Format-ScriptExpandStatementBlocks $Data1;   $comp=(Compare-Object $Data1 $Data2) ; if(($comp -ne $null)-And($comp -ne "")){ $NumDiffs++ ; $DiffsDetected=$true; write-host "[diff]`t" -f Yellow -NoNewLine ; write-host "Format-ScriptExpandStatementBlocks" -f DarkGray;};   Set-Content -Path $TmpFilePath -Value $Data2 ;$Data1=$Data2 ; if(($WriteIterativeResult -eq $true) -And ($DiffsDetected -eq $true)) { Copy-Item $TmpFilePath $Filename ; write-host "[wrote]`t" -f DarkGreen -NoNewLine ; write-host " $Filename" -f DarkGray; if($CompareIterativeResult){ &$COMPAREEXE $Path $Filename; } ; }  ; AutoUpdateProgress ; }
  if(CheckConfig("ScriptExpandTypeAccelerators") -eq $true) { $NumOps++ ; $DiffsDetected=$false ; $Filename = Join-Path $OutputPath "ScriptExpandTypeAccelerators.ps1"  ; $Data1 = Get-Content -Path $TmpFilePath ; $Data2 = Format-ScriptExpandTypeAccelerators $Data1;  $comp=(Compare-Object $Data1 $Data2) ; if(($comp -ne $null)-And($comp -ne "")){ $NumDiffs++ ; $DiffsDetected=$true; write-host "[diff]`t" -f Yellow -NoNewLine ; write-host "Format-ScriptExpandTypeAccelerators" -f DarkGray;};  Set-Content -Path $TmpFilePath -Value $Data2 ;$Data1=$Data2 ; if(($WriteIterativeResult -eq $true) -And ($DiffsDetected -eq $true)) { Copy-Item $TmpFilePath $Filename ; write-host "[wrote]`t" -f DarkGreen -NoNewLine ; write-host " $Filename" -f DarkGray; if($CompareIterativeResult){ &$COMPAREEXE $Path $Filename; } ; }  ; AutoUpdateProgress ; }
  if(CheckConfig("ScriptFormatCodeIndentation") -eq $true)  { $NumOps++ ; $DiffsDetected=$false ; $Filename = Join-Path $OutputPath "ScriptFormatCodeIndentation.ps1"   ; $Data1 = Get-Content -Path $TmpFilePath ; $Data2 = Format-ScriptFormatCodeIndentation $Data1;   $comp=(Compare-Object $Data1 $Data2) ; if(($comp -ne $null)-And($comp -ne "")){ $NumDiffs++ ; $DiffsDetected=$true; write-host "[diff]`t" -f Yellow -NoNewLine ; write-host "Format-ScriptFormatCodeIndentation" -f DarkGray;};   Set-Content -Path $TmpFilePath -Value $Data2 ;$Data1=$Data2 ; if(($WriteIterativeResult -eq $true) -And ($DiffsDetected -eq $true)) { Copy-Item $TmpFilePath $Filename ; write-host "[wrote]`t" -f DarkGreen -NoNewLine ; write-host " $Filename" -f DarkGray; if($CompareIterativeResult){ &$COMPAREEXE $Path $Filename; } ; }  ; AutoUpdateProgress ; }
  if(CheckConfig("ScriptFormatCommandNames") -eq $true)     { $NumOps++ ; $DiffsDetected=$false ; $Filename = Join-Path $OutputPath "ScriptFormatCommandNames.ps1"      ; $Data1 = Get-Content -Path $TmpFilePath ; $Data2 = Format-ScriptFormatCommandNames $Data1;      $comp=(Compare-Object $Data1 $Data2) ; if(($comp -ne $null)-And($comp -ne "")){ $NumDiffs++ ; $DiffsDetected=$true; write-host "[diff]`t" -f Yellow -NoNewLine ; write-host "Format-ScriptFormatCommandNames" -f DarkGray;};      Set-Content -Path $TmpFilePath -Value $Data2 ;$Data1=$Data2 ; if(($WriteIterativeResult -eq $true) -And ($DiffsDetected -eq $true)) { Copy-Item $TmpFilePath $Filename ; write-host "[wrote]`t" -f DarkGreen -NoNewLine ; write-host " $Filename" -f DarkGray; if($CompareIterativeResult){ &$COMPAREEXE $Path $Filename; } ; }  ; AutoUpdateProgress ; }
  if(CheckConfig("ScriptFormatTypeNames") -eq $true)        { $NumOps++ ; $DiffsDetected=$false ; $Filename = Join-Path $OutputPath "ScriptFormatTypeNames.ps1"         ; $Data1 = Get-Content -Path $TmpFilePath ; $Data2 = Format-ScriptFormatTypeNames $Data1;         $comp=(Compare-Object $Data1 $Data2) ; if(($comp -ne $null)-And($comp -ne "")){ $NumDiffs++ ; $DiffsDetected=$true; write-host "[diff]`t" -f Yellow -NoNewLine ; write-host "Format-ScriptFormatTypeNames" -f DarkGray;};         Set-Content -Path $TmpFilePath -Value $Data2 ;$Data1=$Data2 ; if(($WriteIterativeResult -eq $true) -And ($DiffsDetected -eq $true)) { Copy-Item $TmpFilePath $Filename ; write-host "[wrote]`t" -f DarkGreen -NoNewLine ; write-host " $Filename" -f DarkGray; if($CompareIterativeResult){ &$COMPAREEXE $Path $Filename; } ; }  ; AutoUpdateProgress ; }
  if(CheckConfig("ScriptPadExpressions") -eq $true)         { $NumOps++ ; $DiffsDetected=$false ; $Filename = Join-Path $OutputPath "ScriptPadExpressions.ps1"          ; $Data1 = Get-Content -Path $TmpFilePath ; $Data2 = Format-ScriptPadExpressions $Data1;          $comp=(Compare-Object $Data1 $Data2) ; if(($comp -ne $null)-And($comp -ne "")){ $NumDiffs++ ; $DiffsDetected=$true; write-host "[diff]`t" -f Yellow -NoNewLine ; write-host "Format-ScriptPadExpressions" -f DarkGray;};          Set-Content -Path $TmpFilePath -Value $Data2 ;$Data1=$Data2 ; if(($WriteIterativeResult -eq $true) -And ($DiffsDetected -eq $true)) { Copy-Item $TmpFilePath $Filename ; write-host "[wrote]`t" -f DarkGreen -NoNewLine ; write-host " $Filename" -f DarkGray; if($CompareIterativeResult){ &$COMPAREEXE $Path $Filename; } ; }  ; AutoUpdateProgress ; }
  if(CheckConfig("ScriptPadOperators") -eq $true)           { $NumOps++ ; $DiffsDetected=$false ; $Filename = Join-Path $OutputPath "ScriptPadOperators.ps1"            ; $Data1 = Get-Content -Path $TmpFilePath ; $Data2 = Format-ScriptPadOperators $Data1;            $comp=(Compare-Object $Data1 $Data2) ; if(($comp -ne $null)-And($comp -ne "")){ $NumDiffs++ ; $DiffsDetected=$true; write-host "[diff]`t" -f Yellow -NoNewLine ; write-host "Format-ScriptPadOperators" -f DarkGray;};            Set-Content -Path $TmpFilePath -Value $Data2 ;$Data1=$Data2 ; if(($WriteIterativeResult -eq $true) -And ($DiffsDetected -eq $true)) { Copy-Item $TmpFilePath $Filename ; write-host "[wrote]`t" -f DarkGreen -NoNewLine ; write-host " $Filename" -f DarkGray; if($CompareIterativeResult){ &$COMPAREEXE $Path $Filename; } ; }  ; AutoUpdateProgress ; }
   
  Copy-Item $TmpFile $OutputFile
  write-host "[OK]`t" -f DarkGreen -NoNewLine 
  write-host "Saved to $OutputFile" -f Gray 
  Write-Host "[DONE]`t" -f DarkGreen -NoNewLine
  Write-Host "Operation completed! Used $NumOps formatting calls, $NumDiffs calls created differences (output format different than input)" -f White
  Write-Progress -Activity $Script:ProgressTitle -Completed 

  if($CompareResults){
    &$COMPAREEXE $Path $OutputFile
  }

  

}catch{
  PrintScriptException($_)
}

  


<#ForEach($command in $CmdNames){
  #Set-Content -Path $TmpFilePath -Value $Data2
  $Expression = '{ if(CheckConfig("") -eq $true) { $NumOps++ ; $DiffsDetected=$false ; $Filename = Join-Path $OutputPath "ScriptCondenseEnclosures.ps1" ; $Data1 = Get-Content -Path $TmpFilePath ; $Data2 = ' + "$command " + '$Data1 ; Compare-Object $Data1 $Data2; }'
  $scriptBlock = [Scriptblock]::Create($Expression)
  Invoke-Command -ScriptBlock $scriptBlock | Out-Null
  Write-Host "[OK]`t" -f DarkGreen -NoNewLine
  Write-Host " processing through $command"  -f Gray
  if(CheckConfig("") -eq $true) { $NumOps++ ; $DiffsDetected=$false ; $Filename = Join-Path $OutputPath "$Index.ps1"
  Set-Content -Path $Filename -Value $Data
  $Index++
}#>
<#
ForEach($command in $CmdNames){
  $String1 = 'if(CheckConfig("") -eq $true) { $NumOps++ ; $DiffsDetected=$false ; $Filename = Join-Path $OutputPath "ScriptCondenseEnclosures.ps1" ; $Data1 = Get-Content -Path $TmpFilePath ; $Data2 = ' + $command + ' $Data1;'
  $String2 = @'
  $comp=(Compare-Object $Data1 $Data2) ; if(($comp -ne $null)-And($comp -ne ""))
'@
  $String3 = '{write-host "[diff]`t ' + $command + '" -f DarkGray;};'
  $String4 = @'
  Set-Content -Path $TmpFilePath -Value $Data2 ;
  $Data1=$Data2 ;
'@
  $FullString = $String1 + $String2 + $String3 + $String4
  $FullString
  Write-Host "`n#-------`n" -f Red
}
#>

