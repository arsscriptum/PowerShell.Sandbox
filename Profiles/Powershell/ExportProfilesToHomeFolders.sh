#!/bin/bash

echo -e "Exporting PowerShell Profiles"
current_path=`pwd`
myusername=`whoami`
myhomepath=/c/users/$myusername
if [ -n "$HOME" ]; then
  echo -e "Environment variable HOME is defined. Using $HOME"
  myhomepath=$HOME
else
  echo -e "Environment variable HOME is not defined."
  echo -e "Using default: $myhomepath"
fi

# $Home\[My ]Documents\WindowsPowerShell\Profile.ps1
# $home --> /c/Users/radic
custom_profile_filename=Profile.ps1
custom_profile_path=$myhomepath/Documents/WindowsPowerShell

echo -e "PRIVATE"
if [[ -r $custom_profile_path/$custom_profile_filename ]]
then
	 echo -e " found existing profile"
	 echo -e " deleting existing profile" 
	 rm -rf $custom_profile_path/$custom_profile_filename
	 cp $current_path/PrivateProfile.ps1 $custom_profile_path/$custom_profile_filename
	 echo -e " exporting new profile" 
	 echo -e " path: $custom_profile_path" 
else
	 echo -e " profile not found"
	 echo -e " exporting new profile" 
	 cp $current_path/PrivateProfile.ps1 $custom_profile_path/$custom_profile_filename
	 echo -e " path: $custom_profile_path" 
fi

# $PSHOME\Microsoft.PowerShell_profile.ps1
# $PSHOME --> C:\Windows\System32\WindowsPowerShell\v1.0

pshomepath=/c/Windows/System32/WindowsPowerShell/v1.0
if [ -n "$PSHOME" ]; then
  echo -e "Environment variable PSHOME is defined. Using $PSHOME"
  pshomepath=$PSHOME
else
  echo -e "Environment variable PSHOME is not defined."
  echo -e "Using default: $pshomepath"
fi

public_profile_path=/c/Windows/System32/WindowsPowerShell/v1.0
public_profile_filename=Profile.ps1

custom_profile_filename=$public_profile_filename
custom_profile_path=$public_profile_path

echo -e "PUBLIC"

if [[ -r $custom_profile_path/$custom_profile_filename ]]
then
	 echo -e " found existing profile"
	 echo -e " deleting existing profile" 
	 rm -rf $custom_profile_path/$custom_profile_filename
	 cp $current_path/PublicProfile.ps1 $custom_profile_path/$custom_profile_filename
	 echo -e " exporting new profile" 
	 echo -e " path: $custom_profile_path" 
else
	 echo -e " profile not found"
	 echo -e " exporting new profile" 
	 cp $current_path/PublicProfile.ps1 $custom_profile_path/$custom_profile_filename
	 echo -e " path: $custom_profile_path" 
fi