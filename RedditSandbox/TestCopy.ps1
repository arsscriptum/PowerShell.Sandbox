

    # Limit of 100 Megabytes (in Kb)
    $Script:Threshold = 100 * 1024

    function Write-CopyLog {
      [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory=$true,Position=0)]
            [Alias('m')]
            [String]$Message,
            [Parameter(Mandatory=$false)]
            [Alias('t')]
            [ValidateSet('wrn','nrm','err','don')]
            [String]$Type='nrm'
        )

        switch ($Type) {
            'nrm'  {
                Write-Host -n -f DarkCyan "[COPY] " ; Write-Host -f DarkGray "$Message"  
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
                # if($_ | Test-Path -PathType Leaf){$Script:CopyFileA = ((Read-Host "Copy `"$_`" ? (y/N) ") -eq 'y') ; return $true }
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
                # Ask for confirmation
                # if($_ | Test-Path -PathType Leaf){$Script:CopyFileA = ((Read-Host "Copy `"$_`" ? (y/N) ") -eq 'y') ; return $true }
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
                Copy-Item -Path $Src -Destination $Dst -Force  -ErrorAction Ignore  | Out-Null
                log "Copied $Src to $Dst" -t 'don' 
            }
            if($Script:CopyFileB){
                $Src = (Get-Item $FileB).FullName
                $Dst = Join-Path $Destination ((Get-Item $FileB).Name)
                Copy-Item -Path $Src -Destination $Dst -Force  -ErrorAction Ignore  | Out-Null
                log "Copied $Src to $Dst" -t 'don' 
            }
        }catch{
            log "$Src ==> $Destination" -t 'wrn'
            log "$_" -t 'err'
        }

    }


    function Watch-Clipboard {
        $Clipboard = Get-Clipboard
        If ($Clipboard -match "testxxx") {
        Start "https://www.google.com/search?q=$Clipboard"
        }
        while ($Clipboard -eq (Get-Clipboard)) {}
        Watch-Clipboard
    }


    function Invoke-PipeClient {
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory=$true,Position=0)]
            [String]$Name
        )
        # Use in one powershell window
        $Pipe = [System.IO.Pipes.NamedPipeServerStream]::new($Name)
        $Pipe.WaitForConnection()
        $Reader = [System.IO.StreamReader]::new($Pipe)
        $Script = ""
        while (($Command = $Reader.ReadLine()) -ne "END") 
        {
         $Script = $Script + "`n" + $Command
        }
        Invoke-Expression $Script
        $Reader.Dispose()
        $Pipe.Dispose()
    }

    function Invoke-PipeServer {
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory=$true,Position=0)]
            [String]$Name
        )
        # Use in a different powershell window
        $Pipe = [System.IO.Pipes.NamedPipeClientStream]::new($Name)
        $Pipe.Connect()
        $Writer = [System.IO.StreamWriter]::new($Pipe)
        $Writer.WriteLine("Get-Date")
        $Writer.WriteLine("Write-Host 'Its-a-me, Mario!' -ForegroundColor Red")
        $Writer.WriteLine("END")
        $Writer.Dispose()
        $Pipe.Dispose()
    }