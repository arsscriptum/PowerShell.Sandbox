

    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true, Position=0, ValueFromPipeline=$true, HelpMessage="The list of receipients as a string, colon separated")]
        [ValidateNotNullOrEmpty()]
        [String]$To,
        [Parameter(Mandatory = $true, Position=1, ValueFromPipeline=$true, HelpMessage="Client Name")]
        [ValidateNotNullOrEmpty()]
        [String]$ClientName,
        [Parameter(Mandatory = $true, Position=2, ValueFromPipeline=$true, HelpMessage="Client ID")]
        [ValidateNotNullOrEmpty()]
        [String]$ClientId,
        [Parameter(Mandatory = $true, Position=3, ValueFromPipeline=$true, HelpMessage="Path for the template txt file")]
        [ValidateNotNullOrEmpty()]
        [String]$TemplateFilePath,
        [Parameter(Mandatory = $false, ValueFromPipeline=$true, HelpMessage="Email subject")]
        [String]$Subject = "MONITORING FEEDBACK",
        [Parameter(Mandatory = $false, ValueFromPipeline=$true, HelpMessage="Test only, no email sent")]
        [Switch]$Test        
    )

    #include script
    $CurrentPath = $PWD.Path
    $Script = Join-Path $CurrentPath "FormatEmailReply.ps1"
    . "$Script"

    $TestMode = $False
    if($Test) {$TestMode = $True ; Write-Host "TESTMODE ENABLED" -f DarkCyan}
    Format-ReplyMessage -To $To -ClientName $ClientName -ClientId $ClientId -TemplateFilePath $TemplateFilePath -Subject $Subject -Test:$TestMode