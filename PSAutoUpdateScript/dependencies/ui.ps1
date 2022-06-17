

<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



#==============================================================================================================================================================
#                                             -------------- THIS FILE CONTAINS FUNCTIONS THAT ARE RELATED TO THE UI --------------
#==============================================================================================================================================================


#####################################################################
# MENU WRITER FUNCTIONS : uimi, uimt, uiml
#####################################################################

function uimi{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [Alias('t')]
        [switch]$Title,
        [Parameter(Mandatory=$false)]
        [Alias('s')]
        [switch]$SysOptions,
        [Parameter(Mandatory=$false)]
        [Alias('m')]
        [switch]$SpecialMode
    ) 
    if($Title){
        Write-Host -f Gray "$Message"    
    }elseif($SysOptions){
        Write-Host -n -f Red "$Message"
    }elseif($SpecialMode){
        Write-Host -n -f Yellow "$Message"
    }
    else{

        Write-Host -f Cyan "$Message"
    }
    
}

function uimt{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [Alias('t')]
        [switch]$Title
    ) 
    if($Title){
        Write-Host -n -f DarkRed "$Message"    
    }else{
        Write-Host -n -f DarkYellow "$Message"
    }
    
}


function uiml{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message
    ) 

    Write-Host -n -f White "$Message"
}





# Display Main Menu
#/======================================================================================/
function Show-Menu
{
    Clear-Host

    uimt 'General Functions                                                  ' -t; uimt "System Info`n" -t
    uimt '=======================================================            '; uimt "======================================`n" ; 
    uiml " 1. Run Local Script                                               "; uimi "Hostname:                    $Script:HostName" -t;
    uiml " 2. Get Current Version Information                                "; uimi "Administrarot                $Script:IsAdmin" -t;
    uiml " 3. Get Latest Script Version (no update)                          "; uimi "Network Status (is online)   $Script:IsOnline" -t;
    uiml " 4. Update Local Script file if new version available              "; uimi "IPv4 Address:                $Script:IPv4" -t;
    uiml " 5. List Revisions                                                 "; uimi "Test Mode                    $Script:TestMode`n" -m;
    uiml "                                                                   "; uimi "Debug Mode                   $Script:Debug`n" -m;
    uiml "                                                                   "; uimt " Script Information`n" -t
    uimt "                                                                   "; uimt "======================================`n"
    uimi "A) Admin Mode                                                      " -s; uimi "Current Script Version:   $Script:CurrentVersion"
    uimi "N) Update Network Status                                           " -s; uimi "Current Script GIT rev    $Script:CurrentGitRev"
    uimi "X) Exit                                                            " -s; uimi "Latest Script Version     $Script:LatestVersion"
    uiml "                                                                   "; uimi "Latest Script GIT rev        $Script:LatestGitRevision"
    
}
#//====================================================================================//


# Prompt to show at the end of each function
#/======================================================================================/
function Show-End
{
    Write-Host ""
    Write-Host "Operation complete."
    Write-Host "Press any key to return to the menu."
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-Menu
}
#//====================================================================================//




#####################################################################
#
# NETWORK -- LOOP UNTIL ONLINE
#
# This function is used to loop in the menu until we are ONLINE
#
#####################################################################
function Request-OnlineState{
    
    if($Script:IsOnline -eq $False){
        Clear-Host
        Write-Host -f DarkRed  "`tYOU ARE OFFLINE"
        Write-Host -f DarkYellow  "`t===============`n`n"
        Write-Host -f Yellow  "You are not connected to the internet. You cannot update the script!`n`n"
        Start-Sleep 2
        do{
            Read-Host -Prompt 'Press any key to test network'
            $Script:IsOnline = Get-NetworkStatus -Quick
        }while($Script:IsOnline -eq $False)
            cls
        }
}



