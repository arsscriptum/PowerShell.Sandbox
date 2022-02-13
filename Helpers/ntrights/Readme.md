# ntrights

## Groups

I use 2 groups for simplicity:

Unwelcomed and PowerDevs



ntrights.exe -u BCADD0260\DefaultAccount +r SeSystemtimePrivilege
ntrights.exe -u BCADD0260\DefaultAccount -r SeSystemtimePrivilege


===================================================================================
===================================================================================

### To deny, add the right (+r) to the Deny rights like this:
ntrights.exe -u BCADD0260\Unwelcomed +r SeDenyBatchLogonRight

SeDenyBatchLogonRight
SeDenyInteractiveLogonRight
SeDenyServiceLogonRight
SeDenyNetworkLogonRight
SeDenyRemoteInteractiveLogonRight

### To allow back, remove the flag on those groups
ntrights.exe -u BCADD0260\Unwelcomed -r SeDenyBatchLogonRight


### To allow a PowerDev group:

ntrights.exe -u BCADD0260\PowerDevs +r SeBatchLogonRight

SeBatchLogonRight
SeInteractiveLogonRight
SeServiceLogonRight
SeNetworkLogonRight
SeRemoteInteractiveLogonRight


===================================================================================
===================================================================================

### Logon Privileges:

 Log on as a batch job            SeBatchLogonRight
 Deny logon as a batch job    SeDenyBatchLogonRight
 Log on locally                   SeInteractiveLogonRight
 Deny local logon             SeDenyInteractiveLogonRight
 Logon as a service               SeServiceLogonRight
 Deny logon as a service      SeDenyServiceLogonRight
 Access this Computer from the Network         SeNetworkLogonRight
 Deny Access to this computer via network  SeDenyNetworkLogonRight
 Allow logon through RDP/Terminal Services     SeRemoteInteractiveLogonRight
 Deny logon through RDP/Terminal Services  SeDenyRemoteInteractiveLogonRight

### System Admin Privileges:

 Generate security audits         SeAuditPrivilege
 Manage auditing and security log SeSecurityPrivilege
 Backup files and directories     SeBackupPrivilege
 Create symbolic links            SeCreateSymbolicLinkPrivilege
 Add workstations to the domain   SeMachineAccountPrivilege
 Shut down the system             SeShutdownPrivilege
 Force shutdown from a remote system  SeRemoteShutdownPrivilege
 Create a pagefile                SeCreatePagefilePrivilege
 Increase quotas                  SeIncreaseQuotaPrivilege
 Restore files and directories    SeRestorePrivilege  
 Change the system time           SeSystemTimePrivilege
 Change the time zone             SeTimeZonePrivilege
 Take ownership of files/objects  SeTakeOwnershipPrivilege
 Enable computer/user accounts
   to be trusted for delegation       SeEnableDelegationPrivilege
 Remove computer from docking station SeUndockPrivilege

### Service Privileges:

 Create permanent shared objects  SeCreatePermanentPrivilege
 Create a token object            SeCreateTokenPrivilege
 Replace a process-level token    SeAssignPrimaryTokenPrivilege
 Impersonate a client after authentication  SeImpersonatePrivilege
 Increase scheduling priority     SeIncreaseBasePriorityPrivilege
 Act as part of the operating system   SeTcbPrivilege
 Profile a single process         SeProfileSingleProcessPrivilege
 Load and unload device drivers   SeLoadDriverPrivilege
 Lock pages in memory             SeLockMemoryPrivilege
 Create global objects            SeCreateGlobalPrivilege

### Misc Privileges:

 Debug programs                   SeDebugPrivilege
 Bypass traverse checking         SeChangeNotifyPrivilege
 Synch directory service data     SeSyncAgentPrivilege
 Edit firmware environment values SeSystemEnvironmentPrivilege
 Perform volume maintenance tasks SeManageVolumePrivilege
 Profile system performance       SeSystemProfilePrivilege
 Obsolete and unused              SeUnsolicitedInputPrivilege (has no effect)

### Other valid NTRights are:
  SeCreateTokenPrivilege
  SeAssignPrimaryTokenPrivilege
  SeLockMemoryPrivilege
  SeIncreaseQuotaPrivilege
  SeUnsolicitedInputPrivilege
  SeMachineAccountPrivilege
  SeTcbPrivilege
  SeSecurityPrivilege
  SeTakeOwnershipPrivilege
  SeLoadDriverPrivilege
  SeSystemProfilePrivilege
  SeSystemtimePrivilege
  SeProfileSingleProcessPrivilege
  SeIncreaseBasePriorityPrivilege
  SeCreatePagefilePrivilege
  SeCreatePermanentPrivilege
  SeBackupPrivilege
  SeRestorePrivilege
  SeShutdownPrivilege
  SeAuditPrivilege
  SeSystemEnvironmentPrivilege
  SeChangeNotifyPrivilege
  SeRemoteShutdownPrivilege

