1##===----------------------------------------------------------------------===
##  ┌─┐┬ ┬┌┐ ┌─┐┬─┐┌─┐┌─┐┌─┐┌┬┐┌─┐┬─┐ 
##  │  └┬┘├┴┐├┤ ├┬┘│  ├─┤└─┐ │ │ │├┬┘ 
##  └─┘ ┴ └─┘└─┘┴└─└─┘┴ ┴└─┘ ┴ └─┘┴└─ 
##  ┌┬┐┌─┐┬  ┬┌─┐┬  ┌─┐┌─┐┌┬┐┌─┐┌┐┌┌┬┐
##   ││├┤ └┐┌┘├┤ │  │ │├─┘│││├┤ │││ │ 
##  ─┴┘└─┘ └┘ └─┘┴─┘└─┘┴  ┴ ┴└─┘┘└┘ ┴ 
##===----------------------------------------------------------------------===

<#
    .SYNOPSIS
    System-EventManager class: Windows Events Helper for different scripts

    .DESCRIPTION
    A class to handle the fetching and the secure storage of the data required
    by the Reddit API to do request. This data is:
    - Username
    - PAssword
    - Application ClientID
    - Application SecretID
    - Authorization Token 

    So when you instanciate this class, you pass in a file path. If that file does not exists
    the user will be prompted for the username/pasword, 
    .EXAMPLE 
    $AppCreds = [RedditAppCredentials]::new()
    $AppCreds.Initialize($AppCredentialsFile,$False) | Out-null

    $Token=$AppCreds.GetClearAuthToken()
#>






class EventManager 
{
    [string]$DefaultEventSource=""
    [System.Collections.Generic.Dictionary[string,int]]$EventSourcesIds = [System.Collections.Generic.Dictionary[string,int]]::new()

    [string]$eventLog = "Application"
    [string]$eventSource = "MyScript"
$eventID = 4000
    [string]$entryType = "Error"

    [boolean]$Initialized=$false

    [boolean]IsInitialized(){
        return $this.Initialized
    }
    [string]GetEventSource(){
        return $this.EventSource
    }

    [boolean]IsAdmin(){
        $IsAdmin=([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')
        return $IsAdmin
    }

    [void]Initialize([string]$Source) 
    {
        # Set the event source
        $this.EventSource=$Source

        # Check if the source exists and create if needed
        If ([System.Diagnostics.EventLog]::SourceExists($Source) -eq $False) {
            if($this.IsAdmin() -eq $False){
                throw "The required event source $eventSource is misssing. Admin privilege required for initial setup."
            }
            else{
                $this.VerboseMsg("The required event source $eventSource is missing. Creating it...")
                New-EventLog -LogName Application -Source $Source  
            }
        }

        $this.Initialized=$True
    }

    [void]Register-App-AppEventLog ([string]$LogMessage)
    {

    }

    [void]Write-AppEventLog ([string]$LogMessage) 
    {
        <#
        .SYNOPSIS
                Create a fully qualified domain name
        .DESCRIPTION
                Create a fully qualified domain name object to be used in the certificate creation.
                The FQDN of the certificate matches the hostname (i.e. domain name) to which the client is trying to connect.
      
        .EXAMPLE

        .NOTES
            Possible . From EventLogEntryType Enum
            Error           1   
                An error event. This indicates a significant problem the user should know about; usually a loss of functionality or data.
            FailureAudit    16  
                A failure audit event. This indicates a security event that occurs when an audited access attempt fails; for example, a failed attempt to open a file.
            Information     4   
                An information event. This indicates a significant, successful operation.
            SuccessAudit    8   
                A success audit event. This indicates a security event that occurs when an audited access attempt is successful; for example, logging on successfully.
            Warning         2   

        #>


        # Check if the event manager is initializedd
        if($this.Initialized -eq $False){ throw "EventManager is not initialize" }

        Write-EventLog -LogName $this.eventLog -EventID $this.eventID -EntryType $this.entryType -Source $this.eventSource -Message $LogMessage 
    }


    [void]DebugMsg($Msg) {
        if($this.DebugEnabled){
            Write-Host "   [debug] -> " -NoNewLine -ForegroundColor Red; Write-Host $Msg -ForegroundColor DarkYellow
        } 
    }

    [void]VerboseMsg($Msg){
        Write-Host "   [log] -> " -NoNewLine -ForegroundColor DarkCyan; Write-Host $Msg -ForegroundColor Gray
    }

    [void]ExceptionMsg($Msg){

        $formatstring = "{0} : {1}`n{2}`n" +
                    "    + CategoryInfo          : {3}`n" +
                    "    + FullyQualifiedErrorId : {4}`n"
        $fields = $Msg.InvocationInfo.MyCommand.Name,
                  $Msg.ErrorDetails.Message,
                  $Msg.InvocationInfo.PositionMessage,
                  $Msg.CategoryInfo.ToString(),
                  $Msg.FullyQualifiedErrorId

        $ExceptMsg=($formatstring -f $fields)
        Write-Host "   [exception] -> " -NoNewLine -ForegroundColor DarkRed; Write-Host $ExceptMsg -ForegroundColor Yellow
    }   
}