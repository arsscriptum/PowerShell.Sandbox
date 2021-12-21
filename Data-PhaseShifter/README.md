# **Data-PhaseShifter**
===========================================

Phase shifting, or phasing, is the process by which  files (or any data representation) can be placed out of phase from regular files which can cause effects ranging from disguise to invisibility. This brings advantages like appearing innocuous or invisible to bad actors.


## Genesis
I had the idea of a similar application by thinking about my data storage needs. I urgently needed to upload a large media file and share it to people. I don't have a Dropbox account, OneDrive, etc... and I will
get a membership to a cloud service, but I want to take my time to choose intelligently. The only reliable/quick and easy solution that was presenting to me was Github. Storing on github is a breeze, I have all my setup
already done and I can share along with a UI in Github pages if needed. The problem ? Github will not accept a commit including a large media file. It's a service for developer that are archiving source code and resources.
A pre-commit hook will check the file name, size and content for media similarities and deny the commit if not following guidelines.

Hence, the **Data-PhaseShifter**. This tool can take a large file, or group of files and transform the data in a format ressembling a c++ application project. The media binary data is transformed to text and divided and 
multiple different files containing that generated text.

***IMPORTANT NOTE***
Please note that, even if the ~~original requirement~~ I had was the reason I made the **Data-PhaseShifter**, it was an emergency and I quickly migrated my data to NordLocker (yes I chose Nord) after a day.
Github is not a place to store large media file, even if hidden using steganographic or phase shifting tools.

## Why ?


The reasons to use **Data-PhaseShifter** are the following:
+ Obvioulsy the main reason is the same as to why we use steganographic tools: to hide data in plain sight.
+ You want to transfer large files with more flexibility: having multiple file parts if useful to send via emails, use torrents, etc...
+ You want to have more security like dividing your large file or group of files in multiple groups each carried by a different person. Your data can only be recreated with the presence of all the participants.

## How ?

Identification of data to process ➤ Group the data in a single package (Compress-Archive)  ➤  Reformat the archive in BASE64 ➤ Following the user-provided guidelines, divide the packages in multiple files, keeping a single INDEX file use to recreate the archive.


## Usage

### Arguments

```
ConvertTo-PhaseShift 
      [-Path] <String[]>
      [-Exclude <String[]>]
      [-Recurse]
      [-PhaseShiftOptions <PhaseShiftParameters>]
      [-WhatIf]
      [-Output] <String>

ConvertFrom-PhaseShift 
      [-Path] <String>
      [-Output] <String>

```


#### -Path
Specifies the path of the locations of the new items. This is a string array representing files, directories to be processed
#### -Exclude
Specifies, as a string array, an item or items that this cmdlet excludes in the operation. The value of this parameter qualifies the Path parameter. Enter a path element or pattern, such as \*.txt. Wildcard characters are permitted. 

#### -Recurse
Indicates that this cmdlet process the items in the specified locations and in all child items of the locations.

#### -PhaseShiftOptions

#### -WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

#### -Output
Specifies the path where the processed data will be copied. This is always a directory, no a filename. To get more details on all the outputed files, see the result object.


## Examples

### Example 1
Will process a single file using the provided phase shift options, but with the '-WhatIf' argument, no data will be written on disk.
```
./ConvertTo-PhaseShifter -Path c:\Movies\GenieInABottle.avi -Type File -NoOp

```

### Example 2
Will process a directory and all the files in the sub folders (-Recurse). The generated obfustated data will be copied in c:\Users\Me\Documents. The user can get the operation results in details by reading the PSObject returned by the function.

```
./ConvertTo-PhaseShifter -Path c:\Vault -Type Directory -Recurse -PhaseShiftOptions $Opts -Output c:\Users\Me\Documents

```

## Inputs
None

You cannot pipe input to this cmdlet.

## Outputs
PS Object

This cmdlet generates a custom object with these keys that are self-explanatory:
+ OutputIndex
+ OutputFiles
+ SizeBefore
+ NumFilesBefore
+ SizeAfter
+ NumFilesAfter
+ ExitCode       
+ StdOut       
+ StdErr         
+ StopWatch



## Tasks List
-------------
- [ ] Add encryption in the data manipulation
- [ ] Add parity and ability to kep the archive validity even if one file is lost
- [ ] Add the '-Async' parameter that will instruct the script to return immediatly and process the data in a separate thread.

## Ideas and upcoming features
...