
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

<#
.SYNOPSIS
    Script with auto update
.DESCRIPTION
   From the PowerShell forums at https://www.reddit.com/r/PowerShell/comments/vdgush/best_way_to_selfupdate_a_script/ where

#> 




#==============================================================================================================================================================
#                                             -------------- THIS FILE CONTAINS FUNCTIONS THAT ARE USED BY THE TEST CASE IMPLEMENTATION  --------------
#==============================================================================================================================================================





#===============================================================================
# Helpers
#===============================================================================


function Write-ErrorMessage{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.ErrorRecord]$Record,
        [Parameter(Mandatory=$false)]
        [switch]$ShowStack
    )       
    $formatstring = "{0}`n{1}"
    $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
    $ExceptMsg=($formatstring -f $fields)
    $Stack=$Record.ScriptStackTrace
    Write-Host "`n[ERROR] -> " -NoNewLine -ForegroundColor DarkRed; 
    Write-Host "$ExceptMsg`n`n" -ForegroundColor DarkYellow
    if($ShowStack){
        Write-Host "--stack begin--" -ForegroundColor DarkGreen
        Write-Host "$Stack" -ForegroundColor Gray  
        Write-Host "--stack end--`n" -ForegroundColor DarkGreen       
    }
}  



function Check-RequiredDefinitions{

    $ObjectDeclared = $true
    # Validate the declaration of the ScriptVersion object
    try{
        # New Select-Object
        [ScriptVersionData]$Global:ScriptVersionObject = New-Object -TypeName ScriptVersionData -ErrorAction Stop

        if( $Null -eq $verData ){
            $ObjectDeclared = $false
        }else{

            $ObjMembers = $verData | gm
            $Global:ScriptVersionMemberCount = $ObjMembers.Count

            # Set the instanciation time...
            $Global:ScriptVersionActivationtime = Get-Date -UFormat %s

        }
    }catch{

        $ObjectDeclared = $false

    }

}










