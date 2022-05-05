
<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$false)]
    [Alias('test', 't', 'var')]
    [switch]$ShowVariables        
        
)




function Test-RegistryValue
{
<#
    .Synopsis
    Check if a value exists in the Registry
    .Description
    Check if a value exists in the Registry
    .Parameter Path
    Value registry path
    .Parameter Entry
    The entry to validate
    .Inputs
    None
    .Outputs
    None
    .Example
    Reg-Test-Value "$ENV:OrganizationHKLM\reddit-pwsh-script" "AccessToken"
    >> TRUE

#>
    param (
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Entry
    )

    if(-not(Test-Path $Path)){
        return $false
    }
    try {
        Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Entry -ErrorAction Stop | Out-Null
        return $true
    }

    catch {
        return $false
    }
}



function Get-RegistryValue
{
<#
    .Synopsis
    Check if a value exists in the Registry
    .Description
    Check if a value exists in the Registry
    .Parameter Path
    Value registry path
    .Parameter Entry
    The entry to validate
    .Inputs
    None
    .Outputs
    None
    .Example
    Get-RegistryValue "$ENV:OrganizationHKCU\terminal" "CurrentProjectPath" 
    Get-RegistryValue "$ENV:OrganizationHKLM\PowershellToolsSuite\GitHubAPI" "AccessToken"
    >> TRUE

#>
    param (
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Entry
    )

    if(-not(Test-Path $Path)){
        return $null
    }
    try {
        $Result=(Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Entry)
        return $Result
    }

    catch {
        return $null
    }
   
}




function Set-RegistryValue
{
<#
    .Synopsis
    Add a value in the registry, if it exists, it will replace
    .Description
    Add a value in the registry, if it exists, it will replace
    .Parameter Path
    Path
    .Parameter Name
    Name
    .Parameter Value
    Value 
    .Inputs
    None
    .Outputs
    SUCCESS(true) or FAILURE(false)
    .Example
    Set-RegistryValue "$ENV:OrganizationHKLM\reddit-pwsh-script" "ATestingToken" "blabla"
    >> TRUE

#>
    param (
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Name,
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Value
    )

     if(-not(Test-Path $Path)){
        New-Item -Path $Path -Force  -ErrorAction ignore | Out-null
    }

    try {
        if(Test-RegistryValue -Path $Path -Entry $Name){
            Remove-ItemProperty -Path $Path -Name $Name -Force  -ErrorAction ignore | Out-null
        }
      
        New-ItemProperty -Path $Path -Name $Name -Value $Value -Force | Out-null
        return $true
    }

    catch {
        return $false
    }
}




function New-RegistryValue
{
<#
    .Synopsis
    Create FULL Registry Path and add value
    .Description
    Add a value in the registry, if it exists, it will replace
    .Parameter Path
    Path
    .Parameter Name
    Name
    .Parameter Value
    Value 
    .Inputs
    None
    .Outputs
    SUCCESS(true) or FAILURE(false)
    .Example
    New-RegistryValue "$ENV:OrganizationHKLM\reddit-pwsh-script" "ATestingToken" "blabla"
    New-RegistryValue "$ENV:OrganizationHKCU\terminal" "CurrentProjectPath" "D:\Development\CodeCastor\network\netlib"
    >> TRUE

#>
    param (
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Name,
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Value,
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Type
    )

    try {
        if(Test-Path -Path $Path){
            if(Test-RegistryValue -Path $Path -Entry $Name){
                Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction ignore | Out-null
            }
        }
        else{
            New-Item -Path $Path -Force | Out-null
        }

        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type  | Out-null
        
        return $true
    }

    catch {
        return $false
    }
   
}


