<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   
#̷𝓍   Optional Copy. Powershell Reddit question
#̷𝓍   
#̷𝓍   I wrote this to help this dude on Reddit:
#̷𝓍   https://www.reddit.com/r/PowerShell/comments/vv50w0/better_way_to_do_this/
#̷𝓍   
#̷𝓍   Get it here:
#̷𝓍   https://github.com/arsscriptum/PowerShell.Sandbox/blob/main/InvokeOptionalCopy/Invoke-OptionalCopy.ps1
#̷𝓍   
#̷𝓍   <guillaumeplante.qc@gmail.com>
#̷𝓍   https://arsscriptum.github.io/
#>


# Files under this size will be copied
$Script:Threshold = 100 * 1024

# If set to $True, user will be ask for copy confirmation.
$Script:AskConfirmation = $False

function Write-CopyLog {

    <#
    .SYNOPSIS
        Copy one or 2 files to a destination folder
    .DESCRIPTION
        Copy one or 2 files to a destination folder 
            - if file size is less than pre-defined value (Threshold) 
            - after asking the user for copy confirmation   
       
    .PARAMETER Message (-m)
        Log Message
    .PARAMETER Type 'wrn','nrm','err','don'
        Message Type
            'wrn' : Warning
            'nrm' : Normal
            'err' : Error
            'don' : Done

    .EXAMPLE 
        log "Copied $Src to $Dst" -t 'don'  
        log "$Src ==> $Destination" -t 'wrn'
        log "test error" -t 'err'
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('m')]
        [String]$Message,
        [Parameter(Mandatory=$false)]
        [Alias('t')]
        [ValidateSet('wrn','nrm','err','don')]
        [String]$Type='nrm',
        [Parameter(Mandatory=$false)]
        [Alias('n')]
        [switch]$NoReturn
    )

    switch ($Type) {
        'nrm'  {
            Write-Host -n -f DarkCyan "[COPY] " ; if($NoReturn) { Write-Host -n -f DarkGray "$Message"} else {Write-Host -f DarkGray "$Message"}
        }
        'don'  {
            Write-Host -n -f DarkGreen "[DONE] " ; Write-Host -f DarkGray "$Message"  
        }
        'wrn'  {
            Write-Host -n -f DarkYellow "[WARN] " ; Write-Host -f White "$Message" 
        }
        'err'  {
            Write-Host -n -f DarkRed "[ERROR] " ; Write-Host -f DarkYellow "$Message" 
        }
    }
}

New-Alias -Name 'log' -Value 'Write-CopyLog' -ErrorAction Ignore -Force

function Invoke-OptionalCopy {

    <#
    .SYNOPSIS
        Copy one or 2 files to a destination folder
    .DESCRIPTION
        Copy one or 2 files to a destination folder 
            - if file size is less than pre-defined value (Threshold) 
            - after asking the user for copy confirmation   
       
    .PARAMETER FileA (-FileA or -a)
        File to copy (first), if exist, will ask the user to confirm copy
    .PARAMETER FileB (-FileB or -b)
        File to copy (2nd), if exist, will ask the user to confirm copy
    .PARAMETER Destination (-Destination or -dst or -d)
        Destination directory, if it doesn't exist, it will be created
        Default value to $ENV:Temp
    .EXAMPLE 
        # copy to $ENV:Temp
        Invoke-OptionalCopy "c:\Documents\List.txt" "c:\TestFile.txt"
        # Copy to "c:\Dump"
        Invoke-OptionalCopy -a "c:\Documents\List.txt" -b "c:\TestFile.txt" -d "c:\Dump"
        # Simulation : Log copy operation to $ENV:Temp but not copy for real
        Invoke-OptionalCopy "c:\Documents\List.txt" "c:\TestFile.txt" -WhatIf
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
            if($_ | Test-Path -PathType Leaf){$Kb = (Get-Item $_).Length / 1024;  $Script:CopyFileA = ($Kb -lt $Script:Threshold) ;log "File $_ is $Kb Kb. Copy => $Script:CopyFileA";return $true }
            elseif( ($_ | Test-Path) -And (-Not ($_ | Test-Path -PathType Leaf) ) ){throw "The Path argument must be a File. Directory paths are not allowed."}  
            else{ $Script:CopyFileA = $False ; return $true }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [Alias('a')]
        [String]$FileA,
        [Parameter(Mandatory=$true,Position=1)]
        [ValidateScript({
            # Copy if less than $Threshold
            if($_ | Test-Path -PathType Leaf){$Kb = (Get-Item $_).Length / 1024;  $Script:CopyFileB = ($Kb -lt $Script:Threshold) ;log "File $_ is $Kb Kb. Copy => $Script:CopyFileB";return $true }
            elseif( ($_ | Test-Path) -And (-Not ($_ | Test-Path -PathType Leaf) ) ){throw "The Path argument must be a File. Directory paths are not allowed."}  
            else{ $Script:CopyFileB = $False ; return $true }
            return $true 
        })]
        [Alias('b')]
        [String]$FileB,
        [Parameter(Mandatory=$false)]
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){ $Null = New-Item -Path $_ -ItemType Directory -Force ; Write-Host -n -f DarkRed "[WARN] " ; Write-Host -f DarkYellow "Creating $_" ;}  
            return $true 
        })]
        [Alias('d','dst')]
        [string]$Destination = "$ENV:Temp"
    )

    try{
        if($Script:CopyFileA){
            $Src = (Get-Item $FileA).FullName
            $Dst = Join-Path $Destination ((Get-Item $FileA).Name)
            if($Script:AskConfirmation){
                # Ask for confirmation
                log "Should Copy `"$Src`"" -n
                $Script:CopyFileA = ((Read-Host "? (y/N) ") -eq 'y')
            }

            if($Script:CopyFileA){
                Copy-Item -Path $Src -Destination $Dst -Force  -ErrorAction Ignore  | Out-Null
                log "Copied $Src to $Dst" -t 'don' 
            }else{
                log "Skipped $Src"
            }
            
        }
        if($Script:CopyFileB){
            $Src = (Get-Item $FileB).FullName
            $Dst = Join-Path $Destination ((Get-Item $FileB).Name)
            if($Script:AskConfirmation){
                # Ask for confirmation
                log "Should Copy `"$Src`"" -n
                $Script:CopyFileB = ((Read-Host "? (y/N) ") -eq 'y')
            }

            if($Script:CopyFileB){
                Copy-Item -Path $Src -Destination $Dst -Force  -ErrorAction Ignore  | Out-Null
                log "Copied $Src to $Dst" -t 'don' 
            }else{
                log "Skipped $Src"
            }
        }
    }catch{
        log "$Src ==> $Destination" -t 'wrn'
        log "$_" -t 'err'
    }

}
