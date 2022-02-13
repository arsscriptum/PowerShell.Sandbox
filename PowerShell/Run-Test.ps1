##===----------------------------------------------------------------------===
##  Run-Test.ps1 - PowerShell script
##
##  The purpose of this script is to test different functionalities provided
##  in other PowerShell files in this directory. It can be changed and
##  don't expect it to work. It's in a state of eternal WIP.
##
##  Guillaume Plante <radicaltronic@gmail.com>
##  Copyright(c) All rights reserved.
##===----------------------------------------------------------------------===
 
# Includes

. (Join-Path $env:PowerShellScriptsRoot "\Redmine\Invoke-Redmine.ps1")


function LoadConfig
{   
    $xml = [xml](Get-Content .\config.xml)

    $apiKey = $xml.config.apiKey
    $rmUrl = $xml.config.rmUrl
    $rmAssign = $xml.config.rmAssign

    #Write-Host Loaded: -NonewLine -ForeGround Red
    #Write-Host $apiKey $rmUrl -ForeGround Red
    $apiKey,$rmUrl,$rmAssign
}
 
#CSS codes
$header = @"
<style>

    h1 {

        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 28px;

    }

    
    h2 {

        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;

    }

    
    
   table {
        font-size: 12px;
        border: 0px; 
        font-family: Arial, Helvetica, sans-serif;
    } 
    
    td {
        padding: 4px;
        margin: 0px;
        border: 0;
    }
    
    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
    }

    tbody tr:nth-child(even) {
        background: #f0f0f2;
    }
    


    #CreationDate {

        font-family: Arial, Helvetica, sans-serif;
        color: #ff3300;
        font-size: 12px;

    }



    .StopStatus {

        color: #ff0000;
    }
    
  
    .RunningStatus {

        color: #008000;
    }




</style>
"@

Write-Host Loading configuration...

$config = LoadConfig
$apiKey = $config[0]
$rmUrl = $config[1]
$rmAssign = $config[2]
     
# $pageTitle="<h3><center>Problematic SWRs (with # or ##)</center></h3>"
$pageTitle="<h3><center>DesignerReflex SWRs</center></h3>"

$data=Get-SWRS  $apiKey $rmUrl 1 
$data+=Get-SWRS  $apiKey $rmUrl 2
#$data | ConvertTo-Html -As LIST -Property "id", "Test", "External/Process Risk Controls" | Out-File services.htm
$datasorted= $data | Sort-Object -Property id

#$html=($datasorted | ConvertTo-Html -PreContent $pageTitle -Head $header -Property @{Label="Link";Expression={"<a href='$($_.Link)'>$($_.id)</a>"}}, "author","Test" )
$html=($datasorted | ConvertTo-Html -PreContent $pageTitle -Head $header -Property @{Label="Link";Expression={"<a href='$($_.Link)'>$($_.id)</a>"}}, *  )
# | Out-File services.htm
Add-Type -AssemblyName System.Web
[System.Web.HttpUtility]::HtmlDecode($html) | Out-File problematic-swrs.htm
# $list | Format-Table -AutoSize
Write-Host "Total results: " $data.count -ForeGround Red

#$rmurl="http://bcadlx01/redmine/projects/knee/issues.csv?query_id=122"
#Get-Exported-Issues-CSV $rmUrl "e:\rmissues.csv"