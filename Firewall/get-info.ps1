
Function Get-FireWallRule
{Param ($Name, $Direction, $Enabled, $Protocol, $profile, $action, $grouping)
$Rules=(New-object –comObject HNetCfg.FwPolicy2).rules
If ($name)      {$rules= $rules | where-object {$_.name     –like $name}}
If ($direction) {$rules= $rules | where-object {$_.direction  –eq $direction}}
If ($Enabled)   {$rules= $rules | where-object {$_.Enabled    –eq $Enabled}}
If ($protocol)  {$rules= $rules | where-object {$_.protocol  -eq $protocol}}
If ($profile)   {$rules= $rules | where-object {$_.Profiles -bAND $profile}}
If ($Action)    {$rules= $rules | where-object {$_.Action     -eq $Action}}
If ($Grouping)  {$rules= $rules | where-object {$_.Grouping -Like $Grouping}}
$rules}