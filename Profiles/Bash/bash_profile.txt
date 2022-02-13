
#-------------------------------------------------------------
# Source global definitions (if any)
#-------------------------------------------------------------


if [ -f /etc/bashrc ]; then
      . /etc/bashrc   # --> Read /etc/bashrc, if present.
fi

export BACKUP_PATH=~/backup
export HG_BACKUP_PATH=$BACKUP_PATH/hg
export HG_PROJECT_BACKUP_PATH=""

#-------------------------------------------------------------
# Some settings
#-------------------------------------------------------------

#set -o nounset     # These  two options are useful for debugging.
#set -o xtrace
alias debug="set -o nounset; set -o xtrace"

ulimit -S -c 0      # Don't want coredumps.
set -o notify
set -o noclobber
set -o ignoreeof


# Enable options:
shopt -s cdspell
shopt -s cdable_vars
shopt -s checkhash
shopt -s checkwinsize
shopt -s sourcepath
shopt -s no_empty_cmd_completion
shopt -s cmdhist
shopt -s histappend histreedit histverify
shopt -s extglob       # Necessary for programmable completion.

# Disable options:
shopt -u mailwarn
unset MAILCHECK        # Don't want my shell to warn me of incoming mail.


#-------------------------------------------------------------
# Greeting, motd etc. ...
#-------------------------------------------------------------

# Color definitions (taken from Color Bash Prompt HowTo).
# Some colors might look different of some terminals.
# For example, I see 'Bold Red' as 'orange' on my screen,
# hence the 'Green' 'BRed' 'Red' sequence I often use in my prompt.

#  0    black     COLOR_BLACK     0,0,0
#  1    red       COLOR_RED       1,0,0
#  2    green     COLOR_GREEN     0,1,0
#  3    yellow    COLOR_YELLOW    1,1,0
#  4    blue      COLOR_BLUE      0,0,1
#  5    magenta   COLOR_MAGENTA   1,0,1
#  6    cyan      COLOR_CYAN      0,1,1
#  7    white     COLOR_WHITE     1,1,1

set_red=`tput setaf 1`
set_green=`tput setaf 2`
set_yellow=`tput setaf 3`
set_blue=`tput setaf 4`
set_magenta=`tput setaf 5`
set_cyan=`tput setaf 6`
set_white=`tput setaf 7`

set_reset=`tput sgr0`

#   tput bold    # Select bold mode
#   tput dim     # Select dim (half-bright) mode
#   tput smul    # Enable underline mode
#   tput rmul    # Disable underline mode
#   tput rev     # Turn on reverse video mode
#   tput smso    # Enter standout (bold) mode
#   tput rmso    # Exit standout mode

set_bold=`tput bold`
set_dim=`tput dim`
set_smul=`tput smul`
set_rmul=`tput rmul`
set_rev=`tput rev`
set_smso=`tput smso`
set_rmso=`tput rmso`

# Normal Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
On_Green='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

NC="\e[m"               # Color Reset

TITLE3=${BRed}${On_Blue}
TITLE4=${BWhite}${On_Blue} 
TITLE5=${BWhite}${On_Purple}
 
TITLE=${BCyan}${On_Black} 
ALERT=${BWhite}${On_Red}
ERROR=${BRed}${On_Black}

#============================================================
#
#  ALIASES AND FUNCTIONS
#
#  Arguably, some functions defined here are quite big.
#  If you want to make this file smaller, these functions can
#+ be converted into scripts and removed from here.
#
#============================================================

#-------------------
# Personnal Aliases
#-------------------

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
# -> Prevents accidentally clobbering files.
alias mkdir='mkdir -p'

alias h='history'
alias j='jobs -l'
alias which='type -a'
alias ..='cd ..'

# Pretty-print of some PATH variables:
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'


alias du='du -kh'    # Makes a more readable output.
alias df='df -kTh'