#####################################################################
#
# GUI TEST FUNCTION TO PRINT NUMBERS IN ASCII ART
#
#####################################################################
function Get-NumberInAscii{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True)]
        [int]$Number
    ) 

        $Ret = ''
        switch($Number){
              10 {
                        $Ret = '
🅳🅾🆃
'}
                0 {
                        $Ret = '
╭━━━━┳━━━┳━━━┳━━━╮
╰━━╮━┃╭━━┫╭━╮┃╭━╮┃
╱╱╭╯╭┫╰━━┫╰━╯┃┃╱┃┃
╱╭╯╭╯┃╭━━┫╭╮╭┫┃╱┃┃
╭╯━╰━┫╰━━┫┃┃╰┫╰━╯┃
╰━━━━┻━━━┻╯╰━┻━━━╯
'}
                1 {
                        $Ret = '

░█████╗░███╗░░██╗███████╗
██╔══██╗████╗░██║██╔════╝
██║░░██║██╔██╗██║█████╗░░
██║░░██║██║╚████║██╔══╝░░
╚█████╔╝██║░╚███║███████╗
░╚════╝░╚═╝░░╚══╝╚══════╝
'}
                2 {
                        $Ret = '

▀▀█▀▀ ▒█░░▒█ ▒█▀▀▀█ 
░▒█░░ ▒█▒█▒█ ▒█░░▒█ 
░▒█░░ ▒█▄▀▄█ ▒█▄▄▄█
'}


                3 {
                        $Ret = '

▀▀█▀▀ ▒█░▒█ ▒█▀▀█ ▒█▀▀▀ ▒█▀▀▀ 
░▒█░░ ▒█▀▀█ ▒█▄▄▀ ▒█▀▀▀ ▒█▀▀▀ 
░▒█░░ ▒█░▒█ ▒█░▒█ ▒█▄▄▄ ▒█▄▄▄
'}

                4 {
                        $Ret = '

█▄─▄▄─█─▄▄─█▄─██─▄█▄─▄▄▀█
██─▄███─██─██─██─███─▄─▄█
▀▄▄▄▀▀▀▄▄▄▄▀▀▄▄▄▄▀▀▄▄▀▄▄▀
'}

                5 {
                        $Ret = '

███████╗██╗██╗░░░██╗███████╗
██╔════╝██║██║░░░██║██╔════╝
█████╗░░██║╚██╗░██╔╝█████╗░░
██╔══╝░░██║░╚████╔╝░██╔══╝░░
██║░░░░░██║░░╚██╔╝░░███████╗
╚═╝░░░░░╚═╝░░░╚═╝░░░╚══════╝
'}

                6 {
                        $Ret = '

█████████████████
█─▄▄▄▄█▄─▄█▄─▀─▄█
█▄▄▄▄─██─███▀─▀██
▀▄▄▄▄▄▀▄▄▄▀▄▄█▄▄▀
'}

                7 {
                        $Ret = '

█─▄▄▄▄█▄─▄▄─█▄─█─▄█▄─▄▄─█▄─▀█▄─▄█
█▄▄▄▄─██─▄█▀██▄▀▄███─▄█▀██─█▄▀─██
▀▄▄▄▄▄▀▄▄▄▄▄▀▀▀▄▀▀▀▄▄▄▄▄▀▄▄▄▀▀▄▄▀
'}

                8 {
                        $Ret = '

▒█▀▀▀ ▀█▀ ▒█▀▀█ ▒█░▒█ ▀▀█▀▀ 
▒█▀▀▀ ▒█░ ▒█░▄▄ ▒█▀▀█ ░▒█░░ 
▒█▄▄▄ ▄█▄ ▒█▄▄█ ▒█░▒█ ░▒█░░
'}

                9 {
                        $Ret = '

███████████████████████████
█▄─▀█▄─▄█▄─▄█▄─▀█▄─▄█▄─▄▄─█
██─█▄▀─███─███─█▄▀─███─▄█▀█
▀▄▄▄▀▀▄▄▀▄▄▄▀▄▄▄▀▀▄▄▀▄▄▄▄▄▀
'}

        }
            return $Ret
}



#####################################################################
#
# Invoke-Script : Placeholder function that does some stuff.
# It will print out the script version as well so that when you 
# run the Updated script, you can validate the code is OK
#
#####################################################################
function Invoke-OriginalScript{
    [CmdletBinding(SupportsShouldProcess)]
    param(
    ) 

    Clear-Host
    
    $t = "
  _


░█▀▀▀█ ░█▀▀█ ▀█▀ ░█▀▀█ ▀█▀ ░█▄─░█ ─█▀▀█ ░█─── 　 ░█▀▀▀█ ░█▀▀█ ░█▀▀█ ▀█▀ ░█▀▀█ ▀▀█▀▀ 
░█──░█ ░█▄▄▀ ░█─ ░█─▄▄ ░█─ ░█░█░█ ░█▄▄█ ░█─── 　 ─▀▀▀▄▄ ░█─── ░█▄▄▀ ░█─ ░█▄▄█ ─░█── 
░█▄▄▄█ ░█─░█ ▄█▄ ░█▄▄█ ▄█▄ ░█──▀█ ░█─░█ ░█▄▄█ 　 ░█▄▄▄█ ░█▄▄█ ░█─░█ ▄█▄ ░█─── ─░█──

"

    $t2 = @"

░█▀▀█ ░█▀▀▀█ 　 ─█▀▀█ ░█─░█ ▀▀█▀▀ ░█▀▀▀█ 　 ░█─░█ ░█▀▀█ ░█▀▀▄ ─█▀▀█ ▀▀█▀▀ ░█▀▀▀ 　 ░█▀▀▄ ░█▀▀▀ ░█▀▄▀█ ░█▀▀▀█ 
░█▄▄█ ─▀▀▀▄▄ 　 ░█▄▄█ ░█─░█ ─░█── ░█──░█ 　 ░█─░█ ░█▄▄█ ░█─░█ ░█▄▄█ ─░█── ░█▀▀▀ 　 ░█─░█ ░█▀▀▀ ░█░█░█ ░█──░█ 
░█─── ░█▄▄▄█ 　 ░█─░█ ─▀▄▄▀ ─░█── ░█▄▄▄█ 　 ─▀▄▄▀ ░█─── ░█▄▄▀ ░█─░█ ─░█── ░█▄▄▄ 　 ░█▄▄▀ ░█▄▄▄ ░█──░█ ░█▄▄▄█
  ____                       _____ _          _ _ 
 |  __ \                     / ____| |        | | |
 | |__) |____      _____ _ __ (___ | |__   ___| | |
 |  ___/ _ \ \ /\ / / _ \ '__\___ \| '_ \ / _ \ | |
 | |  | (_) \ V  V /  __/ |  ____) | | | |  __/ | |         AUTO UPDATE DEMO - THIS SCRIPT VERSION
 |_|   \___/ \_/\_/ \___|_| |_____/|_| |_|\___|_|_|         $Script:CurrentVersionString
                                                   
"@


    
    for ($i=0;$i -lt $t.length;$i++) {
    if ($i%2) {
         $c = "red"
    }
    elseif ($i%5) {
     $c = "yellow"
    }
    elseif ($i%7) {
         $c = "green"
    }
    else {
       $c = "white"
    }
    write-host $t[$i] -NoNewline -ForegroundColor $c
    
    }

    write-host $t2 -f Blue
    Start-Sleep 5

    Invoke-SlidingMessage "THIS IS THE ORIGINAL SCRIPT. IF YOU UPDATE THE VERSION, YOU WILL GET A DIFFERENT OUTPUT. $Script:CurrentVersionString"
    Read-Host -Prompt 'Press any key to return to main menu'
}

function New-Script{
    $Image = '
  888888888888888888888
  s 88 ooooooooooooooo 88     s 888888888888888888888888888888888888888
  S 88 888888888888888 88    SS 888888888888888888888888888888888888888
 SS 88 888888888888888 88   SSS 8888                         - --+ 8888
 SS 88 ooooooooooooooo 88  sSSS 8888           o8888888o         | 8888
sSS 88 888888888888888 88 SSSSS 8888         o88888888888o         8888
SSS 88 888888888888888 88 SSSSS 8888        8888 88888 8888      | 8888
SSS 88 ooooooooooooooo 88 SSSSS 8888       o888   888   888o       8888
SSS 88 888888888888888 88 SSSSS 8888       8888   888   8888       8888
SSS 88 888888888888888 88 SSSSS 8888       8888   888   8888       8888
SSS 88 oooooooooo      88 SSSSS 8888       8888o o888o o8888       8888
SSS 88 8888888888 .::. 88 SSSSS 8888       988 8o88888o8 88P       8888
SSS 88 oooooooooo :::: 88 SSSSS 8888        8oo 9888889 oo8        8888
SSS 88 8888888888  ``  88 SSSSS 8888         988o     o88P         8888
SSS 88ooooooooooooooooo88  SSSS 8888           98888888P           8888
SSS 888888888888888888888__SSSS 8888                               8888_____
SSS |   *  *  *   )8c8888  SSSS 888888888888888888888888888888888888888
SSS 888888888888888888888.  SSS 888888888888888888888888888888888888888
SSS 888888888888888888888 \_ SSsssss oooooooooooooooooooooooooooo ssss
SSS 888888888888888888888  \\   __SS 88+-8+-88============8-8==88 S
SSS 888888888888888888888-. \\  \  S 8888888888888888888888888888
SSS 888888888888888888888  \\\  \\       `.__________.`      ` .
SSS 88O8O8O8O8O8O8O8O8O88  \\.   \\______________________________`_.
SSS 88 el cheapo 8O8O8O88 \\  `.  \|________________________________|
 SS 88O8O8O8O8o8O8O8O8O88  \\   `-.___
  S 888888888888888888888 /~          ~~~~~-----~~~~---.__
 .---------------------------------------------------.    ~--.
 \ \______\ __________________________________________\-------^.-----------.
 :`  _   _ _ _ _  _ _ _ _  _ _ _ _   _ _ _           `\        \
 ::\ ,\_\,\_\_\_\_\\_\_\_\_\\_\_\_\_\,\_\_\_\           \      o `8o 8o .
 |::\  -_-_-_-_-_-_-_-_-_-_-_-_-_-___  -_-_-_   _ _ _ _  \      8o 88 88 \
 |_::\ ,\_\_\_\_\_\_\_\_\_\_\_\_\_\___\,\_\_\_\,\_\_\_\_\ \      88       \
    `:\ ,\__\_\_\_\_\_\_\_\_\_\_\_\_\  \,\_\_\_\,\_\_\_\ \ \      88       .
     `:\ ,\__\_\_\_\_\_\_\_\_\_\_\_\____\    _   ,\_\_\_\_\ \      88o    .|
       :\ ,\____\_\_\_\_\_\_\_\_\_\_\____\  ,\_\ _,\_\_\_\ \ \      `ooooo`
        :\ ,\__\\__\_______________\__\\__\,\_\_\_\,\___\_\_\ \
         `\  --  -- --------------- --  --   - - -   --- - -   )____________
           `--------------------------------------------------`

'
    Write-Host $Image -f DarkRed


}


Function Get-MissionImpossible {
    [console]::beep(784, 150)
    Start-Sleep -m 300
    [console]::beep(784, 150)
    Start-Sleep -m 300
    [console]::beep(932, 150)
    Start-Sleep -m 150
    [console]::beep(1047, 150)
    Start-Sleep -m 150
    [console]::beep(784, 150)
    Start-Sleep -m 300
    [console]::beep(784, 150)
    Start-Sleep -m 300
    [console]::beep(699, 150)
    Start-Sleep -m 150
    [console]::beep(740, 150)
    Start-Sleep -m 150
    [console]::beep(784, 150)
    Start-Sleep -m 300
    [console]::beep(784, 150)
    Start-Sleep -m 300
    [console]::beep(932, 150)
    Start-Sleep -m 150
    [console]::beep(1047, 150)
    Start-Sleep -m 150
    [console]::beep(784, 150)
    Start-Sleep -m 300
    [console]::beep(784, 150)
    Start-Sleep -m 300
    [console]::beep(699, 150)
    Start-Sleep -m 150
    [console]::beep(740, 150)
    Start-Sleep -m 150
    [console]::beep(932, 150)
    [console]::beep(784, 150)
    [console]::beep(587, 1200)
    Start-Sleep -m 75
    [console]::beep(932, 150)
    [console]::beep(784, 150)
    [console]::beep(554, 1200)
    Start-Sleep -m 75
    [console]::beep(932, 150)
    [console]::beep(784, 150)
    [console]::beep(523, 1200)
    Start-Sleep -m 150
    [console]::beep(466, 150)
    [console]::beep(523, 150)
}

function Test-DisplayCurrentVersion {
    [CmdletBinding(SupportsShouldProcess)]
    param(
      
    ) 

    $BigVersion = ''

    $BigVersion += Get-NumberInAscii $CurrentVersion.Major
    $BigVersion += Get-NumberInAscii 10
    $BigVersion += Get-NumberInAscii $CurrentVersion.Minor
    $BigVersion += Get-NumberInAscii 10
    $BigVersion += Get-NumberInAscii $CurrentVersion.Revision
    $BigVersion += Get-NumberInAscii 10
    $BigVersion += Get-NumberInAscii $CurrentVersion.Major


    Read-Host -Prompt 'Press any key to return to main menu'

}

function Invoke-SlidingMessage {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True)]
        [string]$Text,
        [Parameter(Mandatory=$False)]
        [int]$TimeToLive=5,
        [Parameter(Mandatory=$false)]
        [switch]$ClearScreen,
        [Parameter(Mandatory=$false)]
        [array]$OverrideTextPosition
    ) 

    
    # Get the position of the Cursor on the screen and move it
    $Position=$HOST.UI.RawUI.CursorPosition

    $ValueCount = $OverrideTextPosition.Count
    if(($OverrideTextPosition -ne $Null) -And ($ValueCount -eq 2) ) {
        Write-Verbose "Invoke-SlidingMessage -- OverrideTextPosition was specified, with those values: ValueX $ValueX . ValueY $ValueY"
        $ValueX = $OverrideTextPosition[0]
        $ValueY = $OverrideTextPosition[1]

        $Position.X=$ValueX
        $Position.Y=$ValueY
    }else{
        $ValueX = $Position.X
        $ValueY = $Position.Y
        Write-Verbose "Invoke-SlidingMessage -- OverrideTextPosition was NOT specified, using current position. ValueX $ValueX . ValueY $ValueY"
    }
    
    
    # Clear the console of rubbish
    if($ClearScreen){
        Write-Verbose "Invoke-SlidingMessage -- ClearScreen"
        cls
    }

    Write-Verbose "Invoke-SlidingMessage -- TimeToLive Set to $TimeToLive"

    # Are how much information the user keyed in
    $length=$text.Length

    # Mark our Start end End points for our Marquee loop
    $Start=1
    $End=$Length
    $zerocharacters=0


    $StartSecs = Get-Date -UFormat %s
    $CurrSecs  = $StartSecs 
    # Do this over and repeatedly and over ….
    do {
        $CurrSecs = Get-Date -UFormat %s
        $ElapsedSecs = $CurrSecs - $StartSecs

        if($ElapsedSecs -gt $TimeToLive) {  return }
        foreach ($count in $start .. $end) {

        # Keep everthing on the same line
        $HOST.UI.RawUI.CursorPosition=$Position

        # Remember how many characters for that OTHER loop
        $characters=($length – $count)

        # Put exactly WHAT we what WHERE we want WHEN we want
        $text.Substring(($zerocharacters*$characters),$count).padleft(([int]!$zerocharacters*$Length),’ ‘).padright(($zerocharacters*$Length),’ ‘)

        # Time a quick ‘POWER Nap’ – Oh sorry, was that Bad?
        start-sleep -milliseconds 50
        }
        # Flip the counters around
        $start=($length+1)-$start
        $end=$length-$end
        $zerocharacters=1-$zerocharacters
    } Until ($start -eq -9) # You can change this to wait for a key if you REAAALY want 🙂
}



Function ConvertTo-ASCIIArt {
    [cmdletbinding()]
    [alias("cart")]
    [outputtype([System.String])]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter a short string of text to convert", ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Text,
        [Parameter(Position = 1,HelpMessage = "Specify a font from https://artii.herokuapp.com/fonts_list. Font names are case-sensitive")]
        [ValidateNotNullOrEmpty()]
        [string]$Font = "big"
    )

    
    Write-Verbose "Processing $text with font $Font"
    $testEncode = [uri]::EscapeDataString($Text)
    $url = "http://artii.herokuapp.com/make?text=$testEncode&font=$Font"
    Try {
        Invoke-Restmethod -Uri $url -DisableKeepAlive -ErrorAction Stop
    }
    Catch {
        Show-ExceptionDetails $_ -ShowStack
    }


}

function Update-AllVersionValues{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$CurrentVersionUpdate,
        [Parameter(Mandatory=$false)]
        [switch]$LatestVersionUpdate,
        [Parameter(Mandatory=$false)]
        [switch]$CheckOnline
    ) 


    [string]$Script:CurrentVersionString = "__CURRENT_VERSION_STRING__"
    if($Script:CurrentVersionString -eq '__CURRENT_VERSION_STRING__'){
        [string]$Script:CurrentVersionString = $Script:DEFAULT_VERSION
    }
    

    if ( ($PSBoundParameters.ContainsKey('CurrentVersionUpdate')) -And ($CurrentVersionUpdate -ne $Null) -And   ($CurrentVersionUpdate -ne '')){ 
        
        Write-Verbose "Argument Specified CurrentVersionUpdate ==> $CurrentVersionUpdate"
        $Script:CurrentVersionString = $CurrentVersionUpdate
    }
    if ( ($PSBoundParameters.ContainsKey('LatestVersionUpdate')) -And ($LatestVersionUpdate -ne $Null) -And   ($LatestVersionUpdate -ne '')){ 
        
        Write-Verbose "Argument Specified LatestVersionUpdate ==> $LatestVersionUpdate"
        $Script:LatestScriptVersionString = $LatestVersionUpdate
    }

    if($CheckOnline){
        if($Script:IsOnline -eq $False){ 
            Write-Warning "Can't check online version :ffline mode"; 
        }else{
            try{
                [string]$Script:LatestVersionString = Get-OnlineStringNoCache $Script:OnlineVersionFileUrl
            }catch{
                Write-Warning "Error while fetch version on server"; 
                [string]$Script:LatestVersionString = $Script:UNKNOWN_VERSION
            }
            
        }
        
    }
    [Version]$Script:CurrentVersion =  $Script:CurrentVersionString
    [string]$script:LatestScriptRevision = $Script:LatestScriptVersionString

    
    Write-Verbose "CurrentVersion ==> $Script:CurrentVersion"
    Write-Verbose "LatestScriptRevision ==> $Script:LatestScriptRevision"
}