

$FanControllerRoot = 'C:\Program Files (x86)\NoteBook FanControl'
$FanStatusExe = Join-Path $FanControllerRoot 'nbfc.exe'

$MAX_CHART_SIZE = 50


$SpeedDataQueue = New-Object System.Collections.Queue
$TempDataQueue = New-Object System.Collections.Queue

function GetCurrentFanStatus{
    $FanData = New-Object -TypeName PSObject 

    $StatusData = (&$FanStatusExe status)
    $Key = ''
    $Val = ''
    Foreach ( $KeyVal in  $StatusData ){
        if( $KeyVal.IndexOf(':') -gt 0 ){
            $KeyVal = $KeyVal.Split(':')
            $Key = $KeyVal[0].trim()
            $Val = $KeyVal[1].trim()
            $FanData | Add-Member -MemberType NoteProperty -Name "$Key" -Value $Val
        }
    }
    return $FanData
}

function InitializeSpeedData{
    For($i = 0 ;$i -lt $MAX_CHART_SIZE; $i++){
        $SpeedDataQueue.Enqueue( 0 )
    }
    Set-Variable -Name SpeedDataPoints -Scope Global -Option allscope -Value $SpeedDataQueue

}

function UpdateSpeedData{
    $status = GetCurrentFanStatus
    $SpeedDataQueue.Enqueue($status.'Current fan speed')
    Set-Variable -Name SpeedDataPoints -Scope Global -Option allscope -Value $SpeedDataQueue
    Set-Variable -Name CurrentFanSpeed -Scope Global -Option allscope -Value $status.'Current fan speed'
}


function InitializeTemperatureData{
    For($i = 0 ;$i -lt $MAX_CHART_SIZE; $i++){
        $TempDataQueue.Enqueue( 0 )
    }
    Set-Variable -Name TempDataPoints -Scope Global -Option allscope -Value $TempDataQueue

}

function UpdateTemperatureData{

    $status = GetCurrentFanStatus
    $TempDataQueue.Enqueue($status.Temperature)
    Set-Variable -Name TempDataPoints -Scope Global -Option allscope -Value $TempDataQueue
    Set-Variable -Name CurrentCPUTemp -Scope Global -Option allscope -Value $status.Temperature

}

InitializeTemperatureData
InitializeSpeedData
do {
    #if($SpeedDataQueue.Count -ge $MAX_CHART_SIZE){
    #    do{$null=$SpeedDataQueue.Dequeue()}while($SpeedDataQueue.Count -gt $MAX_CHART_SIZE)
    #}
    $null=$SpeedDataQueue.Dequeue()
    $null=$TempDataQueue.Dequeue()
    $status = GetCurrentFanStatus
    [int]$rpm = [int]$status.'Fan speed steps' * [int]$status.'Current fan speed'
    UpdateTemperatureData
    UpdateSpeedData
    Clear-Host
    Show-Graph -datapoints $TempDataQueue -GraphTitle 'CPU TEMP' -YAxisTitle "Celcius" -XAxistitle "Time" -YAxisMinRange 0 -YAxisMaxRange 90
    Show-Graph -datapoints $SpeedDataQueue -GraphTitle 'FAN SPEED' -YAxisTitle "%" -XAxistitle "Time" -YAxisMinRange 0 -YAxisMaxRange 90
    Write-Host " "
    Write-Host "TRGT.SPD`tCURR.SPD`tCURR.RPM`tCPU.TEMP" -f Red
    Write-Host "--------`t--------`t--------`t--------" -f DarkRed
    Write-Host "$($status.'Target fan speed')`t`t$Global:CurrentFanSpeed`t`t$rpm`t`t$Global:CurrentCPUTemp" -f DarkYellow

    Start-Sleep -Milliseconds 3000
} while ($true)



