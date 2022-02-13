
 Test-Connection 10.242.2.2,10.1.31.147,192.168.0.1
  Test-Connection 10.242.2.2 -Count 1
-Count <int>

 Test-Connection 10.242.2.2,10.1.31.147,192.168.0.1 -Quiet -Count 1| ConvertTo-Html  -Property Time -Title "time"


 if (Test-Connection -computername $computer -Quiet -Count 1) {
    # succeeded do stuff
} else {
    # failed, log or whatever
}

 Test-Connection 10.242.2.2,192.168.0.1 -Quiet -Count 1