function Get-ObfuscationCommand
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [System.String]
        $String,

        [Parameter(Position = 1)]
        [System.UInt32]
        $BytesPerCharacter = 1
    )

    if ($BytesPerCharacter -eq 0) { $BytesPerCharacter = 1 }

    $hexCharsPerCharacter = $BytesPerCharacter * 2

    $byteString = New-Object System.Text.StringBuilder

    foreach ($char in $String.GetEnumerator())
    {
        $null = $byteString.Append(([int][char]$char).ToString("X$hexCharsPerCharacter"))
    }

    $obfuscatedString = $byteString.ToString()
    $charCount = [int]($obfuscatedString.Length / $hexCharsPerCharacter)

    Write-Output "-join('$obfuscatedString' -split '(?<=\G.{$hexCharsPerCharacter})',$charCount|%{[char][int]`"0x`$_`"})"
}
