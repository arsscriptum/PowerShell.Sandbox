##===----------------------------------------------------------------------===
##  Invoke-Redmine.ps1 - PowerShell script for Redmine action!
##
##  Invoke-Redmine contains functions developped specifically
##  for Bodycad's Development Team needs. No prior knowledge of Redmine's API,
##  so one of the purpose of this code is to get the know the common pitfalls
##  we face when using Redmine's API.
##  
##  Major Goal: Software Requirements. Bodycad's Software submission do require an
##  extensive validation process. The development team are writing tests procedures
##  and validation documents called 'SWRs'. They are inputted in Redmine and then
##  exported with the Redmine export fonctionality.
##
##  Unfortunately, the exported document does not completely represent what is 
##  required, so we use JavaScript's Serializer, Redmine's rest API and PowerShell
##  to mold all this in the format we need. I'm developping this and getting 
##  requirements from Marc Bédard as I go along.
##
##  Guillaume Plante <radicaltronic@gmail.com>
##  Copyright(c) All rights reserved.
##===----------------------------------------------------------------------===
 

function Get-Exported-Issues-CSV {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$rmUrl,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$localFile 
    )
    $client = new-object System.Net.WebClient
    $client.Credentials = Get-Credential
    $client.DownloadFile($rmUrl,$localFile)
}

function Get-Licenses {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$cmVer
    )

    # http://bcadlx01/redmine/projects/knee/issues?per_page=100&query_id=122
    # http://bcadlx01/redmine/projects/knee/issues.csv?query_id=122

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
  
  
    $list=@()
    $i = 0
    #while ( $i -lt $obj["issues"].count)
    #{

        #   Software Cause  Related software component  Detailed Software Cause SW Risk Control Measures    External/Process Risk Controls  Status  Subject Test    Implementation Version
        $hash = New-Object PSObject
        $Now = Get-Date -Uformat "%A, %d/%m/%Y"
        $linkstr='http://bcadlx01/redmine/issues/' + $idstr
        $hash | Add-Member -MemberType "NoteProperty" -Name "Product" -Value "Osteotomy"
        $hash | Add-Member -MemberType "NoteProperty" -Name "Version" -Value "2.22.0.0"
        $hash | Add-Member -MemberType "NoteProperty" -Name "Status" -Value '<center><img src="http://bcadd0260/check24.png"></center>'
        $hash | Add-Member -MemberType "NoteProperty" -Name "Product Id" -Value "16"
        $hash | Add-Member -MemberType "NoteProperty" -Name "Features" -Value "0x000000ff"
        $hash | Add-Member -MemberType "NoteProperty" -Name "Internal" -Value "Yes"
        $hash | Add-Member -MemberType "NoteProperty" -Name "Dongles" -Value "None"
        $hash | Add-Member -MemberType "NoteProperty" -Name "Created On" -Value $Now

        <#
        $hash = New-Object PSObject
        $Now = Get-Date -Uformat "%A, %d/%m/%Y"
        $linkstr='http://bcadlx01/redmine/issues/' + $idstr
        $hash | Add-Member -MemberType "NoteProperty" -Name "Product" -Value "Motion"
        $hash | Add-Member -MemberType "NoteProperty" -Name "Version" -Value "1.3.0.0"
        $hash | Add-Member -MemberType "NoteProperty" -Name "Status" -Value '<center><img src="http://bcadd0260/check24.png"></center>'
        $hash | Add-Member -MemberType "NoteProperty" -Name "Product Id" -Value "7"
        $hash | Add-Member -MemberType "NoteProperty" -Name "Features" -Value "N/A"
        $hash | Add-Member -MemberType "NoteProperty" -Name "Internal" -Value "Yes"
        $hash | Add-Member -MemberType "NoteProperty" -Name "Dongles" -Value "None"
        $hash | Add-Member -MemberType "NoteProperty" -Name "Created On" -Value $Now
        #>

        $list += $hash

        <#$hash1 = New-Object PSObject
        $Now = Get-Date -Uformat "%A, %d/%m/%Y"
        $linkstr='http://bcadlx01/redmine/issues/' + $idstr
        $hash1 | Add-Member -MemberType "NoteProperty" -Name "Product" -Value "Positioner"
        $hash1 | Add-Member -MemberType "NoteProperty" -Name "Version" -Value "1.3.0.0"
        $hash1 | Add-Member -MemberType "NoteProperty" -Name "Status" -Value '<center><img src="http://bcadd0260/check24.png"></center>'
        $hash1 | Add-Member -MemberType "NoteProperty" -Name "Product Id" -Value "6"
        $hash1 | Add-Member -MemberType "NoteProperty" -Name "Features" -Value "N/A"
        $hash1 | Add-Member -MemberType "NoteProperty" -Name "Internal" -Value "Yes"
        $hash1 | Add-Member -MemberType "NoteProperty" -Name "Dongles" -Value "None"
        $hash1 | Add-Member -MemberType "NoteProperty" -Name "Created On" -Value $Now
        $list += $hash1
        #>
    #}

    $list
}