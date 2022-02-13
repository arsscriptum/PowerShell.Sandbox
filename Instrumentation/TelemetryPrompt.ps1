#requires -version 5.1
#this requires a windows platform

Function prompt {

    $charHash = @{
        Up   = 0x25b2 -as [char]
        Down = 0x25bc -as [char]
    }

    Try {
        #verify there is a global hashtable variable
        Get-Variable -Name rsHash -Scope global -ErrorAction Stop | Out-Null
    }
    Catch {
        #create the runspace and synchronized hashtable
        $global:rsHash = [hashtable]::Synchronized(@{Computername = $env:computername; results = ""; date = (Get-Date); computers = @()})
        $newRunspace = [runspacefactory]::CreateRunspace()
        #set apartment state if available
        if ($newRunspace.ApartmentState) {
            $newRunspace.ApartmentState = "STA"
        }
        $newRunspace.ThreadOptions = "ReuseThread"         
        $newRunspace.Open()
        $newRunspace.SessionStateProxy.SetVariable("rsHash", $rsHash)  

        $pscmd = [PowerShell]::Create().AddScript( {                      

            #define the path to the list of computers
            $script:listPath = "C:\scripts\watch.txt"
            #define scriptblock to run remotely
                $sb = {

                    Try {        
                        $mem = Get-CimInstance -ClassName win32_operatingsystem -Property TotalVisibleMemorySize, FreePhysicalMemory -ErrorAction Stop -OperationTimeoutSec 2
                        $memUsage = ($mem.FreePhysicalMemory / $mem.TotalVisibleMemorySize) * 100 -as [int]
                        $disk = Get-CimInstance -Classname win32_logicaldisk -filter "deviceID = 'c:'" -Property DeviceID, Size, FreeSpace -ErrorAction Stop -OperationTimeoutSec 2
                        $diskFree = ($disk.FreeSpace / $disk.Size) * 100 -as [int]
                        #get a count of all processes except idle and system and subtract 1 for the remote connection
                        $proc = (Get-Process).Where({$_.name -notmatch 'Idle|system'}).count -1
                        $os = Get-CimInstance -ClassName win32_operatingsystem -Property lastbootupTime
                        $isUp = $True
                    }
                    catch {
                        #this will probably never be used
                        $memUsage = 0
                        $diskFree = 0
                        $isUp = $False
                        Processes = 0
                        OS = "" 
                    }
                    [pscustomobject]@{
                        Computername = $env:computername
                        MemoryUsage  = $memUsage
                        DiskFree     = $diskFree
                        Processes    = $proc
                        IsUp         = $IsUp
                        Uptime       = ((Get-Date) - $os.LastBootUpTime).toString("d\.hh\:mm\:ss")
                    }
                } #end scriptblock
                    
                #define a pssession option to speed up connections
                $opt = New-PSSessionOption -OpenTimeout 1000 -MaxConnectionRetryCount 1

                do {
                    #define the list of computers to test
                    #filter out blank lines and trim any spaces to clean up names.
                    #This should be a short list unless you increase the width of your console sessions
                    if (Test-Path -path $script:listPath ) {
                           $computers = Get-Content -Path $script:listpath |
                            Where-Object {$_ -match '\w+' -AND $_ -notmatch "#"} | Foreach-Object {$_.trim()} | Sort-Object
                }
                else {
                    #if path not found default to local computer
                    $computers = $env:computername
                }


                    #make sure there are sessions for all computers in the list
                    $computers | Where-Object {(get-pssession).where( {$_.state -eq 'opened'}).computername -notcontains $_} |
                        ForEach-Object {
                        New-PSSession -ComputerName $_ -SessionOption $opt
                    }
                    #remove broken sessions
                    Get-PSSession | Where-Object {$_.state -eq 'broken'} | Remove-PSSession
                    $results = Invoke-Command -ScriptBlock $sb -HideComputerName  -Session (Get-PSSession) 

                    $global:rsHash.results = $results
                    $global:rsHash.date = Get-Date
                    $global:rshash.computers = $computers
                    #set a sleep interval between tests
                    Start-Sleep -Seconds 10
                } While ($True)
            }) # script
        $pscmd.runspace = $newrunspace
        [void]$psCmd.BeginInvoke()
    } #catch

    #guess at a line length
    $names = ($global:rshash.computers | Measure-Object -Property length -sum).sum
    #account for a : after each name + character + value
    #you may have to tweak this value to get everything to line up
    #and it might depend on whether you are using the console or ISE
    $len = $names + (($global:rshash.computers.count) * 27) + 1
    
    #display local computername and datetime
    $dt= "`n {2} {0} {1} " -f (get-date).toshortdatestring(),(get-date).TolongTimeString(),$env:computername
    Write-host $dt -ForegroundColor black -BackgroundColor gray

    Write-Host "`n$([char]0x250c)" -NoNewline
    Write-Host $(([char]0x2500).ToString() * $len ) -NoNewline
    Write-Host $([char]0x2510) 
    Write-Host " " -NoNewline

    if ($global:rsHash.results) {
    
        #create a hashtable from the results
        $h = $global:rshash.results | Group-Object -Property Computername -AsHashTable -AsString

        #sort the results by computername
        foreach ($item in $global:rshash.computers) {

            if ($h[$item]) {
                $obj = $h[$item]
            }
            else {
                #create a temporary object for computer that is not running but in the list
                $obj = [pscustomobject]@{
                    Computername = $item.ToUpper()
                    Uptime = (New-TimeSpan).toString()
                    DiskFree = "00"
                    MemoryUsage = "00"
                    Processes = "00"
                    IsUp = $false
                }
            }

            if ($obj.DiskFree -le 20) {
                $diskfg = "red"
            }
            elseif ($obj.DiskFree -le 75) {
                $diskfg = "yellow"
            }
            else {
                $diskfg = "green"
            }
            if ($obj.MemoryUsage -le 30) {
                $memfg = "red"
            }
            elseif ($obj.MemoryUsage -le 60) {
                $memfg = "yellow"
            }
            else {
                $memfg = "green"
            }
            
            if ($obj.IsUp) {
                Write-Host " $($charHash.Up)" -ForegroundColor green -NoNewline
                $upfg = "green"
            }
            else {
                Write-Host " $($charHash.down)" -ForegroundColor red -NoNewline
                $upfg = "red"
            }
            
            Write-Host $obj.Uptime -ForegroundColor $upfg -NoNewline
            Write-Host " $($obj.computername) " -NoNewline            
            Write-Host "$([char]0x058d)$($obj.diskfree)%" -NoNewline -ForegroundColor $diskfg
            Write-Host " $([char]0x3bc)$($obj.MemoryUsage)%"-NoNewline -ForegroundColor $memfg 
            Write-Host " p$($obj.Processes)" -NoNewline
            
        } #foreach
    }
    else {
        Write-Host "Working..." -ForegroundColor yellow -NoNewline
    }

    Write-Host " "
    Write-Host $([char]0x2514) -NoNewline
    Write-Host $(([char]0x2500).ToString() * $len ) -NoNewline
    Write-Host $([char]0x2518) 

    "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "

}