function Format-RegistryPath
{
<#
    .Synopsis
   Check a registry path validity
    .Parameter Path
    Path
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
     [parameter(Mandatory=$false)]
     [Alias('p')]
     [ValidateNotNullOrEmpty()]
     [string]$Path
    )

    try {
        $ValidHives = @('HKCU','HKLM','HKCR','HKCC','HKUS','HKEY_CLASSES_ROOT','HKEY_CURRENT_USER','HKEY_LOCAL_MACHINE','HKEY_USERS','HKEY_CURRENT_CONFIG')
        $Len = $Path.Length 
        if($Len -lt 5){ return $Null }

        if($Path.StartsWith('Computer\')){
            #$Path = $Path.Trim('Computer\')
            $Path = $Path.SubString(9)
            Write-Verbose "Remove 'Computer\'"
        }
        Write-Verbose "Path id $Path"

        $i = $Path.IndexOf('\')

        $Hive = $Path.SubString(0,$i)
        Write-Verbose "Hive is $Hive"
        $Hive = $Hive.Trim(':')
        Write-Verbose "Trim colon Hive is $Hive"
        if($ValidHives.Contains($Hive) -eq $False) {Write-Verbose "Not in valid hives"; return $Null }
        $HiveLen = $Hive.Length
        $Len = $Path.Length 
        $Path = $Path.SubString($HiveLen)
        Write-Verbose "Path is $Path"
        $Path = $Path.Trim(':','\')
        Write-Verbose "Path is $Path"
        if($Hive -eq 'HKCR'){
            $Hive = 'HKEY_CLASSES_ROOT'
        }elseif($Hive -eq 'HKLM'){
            $Hive = 'HKEY_LOCAL_MACHINE'
        }elseif($Hive -eq 'HKUS'){
            $Hive = 'HKEY_USERS'
        }elseif($Hive -eq 'HKCU'){
            $Hive = 'HKEY_CURRENT_USER'
        }elseif($Hive -eq 'HKCC'){
            $Hive = 'HKEY_CURRENT_CONFIG'
        }

        Write-Verbose "Hive is $Hive"
        $RegPath = 'Computer\' + $Hive + '\' + $Path
        return $RegPath
        
    }catch {
        return $Null
    }
}

function Start-RegistryEditor
{
<#
    .Synopsis
    Start Reg Edit and go to a key
    .Description
    Start Reg Edit and go to a key
    .Parameter Path
    Path
    .Parameter Clipboard
    Name
#>
    param (
     [parameter(Mandatory=$false)]
     [Alias('p')]
     [string]$Path,
     [parameter(Mandatory=$false)]
     [Alias('c')]
     [switch]$Clipboard
    )

    [string]$LastKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit"
    [string]$LastKeyValue = "LastKey"
    try {
        if($Clipboard){
            $Path = Get-Clipboard -Raw
        }
        $RegPath = Format-RegistryPath "$Path"
        if($RegPath -eq $Null) { throw "Bad Registry Path" }
        Set-RegistryValue "$LastKeyPath" "$LastKeyValue" "$RegPath"      
        $RegEditExe = (Get-Command "regedit.exe").Source
        &"$RegEditExe"
        return
    }catch{
        Show-ExceptionDetails($_) -ShowStack
    }
}




function Get-DirectoryTree { 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Container) ){
                throw "The Path argument must be a Directory. Files paths are not allowed."
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path,
        [Parameter(Mandatory=$false)]
        [String]$Exclude
        
    )
    $Tree = [System.Collections.ArrayList]::new()   
    $Path=(Resolve-Path $Path).Path
    if ($Path.Chars($Path.Length - 1) -ne '\'){
        $Path = ($Path + '\')
    }

    $obj = [PSCustomObject]@{
        Path = $Path
        Relative = ''
    }
    $null=$Tree.Add($obj)    

    try{
        If( $PSBoundParameters.ContainsKey('Exclude') -eq $True ){
            $DirList = (Get-ChildItem $Path -Recurse -ErrorAction Ignore -Directory) 
            if($DirList -eq $Null){
                return $Tree
            }
            $DirList = Get-ChildItem $Path -Recurse -ErrorAction Ignore -Directory | where Fullname -notmatch "$Exclude"
            if($DirList -eq $Null){
                return $Tree
            }

            $DirList = $DirList | sort -Descending -unique
                
        }else{
            $DirList = (Get-ChildItem $Path -Recurse -Force -ErrorAction Ignore -Directory)
            if($DirList -eq $Null){
                return $Tree
            }
            $DirList = $DirList.Fullname | sort -Descending -unique
        }
        $len = $Path.Length
        
        $DirList.ForEach({
            $fn = $_
            $rel = $fn.SubString($len, $fn.Length-$len)
            $obj = [PSCustomObject]@{
                Path = $fn
                Relative = $rel
            }
            $null=$Tree.Add($obj)
        })
        return $Tree
    }catch {
        Show-ExceptionDetails($_) -ShowStack
    }

} 

# ------------------------------------
# Script file - Assemblies - 
# ------------------------------------
$ScriptBlockAssemblies = "H4sIAAAAAAAACtVXbW/bNhD+HiD/4eAKsIRazqd96RCgiR1v2WLHiINmRWAUjHWO2dKkSlIwjK7/fUeJkmXHL3GwD5sQCDF5rw+fO55OT4LRRPPUfnjgMlELc2EMzp/E8g6nqFFO0MA5fAyj01cIvj+H5lCjQWmZ5Ur2NJvjQulvzbdod5TGVyv63UtmXq8zWhqL87YXaveUnptjlbuaLbh8PlKtCUe6+WsunA6fhsHQfEJtCJ979iSwXf1s99lXpSHG7/BL9OP0BOg5yscoRZzMKJOfpyfTTE7cGcBophbxSz1v/0FzizEF8KQMQuOGGwtMCJhkmuQs6JUjLmFnFA2Ip9BZMvnaqP8GOqwrNpnFt09fcWLBx7MlplL7A1ReIB6oAS5uuMSdavAYDEfXBMs4V+uzZ0fLQpzwob8aSBdJ8hIjCqkQf+zME4H2krIhpoSjLE2VtoaQzUQy1IoSMtG4kE0ZlUy4iupx6BbQog77TCbMKr08D6zOsPWJiQx7Ws2HPEVBufh1WGm753cUaZ88UALnFRggyWgjgnHNE9nj5AAHyg4yIW711Ty1yzCqy1wIzkzYlM21VWM1JTYOSuutQ/FPmTBvS2Di2EVw3y/Tzfh9bHwjtgW3k9k4uJ470IuN6IjiqJKqE74zY1Ki8FFBoxJqFFKuTAuHZSG6x7HExQ0VVwYEzaaH3V4Ki4Q01PRh03fOzHV6Etd3l/C/z863n+4+epYkG6lMT/A/TzH3Kv4t3tfTEKijXKpMJlXApt1R1FW4NH/iMmwWqTWjvIcHPZcB1Ankc3f3sT9s92TGUaLo4b+ulh2EJmUk3l86L1qJ1WbN6NkZQOcdFKZXy8SgxsfyR8WsPIrdE8Ku7fWL77BUcd2tPAfE4B4XLvPQkfkeHdRML91i1O5Ru3LproS7QgyZnTn539DGro9XRqJ2l2u6M4gmg02lvCC3K7nJwjmB99BsJ0I01xRJ6Q/FZZx7rUdQM1wo3OVW1q2XUt5kR81TWtW3qStfh27zLJOGTd1ok0vcZjbNbN5MaPOGPzkw/Ob25uHD9I4a+0Q33W/Gs1e5Flktyr0qntWe3XtFu5iiTIgunPiyhUNe+V4v900EVR927y5OueR5nyzrKy4Cr7pRecbxIWQgrkJJvPaOQEsfm0ABMciY+5nOahUe3KHJhKWj/n+Evu3Ku6Ej0GytJiC+0lrpCz9oWpXuuAF9+o3AA1GDRqPNtFyvn59l2+gw6ssvifDAtHQtM65o1WOERAJWAc97OARfytu0aELr9+kdPtOgizpeAVUNe+9uFEsorO8ZNZkERF6aDkm/vWMI2PrV1ILNz6FWOUO7btSCbR8w1ar/Msn9Fs5pH2lmhpBwnLqB/OAEFNXR26iqw7N2l+lvdwTCtnF7izaN3OS5mLed6mcUQi3WVXbNUKRYu7vKhLeS4DgikOEa3fwVWGfFyT+4S7xdQg8AAA=="

# ------------------------------------
# Script file - MessageBox - 
# ------------------------------------
$ScriptBlockMessageBox = "H4sIAAAAAAAACu0ca28bufF7gPwHYk+AJZy1ttMmLYxTcX5ejMYPWLo4bWC0tERLW6+W6j5sq1f/987wseRyuZLs2Ol9sIPY0nI4M5w3uSTfvnkr/l0XyTCPeELO2TjKcpZ2+8M0muU7WcamV3HEst/eviHw83VvOopZvhsloygZt/vFbMbTPOtPeBGPzlI+ZFnWuZSwZzSl03YH8ePX1gV04neZwjk/Z9csZQn0ID3ytT8HstNwj8cxE6xk4U6a0vknYOdyezthd4hpCZ4fe2RNIloj/yWnRd49KeL4Ed3C/ZTewcCe2v3LNK52XanzWcoyluQUh30IMmN3PL15NAs2lj2esjXo4qK4SKOcdT+z9IpnjAS9b/0JvGiPD/r9nV8Odk+/kKOTowHp9f7SbFgkeDHWJOI8nSvjxZ9Dnh7Q4aTdAumRKFkg1I7Vy8Mg+bozGnUH8xkjXd35BHR3ScR4iSCgxqZ//D0EqAF8gP/y28OQ5sOJxYZk4YKmCdgoIcHXg/Pzo3NyF+UTojH66D+8ffNQcfNfWK4UsR+l4G8cZKRo/EBOTg++nJ2eD57s8fhRmexRcsthFEizR9pI9jNNI3oVM3I8txqBGw5y2eqEn2lcMNk7uiZtC0N41pc8n3Oed4gllyagcvT4h8UZczEez/f4dEqTUXhG80kFZ38WR3kXH5PmHoqAwN3EkPmIyg77xVWWpyjKzfUFYJ9olh8lI3Z/et0Ogk6nqsi3bw5tVR6DDuiY7fL7c5YVca44aclvIPmK4LvC6M4u+h9NPwgTsyInXSH90ySek+5BmvJ0RxI5GicQUSTWlOVFmmjkiqGSHbCLO4sfxYn8/QPZZ9dRwqSdMIgG2RNtTH5sG4H/QAYTRmZ8VszIHk9yCISm8WtJr30MmqNo7r3WIC2YRiqgTq/+Ba5w2VL913UAMfjvRKwgeZTHbBn6awo2UcEv1X7ZGmB3D/arIs8h75GcEzoaPR4/6C6CVtZneXvt9K9r6/Cru0chlsXweecKRNo9ZxAOu1Kd8PBvLOuecAMkv8MHCVc+lx+6g3S+M6ZR0kURRUmBKE54wtYqfFDM25etXTEcEe4gOyE/zz9kRWqvyHI+lQQzh4zSJrmGvySL/vMExUWJsYpD+NMHLDCmrT+6I0LFfjMhgWURmV2ejlg6mETDmwQc44lkHCxAaLMmuTRh6TkdRcVTidgogMKfHQr9CQV/2mczHUkfTcDCAPj/4EoqLr6Nf4MAsL9zBSRLh488yx+PnqtgY3DUjGnKOIRkqFEyNuTJCA37iQYlMNW0O0JbTdUoyCdOR2xE2K0MfY+llImkexXz4c1l6zSR2JaQ3Iuhkno2khKbpiimHWXamSd0Gg1pDHntDHJEDFFyRGZOFlJQgrqdzD3RZJcOb8YpLxIrZrVqbRj3ag/XrB47OaQEiIHMTHugzwm768pcRDyzItlyDKKMred6/lRitATVKuVZtnqpgLAhaU+B23CngHiq6qla54WYw1JlQKN1iEpbPOAQiuK2B1HHknvrvIB8M2Ul1H4k+lJBZdWRKCSyBhl5cFkEIbFAGrUmpmpiGO6mRTZh2SVMrWTlNb1iKZSvOO8aEvVdJD2oW2YszecA2Wc4WCip7mcgnbJB1GEWUSuBP0VTvu5tNRKrJl+sCB+Sjq3x/i5asangQp/ZBxcTmKkECzT47Xpr1x1uvSyy1r1D7KxkUlIQHuS1Pha+aqTD9H0IwSS2bco8xMBgvr1GhFUjAlnFQ41gYd1IfIBVhlD4mvHE/k00I1vfy/mew/FewoGMqJ7Tc2ysi1zGE0sqLhL02Zgz8utRUHWuskC+YNF4YtVeLacF3cx59OprT8i+NVdTa2ahketrQjRGXLfC4ISnUxq/dD50CD+nT9dQ+xzbUyh73bTWZhXKr666OE28uuoL1K7/D2etkX6B4nWZw/qLV9V5wO4BQcqa5rnVdsuFqw2vGfc53Ph1+rnEhWvWGOzGMHX7Tl5cpf4CnuwSWJZ+Rb5u9GBPa1krv3rv8yfhV+9t8l6/JX4f3/XQfvaS+bF+K9/KiEVGi5T1FP3U+vqaXV/98yUXd6uW93380qL5nP5YQev3w1oG9b7ncVrKzPn6juc1a36fVy51C/w+L1wcus+eLZe9bKlkSrm9pKnE9TWL3Ol5/ppEX5PoiyZRvy1+p2zqIf6sadWLf5n39qW7mkflrsJGcuUOSPlhFzYUJ/YW3XKHsdlb7HRROwmhk96ViP++fjn+dNn6QqcxiPtnUMdPanuKwX0/jZOsF0zyfLa9sZENJ2xKsxD2iqQ849d5OOTTDXj3eH2/8W5z88PGPeDamFnbsQMH1fb945DZ/bfxTWYvkDwGskzpBQHB3WIDrpYLsH2UT3aS0Uex/BeoLTewTSHNi9kntdO0F+wBMEthxyxjiQGaI0rc2BeAVHErG243wSfyW0B24hje/wxSmmSwiwa2S897Ae6nDIgJ4fhEtwMDpzM6jHKA2wr+Ioej5BwCUl6koBn1XLQJJsiApmOW43aKXvDb/bbYVyEN7kFjMT1Yji6jd1cAeTad4U4fF9KClruNPe0CBoWZ8ljjqXAjufChLrvLgnMBhID6JY1GFan9pump7bBWY23QjWyDyNV5ABDJxjIeNpCJRUPZWDiWnzYcSfkEvrFA4rrRNoANYQHaVDYabEUJuXSLY9idKh8F5BjUFYGNb20Glb2MvaCyLxFstroVEtqdJxpETB6gub14ptQJYJfyCHXXC4C2PSoJFR5cX0OkdaWwD6YrNzTK9nJU+/0DHELM055KGkTu2xc+/O5PQMTsVET2yy8QF8wOSWixvlkuuRl+CCpWohVeZ1SPYJBG4zGM2x3DAW7mU43kHLYdspF4pCNWKHcGen1ShPQ+7h274jRtMkgIDUsgpDB5cRWznSSSCZKYXqH0Y0u0tTYTRCoCO0z5VKh0wF1Z7hepCqmb25vbWxAiITefw9bGNAMqYh9cVcQvxbCt+yq/dss3sYu+uUAFYDwLFfnThm0kPqvzGJeMky4m5f3a97ObZZ5uxVmvF9d2fXXqYpCsaN/EL09D7BMdYguVX+J4mjTwOcoKGst1GfkZEodOGAexKA8Ff4jkIfBpUkb9JcTA2YDjM5qwWEnZPIDI5mGtgWEsEHf5vUKiZnsQpI+yc0ZHeOJEVxBH2ccI3ndkOYwrAo8ozRFRgHRFXyvCYng3+4YaxG8AQKF6c71Gpr9jiy5hG/B4FnUVQvmedVE3A9VZwWCcCTF0+cjT6D+Ag8Y7cTROUMWoDqichxCAPoP74xZnq00Wd1jWQS3YC9DFbSzKJD0daglx02tBQrH7vGofCivuaDcpeHN9a3MdfwXE9WFjjiWmVUnJGkxSwvNSe5MoHh1GcVyajFdkepRPYgRjn3aAWlxzyqjKA6uG0tUMfAx+NlMQORx7IiKffPv044mzDsdwlIH/wfE32KVXRLZTbX1YMA2wPUyuWdWtbatau5We/g5tCH81KPZcTnX2ijTDSukj7LUWdlsXMnqwLWgRnfAgwf9P1k8NYStL21+1embvdvkK0n6PIn+/xJeao4+rAOuF9u9MAyq/KAZXEJ733TxIr4wfIX4q7fKJAnx6cnOOrK2Qp2r7hgAhDu8ipbOZMAj8ZGKBjAzH9F5Fiveb4JvHUVJ+reZpYwumUvhBnDwiuTleeQ1VK/myc/xJAqgjUvg6Xe87hehwU8xCtB+sHlgKO70RS7ttLZeJk9Zi27c5nI//T2AtQ/Yi3Z10XKCw8ZYB0kIz0CdtW/sReBFkVohMsB7lLMXVcGvOBpMUUOM2dKe/Hqw8qkjUiUdC1RFI2WxO0YqjTdt4XlzlAGulS56y1tq11+oU7MtLyqSqTp0+Gsx340HHkQY+QsWMcesamDZ6PK9kOtbBQBn/OOZFxg7QLdvO7QAtyF+l/4TW8c1g608WzYfOAsSfGL1lj0D8YQXEezGkVRcnyn314+AEQkWFCZRPh3RPZ+rKEFm/6zP8v8T8isakCyFxaJ398lyh8BxsODcsqGARisOA+saQmnwU0CH8QartNVNJrnVQbKKS1Gvb5uy9dmKA0EeX5aMjvFfAOvDcZf8mwelfA9XVEr/l0l1teAjp0GhAqE5kPxpvI4TCtwr1+gHyVdkQPZdxIhAvA1J0V2G3crR9VU6h0zIWTvgzylQy+RLcLaZrH+9flfpKCnrE2JvuFFiVnwqpRiiNfinjmvoqrMtXI12YX5Dq3QN11rEwpMMJILEBxc0zvp5O70Z2K53tNFCLVedsym+ZqK/EvRXkiqZ4s0rC1fcoI7OU30awKmsNWd5lIEbrUYh+XY9lUT2a6sa1hTHXzKMh5oqAC3OWULJb7gdI/cEXR1O55kPwrKXThSF97csXnHXeUSTwlmLIyEisuJJ/FzxnmbxFJ4M+8Airs1sOq3yiDUSUFQCBR/EFVus6gSphWLoFXa8F9sjdfG6VGzqTKYba0HE9WNPytvSJP/YIfoX0SUmOtc0VLKrhmXqqeCO3mCzDMLRkb01UcA3u5WszZ5LXWWgI1opRJftWuTaGgH8OynPlFc3CsFEUorC+ODskTK6EEprBgyGiNdAQGZqV9Fgm7f2/ls720B6aqfzD6lRVs2XvB4moj/TdM5wIf76bsISMUgrr5GpMdZ5x9Ukyq+vL61xGjH1+l9hFoe4LG5XHx+h/Wtody+9ganKLr0GtqRrEpBisBczOckN9+4MnbCgyyJGE8Ve7mpRdwAn0yS2/YV11AxMpKdXLvEVm8i1cOPiNdOBtx0xIZlTO+yC+4sQRYi27B6+wS0V9W8ViEUkYlzmBwJ2ddhOoj5Mijh2JOX0FBadviKy7kn5YJnh928ZTBf/7GFujOoERqo18Aj5vZ0mIJhks0pBIxBXUOXiTnuGLEZhLXZoVfIp9TPqs3iKjgby7NnDuJ9eGBA63YlHM5+r+GJEObPbXCYQCAKgZKoSWIWrFdnARZjQqQCKKGadQEI2egaLs70RClGsn8sobnUP2IwrFfAaLXllYQlYqDOBJ3BjTczUt6JZ9woOYzsCWwgGHpbW+vCuHdMdgNFXeFtmNweazmIUzS9ekfBm7ZpdHqD5QDeZifNKf0QSvK4ClLzWC9lZnQX90oQHO7I2cbHB7OGA7NrseF7EgLCtCuJjOLWtQeQZdEQ1XPrQWusQddjdsJ5snw990M14IB7qO+bjdeQgvaCRoCVSl16k77Zy7SJ2r5A7uh/CqHRpQf86NcfpeIHGlT3vxVULIOr5pXCdnPIuUQ212Lsv72cTFd7J8XHIrUXnFTQXXFuBaZa9eOSAgKT5KYtZOdHw+y4+zMRKy2JKt0XVbdbRCpO2Ald4CMFTiNEB3UMYwcCfVfpRARCkZq1yICAjRF/2QFbCS7o8Qqf4JC/I/NtNvrnv2INbkdpmrZGKq2PreSF3Wqv1IsB4rgatd9aJgXaQlhFq1BqD3Tot8M+VpqF+otuVAWIt37zY9beYI8q9xntJdHo8CB0wsrItDyvTEbTOv0rWJW1pxpZpAUQJmrNNWS15N1LDltCZWDe10Dj/K2QDwJ0RLRiynUaxXLQxc5Xo7t7Eu+7KpFH7wHt5LvYc3gZ4hYlAQUYvpMd0JqUF+E7NgPWsST9dJJh9PpWWaFpgewpwv4TlMHGgCLSIXKpy65tZbLhZJbZ/mNFSA1W7iDlHPvRqu+UJmgGIUNnkI9eu9Pg4u3KPpwWVTRxDAdZqwC+p2hx25sF4rLMf2ma84Db40GuiboNvItQYGUhWG1zUxO3t63V1Pam0tOrbwDWHAQWHCgYpbDWDNdtkcAjYbIG0H+LCALf3iTRzxwFdvDbBNvm8UZy07OJ09ylBbqBkZKgnC2geuicAaAyzaQG+m76S29getpAkDX0Ngzaqrc34/jB6FBNKlBP52CgezbGZz25UrXMEZv4M3nxMGNU2ZzYiIXrDC5x60OYfqXz4sFfjunfVERfAyfMM7EdFvTcmB/JrgO+41ZMm6GXNToXCOCPwNmNJVl9HQw7JC6TOPhuxFiqR1It7EYJV6Fs1YjHf5KkCoecSm8IPpLJ/LlAoEhSLLssa3BFZ511YB8VX+rf48gRfLePOefM3UFQ/ErnQVIBxYCFh4qEHIpL12rHcAkL9HKSX7LLuBStlerat0nTF6I6pZaZEddZ86FlrN02VrEEKwGAZ+dsZhBOB7MYk/0jp1InUam6/c60+hAHegq5dqDegE6lAftWoJAqn8du4Dq1IFj/AB1Q+7SGN2YPv6WJb2D2XF5KQYjZl1Lgt/qhcKN15JXO2kl4jkcuvIrjy9OnNjx89Sh6XbNc5OUE1v3/zu3M6Mzo6TsvKFVOe10EbbGyzTvwBYQfcCbnHJWwFzqmav6UD0jqmcYSkbKCcTNaU6wzcJQgpO6frN/wABKQWNH2MAAA=="

# ------------------------------------
# Script file - Miscellaneous - 
# ------------------------------------
$ScriptBlockMiscellaneous = "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"

# ------------------------------------
# Loader
# ------------------------------------
function ConvertFrom-Base64CompressedScriptBlock {

    [CmdletBinding()] param(
        [String]
        $ScriptBlock
    )

    # Take my B64 string and do a Base64 to Byte array conversion of compressed data
    $ScriptBlockCompressed = [System.Convert]::FromBase64String($ScriptBlock)

    # Then decompress script's data
    $InputStream = New-Object System.IO.MemoryStream(, $ScriptBlockCompressed)
    $GzipStream = New-Object System.IO.Compression.GzipStream $InputStream, ([System.IO.Compression.CompressionMode]::Decompress)
    $StreamReader = New-Object System.IO.StreamReader($GzipStream)
    $ScriptBlockDecompressed = $StreamReader.ReadToEnd()
    # And close the streams
    $GzipStream.Close()
    $InputStream.Close()

    $ScriptBlockDecompressed
}

# For each scripts in the module, decompress and load it.

$ScriptList = @( 'Assemblies', 'Miscellaneous', 'MessageBox' )
$ScriptList | ForEach-Object {
    $ScriptBlock = "`$ScriptBlock$($_)" | Invoke-Expression
    Write-Verbose "Loading $ScriptBlock"
    ConvertFrom-Base64CompressedScriptBlock -ScriptBlock $ScriptBlock | Invoke-Expression
}

Add-Type -AssemblyName 'System' 
Add-Type -AssemblyName 'System.Xml' 
Add-Type -AssemblyName 'System.Windows.Forms'
Add-Type -AssemblyName 'System.Drawing'
Add-Type -AssemblyName 'PresentationFramework'
Add-Type -AssemblyName 'PresentationCore'
Add-Type -AssemblyName 'WindowsBase'


#===============================================================================
# Utils
#===============================================================================

Function ReplaceStrings($DestinationPath)
{
        $NewGuid = (new-guid).Guid
        $AnchorQt5 = 'xxxUSINGQT5xxx'
        $AnchorWinsock = 'xxxUSINGWINSOCKxxx'
        $AnchorSubSystem = 'xxxTEMPLATESUBSYSTEMxxx'
        $AnchorGuid = 'xxxPROJECTGUIDxxx'
        $AnchorCharSet = 'xxxCHARACTERSETxxx'
        $AnchorProjectName = 'xxxPROJECTNAMExxx'

        $FileList = [System.Collections.ArrayList]::new()

       
        $FileList.Add("$DestinationPath\vs\app.vcxproj") | Out-null
        $FileList.Add("$DestinationPath\vs\cfg\app.props") | Out-null
        ForEach($File in $FileList)
        {
            if(-not(Test-Path $File)){
                Write-Error "could not find file $File"
                return
            }
            $FileContent = Get-Content $File
            Write-Output "Updating $File..."
            # File Content is replaced by the correct values 
            $FileContent = ($FileContent -replace $AnchorGuid, $NewGuid)
            $FileContent = ($FileContent -replace $AnchorQt5, $Opt_UseQT)
            $FileContent = ($FileContent  -Replace $AnchorWinsock, $Opt_UseWinSock)    
            $FileContent = ($FileContent -replace $AnchorCharSet, $Opt_Charset) 
            $FileContent = ($FileContent -replace $AnchorSubSystem, $Opt_Subsystem) 
            $FileContent = ($FileContent -replace $AnchorProjectName, $Opt_ProjectName)

            Set-Content -Path $File -Value $FileContent 
        }
}
Function Get-Folder($initialDirectory="$Env:DevelopmentRoot")
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a destination folder..."
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory
    $folder = ""
    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}