#-------------------------------------------------------------
# The 'ls' family (this assumes you use a recent GNU ls).
#-------------------------------------------------------------
# Add colors for filetype and  human-readable sizes by default on 'ls':
alias ls='ls -h --color'
alias lx='ls -lXB'         #  Sort by extension.
alias lk='ls -lSr'         #  Sort by size, biggest last.
alias lt='ls -ltr'         #  Sort by date, most recent last.
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.
alias lu='ls -ltur'        #  Sort by/show access time,most recent last.

# The ubiquitous 'll': directories first, with alphanumeric sorting:
alias ll="ls -lv --group-directories-first"
alias lm='ll |more'        #  Pipe through 'more'
alias lr='ll -R'           #  Recursive ls.
alias la='ll -A'           #  Show hidden files.
alias tree='tree -Csuh'    #  Nice alternative to 'recursive ls' ...

#-------------------------------------------------------------
# Mercurial command alias and function in bash
# Guillaume Plante <gplante@bodycad.com>
#-------------------------------------------------------------

function hgtitle()
{
    echo -n -e "${TITLE}mercurial - $@";
}

function is_valid_repo()
{
      is_abort=`hg id 2>&1 | cut -c 1-5`
      [[ "$is_abort" =~ abort ]] && return 0
      return 1
}

