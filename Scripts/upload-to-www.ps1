$uid= Read-Host -Prompt 'Username' 
$pwd=Read-Host -Prompt 'Password' -AsSecureString
$pwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
       [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd))

if(!$pwd) {Exit;}

curl.exe -T ".\Builds\CurrentRelease\MarkdownMonsterSetup.exe"  "ftps://west-wind.com/Ftp/Files/" -u ${uid}:${pwd} -k
curl.exe -T ".\Builds\CurrentRelease\MarkdownMonsterSetup.zip"  "ftps://west-wind.com/Ftp/Files/" -u ${uid}:${pwd} -k
curl.exe -T ".\Builds\CurrentRelease\MarkdownMonster_Version.xml"  "ftps://west-wind.com/Ftp/Files/" -u ${uid}:${pwd} -k