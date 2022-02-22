[CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [Alias('p')]
        [switch]$Public,
        [Parameter(Mandatory=$false)]
        [Alias('f')]
        [switch]$Force
    )  

function Write-MMsg{               # NOEXPORT   
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false,Position=1)]
        [Alias('h','y')]
        [switch]$Highlight
    )
    if($Highlight){
        Write-Host "⚡ $Message"
    }else{
        Write-Host "⚡ $Message" -f DarkYellow
    }
}

$Repos = @()
$RootPath = 'p:\Development'

if($Public){
    Write-MMsg "CLONING PUBLIC REPOSITORY"
    $Repos = Get-PublicRepositories -User 'arsscriptum'
}else{
    Write-MMsg "CLONING PRIVATE REPOSITORY"
    $Repos = Get-PrivateRepositories -User 'arsscriptum'
}


$ReposCount = $Repos.Count

pushd $RootPath
[int]$i=0
ForEach($repo in $Repos){
    $i++
    $name = $repo.name
    $ssh_clone_url = $repo.ssh_url
    $RepoPath = Join-Path $RootPath $name
    if(Test-Path $RepoPath){
        Write-MMsg "Repository $name is already cloned ($i / $ReposCount)"

        if($Force){
            Write-MMsg "FORCE: Removing $name"
            $Null = Remove-Item -Path $RepoPath -Force -Recursive
        }else{
            continue;
        }
    }
    Write-MMsg "===================================================="
    Write-MMsg "CLONING $name ($ssh_clone_url)" 
    Write-MMsg "$i on $ReposCount" 
    Write-MMsg "===================================================="

    git clone $ssh_clone_url --recursive
}

popd


