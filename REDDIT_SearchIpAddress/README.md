# REDDIT SUPPORT POST

[Reddit Link](https://www.reddit.com/r/PowerShell/comments/w3s0c2/changing_a_registry_value_dont_know_the_whole/)

```
Task I'm trying to accomplish: recurse a registry hive and change a value. I won't necessarily know the full path of the hive I'm recursing.
```


# SOLUTION

## __FIRST__

First, you need to _recursively_ go in a registry tree and find all occurences of the key/values with a specified KEYNAME (in this case, IP Address). For this, I have made the ```Get-EntriesRecursively``` function. You call like this

```
    Get-EntriesRecursively -Path $Path -Name 'IP Address'
```

This returns a list of object with {[Path], [Name], [Value]} like

```
Name                           IP Address
Path                           HKCU:\SOFTWARE\DevelopmentSandbox\TestSettings\ecc48b89
Value                          10.1.11.122
```


## __SECOND__

then, just loop in the list of key/values received from  ```Get-EntriesRecursively``` and change the property using ```Set-ItemProperty``` This is done in ```Update-IPs```

Change all ips
```
    $Path = "HKCU:\SOFTWARE\DevelopmentSandbox\TestSettings"
    Update-IPs -Path $Path -NewIP '1.1.1.1'
```

## __TEST__

### File: NewTestEntries.ps1

This script will add a bunch of entries in the registry path with IP Addresses. to test

```
    .\NewTestEntries.ps1 -StartRegEd

	PS> Root Path [HKCU:\SOFTWARE\DevelopmentSandbox\TestSettings]
	PS> + IP Address / 10.0.82.158              [\dcb55063\d3d4\4007]
	PS> + IP Address / 10.0.62.198              [\67f61386\7c50\4f27]
	PS> + IP Address / 192.168.102.80           [\7160e478\ac6d]
	PS> + IP Address / 192.168.103.42           [\2fe17cd6\93e4\4079]
	PS> + IP Address / 192.168.102.189          [\7f084a19\88a8\4d98\b1a9]
	PS> + IP Address / 192.168.6.124            [\e314bf61\b801\4887\a613]
	PS> + IP Address / 192.168.198.208          [\eb13e48f\b398]
	PS> + IP Address / 192.168.151.51           [\37faee73\db0d\406d\a876]
	PS> + IP Address / 10.0.73.142              [\3c7d4373]
	PS> + IP Address / 10.0.65.226              [\57744065\0968\4b16]
	PS>
	PS> + IPADDRESS ENTRIES : 10
	PS> + BOGUS ENTRIES : 64
	PS> + TOTAL ENTRIES : 79
```

![ADD TEST ENTRIES](https://github.com/arsscriptum/PowerShell.Sandbox/raw/main/REDDIT_SearchIpAddress/img/1.png)


### File SearchAndUpdateIP.ps1

Function "Get-EntriesRecursively" : Get the list of entries recursively from the registry
Function "Update-IPs" : Update all ip address to the same value.

![LIST ENTRIES](https://github.com/arsscriptum/PowerShell.Sandbox/raw/main/REDDIT_SearchIpAddress/img/2.png)


```
    . ./SearchAndUpdateIP.ps1
    $Path = "HKCU:\SOFTWARE\DevelopmentSandbox\TestSettings"
    Get-EntriesRecursively -Path $Path -Name 'IP Address'  -Verbose

    ... <10 entries after ran NewTestEntries>
```

![CHANGE ALL ENTRIES](https://github.com/arsscriptum/PowerShell.Sandbox/raw/main/REDDIT_SearchIpAddress/img/3.png)

Change all ips
```
    $Path = "HKCU:\SOFTWARE\DevelopmentSandbox\TestSettings"
    Update-IPs -Path $Path -NewIP '1.1.1.1' -Verbose
```

![VALIDATE CHANGES](https://github.com/arsscriptum/PowerShell.Sandbox/raw/main/REDDIT_SearchIpAddress/img/4.png)

