
<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param(
        [Parameter(Mandatory=$false,Position=0)]
        [string]$Privilege

    )



function New-CustomAssembly{
    <#
        .SYNOPSIS
            Cmdlet to create a temporary assembly file (dll) with all the reference in it. Then include it in the script

        .EXAMPLE
            PS C:\>  
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, 
            HelpMessage="Assembly name") ]
        [string]$Source,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
            HelpMessage="Assembly name") ]
        [switch]$Dll
    )    
       
    $NewFile = (New-TemporaryFile).Fullname
    $NewDllPath = (Get-Item $NewFile).DirectoryName
    $NewDllName = (Get-Item $NewFile).Basename + '.dll'
    $NewDll = Join-Path $NewDllPath $NewDllName
    Rename-Item $NewFile $NewDll
    Remove-Item $NewDll -Force
    $CompilerOptions = '/unsafe'
    $OutputType = 'Library'
    Write-ChannelMessage "NewDll $NewDll"
    Write-ChannelMessage "CompilerOptions $CompilerOptions"
    Write-ChannelMessage "OutputType $OutputType"
   
    Try {
        if($Dll){
          $Result = Add-Type -TypeDefinition $Source -OutputAssembly $NewDll -OutputType $OutputType -PassThru  
        }
        else{
          $Result = Add-Type -TypeDefinition $Source -PassThru 
        }
        if(Test-Path $NewDll){
            return $NewDll
        }
        return $null
    }  
    Catch {
        Write-Error "Failed to create $NewDll"
    }    
}


function New-PrivilegeModifierAssembly{
    [CmdletBinding(SupportsShouldProcess)]
    param()

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
          //Console.WriteLine("[+] TokenManipulator::AddPrivilege '{0}' to process {1} : {2}", privilege, hproc,retVal);
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

  try{
    $Result = New-CustomAssembly $AdjustTokenPrivileges -Dll
    if($Result -eq $Null) { throw "Error on Dll creation" }
    Add-Type -LiteralPath "$Result" -ErrorAction Stop  
    Write-Host "Custom Type Added: $Result"
    return $true
  }
  catch{
    Write-Host "Custom Type initialisation error : $_"
    return $false
  }
  return $false
}


function Invoke-AutoElevate
{
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    #This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
        Write-Host "You didn't run this script as an Administrator." 
        Write-Host "This script will self elevate to run as an Administrator and continue." 
        Start-Sleep 1
        Write-Host "5, " -n -f DarkGreen;Start-Sleep 1;
        Write-Host "4, " -n -f DarkGreen;Start-Sleep 1;
        Write-Host "3, " -n -f DarkYellow;Start-Sleep 1;
        Write-Host "3, " -n -f DarkYellow;Start-Sleep 1;
        Write-Host "2, " -n -f DarkRed;Start-Sleep 1;
        Write-Host "1, " -n -f DarkRed;Start-Sleep 1;

        Start-Process pwsh.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit
    }
}
#Invoke-AutoElevate
#Invoke-AutoElevate

if(New-PrivilegeModifierAssembly){
  Write-Host "AddPrivilege: SeRestorePrivilege"
  $res = [void][TokenManipulator]::AddPrivilege("SeRestorePrivilege") 
  Write-Host "AddPrivilege: SeRestorePrivilege $res"
   $res = [void][TokenManipulator]::AddPrivilege("SeBackupPrivilege") 
  Write-Host "AddPrivilege: SeBackupPrivilege $res"
   $res = [void][TokenManipulator]::AddPrivilege("SeTakeOwnershipPrivilege") 
  Write-Host "AddPrivilege: SeTakeOwnershipPrivilege $res"
}