Function Show-MsgWarning($message="")
{
    $Image = New-Object System.Windows.Controls.Image
    $Image.Source = $Script:ImageWarning
    $Image.Height = 50
    $Image.Width = 50
    $Image.Margin = 5
     
    $TextBlock = New-Object System.Windows.Controls.TextBlock
    $TextBlock.Text = $message
    $TextBlock.Padding = 10
    $TextBlock.FontFamily = "Verdana"
    $TextBlock.FontSize = 16
    $TextBlock.VerticalAlignment = "Center"
     
    $StackPanel = New-Object System.Windows.Controls.StackPanel
    $StackPanel.Orientation = "Horizontal"
    $StackPanel.AddChild($Image)
    $StackPanel.AddChild($TextBlock)
    Show-MessageBox -Content $StackPanel -Title "WARNING" -TitleFontSize 28 -TitleBackground Orange
}


function Show-Error
{
<#
    .SYNOPSIS
    Display a mesage box with colors to highlight a ERROR message
    .DESCRIPTION
    Display a mesage box with colors to highlight a WARNING message
    .PARAMETER Text
    String to display
#>
 [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()]$Text
        
    )
   
    $ErrorMsgParams = @{
        Title = "Error"
        TitleBackground = "Red"
        TitleTextForeground = "Yellow"
        TitleFontWeight = "UltraBold"
        TitleFontSize = 20
    }

    Show-MessageBox @ErrorMsgParams -Content $Text
}