Function Show-AsciiArt{
<#
.SYNOPSIS

HELPER FUNCTION :: Displays random ASCII art for Invoke-Obfuscation.

Invoke-Obfuscation Function: Show-AsciiArt
Author: Daniel Bohannon (@danielhbohannon)
License: Apache License, Version 2.0
Required Dependencies: None
Optional Dependencies: None
 
.DESCRIPTION

Show-AsciiArt displays random ASCII art for Invoke-Obfuscation, and also displays ASCII art during script startup.

.EXAMPLE

C:\PS> Show-AsciiArt

.NOTES

Credit for ASCII art font generation: http://patorjk.com/software/taag/
This is a personal project developed by Daniel Bohannon while an employee at MANDIANT, A FireEye Company.

.LINK

http://www.danielbohannon.com
#>
    [CmdletBinding()] Param (
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Switch]
        $Random
    )

    # Create multiple ASCII art title banners.
    $Spacing = "`t"
    $InvokeObfuscationAscii  = @()
    $InvokeObfuscationAscii += $Spacing + '    ____                 __                              '
    $InvokeObfuscationAscii += $Spacing + '   /  _/___ _   ______  / /_____                         '
    $InvokeObfuscationAscii += $Spacing + '   / // __ \ | / / __ \/ //_/ _ \______                  '
    $InvokeObfuscationAscii += $Spacing + ' _/ // / / / |/ / /_/ / ,< /  __/_____/                  '
    $InvokeObfuscationAscii += $Spacing + '/______ /__|_________/_/|_|\___/         __  _           '
    $InvokeObfuscationAscii += $Spacing + '  / __ \/ /_  / __/_  ________________ _/ /_(_)___  ____ '
    $InvokeObfuscationAscii += $Spacing + ' / / / / __ \/ /_/ / / / ___/ ___/ __ `/ __/ / __ \/ __ \'
    $InvokeObfuscationAscii += $Spacing + '/ /_/ / /_/ / __/ /_/ (__  ) /__/ /_/ / /_/ / /_/ / / / /'
    $InvokeObfuscationAscii += $Spacing + '\____/_.___/_/  \__,_/____/\___/\__,_/\__/_/\____/_/ /_/ '
    
    # Ascii art to run only during script startup.
    If(!$PSBoundParameters['Random'])
    {
        $ArrowAscii  = @()
        $ArrowAscii += '  |  '
        $ArrowAscii += '  |  '
        $ArrowAscii += ' \ / '
        $ArrowAscii += '  V  '

        # Show actual obfuscation example (generated with this tool) in reverse.
        Write-Host "`nIEX( ( '36{78Q55@32t61_91{99@104X97{114Q91-32t93}32t93}32t34@110m111@105}115X115-101m114_112@120@69-45{101@107X111m118m110-73Q124Q32X41Q57@51-93Q114_97_104t67t91{44V39Q112_81t109@39}101{99@97}108{112}101}82_45m32_32X52{51Q93m114@97-104{67t91t44t39V98t103V48t39-101}99}97V108}112t101_82_45{32@41X39{41_112t81_109_39m43{39-110t101@112{81t39X43@39t109_43t112_81Q109t101X39Q43m39}114Q71_112{81m109m39@43X39V32Q40}32m39_43_39{114-111m108t111t67{100m110{117Q39_43m39-111-114Q103_101t114@39m43-39{111t70-45}32m41}98{103V48V110Q98t103{48@39{43{39-43{32t98m103_48{111@105t98@103V48-39@43{39_32-32V43V32}32t98t103@48X116m97V99t98X103t48_39V43m39@43-39X43Q39_98@103@48}115V117V102Q98V79m45@98m39Q43{39X103_39X43Q39V48}43-39}43t39}98-103{48V101_107Q39t43X39_111X118X110V39X43}39t98_103{48@43}32_98{103}48{73{98-39@43t39m103_39}43{39{48Q32t39X43X39-32{40V32t41{39Q43V39m98X103{39_43V39{48-116{115Q79{39_43_39}98}103m48{39Q43t39X32X43{32_98@103-39@43m39X48_72-39_43t39V45m39t43Q39_101Q98}103_48-32_39Q43V39V32t39V43}39m43Q32V98X39Q43_39@103_48V39@43Q39@116X73t82V119m98-39{43_39}103Q48X40_46_32m39}40_40{34t59m91@65V114V114@97_121}93Q58Q58V82Q101Q118Q101{114}115_101m40_36_78m55@32t41t32-59{32}73{69V88m32{40t36V78t55}45Q74m111@105-110m32X39V39-32}41'.SpLiT( '{_Q-@t}mXV' ) |ForEach-Object { ([Int]`$_ -AS [Char]) } ) -Join'' )" -ForegroundColor Cyan
        Start-Sleep -Milliseconds 650
        ForEach($Line in $ArrowAscii) {Write-Host $Line -NoNewline; Write-Host $Line -NoNewline; Write-Host $Line -NoNewline; Write-Host $Line}
        Start-Sleep -Milliseconds 100
        
        Write-Host "`$N7 =[char[ ] ] `"noisserpxE-ekovnI| )93]rahC[,'pQm'ecalpeR-  43]rahC[,'bg0'ecalpeR- )')pQm'+'nepQ'+'m+pQme'+'rGpQm'+' ( '+'roloCdnu'+'orger'+'oF- )bg0nbg0'+'+ bg0oibg0'+'  +  bg0tacbg0'+'+'+'bg0sufbO-b'+'g'+'0+'+'bg0ek'+'ovn'+'bg0+ bg0Ib'+'g'+'0 '+' ( )'+'bg'+'0tsO'+'bg0'+' + bg'+'0H'+'-'+'ebg0 '+' '+'+ b'+'g0'+'tIRwb'+'g0(. '((`";[Array]::Reverse(`$N7 ) ; IEX (`$N7-Join '' )" -ForegroundColor Magenta
        Start-Sleep -Milliseconds 650
        ForEach($Line in $ArrowAscii) {Write-Host $Line -NoNewline; Write-Host $Line -NoNewline; Write-Host $Line}
        Start-Sleep -Milliseconds 100

        Write-Host ".(`"wRIt`" +  `"e-H`" + `"Ost`") (  `"I`" +`"nvoke`"+`"-Obfus`"+`"cat`"  +  `"io`" +`"n`") -ForegroundColor ( 'Gre'+'en')" -ForegroundColor Yellow
        Start-Sleep -Milliseconds 650
        ForEach($Line in $ArrowAscii) {Write-Host $Line -NoNewline;  Write-Host $Line}
        Start-Sleep -Milliseconds 100

        Write-Host "Write-Host `"Invoke-Obfuscation`" -ForegroundColor Green" -ForegroundColor White
        Start-Sleep -Milliseconds 650
        ForEach($Line in $ArrowAscii) {Write-Host $Line}
        Start-Sleep -Milliseconds 100
        
        # Write out below string in interactive format.
        Start-Sleep -Milliseconds 100
        ForEach($Char in [Char[]]'Invoke-Obfuscation')
        {
            Start-Sleep -Milliseconds (Get-Random -Input @(25..200))
            Write-Host $Char -NoNewline -ForegroundColor Green
        }
        
        Start-Sleep -Milliseconds 900
        Write-Host ""
        Start-Sleep -Milliseconds 300
        Write-Host

        # Display primary ASCII art title banner.
        $RandomColor = (Get-Random -Input @('Green','Cyan','Yellow'))
        ForEach($Line in $InvokeObfuscationAscii)
        {
            Write-Host $Line -ForegroundColor $RandomColor
        }
    }
    Else
    {
        # ASCII option in Invoke-Obfuscation interactive console.

    }

    # Output tool banner after all ASCII art.
    Write-Host ""
    Write-Host "`tAuthor  :: Daniel Bohannon (DBO)" -ForegroundColor Magenta
    Write-Host "`tTwitter :: @danielhbohannon" -ForegroundColor Magenta
    Write-Host "`tBlog    :: http://danielbohannon.com" -ForegroundColor Magenta
    Write-Host "`tGithub  :: https://github.com/danielbohannon/Invoke-Obfuscation" -ForegroundColor Magenta
    Write-Host "`tVersion :: 1.8" -ForegroundColor Magenta
    Write-Host "`tLicense :: Apache License, Version 2.0" -ForegroundColor Magenta
    Write-Host "`tNotes   :: If(!`$Caffeinated) {Exit}" -ForegroundColor Magenta
}