function hg_get_id()
{
    id=`hg id -b -t`
    id=${id// /_}
    eval "$1=$id"
}


function accept_mine()
{
    # test if valid repo
    hgtest ; [[ $? -eq 0 ]] && return 1
    hgtitle "mercurial - merge - accept remote (theirs)"

    echo -e "\nresolving all conflicts..."

    hg resolve -t internal:local --all
}


function accept_theirs()
{
    # test if valid repo
    hgtest ; [[ $? -eq 0 ]] && return 1
    hgtitle "mercurial - merge - accept remote (theirs)"

    echo -e "\nresolving all conflicts..."

    hg resolve -t internal:other --all
}

function hg_setup_backup() 
{ 
    current_id=""
    hg_get_id current_id
    export HG_PROJECT_BACKUP_PATH=$HG_BACKUP_PATH/$current_id
    if [ ! -d $BACKUP_PATH ]; then
        mkdir -p $BACKUP_PATH
    fi
    if [ ! -d $HG_BACKUP_PATH ]; then
        mkdir -p $HG_BACKUP_PATH
    fi
    if [ ! -d $HG_PROJECT_BACKUP_PATH ]; then
        mkdir -p $HG_PROJECT_BACKUP_PATH
    fi 
}

function hgtest() 
{ 
    # check if we are in a valid hg repo
    if is_valid_repo ; then echo -e "$ERROR not a mercurial repo!" 
        return 0
    else
        hg_setup_backup
        return 1
    fi
}

function hgpurge() 
{ 
    # test if valid repo
    hgtest ; [[ $? -eq 0 ]] && return 1
    hgtitle "purge"

    currentdir=`pwd`
    
    echo -e "\n${BRed}list of untracked files: $NC"
    hg st -un $currentdir | awk 'NF { print "\t >>> "$0""}'
    if ask "\n${BRed}do you want to delete untracked files? $NC"
        then
            secs=`date +%s`
            backup_path=$HG_PROJECT_BACKUP_PATH/purge$secs
            mkdir -p $backup_path
            hg st -un0 | xargs -0 -i cp {} $backup_path;
            hg st -un0 | xargs -0 -i rm -rf {};
    fi  
}

function hgs() 
{ 
       # test if valid repo
    hgtest ; [[ $? -eq 0 ]] && return 1
    hgtitle "status"

    echo -e "\n${BCyan}modified files $NC" ; hg st -m | awk 'NF { print "\t >>> "$0""}'
    echo -e "\n${BYellow}added files $NC" ; hg st -a | awk 'NF { print "\t >>> "$0""}'
    echo -e "\n${BRed}deleted files $NC" ; hg st -d | awk 'NF { print "\t >>> "$0""}'
    echo -e "\n${BBlue}untracked files $NC" ; hg st -un | awk 'NF { print "\t >>> "$0""}'
}

function hglog()
{
    username=`whoami`
    branch_name=`hg branch`

    if [ -z "$1" ]
    then
      echo -e "${set_bold}${set_red}error: missing parameter -> days${set_reset}\n"
      
      echo -e "${set_bold}${set_yellow}hglog:\tget changes from the last X days from a specified user.${set_reset}\n"
      echo -e "${set_yellow}Usage:\thglog <num days> <username> <branch>${set_reset}"
      echo -e "${set_yellow}\t<num days>: A number representing the number of days from today.${set_reset}"
      echo -e "${set_yellow}\t<username>: The username from which the changes were made (optional).${set_reset}"
      echo -e "${set_yellow}\t            if blank, we get the changes from the current user ($username).${set_reset}"
      echo -e "${set_yellow}\t<branch>:   The branch name. (optional).${set_reset}"
      echo -e "${set_yellow}\t            if blank, we get the changes from the current branch ($branch_name).${set_reset}\n"
      return -1
    fi    

    logdaysago=$1

    if [ "$2" ]
    then
      username=$2
    fi

    if [ "$3" ]
    then
      branch_name=$3
    fi    
    
    logdate=`date --date="$logdaysago days ago" +%Y-%m-%d`

    echo -e "${set_yellow}${set_bold}\nGetting changes from ${set_white}$username${set_yellow} since ${set_white}$logdate${set_yellow}. Branch ${set_white}$branch_name${set_yellow}.\n"
    echo -e "${set_cyan}"
    hg log -r"date('>$logdate') and branch('$branch_name') and user('$username')" 
    echo -e "${set_reset}"
}

function hgclosebranch()
{
    if [ -z "$1" ]
    then
      echo -e "missing paramweter -> branch name"
      return -1
    fi    

    branchname=$1

    # test if valid repo
    hgtest ; [[ $? -eq 0 ]] && return 1
    hgtitle "closing branch $branchname"

    echo -e "updating..."
    hg up -C "$branchname"
    if [ $? -eq 0 ]; then
        echo "$branchname is up"
    else
        echo "branch not found, please recheck your argument"
        return 1
    fi 

    echo -e "######################"
    echo -e "!!!CLOSING A BRANCH!!!"
    echo -e "Are you REALLY SURE DUDE ??? ( type yes )"
    read sure
    [ "$sure" != "yes" ] && echo "Not sure... Exiting" && return 1

    # if we are here then the branch is up, so we do the following
    hg commit --close-branch -m 'this branch no longer required' 
    echo "$branchname is closed"
    hg up -C default
    echo "default is up" 
}


function hgmergedefault()
{
    if [ -z "$1" ]
    then
      echo -e "missing paramweter -> branch name"
      return -1
    fi    

    branchname=$1

    # test if valid repo
    hgtest ; [[ $? -eq 0 ]] && return 1
    hgtitle "merging default in $branchname"

    echo -e "updating..."
    hg up -C "$branchname"
    if [ $? -eq 0 ]; then
        echo "$branchname is up"
    else
        echo "branch not found, please recheck your argument"
        return 1
    fi 

    hg merge default

    # if we are here then the branch is up, so we do the following
    hg commit -m 'merge default branch' 
    echo "default merged in $branchname"
    
    hg push -b $branchname
}


function hgstrip()
{
    echo -e "####################################"
    echo -e "!!!STRIPPING ALL OUTGOING CHANGES!!!"
    echo -e "Are you REALLY SURE DUDE ??? ( type yes )"
    read sure
    [ "$sure" != "yes" ] && echo "Not sure... Exiting" && return 1
    echo "Ok ... Stripping..."
    hg strip 'roots(outgoing())'
}


function git-send() 
{ 
    echo -e "####################################"
    echo -e " git-send: commit and git push"
    echo -e "Are you sure ( type y )"
    read sure
    [ "$sure" != "y" ] && echo "Not sure... Exiting" && return 1
    echo "Ok ..."
    git commit -a -m "update"
    git push
}

alias hgd='hg vdiff'

alias hgl='hg log -b "propriete intellectuelle" | grep changeset'

alias hgserver='ssh bcadlx05'

#-------------------------------------------------------------
# Tailoring 'less'
#-------------------------------------------------------------

alias more='less'
export PAGER=less
export LESSCHARSET='latin1'
export LESSOPEN='|/usr/bin/lesspipe.sh %s 2>&-'
                # Use this if lesspipe.sh exists.
export LESS='-i -N -w  -z-4 -g -e -M -X -F -R -P%t?f%f \
:stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'

# LESS man page colors (makes Man pages more readable).
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'


#-------------------------------------------------------------
# Spelling typos - highly personnal and keyboard-dependent :-)
#-------------------------------------------------------------

alias xs='cd'
alias vf='cd'
alias moer='more'
alias moew='more'
alias kk='ll'

alias ls_ext="find . -type f -name '*.*' | sed 's|.*\.||' | sort -u"


#-------------------------------------------------------------
# File & strings related functions:
#-------------------------------------------------------------

# Find a file with a pattern in name with minimum information
function ff() { find . -type f -name '*'"$*"'*'; }

# Find a file with specific pattern
function ffp() { find . -type f -name "$*"; }

# Find a file with specific pattern
function ffo() { find . -type f -name '*'"$*"'*' | xargs subl ; }

# Find a file with a pattern in name and print full information:
function ffi() { find . -type f -name '*'"$*"'*' -ls ; }

# Find a file with pattern $1 in name and Execute $2 on it:
function fe() { find . -type f -name '*'"${1:-}"'*' \
-exec ${2:-file} {} \;  ; }

function listqml() { find . -type f -name "*.qml" | awk '/QmlScripts/' | awk '!/x64/' ; }

#  Find a pattern in a set of files and highlight them:
#+ (needs a recent version of egrep).
function fstr()
{
    OPTIND=1
    local mycase=""
    local usage="fstr: find string in files.
Usage: fstr [-i] \"pattern\" [\"filename pattern\"] "
    while getopts :it opt
    do
        case "$opt" in
           i) mycase="-i " ;;
           *) echo "$usage"; return ;;
        esac
    done
    shift $(( $OPTIND - 1 ))
    if [ "$#" -lt 1 ]; then
        echo "$usage"
        return;
    fi
    find . -type f -name "${2:-*}" -print0 | \
