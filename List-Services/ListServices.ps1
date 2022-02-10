
[CmdletBinding(SupportsShouldProcess)]
param ()  

#Requires -Version 5
Set-StrictMode -Version 'Latest'

# ------------------------------------
# Script file - Assemblies - 
# ------------------------------------
$ScriptBlockAssemblies = "H4sIAAAAAAAACp1UbW/aMBD+jsR/ONFIBa2hn/alU6V2ULRJ0KKC1k1VP5jkKG6DnZ4doajrf985TngrVWEWirB9z708d4/rtWAUkUzt2Z1UsV6YS2NwPknyW5wioYrQwPlFs1Xfw+7LORwPCQ0qK6zUqkdijgtNz8f/g+5owr2B5e13YfbHjHJjcd4ujdo9TXNzKLhLYiHV44GwYzgwzO954jBy2gyG5heSYX7GYpJge7ltD8STJgjxBb62Xus14HVQjFGKGM24krd6bZqpyPUARjO9CN/jSv93JC2GP7Sx0OhL/ookgSgjNrJAqyhSwYcpNCCcQicXat+U/wJ36kpEs/Bm8oSRhTKZ7YQq6BksQ0B4ra9x0ZcKd2PgPhiOfjIbDwVmIB7dNHpbpoV/a9xcxvF7ajgZb54Knn7/t7kKdm8s8bw8BBXQX7UO6NcadDOfDqHgSj7sVjDSGUUI53DR8CeZ4VzA9/+bP1IsWZMKNhvkHa0s6cRflE5OTwE6R+BdLYlpXFRlB8xvN0mGws44UJN34RjnqSZBeU8m2Gq7K2/rCBznKULx7eJUKllUUmUa3mQ2zWxV0YbzcFlfXN5L5udTBrcj97n5JLzLzex5hVdEmi5LKXD2yiYFK1JlXLz3RWgzUuvQ7cbc4iOLAylcJbock6O+FjH7eMkkYQyJnDBTrpLtRKtSrrlBsPOVPYHt5/ME1t7FE9j14C1Py5esCOtj8z2yzKAZMH1Ow5+S21rX4pjy9e0n8uwKer5lAnYpdBvKKuWYXqIO9weTRC827T8gzgFXhm9VqW51hOVid2Z8J0g5pYQDNIbfBGj0BE9DDFaDdMNtC8elqgrPpTTcpxyH2j9IWfs7awcAAA=="

$ScriptBlockMusic = "H4sIAAAAAAAACu1WbU/bSBD+jsR/GFmRaquxiUnMWxVVNG0BQWh0LsdJFao29gBbNru+9aZcWvW/d+x1gkOgqNBeezosJXY888zrMztZXjody8RwJWFPflQX2Od5Tr/2Rpmih6FA+Ly8BHS9S5TMlcCTra0hYuaub3SaEEYtz4pjw7TxY0Ei8EfQbrV+KGyzvfoNGAluhoWtzvp9cP9ucmubm/cKstP6/XN7bNwPa9y1Ut7RoOviaKOYhNXWLV7Xo5/iNOr8Aqer7W85vbW+nbW1u82W4i/LV8fmIZodNK+5wEPVY8k5Li9NT8zeKBVoXnCZcnnmxuMsU9rk8bkai3SgVYJ53m0YPUbvxCIyptnItc+lhUHxAg1qt89kyozSk3lEqZUbTQ5OGkdaNO8NHjBzfif6lIn8FrhW/0y201RTUg81c5SjfqiNAcvzS6XTB9gpwtg+Q2m6jmPF1Hr70HitdDJteLfxloo6EyWCEwa6xIxL/83wAyamIElwjMNeKbJ6/NSFxiB+ocYynQWWBz0lDeMy38eJ69SL6njgVcQqrmPNDfrHTEuKFVxngYZPcvDreEuuwgnwHKQyYDA3mAZOxfcy+KxAVLErG3s8IbVRUKVQmgRnrt/OdQNBT2NKmXKq7XwhasboQw26uFIFt9Z+mG+jBzUftsJB6aprPVopzWVxmxX4qoXgSwTHqVewYbsR7CJLi8pTMq4zJoDPCoTTpCxneKr+leUvSJT5Pkt99YkLwVaioAUuH5wric+gNzgC+wxvYgjb76P3IQh+gdBnSfHqLw+2s0wg1X2fm5W1VhSEQRiBu7/7tn/QtLo7mFwoD/4kz3QerYTtQgf6akhcWAmjV2FnA2J2yjQnA50gpFRm1aoo+wf+PSYy0PlB3aKstaCWTqtIbamz3Sv+EC42o5QNlODJZJH6pTCovNQ03Xc3Sw/wIwo6dyuXhyqmWcXZ9NmYaYT30q4rydXZmKdesEPfiwrVHXyNmWAJscCv8/WG1OEpOM/5DOnMccvO3a7KDSzO3BZU5oqZrJmuTExr9VJdSqFYWiDdmlqzPITtflnYMHF5Kv1eO+ZxXfy318Ucpx4XxuPC+GkLY8rD/+/iOFBnvp236eKYm77vXB0WW18e07XxFerR487SEQAA"

