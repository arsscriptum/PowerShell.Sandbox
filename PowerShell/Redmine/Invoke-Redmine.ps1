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

function Get-SWRS {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$apiKey,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$rmUrl,
        [parameter()]
        [int32]$rmPageId = 1,
        [parameter()]
        [int32]$rmResultsPerPages = 100
    )

    # http://bcadlx01/redmine/projects/knee/issues?per_page=100&query_id=122
    # http://bcadlx01/redmine/projects/knee/issues.csv?query_id=122

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
  
    $stdOutTempFile = "$env:TEMP\$(( New-Guid ).Guid)"
    $stdErrTempFile = "$env:TEMP\$(( New-Guid ).Guid)"

    $request = "$rmUrl/issues.json?key=$apiKey&query_id=122&limit=$rmResultsPerPages&page=$rmPageId"
    Write-Host "http request to " $request -ForegroundColor Cyan

    $oXMLHTTP = new-object -com "MSXML2.XMLHTTP.3.0"
    $oXMLHTTP.open("GET","$request","False")
    $oXMLHTTP.send()
    $response = $oXMLHTTP.responseText

    # Was getting a limited amount of entries when requesting issues or SWRs. I was pitted against 2 limits:
    #   1) A Java Serialization limit
    #   2) Then, the server return limit (number at the bottom of the page). per_page=100 or limit=100
    # Our Redmine server is configured with a maximum results per page limit of 100.

    ## Java Serializer Instanciation with big value for objects limit.
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
    $obj = (New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{MaxJsonLength=67108864}).DeserializeObject($response)

    # Normal Java Serializer Instanciation
    #$serializer=new-object System.Web.Script.Serialization.JavaScriptSerializer
    #$obj=$serializer.DeserializeObject($response)

    # Print out object details with this (analyse our SWRs object structure...)
    # $obj
    # $obj["issues"]

    $dict1 = New-Object 'system.collections.generic.dictionary[[string],[system.collections.generic.list[object]]]'
    $dict2 = New-Object 'system.collections.generic.dictionary[[string],[system.collections.generic.list[object]]]'
    $dict3 = New-Object 'system.collections.generic.dictionary[[string],[system.collections.generic.list[object]]]'
    $dict4 = New-Object 'system.collections.generic.dictionary[[string],[system.collections.generic.list[object]]]'
    $dict5 = New-Object 'system.collections.generic.dictionary[[string],[system.collections.generic.list[object]]]'
    $dict6 = New-Object 'system.collections.generic.dictionary[[string],[system.collections.generic.list[object]]]'
    $dict7 = New-Object 'system.collections.generic.dictionary[[string],[system.collections.generic.list[object]]]'
    $dict8 = New-Object 'system.collections.generic.dictionary[[string],[system.collections.generic.list[object]]]'
    $dict9 = New-Object 'system.collections.generic.dictionary[[string],[system.collections.generic.list[object]]]'
    $dict10 = New-Object 'system.collections.generic.dictionary[[string],[system.collections.generic.list[object]]]'

    $dict = @{}
    $list=@()
    $i = 0
    while ( $i -lt $obj["issues"].count)
    {

        #   Software Cause  Related software component  Detailed Software Cause SW Risk Control Measures    External/Process Risk Controls  Status  Subject Test    Implementation Version
        $hash = New-Object PSObject
        $idstr=$obj["issues"]["$i"]["id"]
        $linkstr='http://bcadlx01/redmine/issues/' + $idstr
        $hash | Add-Member -MemberType "NoteProperty" -Name "id" -Value $obj["issues"]["$i"]["id"]
        $hash | Add-Member -MemberType "NoteProperty" -Name "author" -Value $obj["issues"]["$i"]["author"].name   
        $hash | Add-Member -MemberType "NoteProperty" -Name "Link" -Value $linkstr
        $hash | Add-Member -MemberType "NoteProperty" -Name "project" -Value $obj["issues"]["$i"]["project"]["name"]
        $hash | Add-Member -MemberType "NoteProperty" -Name "status" -Value $obj["issues"]["$i"]["status"]["name"]
        $hash | Add-Member -MemberType "NoteProperty" -Name "subject" -Value $obj["issues"]["$i"]["subject"]

        $dict0 = $obj["issues"]["$i"]["custom_fields"][0] # Risk ID
        $dict1 = $obj["issues"]["$i"]["custom_fields"][1] # Related software component
        $dict2 = $obj["issues"]["$i"]["custom_fields"][2] # Software Cause
        $dict3 = $obj["issues"]["$i"]["custom_fields"][3] # Detailed Software Cause
        $dict4 = $obj["issues"]["$i"]["custom_fields"][4] # SW Risk Control Measures
        $dict5 = $obj["issues"]["$i"]["custom_fields"][5] # External/Process Risk Controls
        $dict6 = $obj["issues"]["$i"]["custom_fields"][6] # Implementation Version
        $dict7 = $obj["issues"]["$i"]["custom_fields"][7] # Test
        # $dict8 = $obj["issues"]["$i"]["custom_fields"][8] # Drw no (BC-Reflex Uni

        $hash | Add-Member -MemberType "NoteProperty" -Name $dict0["name"] -Value $dict0["value"] 
        $hash | Add-Member -MemberType "NoteProperty" -Name $dict1["name"] -Value $dict1["value"] 
        $hash | Add-Member -MemberType "NoteProperty" -Name $dict2["name"] -Value $dict2["value"] 
        $hash | Add-Member -MemberType "NoteProperty" -Name $dict3["name"] -Value $dict3["value"] 
        $hash | Add-Member -MemberType "NoteProperty" -Name $dict4["name"] -Value $dict4["value"] 
        $hash | Add-Member -MemberType "NoteProperty" -Name $dict5["name"] -Value $dict5["value"] 
        $hash | Add-Member -MemberType "NoteProperty" -Name $dict6["name"] -Value "Andromède" # $dict6["value"] 
        $hash | Add-Member -MemberType "NoteProperty" -Name $dict7["name"] -Value $dict7["value"] 
        #$hash | Add-Member -MemberType "NoteProperty" -Name $dict8["name"]

        # Filtering out entries if required. 
        # Example: I used this to list the SWRs that contained '#' characters in the 'Test' section.
        #if($dict7["value"] -like '1.' -Or $dict7["value"] -like '*##*')
        #if($dict7["value"].contains('a)'))
        #{
        #    $list += $hash
        #}
        
        $list += $hash
        $i++
    }

    $list
}