# PowerShell Script with auto update

From the PowerShell forums at https://www.reddit.com/r/PowerShell/comments/vdgush/best_way_to_selfupdate_a_script/ where
a user is asking for help with a script that will auto update if new version is available.

## Implementation

Have the script hosted on a revision server, like GIT. In the script repository have a small text file with only the latest script version In your script, add the current script version number.

When you launch the script, you have the following argument available:

Argument -SkipVersionCheck ; no version check, run local script.

Argument -ForceUpdate : Update the script from server, no version check.

Argument -CheckUpdate : do a version check and exit

Argument -AcceptUpdate : automatically accept the update if a new version is available.

If the script detects that there's no internet connection available, it will print a warning and run the local script version, no update.

## Files

 - Version.nfo
 - TheScript.ps1

 