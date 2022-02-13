#!/bin/bash

source ~/scripts/colors.sh


UnixTmp=`cygpath -u $LOCALAPPDATA`
IndexFileStdOut=$UnixTmp/Scripts/stdOutTempFile.txt
IndexFileStdErr=$UnixTmp/Scripts/stdErrTempFile.txt

TmpStdOutStream=""
TmpStdErrStream=""


function fn_title()
{
    echo -e "${TITLE}tailing - $@";
}

function fn_tailstdout() 
{ 
    fn_title "stdout file"

	if [ -f "$IndexFileStdOut" ]; then
	    echo -e "\n${BCyan} Found $IndexFileStdOut";
	    cat $IndexFileStdOut
	    TmpStdOutStream=`head -qn1 $IndexFileStdOut`

	    echo -e "\n${BRed} Stream is $TmpStdOutStream" ;
	    echo -e "\n${BYellow}############################" ;
	    echo -e "\n${BBlue}############################" ;
	    tail -f $TmpStdOutStream
	else 
	    echo "\n${BYellow}$IndexFileStdOut does not exist."
	fi
}

function fn_tailstderr() 
{ 
    fn_title "stderr file"
	if [ -f "$IndexFileStdErr" ]; then
	    echo -e "\n${BCyan} Found $IndexFileStdErr.";
	    TmpStdErrStream=`sed -n '1p' $IndexFileStdErr`
	    echo -e "\n${BRed}############################" ;
	    echo -e "\n${BYellow}############################" ;
	    echo -e "\n${BBlue}############################" ;
	    tail -f $TmpStdErrStream
	else 
	    echo "$IndexFileStdErr does not exist."
	fi
}



 #echo -e "######################"
 #echo -e "Do you want to tail the STD OUT file ? ( type yes )"
 #read sure
 #[ "$sure" != "yes" ] && echo "Not sure... Exiting" && return 1

fn_tailstdout

 #echo -e "######################"
 #echo -e "Do you want to tail the STD OUT file ? ( type yes )"
 #read sure
 #[ "$sure" != "yes" ] && echo "Not sure... Exiting" && return 1


#fn_tailstderr