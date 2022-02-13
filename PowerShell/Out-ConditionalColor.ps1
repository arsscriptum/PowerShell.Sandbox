<#
#>
function Out-ConditionalColor 
{
[cmdletbinding()]
Param(
[Parameter(Position=0,Mandatory=$True,HelpMessage="Enter an ordered hashtable of conditional properties and colors.")]
[ValidateScript({ 
$_ -IS [System.Collections.Specialized.OrderedDictionary] -OR ($_ -IS [hashtable])})]
[psobject]$Conditions,
[Parameter(Position=1,HelpMessage="Enter a property name.")]
[string]$Property,
[Parameter(Position=2,Mandatory=$True,ValueFromPipeline=$True)]
[PSObject[]]$Inputobject

)

Begin {
    Write-Verbose "Starting $($MyInvocation.MyCommand)"
    #save original color
    $saved = $Host.UI.RawUI.ForegroundColor
    Write-Verbose "Original foreground color is $saved"

    #validate colors
    $allowed = [enum]::GetNames([system.consolecolor])
    $bad = $Conditions.Values | where {$allowed -notcontains $_}
    if ($bad) {
        Write-Warning "You are using one or more invalid colors: $($bad -join ',')"
        Break
    }    
   
    if ($Conditions -is [System.Collections.Specialized.OrderedDictionary]) {
        $Complex = $True
        #we'll need this later in the Process script block
        #if doing complex processing
        Write-Verbose "Getting hash table enumerator and names"
        $compare = $conditions.GetEnumerator().name
        Write-Verbose $($compare | out-string)
        #build an If/ElseIf construct on the fly
#the Here strings must be left justified
$If=@"
 if ($($compare[0])) {
  `$host.ui.RawUI.ForegroundColor = '$($conditions.item($($compare[0])))'
 }
"@

        #now add the remaining comparisons as ElseIf
        for ($i=1;$i -lt $conditions.count;$i++) {
         $If+="elseif ($($compare[$i])) { 
         `$host.ui.RawUI.ForegroundColor = '$($conditions.item($($compare[$i])))'
         }
         "
        } #for

#add the final else
$if+=@"
Else { 
`$host.ui.RawUI.ForegroundColor = `$saved 
}
"@

        Write-Verbose "Complex comparison:"
        Write-Verbose $If
    } #if complex parameter set
    Else {
        #validate a property was specified
        if (-NOT $Property) {
            [string]$property = Read-Host "Enter a property name"
            if (-Not $property) { 
                Write-Verbose "Blank property so quitting"
                Break
            }
        }
        Write-Verbose "Conditional property is $Property"
    } 

} #Begin

Process {

    If ($Complex) {
        #Use complex processing
        Invoke-Expression $if        
  } #end complex
  else {
        #get property value as a string
        $value = $Inputobject.$Property.ToString()
        Write-Debug "Testing property value $value"
        if ($Conditions.containsKey($value)) {
         Write-Debug "Property match"
         $host.ui.RawUI.ForegroundColor= $Conditions.item($value)
        }
        else {
         #use orginal color
         Write-Debug "No matches found"
         $host.ui.RawUI.ForegroundColor= $saved
        }        
  } #simple

    #write the object to the pipeline
    Write-Debug "Write the object to the pipeline"
    $_
} #Process

End {
    Write-Verbose "Restoring original foreground color"
    #set color back
    $Host.UI.RawUI.ForegroundColor=$saved
} #end

} #close function

#create an optional alias
Set-Alias -Name occ -Value Out-ConditionalColor