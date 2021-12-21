using System;
using System.Runtime.InteropServices;

 public class ___CLASS_NAME___
 {
  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
  internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall,
  ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);
  [DllImport("kernel32.dll", ExactSpelling = true)]
  internal static extern IntPtr GetCurrentProcess();
  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
  internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr
  phtok);
  [DllImport("advapi32.dll", SetLastError = true)]
  internal static extern bool LookupPrivilegeValue(string host, string name,
  ref long pluid);
  [StructLayout(LayoutKind.Sequential, Pack = 1)]
  internal struct TokPriv1Luid
  {
   public int Count;
   public long Luid;
   public int Attr;
  }
  internal const int SE_PRIVILEGE_DISABLED = 0x00000000;
  internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
  internal const int TOKEN_QUERY = 0x00000008;
  internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
  public const string CreateToken         = "SeCreateTokenPrivilege";
  public const string AssignPrimaryToken        = "SeAssignPrimaryTokenPrivilege"; 
  public const string LockMemory          = "SeLockMemoryPrivilege"; 
  public const string IncreaseQuota       = "SeIncreaseQuotaPrivilege";
  public const string UnsolicitedInput    = "SeUnsolicitedInputPrivilege"; 
  public const string MachineAccount      = "SeMachineAccountPrivilege";
  public const string TrustedComputingBase      = "SeTcbPrivilege";
  public const string Security      = "SeSecurityPrivilege";
  public const string TakeOwnership       = "SeTakeOwnershipPrivilege"; 
  public const string LoadDriver          = "SeLoadDriverPrivilege";
  public const string SystemProfile       = "SeSystemProfilePrivilege"; 
  public const string SystemTime          = "SeSystemtimePrivilege"; 
  public const string ProfileSingleProcess      = "SeProfileSingleProcessPrivilege";
  public const string IncreaseBasePriority      = "SeIncreaseBasePriorityPrivilege"; 
  public const string CreatePageFile      = "SeCreatePagefilePrivilege";
  public const string CreatePermanent     = "SeCreatePermanentPrivilege";
  public const string Backup        = "SeBackupPrivilege";
  public const string Restore       = "SeRestorePrivilege"; 
  public const string Shutdown      = "SeShutdownPrivilege";
  public const string Debug         = "SeDebugPrivilege"; 
  public const string Audit         = "SeAuditPrivilege"; 
  public const string SystemEnvironment         = "SeSystemEnvironmentPrivilege";
  public const string ChangeNotify        = "SeChangeNotifyPrivilege"; 
  public const string RemoteShutdown      = "SeRemoteShutdownPrivilege";
  public const string Undock        = "SeUndockPrivilege";
  public const string SyncAgent           = "SeSyncAgentPrivilege";
  public const string EnableDelegation    = "SeEnableDelegationPrivilege"; 
  public const string ManageVolume        = "SeManageVolumePrivilege";
  public const string Impersonate         = "SeImpersonatePrivilege"; 
  public const string CreateGlobal        = "SeCreateGlobalPrivilege"; 
  public const string TrustedCredentialManagerAccess  = "SeTrustedCredManAccessPrivilege";
  public const string ReserveProcessor    = "SeReserveProcessorPrivilege"; 
  public static bool AddPrivilege(string privilege)
  {
   try
   {
    bool retVal;
    TokPriv1Luid tp;
    IntPtr hproc = GetCurrentProcess();
    IntPtr htok = IntPtr.Zero;
    retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
    tp.Count = 1;
    tp.Luid = 0;
    tp.Attr = SE_PRIVILEGE_ENABLED;
    retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
    retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
    return retVal;
   }
   catch (Exception ex)
   {
    throw ex;
   }
  }
  public static bool RemovePrivilege(string privilege)
  {
   try
   {
    bool retVal;
    TokPriv1Luid tp;
    IntPtr hproc = GetCurrentProcess();
    IntPtr htok = IntPtr.Zero;
    retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
    tp.Count = 1;
    tp.Luid = 0;
    tp.Attr = SE_PRIVILEGE_DISABLED;
    retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
    retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
    return retVal;
   }
   catch (Exception ex)
   {
    throw ex;
   }
  }
 }