function Write-TestLog{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [Alias('m')]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [switch]$NoTime,
        [Parameter(Mandatory=$false)]
        [Alias('i')]
        [switch]$Important
    )  
   
    if ($PSBoundParameters.ContainsKey('Important')) {
        Write-Host -f DarkYellow "`n`n=====BEGIN====="
        Write-Host -f Red "$Message"
        Write-Host -f DarkYellow "=====END=====`n`n"
        return
    }    

    if ($PSBoundParameters.ContainsKey('NoTime')) {
        Write-Host -n -f DarkCyan "[ScriptVersion Test] "
        Write-Host -f White "$Message"
        return
    }

    $LogMsgTime = Get-Date
    $FormattedTimeStamp = $LogMsgTime.ToLocalTime().ToString("HH.mm.ss")

    $formatstring = "{0} {1}"
    $fields = $FormattedTimeStamp,$Message
    $FormattedMessage = ($formatstring -f $fields)
    Write-Host -n -f DarkCyan "[ScriptVersion Test] "
    Write-Host -f White "$FormattedMessage";
    
}




Remove-Alias -Name 'syslog' -ErrorAction Ignore | Out-Null
New-Alias -Name 'syslog' -Value "Write-TestLog" -ErrorAction Ignore -Scope Global | Out-Null