Function Show-Success($message="")
{
    $Image = New-Object System.Windows.Controls.Image
    $Image.Source = $Script:ImageSuccess
    $Image.Height = 50
    $Image.Width = 50
    $Image.Margin = 5
     
    $TextBlock = New-Object System.Windows.Controls.TextBlock
    $TextBlock.Text = $message
    $TextBlock.Padding = 10
    $TextBlock.FontFamily = "Verdana"
    $TextBlock.FontSize = 16
    $TextBlock.VerticalAlignment = "Center"
     
    $StackPanel = New-Object System.Windows.Controls.StackPanel
    $StackPanel.Orientation = "Horizontal"
    $StackPanel.AddChild($Image)
    $StackPanel.AddChild($TextBlock)
    Show-MessageBox -Content $StackPanel -Title "SUCCESS" -TitleFontSize 28 -TitleBackground White
}



function AddRandom{
   
    new-item $Script:RegistrySettingsRecents -Force
    new-item $Script:RegistrySettingsFavourites -Force
    $null=New-RegistryValue $Script:RegistrySettingsRoot $Script:RegistryValueAppPath "$PSCommandPath" "string"
    $null=New-RegistryValue $Script:RegistrySettingsRecents "1" "KEY_CURRENT_USER\SOFTWARE\_gp\powershell" "string"
    $null=New-RegistryValue $Script:RegistrySettingsRecents "2" "Computer\HKEY_CURRENT_USER\SOFTWARE\Bare Metal Software" "string"
    $null=New-RegistryValue $Script:RegistrySettingsRecents "3" "Computer\HKEY_CURRENT_USER\SOFTWARE\_gp\pwsh-formater" "string"
    $null=New-RegistryValue $Script:RegistrySettingsFavourites "1" "Computer\HKEY_LOCAL_MACHINE\HARDWARE\RESOURCEMAP" "string"
    $null=New-RegistryValue $Script:RegistrySettingsFavourites "2" "Computer\HKEY_CURRENT_USER\System\GameConfigStore\Children" "string"

 
 }