xargs -0 egrep --color=always -sn ${case} "$1" 2>&- | more

}


function swap()
{ # Swap 2 filenames around, if they exist (from Uzi's bashrc).
    local TMPFILE=tmp.$$

    [ $# -ne 2 ] && echo "swap: 2 arguments needed" && return 1
    [ ! -e $1 ] && echo "swap: $1 does not exist" && return 1
    [ ! -e $2 ] && echo "swap: $2 does not exist" && return 1

    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}

function extract()      # Handy Extract Program
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.rar)       unrar x $1      ;;
            *.gz)        gunzip $1       ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress $1   ;;
            *.7z)        7z x $1         ;;
            *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}


# Creates an archive (*.tar.gz) from given directory.
function maketar() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }

# Create a ZIP archive of a file or folder.
function makezip() { zip -r "${1%%/}.zip" "$1" ; }

# Make your directories and files access rights sane.
function sanitize() { chmod -R u=rwX,g=rX,o= "$@" ;}

function hcommit() {  cat ~/.bash_history | grep commit; }

#-------------------------------------------------------------
# Process/system related functions:
#-------------------------------------------------------------


### function my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ; }
### function pp() { my_ps f | awk '!/awk/ && $0~var' var=${1:-".*"} ; }


### function killps()   # kill by process name
### {
###     local pid pname sig="-TERM"   # default signal
###     if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
###         echo "Usage: killps [-SIGNAL] pattern"
###         return;
###     fi
###     if [ $# = 2 ]; then sig=$1 ; fi
###     for pid in $(my_ps| awk '!/awk/ && $0~pat { print $1 }' pat=${!#} )
###     do
###         pname=$(my_ps | awk '$1~var { print $5 }' var=$pid )
###         if ask "Kill process $pid <$pname> with signal $sig?"
###             then kill $sig $pid
###         fi
###     done
### }

