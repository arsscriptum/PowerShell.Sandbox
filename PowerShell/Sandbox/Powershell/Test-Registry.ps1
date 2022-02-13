 #requires -version 2.0

# -----------------------------------------------------------------------------
# Script: Export-Registry.ps1
# Author: Jeffery Hicks 
#    http://jdhitsolutions.com/blog
# Date: 01/25/2011 
# Keywords: Registry, PowerShell, Export
# Comments:
#
# "Those who neglect to script are doomed to repeat their work."

#  ****************************************************************
#  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
#  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
#  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
#  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
#  ****************************************************************

# -----------------------------------------------------------------------------

Function Export-Registry {

<#
   .Synopsis
    Export registry item properties.
    .Description
    Export item properties for a give registry key. The default is to write results to the pipeline
    but you can export to either a CSV or XML file. Use -NoBinary to omit any binary registry values.
    .Parameter Path
    The path to the registry key to export.
    .Parameter ExportType
    The type of export, either CSV or XML.
    .Parameter ExportPath
    The filename for the export file.
    .Parameter NoBinary
    Do not export any binary registry values
   .Example
    PS C:\> Export-Registry "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -ExportType xml -exportpath c:\files\WinLogon.xml
    
    .Example
    PS C:\> "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\MobileOptionPack","HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft SQL Server 10" | export-registry
  
    .Example
    PS C:\> dir hklm:\software\microsoft\windows\currentversion\uninstall | export-registry -ExportType Csv -ExportPath "C:\work\uninstall.csv" -NoBinary
    
   .Notes
    NAME: Export-Registry
    VERSION: 2.0
    AUTHOR: Jeffery Hicks
    LASTEDIT: 01/25/2011 10:18:33
    
    Learn more with a copy of Windows PowerShell 2.0: TFM (SAPIEN Press 2010)
    
   .Link
    Http://jdhitsolutions.com/blog
    
    .Link
    Get-ItemProperty
    Export-CSV
    Export-CliXML
    
   .Inputs
    [string[]]
   .Outputs
    [object]
#>

[cmdletBinding()]

Param(
[Parameter(Position=0,Mandatory=$True,
HelpMessage="Enter a registry path using the PSDrive format.",
ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
[ValidateScript({(Test-Path $_) -AND ((Get-Item $_).PSProvider.Name -match "Registry")})]
[Alias("PSPath")]
[string[]]$Path,

[Parameter()]
[ValidateSet("csv","xml")]
[string]$ExportType,

[Parameter()]
[string]$ExportPath,

[switch]$NoBinary

)

Begin {
    Write-Verbose -Message "$(Get-Date) Starting $($myinvocation.mycommand)"
    #initialize an array to hold the results
    $data=@()
 } #close Begin

Process {
    #go through each pipelined path
    Foreach ($item in $path) {
        Write-Verbose "Getting $item"
        $regItem=Get-Item -Path $item
        #get property names
        $properties= $RegItem.Property
        Write-Verbose "Retrieved $(($properties | measure-object).count) properties"
        if (-not ($properties))
            {
                #no item properties were found so create a default entry
                $value=$Null
                $PropertyItem="(Default)"
                $RegType="String"
                
                #create a custom object for each entry and add it the temporary array
                $data+=New-Object -TypeName PSObject -Property @{
                    "Path"=$item
                    "Name"=$propertyItem
                    "Value"=$value
                    "Type"=$regType
                    "Computername"=$env:computername
                 }
            }       
         
            else
            {
            #enumrate each property getting itsname,value and type
            foreach ($property in $properties) {
                Write-Verbose "Exporting $property"
                $value=$regItem.GetValue($property,$null,"DoNotExpandEnvironmentNames")
                #get the registry value type
                $regType=$regItem.GetValueKind($property)
                $PropertyItem=$property
                
                #create a custom object for each entry and add it the temporary array
                $data+=New-Object -TypeName PSObject -Property @{
                    "Path"=$item
                    "Name"=$propertyItem
                    "Value"=$value
                    "Type"=$regType
                    "Computername"=$env:computername
                 }
               } #foreach
            } #else
    }#close Foreach 
 } #close process

End {
  #make sure we got something back
  if ($data)
  {
    #filter out binary if specified
    if ($NoBinary)
    {
        Write-Verbose "Removing binary values"
        $data=$data | Where {$_.Type -ne "Binary"}
    }
  
    #export to a file both a type and path were specified
    if ($ExportType -AND $ExportPath)
    {
      Write-Verbose "Exporting $ExportType data to $ExportPath"
      Switch ($exportType) {
        "csv" { $data | Export-CSV -Path $ExportPath -noTypeInformation }
        "xml" { $data | Export-CLIXML -Path $ExportPath }
      } #switch
    } #if $exportType
    elseif ( ($ExportType -AND (-not $ExportPath)) -OR ($ExportPath -AND (-not $ExportType)) )
    {
        Write-Warning "You forgot to specify both an export type and file."
    }
    else 
    {
        #write data to the pipeline
        $data 
    }  
   } #if $#data
   else 
   {
        Write-Verbose "No data found"
        Write "No data found"
   }
     #exit the function
     Write-Verbose -Message "$(Get-Date) Ending $($myinvocation.mycommand)"
 } #close End

} #end Function


## Export-Registry "HKCR:\Software\Software\Adobe\Acrobat\Exe" -ExportType xml -exportpath c:\Scripts\Test.xml
# Export-Registry "HKEY_CLASSES_ROOT:\Software\Adobe\Acrobat\Exe" -ExportType xml -exportpath c:\Scripts\Test.xml

