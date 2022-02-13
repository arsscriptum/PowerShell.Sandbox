

New-UDInput -Title "Network Tester. Please Enter Destination Server Name For The Server You Want To Ping. (Source is Currently AWS VDI)" -Endpoint {
        param(
            [string]$destination
        )
        
        New-UDInputAction -Content {
            New-UDElement -Tag 'div'  -Content { 

                New-UDTable -Title 'Test Results' -Headers  @('RemoteAddress' , 'InterfaceAlias', 'SourceAddress' , 'PingSucceeded') -Endpoint { 
                    Test-NetConnection -ComputerName $destination | 
                    Select-Object @{name = 'RemoteAddress'; expression = { $_.RemoteAddress.ipaddresstostring | Out-String } },
                     InterfaceAlias,
                      @{name = 'SourceAddress'; expression = { $_.SourceAddress.ipaddress} }, 
                      @{name='PingSucceeded';expression={[String]$_.PingSucceeded}} | 
                      Out-UDTableData -Property @('RemoteAddress' , 'InterfaceAlias', 'SourceAddress' , 'PingSucceeded')
                }
                ####End Network Tester####

            }#close inpuct action 

        }#close input
    }#close input