# ------------------------------------
# Script file - Helpers - 
# ------------------------------------
$ScriptBlockHelpers = "H4sIAAAAAAAACsVVXW/aMBR9j5T/YNFITSRA3WslHjYKbaXxsYSpm1AkvOQC1ozNbEcMIf777HxAAqGdtq5LHuz4Hl/fc+/xjW3Z+o0olhJ1l5gxoGPB1yAUAWlbO9tC+rmqMZn1qVSCsEXo5HbUQdfBw+PgOjd3OZOcQpdTLkJnQlQ+N7ivQCnf1CMHICVeHLF3WHy/F3hbj+4JwUUF60NcDw2SKNK+TxwDsGc834GMBFkrwlll34HA3race8q/YXpbypPUuOlZ3sLbWwYb1zNZt615wiLjFz0JoqCVo3P2OxNQ6blCw1Hvy3jkT/RHEe4qpqA+EBbrMrhBsl5zoWSw5AmN9aGGqxdm2DUWeOVm83Tv2CyAAuEOMIux4mLbcZRIoDnmkpiwOjfF5kqx8/iK9QyRMjKTjMoDlwo1po5bl5l2/uGFqIFac3QBddSLh1pDPoTNR8Lg/JQioOd8lRXlpSW7nH8fZELVafrr61DKwH8tRrNs2hAVLUPnCQumMSf1IXO3sKAW/EBOH1MJXn7TX7eC5et2XsPTs1DwudvtBcFfuNyD5vJPqBybzG8Q6fn+yH/Z3WlnqeGTDa+p+UuqTyPavSx29Baqr0g92EoFq7aGaDYrYKr9PlF8hQ2HLJE+RFzEoZONB8GbwZlzoaHZddEtubG72c/Y7t2+UdgJ0Ng063x3u59Quv2UYEq0KU79P8bNwtr7GUFasfaEB6lT08xTT5lpIBcdt3pqS5coOyaHvn2PnKaS/HOJV7R3IDpjM6Y99rmAheAJi7Mf5PHvmKrO+gVJDew0ZQgAAA=="

# ------------------------------------
# Script file - MessageBox - 
# ------------------------------------
$ScriptBlockMessageBox = "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"

# ------------------------------------
# Loader
# ------------------------------------
function ConvertFrom-Base64CompressedScriptBlock {

    [CmdletBinding()] param(
        [String]
        $ScriptBlock
    )

    # Take my B64 string and do a Base64 to Byte array conversion of compressed data
    $ScriptBlockCompressed = [System.Convert]::FromBase64String($ScriptBlock)

    # Then decompress script's data
    $InputStream = New-Object System.IO.MemoryStream(, $ScriptBlockCompressed)
    $GzipStream = New-Object System.IO.Compression.GzipStream $InputStream, ([System.IO.Compression.CompressionMode]::Decompress)
    $StreamReader = New-Object System.IO.StreamReader($GzipStream)
    $ScriptBlockDecompressed = $StreamReader.ReadToEnd()
    # And close the streams
    $GzipStream.Close()
    $InputStream.Close()

    $ScriptBlockDecompressed
}


# For each scripts in the module, decompress and load it.

$ScriptList = @('Assemblies','Music', 'Helpers', 'MessageBox')
$ScriptList | ForEach-Object {
    $ScriptBlock = "`$ScriptBlock$($_)" | Invoke-Expression
    ConvertFrom-Base64CompressedScriptBlock -ScriptBlock $ScriptBlock | Invoke-Expression
}


$CurrentDir=Get-ScriptDirectory
$rootPath = $CurrentDir | split-path

Register-Assemblies | Out-Null



try{
    # Get Services
    $Fields = @(
        'Status'
        'DisplayName'
        'ServiceName'
    )
    $Services = Get-Service | Select $Fields
     
    # Add Services to a datatable
    $Datatable = New-Object System.Data.DataTable
    [void]$Datatable.Columns.AddRange($Fields)
    foreach ($Service in $Services)
    {
        $Array = @()
        Foreach ($Field in $Fields)
        {
            $array += $Service.$Field
        }
        [void]$Datatable.Rows.Add($array)
    }
     
    # Create a datagrid object and populate with datatable
    $DataGrid = New-Object System.Windows.Controls.DataGrid
    $DataGrid.ItemsSource = $Datatable.DefaultView
    $DataGrid.MaxHeight = 500
    $DataGrid.MaxWidth = 500
    $DataGrid.CanUserAddRows = $False
    $DataGrid.IsReadOnly = $True
    $DataGrid.GridLinesVisibility = "None"
     
    $Params = @{
        Content = $DataGrid
        Title = "Services on $Env:COMPUTERNAME"
        ContentBackground = "WhiteSmoke"
        FontFamily = "Tahoma"
        TitleFontWeight = "Heavy"
        TitleBackground = "LightSteelBlue"
        TitleTextForeground = "Black"
        ContentTextForeground = "DarkSlateGray"
    }
    Show-MessageBox @Params
}catch{
    Write-Host "`n[Error] " -nonewline -f DarkRed
    Write-Host " $_`n" -f DarkGray
}

