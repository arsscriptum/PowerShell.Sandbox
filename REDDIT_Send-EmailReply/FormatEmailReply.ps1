
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Format-ReplyMessage{
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

    $Global:From = 'you@gmail.com'
    $Global:Password = 'mypassword'
    $Global:SMTPServer = "smtp.gmail.com"
    $Global:SMTPServerPort = 587

    try{
        $TestMode = $False
        
        if ( ($PSBoundParameters.ContainsKey('WhatIf') -Or $Test) ){         
            $TestMode = $True
        }

        # Validate template file
        $Exists = Test-Path -Path $TemplateFilePath -PathType 'Leaf'
        if ( $Exists -eq $False ) { throw "The template file doesn't exists." }

        # Get the file content
        $FileContent = Get-Content -Path $TemplateFilePath -Raw -Encoding 'UTF8'

        # Replace the tags '__CLIENT_NAME__' and '__CLIENT_ID__' with the correct values
        $FileContent = $FileContent.Replace('__CLIENT_NAME__',$ClientName)
        $FileContent = $FileContent.Replace('__CLIENT_ID__',$ClientId)

        Write-Verbose "----- EMAIL DATA -----`nSmtpServer`t$Global:SmtpServer`nSmtpServerPort`t$Global:SmtpServerPort`n"
        Write-Verbose "Subject`t$Subject`nFrom`t$Global:From`nPassword`t$Global:Password`nTo`t$To`n-----`n"
        Write-Verbose "----- BEGIN EMAIL -----`n$FileContent`n----- END EMAIL -----"


        if($TestMode -eq $False){
            # Send email
            $SMTPClient = New-Object Net.Mail.SmtpClient($Global:SMTPServer, $Global:SMTPServerPort)

            $MailMessage = new-object System.Net.Mail.MailMessage 
            $MailMessage.From = $Global:From 
            $MailMessage.To.Add($To)
            $MailMessage.IsBodyHtml = $True 
            $MailMessage.Subject = $Subject 
            $MailMessage.body = $FileContent
                
            $SMTPClient.EnableSsl = $true
            $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($From, $Global:Password);
            $SMTPClient.Send($MailMessage)   
        }else{
            Write-Host -n -f DarkRed "[TestMode] "
            Write-Host -f DarkYellow "WOULD SEND EMAIL: " 
            Write-Host -f DarkYellow  "----- EMAIL DATA -----`nSmtpServer`t$Global:SmtpServer`nSmtpServerPort`t$Global:SmtpServerPort`n"
            Write-Host -f DarkYellow  "Subject`t$Subject`nFrom`t$Global:From`nPass`t$Global:Password`nTo`t$To`n-----`n"
            Write-Host -f DarkYellow  "----- BEGIN EMAIL -----`n$FileContent`n----- END EMAIL -----"            
        }


    }catch{
        Write-Host -n -f DarkRed "[ERROR] "
        Write-Host -f DarkYellow "$_"
    }
}


