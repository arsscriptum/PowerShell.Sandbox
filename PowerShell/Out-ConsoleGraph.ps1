#requires -version 3.0

Function Out-ConsoleGraph {

<#
.Synopsis
Create a console-based chart
.Description
This command takes objects and creates a horizontal bar graph based on the 
property you specify. The property should return a numeric value. This command
does NOT write anything to the pipeline. All output is to the PowerShell host.

The default behavior is to use the same color, Green, for all graphed values.
But you can specify conditional coloring using -HighColor, -MediumColor and
-LowColor. If you specify one you must specify all three. The maximum available
graph value is divided into thirds. The top third will be considered high, the
next third medium and the rest low.

The final option is to send the graph results to Out-Gridview. You cannot use
conditional formatting nor specify a graph color. But the grid view will
include the property value.

.Parameter Property
The name of the property to graph.
.Parameter CaptionProperty
The name of the property to use as the caption. The default is Name.
.Parameter Title
A string for the title of your graph. The default is <Property> Report - <date>
.Parameter DefaultColor
The default console color to use for the graph
.Parameter HighColor
The console color to use for the top 1/3 of graphed values.
.Parameter MediumColor
The console color to use for the middle 1/3 of graphed values.
.Parameter LowColor
The console color to use for the bottom 1/3 of graphed values.
.Parameter ClearScreen
Clear the screen before displaying the graph. The parameter has an alias of cls.
.Parameter GridView
Create a graph using Out-Gridview
.Example
PS C:\> Get-Process | Out-ConsoleGraph -property WorkingSet -clearscreen
.Example
PS C:\> $computer="CHI-FP01"
PS C:\> Get-WmiObject Win32_logicaldisk -filter "drivetype=3" -computer $computer | out-ConsoleGraph -property Freespace -Title "FreeSpace Report for $computer on $(Get-Date)"
.Example
PS C:\> get-vm | where state -eq 'running' | out-consolegraph -Property MemoryAssigned -GraphColor Red
.Example
PS C:\> "chi-dc01","chi-dc02","chi-dc03","chi-fp01" | foreach -Begin {cls} { 
  $computer=$_
  Get-WmiObject win32_logicaldisk -filter "drivetype=3" -ComputerName $computer |
  Out-ConsoleGraph -property FreeSpace -title "Freespace Report for $computer - $(Get-Date)" -defaultcolor Cyan
  }
.Example
PS C:\> get-process | where {$_.cpu} | out-consolegraph CPU -high Red -medium magenta -low yellow
.Example
PS C:\> get-process | where {$_.cpu} | Sort CPU -descending | Out-Consolegraph CPU -Caption ID -Grid
.Link
Write-Host
Out-Gridview
.Link
http://jdhitsolutions.com/blog/2013/01/
.Inputs
Object
.Outputs
None
.Notes
Version:  3.0
Updated:  January 14, 2013
Author :  Jeffery Hicks (http://jdhitsolutions.com/blog)

Read PowerShell:
Learn Windows PowerShell 3 in a Month of Lunches
Learn PowerShell Toolmaking in a Month of Lunches
PowerShell in Depth: An Administrator's Guide
#>

[cmdletbinding(DefaultParameterSetName="Single")]
Param (
[parameter(Position=0,Mandatory=$True,HelpMessage="Enter a property name to graph")]
[ValidateNotNullorEmpty()]
[string]$Property,
[parameter(Position=1,ValueFromPipeline=$True)]
[object]$Inputobject,
[string]$CaptionProperty="Name",
[string]$Title="$Property Report - $(Get-Date)",
[Parameter(ParameterSetName="Single")]
[ValidateNotNullorEmpty()]
[System.ConsoleColor]$DefaultColor="Green",
[Parameter(ParameterSetName="Conditional",Mandatory=$True)]
[ValidateNotNullorEmpty()]
[System.ConsoleColor]$HighColor,
[Parameter(ParameterSetName="Conditional",Mandatory=$True)]
[ValidateNotNullorEmpty()]
[System.ConsoleColor]$MediumColor,
[Parameter(ParameterSetName="Conditional",Mandatory=$True)]
[ValidateNotNullorEmpty()]
[System.ConsoleColor]$LowColor,
[alias("cls")]
[switch]$ClearScreen,
[Parameter(ParameterSetName="Grid")]
[switch]$GridView
)

Begin {
    Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"  
    Write-Verbose -Message "Parameter set $($pscmdlet.ParameterSetName)"
    #get the current window width so that our lines will be proportional
    $Width = $Host.UI.RawUI.BufferSize.Width
    Write-Verbose "Width = $Width"
    
    #initialize an array to hold data
    $data=@()
    if ($GridView) {
        Write-Verbose "Initializing gvData"
        $gvData = @()
    }
} #begin

Process {
    #get the data
    $data += $Inputobject

} #end process

End {
    #get largest property value
    Write-Verbose "Getting largest value for $property"
    Try {
       <#
       Modified this original line per Lee Holmes to handle piped objects that
       might not have the same property such as Directory and File. 
       $largest = $data | sort $property | Select -ExpandProperty $property -last 1 -ErrorAction Stop
       #>
       $largest = $data | Foreach-Object { $_.$property } | sort | select -last 1
        Write-Verbose $largest
    }
    Catch {
        Write-Warning "Failed to find property $property"
        Return
    }
    If ($largest) {
        #get length of longest object property used for the caption so we can pad
        #This must be a string so we can get the length
        Write-Verbose "Getting longest value for $CaptionProperty"
        $sample = $data |Sort @{Expression={($_.$CaptionProperty -as [string]).Length}} |
        Select -last 1
        Write-Verbose ($sample | out-string)
        [int]$longest = ($sample.$CaptionProperty).ToString().length
        Write-Verbose "Longest caption is $longest"

        #get remaining available window width, dividing by 100 to get a 
        #proportional width. Subtract 4 to add a little margin.
        $available = ($width-$longest-4)/100
        Write-Verbose "Available value is $available"

        #calculate high, medium and low ranges based on available
        $HighValue = ($available*100) * 0.6666
        $MediumValue = ($available*100) * 0.3333
        #low values will be 1 to $MediumValue
        Write-Verbose "High value will be $HighValue"
        Write-Verbose "Medium value will be $MediumValue"
    
        if ($ClearScreen) {
            Clear-Host
        }
        Write-Host "$Title`n"
        foreach ($obj in $data) {
            #define the caption
            [string]$caption = $obj.$captionProperty

            <#
             calculate the current property as a percentage of the largest 
             property in the set. Then multiply by the remaining window width
            #>
            if ($obj.$property -eq 0) {
                #if property is actually 0 then don't display anything for the graph
                [int]$graph=0
            }
            else {
                $graph = (($obj.$property)/$largest)*100*$available
            }
            if ($graph -ge 2) {
                [string]$g=[char]9608
            }
            elseif ($graph -gt 0 -AND $graph -le 1) {
                #if graph value is >0 and <1 then use a short graph character
                [string]$g=[char]9612
                #adjust the value so something will be displayed
                $graph=1
            }
            
            Write-Verbose "Graph value is $graph"
            Write-Verbose "Property value is $($obj.$property)"

            #send to Out-Gridview if specified
            if ($GridView) {
                #add each object to the gridview data array
                $gvHash = [ordered]@{
                $CaptionProperty = $caption
                $Property = ($g*$graph) 
                Value = $obj.$Property
                } 
                $gvData += New-Object -TypeName PSObject -Property $gvHash
            }
            Else {
            Write-Host $caption.PadRight($longest) -NoNewline
            #add some padding between the caption and the graph
            Write-Host "  " -NoNewline
            if ($pscmdlet.ParameterSetName -eq "Single") {
                $GraphColor = $DefaultColor
            }
            else {
                #using conditional coloring based on value of $graph
                if ($Graph -ge $HighValue) {
                    $GraphColor = $HighColor
                }
                elseif ($graph -ge $MediumValue) {
                    $GraphColor = $MediumColor
                }
                else {
                    $GraphColor = $LowColor
                }
            }
            Write-Host ($g*$graph) -ForegroundColor $GraphColor
            }
        } #foreach
           #add a blank line
           Write-Host `n
    } #if $largest

    if ($gvData) {
      Write-Verbose "Sending data to Out-Gridview"
      $gvData | Out-GridView -Title $Title 
    }
    Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"
} #end

} #end Out-ConsoleGraph

#define an optional alias
Set-Alias -Name ocg -Value Out-ConsoleGraph