### function mydf()         # Pretty-print of 'df' output.
### {                       # Inspired by 'dfc' utility.
###     for fs ; do
### 
###         if [ ! -d $fs ]
###         then
###           echo -e $fs" :No such file or directory" ; continue
###         fi
### 
###         local info=( $(command df -P $fs | awk 'END{ print $2,$3,$5 }') )
###         local free=( $(command df -Pkh $fs | awk 'END{ print $4 }') )
###         local nbstars=$(( 20 * ${info[1]} / ${info[0]} ))
###         local out="["
###         for ((j=0;j<20;j++)); do
###             if [ ${j} -lt ${nbstars} ]; then
###                out=$out"*"
###             else
###                out=$out"-"
###             fi
###         done
###         out=${info[2]}" "$out"] ("$free" free on "$fs")"
###         echo -e $out
###     done
### }


### function my_ip() # Get IP adress on ethernet.
### {
###     MY_IP=$(/sbin/ifconfig eth0 | awk '/inet/ { print $2 } ' |
###       sed -e s/addr://)
###     echo ${MY_IP:-"Not connected"}
### }
### 
### function ii()   # Get current host related info.
### {
###     echo -e "\nYou are logged on ${BRed}$HOST"
###     echo -e "\n${BRed}Additionnal information:$NC " ; uname -a
###     echo -e "\n${BRed}Users logged on:$NC " ; w -hs |
###              cut -d " " -f1 | sort | uniq
###     echo -e "\n${BRed}Current date :$NC " ; date
###     echo -e "\n${BRed}Machine stats :$NC " ; uptime
###     echo -e "\n${BRed}Memory stats :$NC " ; free
###     echo -e "\n${BRed}Diskspace :$NC " ; mydf / $HOME
###     echo -e "\n${BRed}Local IP Address :$NC" ; my_ip
###     echo -e "\n${BRed}Open connections :$NC "; netstat -pan --inet;
###     echo
### }

#-------------------------------------------------------------
# Misc utilities:
#-------------------------------------------------------------

function repeat()       # Repeat n times command.
{
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do  # --> C-like syntax
        eval "$@";
    done
}