function GetNumFavourites{
    $Num = (Get-ItemProperty "$Script:RegistrySettingsFavourites" "max").max
    return $Num
}
function GetNumRecents{
    $Num = (Get-ItemProperty "$Script:RegistrySettingsRecents" "max").max
    return $Num
}


function AddPath{
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$true,Position=0)]
    [string]$Path,
    [Parameter(Mandatory=$true,Position=1)]
    [ValidateSet('Recents', 'Favourites')]
    [string]$Set
)    
    [int]$RetValue = -1
    $RootPath = $Script:RegistrySettingsRecents
    if($Set -eq 'Favourites'){
        $RootPath = $Script:RegistrySettingsFavourites
    }
     Write-Verbose "Add $RootPath =>  $Path"
     $exists=Test-RegistryValue "$RootPath" "$Path"
     if($exists -eq $False){
        Write-Verbose "Add$RootPath =>  $Path DOES NOT EXISTS"
        [string]$NumRecents = (Get-ItemProperty "$RootPath" "max").max
        [int]$RetValue = $NumRecents
        $RetValue++
        [string]$NewIndex = "$RetValue"
        Write-Verbose "Add$RootPath => $NewIndex $Path"
        $null=New-RegistryValue $RootPath "$NewIndex" "$Path" "string"
        set-ItemProperty "$RootPath" "max" "$NewIndex"
     }else{
        Write-Verbose "Add$RootPath  =>  $Path EXISTS"
     }
     return $RetValue
}


