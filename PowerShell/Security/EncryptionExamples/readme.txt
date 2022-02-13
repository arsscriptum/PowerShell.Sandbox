These examples scripts demonstrate several ways to securely encrypt secret data in PowerShell.  The scripts are numbered in increasing order of complexity; I recommend starting with "1-SecureStrings-DPAPI.ps1" and working your way up from there.

Note:  Scripts 1-3 can be executed on PowerShell version 2.0, and have been tested there.  Script 4 technically works on PowerShell 2.0, but the AesCryptoServiceProvider class does not have a Dispose() method in that version of the .NET Framework.  Script 5 was written for the Scripting Games, where it was assumed that all scripts would be running the latest version of PowerShell.  It uses at least a few features that would only work in PowerShell 3.0 or later (such as the [pscustomobject] accelerator.)

1:  SecureStrings (DPAPI)

Many PowerShell cmdlets already allow you to create and work with SecureString objects.  SecureStrings are encrypted in memory, to prevent certain types of malicious attacks, but can be decrypted to their original values at any time.  In order to securely save a SecureString object's value, PowerShell gives us two cmdlets with basically idential methods:  ConvertFrom-SecureString and Export-CliXml.  In both cases, the default behavior is to use the Data Protection API (DPAPI) to encrypt the string.

DPAPI has been built into the Windows operating system since Windows 2000, and can be very handy for simple encryption needs.  Its main benefit is that you don't have to worry about generating or protecting encryption keys yourself; the OS does that for you.  When you use ConvertFrom-SecureString and ConvertTo-SecureString, you never even need to know the encryption algorithm that was used, let alone the keys.

The main drawback to DPAPI is that the encryption keys are associated with a single user (and in many cases, only on a single computer.)  Only the user who encrypted the data will ever be able to decrypt it, making DPAPI just about perfect for protecting your own information, but completely unsuitable for encrypting data that you intend to share with someone else.

2:  SecureStrings (AES)

ConvertTo-SecureString and ConvertFrom-SecureString have two optional parameters (-Key and -SecureKey) which allow you to specify your own AES encryption key, instead of using DPAPI to protect the string.  This allows you to share data with another user; so long as you both know the encryption key, you can both encrypt and decrypt the shared data.  However, now you need to figure out how to protect the encryption key itself; if it's exposed, the data may as well have been in plain text, because anyone can decrypt it.

The -Key parameter accepts arrays of bytes that are either 16, 24 or 32 bytes in length (128, 192 or 256 bits, which are the valid lengths for AES encryption keys.)  The -SecureKey parameter accepts the same number of bytes, but in the form of a SecureString object.  The 2-SecureStrings-AES.ps1 script demonstrates how you can randomly generate an AES key, use it to encrypt / decrypt SecureStrings, convert that raw byte array into a SecureString object, and use the SecureString the same way.  The advantage to the SecureKey parameter is that you can then protect your AES key with DPAPI for each user that needs to be able to read the shared data.  This puts most of the burden of protecting the AES key back on the operating system; the only time it might be exposed is while you're sharing it amongst your users and getting their DPAPI-protected versions of it set up.

3:  SecureStrings (AES and RSA)

Note:  In order to execute Scripts 3 through 5, you will require at least one RSA certificate in your personal store which is valid and for which you have the Private Key.

Script 3 demonstrates a more mature approach to data protection.  It uses a completely random AES key every time it encrypts a new piece of data, instead of a pre-shared key.  In order to allow the proper users to obtain the AES key and decrypt the secure data, it encrypts one or more copies of the AES key using public-key encryption (in this case, RSA certificates.)  By encrypting copies of the AES key with RSA public keys, you've ensured that only the person who has the certificate's private key will be able to read your data.  As before, we've accomplished the desirable effect of making the OS do the work of protecting our encryption keys, instead of having to try to keep them safe ourselves.

The person encrypting the data needs a copy of all of the target certificates (which would typically be in a store like "Trusted People"), but does not need their private keys.  Private keys are required to decrypt the data later.

Script 3 also begins to introduce the idea of being aware of sensitive data lying around in memory.  Instead of using ConvertTo-SecureString -AsPlainText -Force (which leaves the original decrypted String value in memory for some undetermined amount of time), it prompts you to enter some secret text with Read-Host -AsSecureString.  It uses try/finally blocks to make sure that the AES encryption key is not left in memory for longer than it is absolutely needed.

4:  Binary Data (AES and RSA)

Script 4 uses the same principles as Script 3:  Randomly generating an AES key to protect some data, encrypting copies of the AES key with one or more RSA certificates, and saving everything to disk.  The difference is that it saves the encrypted data in its raw binary form, instead of using a string representation.  This can come in handy when you want to encrypt an entire file, or when the data is large enough that displaying it as a string starts to take up an undesirable amount of space.

For simplicity's sake, this script saves the RSA-protected keys in a separate file from the encrypted data itself.  It is possible to put everything into the same file (as you'll see in script 5), but the code to read and write the file becomes a bit more complicated.  The purpose of Script 4 is mainly to introduce you to using .NET Streams (including the CryptoStream) with AES.  It also demonstrates the proper use of Disposable .NET objects from a PowerShell script.

5:  Bonus (2014 Winter Scripting Games event entry)

Script 5 is a complete example, from our entry for Event 2 of the 2014 Winter Scripting Games.  It uses the same techniques as Script 4 (.NET Streams, AES encryption, RSA protection of AES keys).  The difference is that this function puts the keys and encrypted data all into a single binary file, which is easier to transfer around and keeps disk space utilization to a minimum.

The code is not as heavily commented as the previous samples, but if you've been following along, there's not too much that's new.  It uses a new type of .NET stream wrapper (BinaryReader / BinaryWriter), and defines its own file structure consisting of a fixed header, record / byte counts, and raw binary data.  It also has error handling, which was left out of the previous examples to make the code more simple and easy to understand.