function ask()          # See 'killps' for example of use.
{
    echo -n -e "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

function corename()   # Get name of app that created a corefile.
{
    for file ; do
        echo -n $file : ; gdb --core=$file --batch | head -1
    done
}

function example()
{
    local filename=$1.txt
    local examplepath=~/Documents/Examples
    local filepath=$examplepath/$filename

    if [ -f "$filepath" ]; then
        echo ""
        cat $filepath
        echo ""
    else 
        echo "example: $filename does not exist. Add it to the $examplepath directory."
    fi
}


#=========================================================================
#
#  PROGRAMMABLE COMPLETION SECTION
#  Most are taken from the bash 2.05 documentation and from Ian McDonald's
# 'Bash completion' package (http://www.caliban.org/bash/#completion)
#  You will in fact need bash more recent then 3.0 for some features.
#
#  Note that most linux distributions now provide many completions
# 'out of the box' - however, you might need to make your own one day,
#  so I kept those here as examples.
#=========================================================================

if [ "${BASH_VERSION%.*}" \< "3.0" ]; then
    echo "You will need to upgrade to version 3.0 for full \
          programmable completion features"
    return
fi

shopt -s extglob        # Necessary.

complete -A hostname   rsh rcp telnet rlogin ftp ping disk
complete -A export     printenv
complete -A variable   export local readonly unset
complete -A enabled    builtin
complete -A alias      alias unalias
complete -A function   function
complete -A user       su mail finger

complete -A helptopic  help     # Currently same as builtins.
complete -A shopt      shopt
complete -A stopped -P '%' bg
complete -A job -P '%'     fg jobs disown

complete -A directory  mkdir rmdir
complete -A directory   -o default cd

# Compression
complete -f -o default -X '*.+(zip|ZIP)'  zip
complete -f -o default -X '!*.+(zip|ZIP)' unzip
complete -f -o default -X '*.+(z|Z)'      compress
complete -f -o default -X '!*.+(z|Z)'     uncompress
complete -f -o default -X '*.+(gz|GZ)'    gzip
complete -f -o default -X '!*.+(gz|GZ)'   gunzip
complete -f -o default -X '*.+(bz2|BZ2)'  bzip2
complete -f -o default -X '!*.+(bz2|BZ2)' bunzip2
complete -f -o default -X '!*.+(zip|ZIP|z|Z|gz|GZ|bz2|BZ2)' extract


# Documents - Postscript,pdf,dvi.....
complete -f -o default -X '!*.+(ps|PS)'  gs ghostview ps2pdf ps2ascii
complete -f -o default -X \
'!*.+(dvi|DVI)' dvips dvipdf xdvi dviselect dvitype
complete -f -o default -X '!*.+(pdf|PDF)' acroread pdf2ps
complete -f -o default -X '!*.@(@(?(e)ps|?(E)PS|pdf|PDF)?\
(.gz|.GZ|.bz2|.BZ2|.Z))' gv ggv
complete -f -o default -X '!*.texi*' makeinfo texi2dvi texi2html texi2pdf
complete -f -o default -X '!*.tex' tex latex slitex
complete -f -o default -X '!*.lyx' lyx
complete -f -o default -X '!*.+(htm*|HTM*)' lynx html2ps
complete -f -o default -X \
'!*.+(doc|DOC|xls|XLS|ppt|PPT|sx?|SX?|csv|CSV|od?|OD?|ott|OTT)' soffice

# Multimedia
complete -f -o default -X \
'!*.+(gif|GIF|jp*g|JP*G|bmp|BMP|xpm|XPM|png|PNG)' xv gimp ee gqview
complete -f -o default -X '!*.+(mp3|MP3)' mpg123 mpg321
complete -f -o default -X '!*.+(ogg|OGG)' ogg123
complete -f -o default -X \
'!*.@(mp[23]|MP[23]|ogg|OGG|wav|WAV|pls|\
m3u|xm|mod|s[3t]m|it|mtm|ult|flac)' xmms
complete -f -o default -X '!*.@(mp?(e)g|MP?(E)G|wma|avi|AVI|\
asf|vob|VOB|bin|dat|vcd|ps|pes|fli|viv|rm|ram|yuv|mov|MOV|qt|\
QT|wmv|mp3|MP3|ogg|OGG|ogm|OGM|mp4|MP4|wav|WAV|asx|ASX)' xine



complete -f -o default -X '!*.pl'  perl perl5


#  This is a 'universal' completion function - it works when commands have
#+ a so-called 'long options' mode , ie: 'ls --all' instead of 'ls -a'
#  Needs the '-o' option of grep
#+ (try the commented-out version if not available).

#  First, remove '=' from completion word separators
#+ (this will allow completions like 'ls --color=auto' to work correctly).

COMP_WORDBREAKS=${COMP_WORDBREAKS/=/}


_get_longopts()
{
  #$1 --help | sed  -e '/--/!d' -e 's/.*--\([^[:space:].,]*\).*/--\1/'| \
  #grep ^"$2" |sort -u ;
    $1 --help | grep -o -e "--[^[:space:].,]*" | grep -e "$2" |sort -u
}

_longopts()
{
    local cur
    cur=${COMP_WORDS[COMP_CWORD]}

    case "${cur:-*}" in
       -*)      ;;
        *)      return ;;
    esac

    case "$1" in
       \~*)     eval cmd="$1" ;;
         *)     cmd="$1" ;;
    esac
    COMPREPLY=( $(_get_longopts ${1} ${cur} ) )
}
complete  -o default -F _longopts configure bash
complete  -o default -F _longopts wget id info a2ps ls recode