function ClearFavourites{
 AddLog "ClearFavourites"
    $Null=Remove-Item $Script:RegistrySettingsFavourites -Force -Recurse -ErrorAction Ignore
    $Null=New-Item $Script:RegistrySettingsFavourites -ItemType Directory -Force -ErrorAction Ignore
    set-ItemProperty "$Script:RegistrySettingsFavourites" "max" "0"
}

function UpdateButtonStates{
    AddLog "UpdateButtonStates"
    $Path = $var_textBoxRegPath.Text
    if(($Path -eq $Null)-Or($Path -eq '')){ 
        $var_buttonAddFav.IsEnabled = $False ; 
        $var_buttonGo.IsEnabled = $False ;
    }else{ 
        $var_buttonAddFav.IsEnabled = $True; 
        $var_buttonGo.IsEnabled = $True;
    }
    $NumFav = GetNumFavourites
    if($NumFav -gt 0){
        $var_buttonRMFav.IsEnabled = $True;
    }else{
        $var_buttonRMFav.IsEnabled = $False;
    }
    $var_buttonClearRecent.IsEnabled = $True;
    $var_buttonRefreshClip.IsEnabled = $True;
}

function AddLog{
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$true,Position=0)]
    [string]$Log
)  

    $Script:AppLogs += $Log
    if($Script:TEXTBOX_LOGS){
        $Script:TEXTBOX_LOGS.Text += $Log    
    }
    

}

function ClearRecent{

    $Null=Remove-Item $Script:RegistrySettingsRecents -Force -Recurse -ErrorAction Ignore
    $Null=New-Item $Script:RegistrySettingsRecents -ItemType Directory -Force -ErrorAction Ignore
    set-ItemProperty "$Script:RegistrySettingsRecents" "max" "0"
}
function ClearFavourites{

    $Null=Remove-Item $Script:RegistrySettingsFavourites -Force -Recurse -ErrorAction Ignore
    $Null=New-Item $Script:RegistrySettingsFavourites -ItemType Directory -Force -ErrorAction Ignore
    set-ItemProperty "$Script:RegistrySettingsFavourites" "max" "0"
}

function ReloadComboFav{

    $var_comboBoxFav.Clear()
    [int]$NumRecents = (Get-ItemProperty "$Script:RegistrySettingsFavourites" "max").max
    if($NumRecents -eq 0){  
        $var_comboBoxFav.SelectedIndex = -1;
        $var_comboBoxFav.IsEnabled = $False
        return
    }
    $var_comboBoxFav.IsEnabled = $True
    For($i = 1 ; $i -le $NumRecents ; $i++){
        $RegPath = (Get-ItemProperty "$Script:RegistrySettingsFavourites" "$i")."$i"
        $Null=$var_comboBoxFav.Items.Add($RegPath);
    }
    $var_comboBoxFav.SelectedIndex = $NumRecents-1;
}

