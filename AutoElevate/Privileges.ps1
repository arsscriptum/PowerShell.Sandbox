$Target = "\\domain.net\myFolder"
$TempFolder = 'C:\TempFolder'
$TempFile = 'C:\TempFile'

#region Load super powers
$AdjustTokenPrivileges = @"
using System;
using System.Runtime.InteropServices;

 public class TokenManipulator
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
"@
Add-Type $AdjustTokenPrivileges
[void][TokenManipulator]::AddPrivilege("SeRestorePrivilege") 
[void][TokenManipulator]::AddPrivilege("SeBackupPrivilege") 
[void][TokenManipulator]::AddPrivilege("SeTakeOwnershipPrivilege") 
#endregion

$BuiltinAdmin = New-Object System.Security.Principal.NTAccount("BUILTIN\Administrators")
$BuiltinAdminFullControlAcl = New-Object System.Security.AccessControl.FileSystemAccessRule($BuiltinAdmin,"FullControl","Allow")

#region Create temp folder with Admin owner and full control
$FolderBuiltinAdminOwnerAcl = New-Object System.Security.AccessControl.DirectorySecurity
$FolderBuiltinAdminOwnerAcl.SetOwner($BuiltinAdmin)

Remove-Item $TempFolder -EA Ignore
New-Item -Type Directory -Path $TempFolder

$TempFolderAcl = Get-Acl -Path $TempFolder
$TempFolderAcl.SetAccessRule($BuiltinAdminFullControlAcl)
#endregion

#region Change folder owners to Admin
$Folders = @(Get-ChildItem -Path $Target -Directory -Recurse)

foreach ($Folder in $Folders) {
    $Folder.SetAccessControl($FolderBuiltinAdminOwnerAcl)
    Set-Acl -Path $Folder -AclObject $TempFolderAcl
}
#endregion

#region Create temp file with Admin owner and full control
$FileBuiltinAdminOwnerAcl = New-Object System.Security.AccessControl.FileSecurity
$FileBuiltinAdminOwnerAcl.SetOwner($BuiltinAdmin)

Remove-Item $TempFile -EA Ignore
New-Item -Type File -Path $TempFile

$TempFileAcl = Get-Acl -Path $TempFile
$TempFileAcl.SetAccessRule($BuiltinAdminFullControlAcl)
#endregion

#region Change file owners to Admin
$Files = @(Get-ChildItem -Path $Target -File -Recurse)

foreach ($File in $Files) {
    $File.SetAccessControl($FileBuiltinAdminOwnerAcl)
    Set-Acl -Path $File -AclObject $TempFileAcl
}
#endregion

#region Clean-up
Remove-Item $TempFile, $TempFolder
#endregion