_tar()
{
    local cur ext regex tar untar

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

    # If we want an option, return the possible long options.
    case "$cur" in
        -*)     COMPREPLY=( $(_get_longopts $1 $cur ) ); return 0;;
    esac

    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( $( compgen -W 'c t x u r d A' -- $cur ) )
        return 0
    fi

    case "${COMP_WORDS[1]}" in
        ?(-)c*f)
            COMPREPLY=( $( compgen -f $cur ) )
            return 0
            ;;
        +([^Izjy])f)
            ext='tar'
            regex=$ext
            ;;
        *z*f)
            ext='tar.gz'
            regex='t\(ar\.\)\(gz\|Z\)'
            ;;
        *[Ijy]*f)
            ext='t?(ar.)bz?(2)'
            regex='t\(ar\.\)bz2\?'
            ;;
        *)
            COMPREPLY=( $( compgen -f $cur ) )
            return 0
            ;;

    esac

    if [[ "$COMP_LINE" == tar*.$ext' '* ]]; then
        # Complete on files in tar file.
        #
        # Get name of tar file from command line.
        tar=$( echo "$COMP_LINE" | \
                        sed -e 's|^.* \([^ ]*'$regex'\) .*$|\1|' )
        # Devise how to untar and list it.
        untar=t${COMP_WORDS[1]//[^Izjyf]/}

        COMPREPLY=( $( compgen -W "$( echo $( tar $untar $tar \
                                2>/dev/null ) )" -- "$cur" ) )
        return 0

    else
        # File completion on relevant files.
        COMPREPLY=( $( compgen -G $cur\*.$ext ) )

    fi

    return 0

}

complete -F _tar -o default tar

_make()
{
    local mdef makef makef_dir="." makef_inc gcmd cur prev i;
    COMPREPLY=();
    cur=${COMP_WORDS[COMP_CWORD]};
    prev=${COMP_WORDS[COMP_CWORD-1]};
    case "$prev" in
        -*f)
            COMPREPLY=($(compgen -f $cur ));
            return 0
            ;;
    esac;
    case "$cur" in
        -*)
            COMPREPLY=($(_get_longopts $1 $cur ));
            return 0
            ;;
    esac;

    # ... make reads
    #          GNUmakefile,
    #     then makefile
    #     then Makefile ...
    if [ -f ${makef_dir}/GNUmakefile ]; then
        makef=${makef_dir}/GNUmakefile
    elif [ -f ${makef_dir}/makefile ]; then
        makef=${makef_dir}/makefile
    elif [ -f ${makef_dir}/Makefile ]; then
        makef=${makef_dir}/Makefile
    else
       makef=${makef_dir}/*.mk         # Local convention.
    fi


    #  Before we scan for targets, see if a Makefile name was
    #+ specified with -f.
    for (( i=0; i < ${#COMP_WORDS[@]}; i++ )); do
        if [[ ${COMP_WORDS[i]} == -f ]]; then
            # eval for tilde expansion
            eval makef=${COMP_WORDS[i+1]}
            break
        fi
    done
    [ ! -f $makef ] && return 0

    # Deal with included Makefiles.
    makef_inc=$( grep -E '^-?include' $makef |
                 sed -e "s,^.* ,"$makef_dir"/," )
    for file in $makef_inc; do
        [ -f $file ] && makef="$makef $file"
    done


    #  If we have a partial word to complete, restrict completions
    #+ to matches of that word.
    if [ -n "$cur" ]; then gcmd='grep "^$cur"' ; else gcmd=cat ; fi

    COMPREPLY=( $( awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ \
                               {split($1,A,/ /);for(i in A)print A[i]}' \
                                $makef 2>/dev/null | eval $gcmd  ))

}

complete -F _make -X '+($*|*.[cho])' make gmake pmake


_killall()
{
    local cur prev
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

    #  Get a list of processes
    #+ (the first sed evaluation
    #+ takes care of swapped out processes, the second
    #+ takes care of getting the basename of the process).
    COMPREPLY=( $( ps -u $USER -o comm  | \
        sed -e '1,1d' -e 's#[]\[]##g' -e 's#^.*/##'| \
        awk '{if ($0 ~ /^'$cur'/) print $0}' ))

    return 0
}

