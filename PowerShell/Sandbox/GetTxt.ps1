
$all_content = ""
Get-ChildItem "C:\Scripts" -Filter *.ps1 | 
Foreach-Object {
    $content = Get-Content $_.FullName
    $all_content += $content
   

    #filter and save content to a new file 
    
}
$all_content | Set-Content ("all.log")
Get-ChildItem "C:\Scripts" -Filter *.ps1 | Get-Content $_.FullName
Get-ChildItem "C:\Scripts" -Filter *.ps1 | Copy-Item -Path $_.FullName -Destination .\tmp\{$_.FullName}

Get-ChildItem "C:\Scripts\" -Filter *.ps1 |  Rename-Item -NewName {$_.FullName -replace ‘ps1’,’log’ }

Get-ChildItem "C:\Scripts" -Filter *.log |  Rename-Item -NewName {$_.FullName -replace ‘log’,’ps1’ }


Get-ChildItem "C:\Scripts" -Filter *.ps1 | echo {$_.FullName}

("one", "two", "three").ForEach("ToUpper")

"10.242.2.2", "10.1.31.147","192.168.0.1"


$computers = "10.242.2.2", "10.1.31.147","192.168.0.1"
$computers.ForEach('TestConnection') 


function TestConnection($servername)
{
	echo "calling bla $servername"
}


#ConvertTo-Html -Property BaseName -Title "file"
<#
PSPath
PSParentPath
PSChildName
PSDrive
PSProvider
PSIsContainer
Mode
VersionInfo
BaseName
Target
LinkType
Name
Length
DirectoryName
Directory
IsReadOnly
Exists
FullName
Extension
CreationTime
CreationTimeUtc
LastAccessTime
LastAccessTimeUtc
LastWriteTime
LastWriteTimeUtc
Attributes
#>