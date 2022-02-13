<# 
 # Set-System-Variables : small script that will configure all my environment variables.
 #                        most of my scripts are using environemtn variables like PATH
 #                        or more specialized variables. In order to make the configuration
 #                        of a computer for usage of my scripts easier, they are all listed in here.
 #
 ##############################################################################################################>

function Add-EnvPath {
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path,

        [ValidateSet('Machine', 'User', 'Session')]
        [string] $Container = 'Session'
    )

    if ($Container -ne 'Session') {
        $containerMapping = @{
            Machine = [EnvironmentVariableTarget]::Machine
            User = [EnvironmentVariableTarget]::User
        }
        $containerType = $containerMapping[$Container]

        $persistedPaths = [Environment]::GetEnvironmentVariable('Path', $containerType) -split ';'
        if ($persistedPaths -notcontains $Path) {
            $persistedPaths = $persistedPaths + $Path | where { $_ }
            [Environment]::SetEnvironmentVariable('Path', $persistedPaths -join ';', $containerType)
        }
    }

    $envPaths = $env:Path -split ';'
    if ($envPaths -notcontains $Path) {
        $envPaths = $envPaths + $Path | where { $_ }
        $env:Path = $envPaths -join ';'
    }
}

$pcname=$env:computername


	write-host "Setting up environment for machine at work. Computername is $pcname" 
	$hashservers = @{
        
        'cactiiroot' = 'D:\Server\cactii'
        'rrdtoolroot' = 'D:\Server\cactii\rrdtool'
        'SpineRotot' = 'D:\Server\cactii\Spine'
        'phproot' = 'D:\Server\cactii\php'
        'wwwroot' = 'D:\Server\cactii\Apache24\htdocs'
        'phproot' = 'D:\Server\cactii\php'
        'httpsrvroot' = 'D:\Server\cactii\Apache24'
	}




Write-Host "----------------------------------------"
Write-Host "Configuring system environment variables"

foreach ($h in $hashservers.GetEnumerator()) 
{
    Write-Host "   -->  $($h.Name) --> $($h.Value)"
    [System.Environment]::SetEnvironmentVariable($($h.Name),$($h.Value),[System.EnvironmentVariableTarget]::Machine)

    ### Add the path to the machine's PATH environemnt variable
    ###Add-EnvPath $h.Value 'Machine'

    $valname=$h.Name
    $path=$h.Value
    $tmpfile="temp.txt"
    $filepath= Join-Path "$path" "$tmpfile" #generate unc paths to files or folders
    if((Test-Path $path) -eq 0)
    {
    	Write-Host "   -->  The directory does not exists: $path" -fore yellow	
    	#if($valname -like "Temporary*" -Or $valname -like "Screenshot*"){
    		$res = new-item $path -itemtype directory -Force
    		$res = New-Item $filepath -itemtype file
    		if (Test-Path $filepath)
    		{
    			Write-Host "   -->  Created $path"  -fore green	
    		}
    	#}
	} 
}

Write-Host "Done!"
