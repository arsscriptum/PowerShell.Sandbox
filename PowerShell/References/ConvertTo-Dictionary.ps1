function ConvertTo-Dictionary
{
    #requires -Version 2.0

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [hashtable]
        $InputObject,

        [Type]
        $KeyType = [string]
    )

    process
    {
        $outputObject = New-Object "System.Collections.Generic.Dictionary[[$($KeyType.FullName)],[Object]]"

        foreach ($entry in $InputObject.GetEnumerator())
        {
            $newKey = $entry.Key -as $KeyType
            
            if ($null -eq $newKey)
            {
                throw 'Could not convert key "{0}" of type "{1}" to type "{2}"' -f
                      $entry.Key,
                      $entry.Key.GetType().FullName,
                      $KeyType.FullName
            }
            elseif ($outputObject.ContainsKey($newKey))
            {
                throw "Duplicate key `"$newKey`" detected in input object."
            }

            $outputObject.Add($newKey, $entry.Value)
        }

        Write-Output $outputObject
    }
}
