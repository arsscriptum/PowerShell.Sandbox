Set-ExecutionPolicy -Scope Process Bypass

$EmailFile=Join-Path $env:ScriptsRoot 'PowerShell\Send-Email-Function.ps1'

. $EmailFile

if ($env:SHADOWPATH -eq $null) 
{
    $TestPath = Join-Path 'e:' 'Shadow'
    if(Test-Path $TestPath) 
    { 
        $env:SHADOWPATH = $TestPath
        Set-Item -Path Env:SHADOWPATH -Value $TestPath
    }
    else 
    {
        $TestPath = Join-Path $env:SystemDrive 'Shadow'
        $env:SHADOWPATH = $TestPath
        Set-Item -Path Env:SHADOWPATH -Value $TestPath
    }
}

  
$rootdirectory = $env:SHADOWPATH

$tempDir = Join-Path $env:SHADOWPATH "exec"
if (![System.IO.Directory]::Exists($tempDir)) {[void][System.IO.Directory]::CreateDirectory($tempDir)}

$file = Join-Path $tempDir "commands.txt"

$fileitem = get-item $file
$stream_reader = New-Object -TypeName System.IO.StreamReader -ArgumentList $fileitem

$line_number = 1

$executable=$env:ComSpec
$datetime = Get-Date -uformat "%m%d-%H%M%S"
$filename = $_.name -replace $_.extension,"" 
$newname = "${filename}_${datetime}.log_old"

$logdirectory=$rootdirectory + "\$datetime"
if(!(Test-Path $logdirectory))
{
    New-Item -ItemType directory -Path $logdirectory
    Write-Host "Creating $logdirectory"
}

while (($current_line =$stream_reader.ReadLine()) -ne $null)
{
	$line_number++
	$file_err="$logdirectory\err$line_number.log"
	$file_out="$logdirectory\out$line_number.log"
	Write-Host "exec: $executable"
    Write-Host "args: $current_line"
	$startProcessParams = @{
            FilePath               = $executable
            ArgumentList           = $current_line
            RedirectStandardError  = $file_err
            RedirectStandardOutput = $file_out
            Wait                   = $true;
            PassThru               = $true;
            NoNewWindow            = $true;
        }
    $cmd = Start-Process @startProcessParams
}
$stream_reader.Dispose()

$std_err = Get-Content $file_err
$std_out = Get-Content $file_out

Write-Host -Foreground Red $std_err
Write-Host -Foreground Blue $std_out

Send-Email 'gplante@bodycad.com' 'Commands Executed!'