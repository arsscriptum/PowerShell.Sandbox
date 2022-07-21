# REDDIT SUPPORT POST

[Reddit Link](https://www.reddit.com/r/PowerShell/comments/w3s0c2/changing_a_registry_value_dont_know_the_whole/)

Task I'm trying to accomplish: recurse a registry hive and change a value. I won't necessarily know the full path of the hive I'm recursing.


## PROPOSED SOLUTION

### NewTestEntries.ps1

This script will add a bunch of entries in the registry path with IP Addresses. to test

```

    . ./NewTestEntries.ps1

```


### SearchAndUpdateIP.ps1

Function "Get-EntriesRecursively" : Get the list of entries recursively from the registry
Function "Update-IPs" : Update all ip address to the same value.


```
    . ./SearchAndUpdateIP.ps1
    $Path = "HKCU:\SOFTWARE\DevelopmentSandbox\TestSettings"
    Get-EntriesRecursively -Path $Path -Name 'IP Address'

    ... <10 entries after ran NewTestEntries>
```

Change all ips
```
    $Path = "HKCU:\SOFTWARE\DevelopmentSandbox\TestSettings"
    Update-IPs -Path $Path -NewIP '1.1.1.1'
```