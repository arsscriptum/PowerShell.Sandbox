
<#
.Synopsis
   Create a password from composing several random passwords using the membership C# class.
.DESCRIPTION
   This script will give a random password composite for several passwords
.EXAMPLE
   .\Get-RandomPwd -Long 30
   Will provide a password with 30 of longitude, composite by (Long/int) passwords.
   Int by default has a value of 10. so (Long/int) = 3 (3 different passwords).
.EXAMPLE
   .\Get-RandomPwd -Long 30 -int 5
   Will provide a password with 30 of longitude, composite by (Long/int) passwords.
   Int by default has a value of 5. so (Long/int) = 6 (6 different passwords).
.EXAMPLE
   .\Get-RandomPwd -Long 30 
   Will provide a password with 30 of longitude, composite by 3 passwords of 30 characters.
   from the 1st password it will get the 10 1st characters (remember int =10).
   from the 2nd passwords it will get the characters in place 11 to 20 (again int 10)
   and from the 3rd passwords it will take the last 10 characters to get the new password.
.INPUTS
   Long: Size of the random password.
   Int: default value 10. it can be easily modified using -int X parameter.
   
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   It's important than Long/int gives an integer, if it's a decimal or racional the script will stop with a error
.COMPONENT
   This script doesn't below to any component.
.ROLE
   This script doesn't contain any role.
.FUNCTIONALITY
   This script will get (Long/Int) random passwords.
   Then, it will get the 1st (int) characters from the 1st password,
   then  it will get the 2nd (int) characters from the 2nd password
   etc. until it's completed the passsword.
#>
#require version 5
[CmdletBinding()]
param(
    [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)][ValidatePattern("\d{1,2}")] [string]$Long,
    [Parameter(Position=1,Mandatory=$false,ValueFromPipeline=$true)][ValidatePattern("\d{1,2}")][string]$int=10

)

#Load System.Web.
[reflection.assembly]::loadwithpartialname("system.web") | Out-Null

function PrintItem{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)]$counter,
        [Parameter(Position=1,Mandatory=$true)]$string

    )

    process{
        switch($counter){
            0 {write-host -ForegroundColor Green      $string;Break}
            1 {write-host -ForegroundColor Cyan       $string;Break}
            2 {write-host -ForegroundColor Magenta    $string;Break}
            3 {write-host -ForegroundColor Yellow     $string;Break}
            4 {write-host -ForegroundColor Blue       $string;Break}
            5 {write-host -ForegroundColor Red        $string;Break}
            6 {write-host -ForegroundColor white      $string;Break}
            7 {write-host -ForegroundColor DarkGray   $string;Break}
            8 {write-host -ForegroundColor DarkYellow $string;Break}
            9 {write-host -ForegroundColor DarkGreen  $string;Break}
            10{write-host -ForegroundColor DarkCyan   $string;Break}
        }
    }
}
function PrintSubString{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)]$counter,
        [Parameter(Position=1,Mandatory=$true)]$string,
        [Parameter(Position=2,Mandatory=$true)]$integer
    )
    process{
        switch($counter/$integer){
            0{write-host -ForegroundColor Green      $string -NoNewLine; Break}
            1{write-host -ForegroundColor Cyan       $string -NoNewLine; Break}
            2{write-host -ForegroundColor Magenta    $string -NoNewLine; Break}
            3{write-host -ForegroundColor Yellow     $string -NoNewLine; Break}
            4{write-host -ForegroundColor Blue       $string -NoNewLine; Break}
            5{write-host -ForegroundColor Red        $string -NoNewLine; Break}
            6{write-host -ForegroundColor white      $string -NoNewLine; Break}
            7{write-host -ForegroundColor DarkGray   $string -NoNewLine; Break}
            8{write-host -ForegroundColor DarkYellow $string -NoNewLine; Break}
            9{write-host -ForegroundColor DarkGreen  $string -NoNewLine; Break}
           10{write-host -ForegroundColor DarkCyan   $string -NoNewLine; Break}
        }
    }
}



if(! ($Long % $int -le 0)){
    Write-Error "Please select a parameter ""Long"" that is divisible by ""int"" exactly for this script to work"
    exit -1
}
else{
    Write-Host -ForegroundColor Black -BackgroundColor White "The length of the password would be: $Long characters"
}


$Global:parts=[System.math]::Ceiling($long/$int)

[string]$pwd=$null
[Array]$originals=@()
for($i=0; $i -lt $Global:parts; $i++){
    [string]$str1=[System.Web.Security.Membership]::GeneratePassword($Long,0)
    $originals+=$str1
    $pwd+=$str1.Substring($i*$int,$int)
}

#Show all passwords:
$i=0;
Write-host -ForegroundColor White "ORIGINAL Passwords" -BackgroundColor Black
foreach($item in $originals){
    PrintItem -counter $i -string $item
    $i++
}
Write-host -ForegroundColor White "Final Passwords" -BackgroundColor Black
for($i=0; $i -lt $Global:parts; $i++){
    PrintSubString -counter $($i*$int) -string $pwd.Substring($i*$int,$int) -integer $int
}
