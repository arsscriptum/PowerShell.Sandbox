
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
    param (
        [parameter(Mandatory=$false)]
        [string]$Path = "HKCU:\SOFTWARE\DevelopmentSandbox\TestSettings",
        [parameter(Mandatory=$false)]
        [int]$NumEntries = 10,
        [parameter(Mandatory=$false)]
        [int]$MaxDepth = 5,
        [parameter(Mandatory=$false)]
        [switch]$BogusEntries,
        [parameter(Mandatory=$false)]
        [switch]$Test,
        [parameter(Mandatory=$false)]
        [switch]$StartRegEd
    )

try{

    $TestMode = $False        
    if ( ($PSBoundParameters.ContainsKey('WhatIf') -Or $Test) ){         
        $TestMode = $True
    }

    $TotalEntries = 0
    Write-Host "Root Path " -f Red -n ; Write-Host "[$Path]" -f Gray
    New-Item -Path $Path -ItemType 'Directory' -Force  -ErrorAction Ignore | Out-null

    New-PSDrive -Name MySb -PSProvider Registry -Root $Path | Out-null

    Get-Random -SetSeed $(Get-Date -UFormat %s) | Out-null
    $p = '' 
    $Noise = [System.Collections.ArrayList]::new()
    For($i = 0 ; $i -lt $numEntries ; $i++){
        $Depth = Get-Random -Maximum $MaxDepth -Minimum 1

        $p = $Path
        $rel = '/'
        [string]$s = (New-Guid).Guid 
        [string[]]$sa = $s.Split('-') 
        For($j = 0 ; $j -lt $Depth ; $j++){
            $p = Join-Path $p $sa[$j]
            $rel = Join-Path $rel $sa[$j]

            if($BogusEntries){
                $n1 = "Guid_$j"
                $n2 = "Date_$j"
                $v1 = $((New-Guid).Guid)
                $v2 = $((Get-Date).GetDateTimeFormats()[$j])

                if(-not $TestMode){
	                New-Item -Path $p -Force | Out-null
	                New-ItemProperty -Path $p -Name $n1 -Value $v1 -PropertyType 'String'  | Out-null
	                New-ItemProperty -Path $p -Name $n2 -Value $v2 -PropertyType 'String'  | Out-null

	                Write-Verbose "`t+$p"
	                Write-Verbose "`t===> $n1 / $v1"
	                Write-Verbose "`t===> $n2 / $v2"
	                $Null = $Noise.Add(@{
	                    Path = $p
	                    Name = $n1
	                    Value = $v1
	                })
	                $Null = $Noise.Add(@{
	                    Path = $p
	                    Name = $n2
	                    Value = $v2
	                })	                
                }else{
            		Write-Host -n -f DarkRed "[TestMode] "
            		Write-Host -n -f Gray "$p"
                    Write-Host -f DarkYellow "/[$n1;$v1]"
            	}
            }
        }

        $Name 	= 'IP Address'
        $Type 	= 'String'
        $Value 	= "" ; 

        $r = Get-Random -Maximum 4 -Minimum 1
        switch($r){
        	1  {$Value = "192.168.$(Get-Random -Maximum 255 -Minimum 1).$(Get-Random -Maximum 255 -Minimum 1)" ; }
            2  {$Value = "$(Get-Random -Maximum 99 -Minimum 1).$(Get-Random -Maximum 99 -Minimum 1).$(Get-Random -Maximum 255 -Minimum 1).$(Get-Random -Maximum 255 -Minimum 1)" ; }
            3  {$Value = "10.0.$(Get-Random -Maximum 100 -Minimum 1).$(Get-Random -Maximum 255 -Minimum 1)" ; }
        }
        
        if(-not $TestMode){
        	New-Item -Path $p -Force | Out-null
        	New-ItemProperty -Path $p -Name $Name -Value $Value -PropertyType $Type  | Out-null
            
        	Write-Host "+ $Name / " -n -f Blue
        	Write-Host "$Value" -n -f Yellow
        	Write-Host "`t`t[$rel]" -f Gray
       }else{
            Write-Host -n -f DarkRed "[TestMode] "
            Write-Host -n -f Gray "$p"
            Write-Host -f DarkYellow "/[$Name;$Value]"
        }
        $TotalEntries++
    }

    Write-Host -f DarkCyan "+ IPADDRESS ENTRIES : $TotalEntries"
    if($BogusEntries){ Write-Host -f DarkYellow "+ BOGUS ENTRIES : $($Noise.Count)" }
    $TotalEntries += $($Noise.Count)
    Write-Host -f Red "+ TOTAL ENTRIES : $TotalEntries"

    if($StartRegEd){
        $TkExe = (Get-Command "taskkill.exe").Source
        &"$TkExe" -IM "regedit.exe"
        [string]$LastKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit"
        [string]$LastKeyValue = "LastKey"
        $RegPath = $p.Replace('HKCU:\','Ordinateur\HKEY_CURRENT_USER\')
        Set-ItemProperty -Path "$LastKeyPath" -Name "$LastKeyValue" -Value "$RegPath"      
        $RegEditExe = (Get-Command "regedit.exe").Source
        &"$RegEditExe"        
    }
}catch{
    Write-Error "$_"
}

Remove-PSDrive -Name MySb