function ReloadComboRecent{
    AddLog "ReloadComboRecent comboBoxRecent.Clear()"
    $var_comboBoxRecent.Clear()
    [int]$NumRecents = (Get-ItemProperty "$Script:RegistrySettingsRecents" "max").max
     AddLog "NumRecents $NumRecents"
    if($NumRecents -eq 0){  
        $var_comboBoxRecent.SelectedIndex = -1;
        $var_comboBoxRecent.IsEnabled = $False
        return
    }
    $var_comboBoxRecent.IsEnabled = $True
    For($i = 1 ; $i -le $NumRecents ; $i++){
        $RegPath = (Get-ItemProperty "$Script:RegistrySettingsRecents" "$i")."$i"
        AddLog "Get-ItemProperty $Script:RegistrySettingsRecents $i"
        $Null=$var_comboBoxRecent.Items.Add($RegPath);
         AddLog "comboBoxRecent.Items.Add($RegPath)"
    }
    $var_comboBoxRecent.SelectedIndex = $NumRecents-1;
    AddLog "var_comboBoxRecent.SelectedIndex = $NumRecents"
}

try
{
    $ScriptReturnValue = 0
    $OrigError = $ErrorActionPreference
    $ErrorActionPreference = "Ignore"

    [string]$Script:AppLogs                    = ""
    [string]$Script:RegistrySettingsRoot       = "$ENV:OrganizationHKCU\RegThunderLauncher"
    [string]$Script:RegistrySettingsRecents    = "$Script:RegistrySettingsRoot\recents"
    [string]$Script:RegistrySettingsFavourites = "$Script:RegistrySettingsRoot\favourites"
    [string]$Script:RegistryValueAppPath       = "install_path"
    [string]$Script:RegistryValueRecents       = "favourites"
    [string]$Script:LastKeyPath                = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit"
    [string]$Script:LastKeyValue               = "LastKey"


    $Script:CurrentPath = (Get-Location).Path
    $Script:RootPath = (Resolve-Path "$Script:CurrentPath\..").Path
    $Script:SourcePath = $Script:RootPath

    Write-Verbose "Looked up Ui files in path $CurrentPath"

    $Script:ImageWarning = Join-Path $Script:CurrentPath '\img\warning.png'
    $Script:ImageError = Join-Path $Script:CurrentPath '\img\error.png'
    $Script:ImageSuccess = Join-Path $Script:CurrentPath '\img\success_1.png'

    Write-Verbose "SourcePath $Script:SourcePath"
    Write-Verbose "ImageWarning $Script:ImageWarning"
    Write-Verbose "ImageSuccess $Script:ImageSuccess"
    # where is the XAML file?
    $xamlFile = "$Script:CurrentPath\regthunderui.xaml"
    Write-Verbose "Loading $xamlFile..."

    if(-not(Test-Path -Path $xamlFile))
    {
        Show-Error 'NOT IN SCRIPTS FOLDER !!'
        Show-Error 'Please Run from DEVPATH/Templates/Template.Cpp.WindowsApp/scripts'
        exit
    }

    Write-Verbose "Loading xaml file: $xamlFile"
    Write-Verbose "Loading xaml file: $xamlFile"

    #create window
    $inputXML = Get-Content $xamlFile -Raw
    $inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
    [XML]$XAML = $inputXML

    #Read XAML
    $Script:reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $Script:window = [Windows.Markup.XamlReader]::Load( $reader )

    # Create variables based on form control names.
    # Variable will be named as 'var_<control name>'

    $xaml.SelectNodes("//*[@Name]") | ForEach-Object {
        Set-Variable -Name "var_$($_.Name)" -Value $Script:window.FindName($_.Name) -ErrorAction Stop
    }
    $Ready = $True
    #if($ShowVariables){
        Get-Variable var_*    
   # }

   $RawMembers = $var_comboBoxRecent

    [System.Collections.ArrayList]$OutputMembers = @()
    Foreach ( $RawMember in $RawMembers ) {
        
        $OutputProps = [ordered]@{
            'Name'= $RawMember.Name
            'MemberType'= $RawMember.MemberType
        }
        $OutputMember = New-Object -TypeName psobject -Property $OutputProps
        $OutputMembers += $OutputMember
    }
    $OutputMembers | Select-Object -Property * -Unique

    $Path = Get-Clipboard -Raw
    Write-Verbose "Get-Clipboard => $Path"

    $ClipRegPath = Format-RegistryPath "$Path"
    if($ClipRegPath -ne $Null){
        Write-Verbose "Get-Clipboard => VALID $ClipRegPath"
        $var_textBoxClip.Text = $ClipRegPath
        AddPath $ClipRegPath 'Recents'
    }else{
        $var_textBoxClip.Text = 'null'
    }

    [int]$NumFavourites = (Get-ItemProperty "$Script:RegistrySettingsFavourites" "max").max
    $var_comboBoxFav.SelectedIndex = $NumFavourites;
    For($i = 1 ; $i -le $NumFavourites ; $i++){
        $RegPath = (Get-ItemProperty "$Script:RegistrySettingsFavourites" "$i")."$i"
        $Null=$var_comboBoxFav.Items.Add($RegPath);
    }

    ReloadComboRecent
    ReloadComboFav

    $Script:TEXTBOX_LOGS = $var_textBoxLogs

    $var_buttonAddFav.Add_Click( {
       AddLog "buttonAddFav clicked"
       $Path = $var_textBoxRegPath.Text
       if(($Path -eq $Null)-Or($Path -eq '')){ $var_buttonAddFav.IsEnabled = $False ; return }
       [int]$Index = AddPath $Path 'Favourites'
       $Null=$var_comboBoxFav.Items.Add($RegPath);
       $var_comboBoxFav.SelectedIndex = $Index-1;
       })

    $var_buttonRMFav.Add_Click( {
        AddLog "ClearFavourites Clicked."
        ClearFavourites
        #Show-MsgWarning "Recent List Cleared"
        $Null=$var_comboBoxFav.Items.Clear();
        $var_comboBoxFav.SelectedIndex = -1;
       })

    $var_buttonRefreshClip.Add_Click( {
        $Path = Get-Clipboard -Raw
        AddLog "buttonRefreshClip Clicked. Clip: $Path "
        $ClipRegPath = Format-RegistryPath "$Path"
        if($ClipRegPath -ne $Null){
            AddLog "Format-RegistryPath => VALID $ClipRegPath"
            Write-Verbose "Get-Clipboard => VALID $ClipRegPath"
            $var_textBoxClip.Text = $ClipRegPath
            $var_textBoxRegPath.Text = $ClipRegPath
            [int]$Index = AddPath $ClipRegPath 'Recents'
            $Null=$var_comboBoxRecent.Items.Add($ClipRegPath);
            $var_comboBoxRecent.SelectedIndex = $Index-1;
            AddLog "Recent.SelectedIndex = $Index"
        }else{
            AddLog "Format-RegistryPath => NOT VALID $ClipRegPath"
            $var_textBoxClip.Text = 'null'
        }
       })
    

    $var_buttonClearRecent.Add_Click( {
        AddLog "buttonClearRecent Clicked."
        ClearRecent
        #Show-MsgWarning "Recent List Cleared"
        $Null=$var_comboBoxRecent.Items.Clear();
        $var_comboBoxRecent.SelectedIndex = -1;
       })
    $var_buttonGo.Add_Click( {
        [string]$RegPath = $var_textBoxRegPath.Text
        AddLog "buttonGo Clicked. Path : $RegPath"
        [string]$RegPath = Format-RegistryPath "$RegPath"
        if($RegPath -eq $Null) { AddLog "Bad Registry Path $RegPath" ; Show-MsgWarning "Bad Registry Path" ; return }

        [string]$StrScr = "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"
        $S = Convert-FromBase64CompressedScriptBlock $StrScr
        $S = $S.Replace('___REGISTRY_PATH___',"$RegPath")
        [string]$File = (New-TemporaryFile).Fullname
        [string]$File += '.ps1'
        Set-Content "$File" -Value $S

        Start-Process pwsh.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $File) -Verb RunAs
        AddLog "Wrote $File"
        #$Script:window.Close()

       })


    #region handler_CBoxRecent_Changed
    $handler_CBoxRecent_Changed = {
        AddLog "CBoxRecent_Changed "
            [string]$RegPath = $var_comboBoxRecent.Text
            if(($Path -eq $Null)-Or($Path -eq '')){return;}
            $var_textBoxRegPath.Text = $RegPath
        }
    #endregion handler_CBoxRecent_Changed

    #region handler_CBoxFavourites_Changed    
    $handler_CBoxFavourites_Changed = {
            AddLog "CBoxFavourites_Changed "
            [string]$RegPath = $var_comboBoxFav.Text
            if(($Path -eq $Null)-Or($Path -eq '')){return;}
            $var_textBoxRegPath.Text = $RegPath
            UpdateButtonStates
        }        
    #endregion handler_CBoxFavourites_Changed
        
    $var_comboBoxRecent.Add_SelectionChanged($handler_CBoxRecent_Changed)
    $var_comboBoxFav.Add_SelectionChanged($handler_CBoxFavourites_Changed)

    $var_textBoxRegPath.Add_TextChanged({

        [string]$RegPath = $var_textBoxRegPath.Text
        if(($Path -eq $Null)-Or($Path -eq '')){ UpdateButtonStates ; return }
        $Len = $Path.Length
        AddLog "TextChanged len: $Len"
        UpdateButtonStates
    })
    if($Ready){
        $Script:window.Title = "Visual Studio Project Generator"
        $Null = $Script:window.ShowDialog()

        $ErrorActionPreference = $OrigError
        return $true  
    }

    return $false  
     
 }catch {
    write-host $_
        Show-ExceptionDetails($_) -ShowStack
    }
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUXfIM0k1zm4KFRyjVr5V3qk/x
# 2lSgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0yMjAyMDkyMzI4NDRaFw0zOTEyMzEyMzU5NTlaMCUxIzAhBgNVBAMTGkFyc1Nj
# cmlwdHVtIFBvd2VyU2hlbGwgQ1NDMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
# CgKCAQEA60ec8x1ehhllMQ4t+AX05JLoCa90P7LIqhn6Zcqr+kvLSYYp3sOJ3oVy
# hv0wUFZUIAJIahv5lS1aSY39CCNN+w47aKGI9uLTDmw22JmsanE9w4vrqKLwqp2K
# +jPn2tj5OFVilNbikqpbH5bbUINnKCDRPnBld1D+xoQs/iGKod3xhYuIdYze2Edr
# 5WWTKvTIEqcEobsuT/VlfglPxJW4MbHXRn16jS+KN3EFNHgKp4e1Px0bhVQvIb9V
# 3ODwC2drbaJ+f5PXkD1lX28VCQDhoAOjr02HUuipVedhjubfCmM33+LRoD7u6aEl
# KUUnbOnC3gVVIGcCXWsrgyvyjqM2WQIDAQABo3YwdDATBgNVHSUEDDAKBggrBgEF
# BQcDAzBdBgNVHQEEVjBUgBD8gBzCH4SdVIksYQ0DovzKoS4wLDEqMCgGA1UEAxMh
# UG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZpY2F0ZSBSb290ghABvvi0sAAYvk29NHWg
# Q1DUMAkGBSsOAwIdBQADggEBAI8+KceC8Pk+lL3s/ZY1v1ZO6jj9cKMYlMJqT0yT
# 3WEXZdb7MJ5gkDrWw1FoTg0pqz7m8l6RSWL74sFDeAUaOQEi/axV13vJ12sQm6Me
# 3QZHiiPzr/pSQ98qcDp9jR8iZorHZ5163TZue1cW8ZawZRhhtHJfD0Sy64kcmNN/
# 56TCroA75XdrSGjjg+gGevg0LoZg2jpYYhLipOFpWzAJqk/zt0K9xHRuoBUpvCze
# yrR9MljczZV0NWl3oVDu+pNQx1ALBt9h8YpikYHYrl8R5xt3rh9BuonabUZsTaw+
# xzzT9U9JMxNv05QeJHCgdCN3lobObv0IA6e/xTHkdlXTsdgxggHhMIIB3QIBATBA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdAIQ
# mkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUcWRk8gMQO1aLFfqMZLp4
# 1ZP832AwDQYJKoZIhvcNAQEBBQAEggEAJMPP8huUQO23CvYPYzcANlebH7XBKFim
# EEdwylGCGHKl7DGcOQ2hcz7MuNg5Ai743Cy043oxdG0Cu212PrKursLQLAGZE2o6
# TE+cy95+2mlv1a/k5dhXObOQFEwt4i1dEWhAJOp0RTw/7Gdw/oBh1Ibqc7zGUnCH
# Ap9hAh9f3SXwATO3/U+eXuC62UH+BJBJKE/JlvEh7P8E5R3z5zb4I8T1/OXQUIqs
# QzZ37HOgQvvEgfWhXsd6k5xSNCiMK5+F0Z7LZkMgA1h/ahomc4dEw2DWwp8rXf2b
# F3D3vaKq3SWBb+o7EIpmLk3h6MvHkAmS+d+pwe6KIFs3ffK4cMgsTw==
# SIG # End signature block