cdhelp()
{
    echo "alias ex='$explorer_path `pwd`'"
    echo "alias dev='cd $DevelopmentRoot'"
    echo "alias code='cd $DevelopmentRoot'"
    echo "alias bcad='cd $BodycadDevMain'"
    echo "alias bcadgp='cd $BodycadDevBranch'"
    echo "alias logdir='cd $APPDATA/../Local/Temp/Bodycad/'"
    echo "alias scripts='cd $ScriptsRoot'"
    echo "alias tools='cd $ToolsRoot'"
    echo "alias radsrc='cd $RadicalRoot'"
    echo "alias goto1='cd $RadicalRoot/procmgr'"
    echo "alias gotools='cd /e/d/tools-development'"
    echo "alias home='cd ~'"
}

helpcd()
{
    cdhelp
}

callexplorer()
{
   
    explorer_path=`where explorer`
    currentpath=`pwd`
    winpath=`cygpath -w $currentpath`
    echo -e "${set_bold}${set_red}opening explorer in $winpath${set_reset}"
    $explorer_path $winpath
}

complete -F _killall killall killps


# shell options
# Toggle the values of settings controlling optional shell behavior
# failglob: If set, patterns which fail to match filenames during filename expansion result in an expansion error.
shopt -s failglob

# QT Environment variables
export CMAKE_PREFIX_PATH=/e/Code/Bodycad/external/Qt5124/msvc2015_64
export Qt5_DIR=/e/Code/Bodycad/external/Qt5124/msvc2015_64


#########################################################################################
#########################################################################################

# Update system path, add Scripts directory and sublime text path
export PATH=$PATH:$PSToolsRoot:$HelpersRoot
export toolsroot=/d/Scripts
export toolspath=/d/Scripts

explorer_path=`where explorer`

alias ex='callexplorer'
alias dev='cd $DevelopmentRoot'
alias code='cd $DevelopmentRoot'
alias bcad='cd $BodycadDevMain'
alias bcadgp='cd $BodycadDevBranch'
alias logdir='cd $APPDATA/../Local/Temp/Bodycad/'
alias scripts='cd $ScriptsRoot'
alias tools='cd $ToolsRoot'
alias radsrc='cd $RadicalRoot'
alias goto1='cd $RadicalRoot'
alias home='cd ~'

echo "${set_bold}${set_magenta}-----------------------------------------${set_reset}"
echo "${set_bold}${set_red}bash shell - current user: $USERNAME${set_reset}"
echo "${set_bold}${set_yellow}"
date
echo -e "${set_bold}${set_red}useful env variables${set_reset}"
echo -e "   SystemScriptsPath = ${set_bold}${set_yellow}$SystemScriptsPath${set_reset}"
echo -e "   ScreenshotFolder = ${set_bold}${set_yellow}$ScreenshotFolder${set_reset}"
echo -e "   DevelopmentRoot = ${set_bold}${set_yellow}$DevelopmentRoot${set_reset}"
echo -e "   BodycadDevMain = ${set_bold}${set_yellow}$BodycadDevMain${set_reset}"
echo -e "   BodycadDevBranch = ${set_bold}${set_yellow}$BodycadDevBranch${set_reset}"
echo -e "   ScriptsRoot = ${set_bold}${set_yellow}$ScriptsRoot${set_reset}"
echo -e "   wwwroot = ${set_bold}${set_yellow}$wwwroot${set_reset}"
echo -e "${set_bold}${set_red}commands${set_reset}"
echo -e "   dev, code = ${set_bold}${set_yellow}go in dev dir${set_reset}"
echo -e "   bcad, bcadgp = ${set_bold}${set_yellow}bcad path${set_reset}"
echo -e "   steps = ${set_bold}${set_yellow}go to steps designer${set_reset}"

alias subl='/c/Program\ Files/Sublime\ Text\ 3/subl.exe'

# Local Variables:
# mode:shell-script
# sh-shell:bash
# End: