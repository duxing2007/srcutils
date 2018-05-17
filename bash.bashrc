#!/bin/bash
#
#
#Remeber to add below line in ~/.bashrc
#   source ~/srcutils/bash.bashrc

export EDITOR=vi
export PATH=~/srcutils/bin/:$PATH
export GTAGSFORCECPP=""

#history config
HISTCONTROL=erasedups:ignorespace
HISTSIZE=9000
HISTFILESIZE=9000

#ls alias
alias ll='ls -clth'
alias ls='ls --group-directories-first --color=never'
alias cls='ack-grep -f --asm --cc --cpp'
alias jls='ack-grep -f --java'

#grep alias
alias grep='grep --color=never'
alias fgrep='fgrep --color=never'
alias egrep='egrep --color=never'
alias man='LC_MESSAGES=en_US.UTF-8 man'

alias svnst='svn status|grep  "\." | grep -v ".obj"'

function fname()
{
    find . -iname "*$@*"
}

function mkgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -type f \( -name '*.mk' -o -name Makefile -o -name Makefile.am \) -print0 | xargs -0 grep --color -n "$@"
}

function kgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -type f \( -name 'Kconfig*' -o -name Makefile -o -name Kbuild \) -print0 | xargs -0 grep --color -n "$@"
}

function jgrep()
{
    find . -name .repo -prune -o -name .git -prune -o  -type f -name "*\.java" -print0 | xargs -0 grep --color -n "$@"
}

function sgrep()
{
    find . -name .repo -prune -o -name .git -prune -o  -type f -iname "*\.S" -print0 | xargs -0 grep --color -n "$@"
}

function cgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -type f \( -name '*.c' -o -name '*.cc' -o -name '*.cpp' -o -name '*.h' -o -name '*.inl' -o -iname "*\.S" \) -print0 | xargs -0 grep --color -n "$@"
}

function resgrep()
{
    for dir in `find . -name .repo -prune -o -name .git -prune -o -name res -type d`; do find $dir -type f -name '*\.xml' -print0 | xargs -0 grep --color -n "$@"; done;
}

MY_CD_FILELIST="/data/godir_filelist"

function mycd()
{
	local lastarg=${!#}

	if [[ ! -d $lastarg ]]
	then
		return
	fi


	if [[ ! -f $MY_CD_FILELIST ]]
	then
		touch $MY_CD_FILELIST
	fi

	local mydir=$(readlink -f $lastarg)
	cd $*	
	if grep -q -x -F "$mydir" $MY_CD_FILELIST
	then
		return
	fi

	
	local maxnum=200
	local halfnum=$(($maxnum/2))
	local filenum=$(wc -l $MY_CD_FILELIST | cut -d' ' -f1)

	if [[ $filenum -ge $maxnum ]]
	then
		tail -$halfnum $MY_CD_FILELIST > /tmp/tmp_filelist
		mv /tmp/tmp_filelist $MY_CD_FILELIST
	fi

	echo $mydir >> $MY_CD_FILELIST
}

alias cd='mycd'

function godir () 
{
    if [[ -z "$1" ]]; then
        echo "Usage: godir <regex>"
        return
    fi
    local lines
    lines=($(grep "$1" $MY_CD_FILELIST |  sort | uniq))
    if [[ ${#lines[@]} = 0 ]]; then
        echo "Not found"
        return
    fi
    local pathname
    local choice
    if [[ ${#lines[@]} > 1 ]]; then
        while [[ -z "$pathname" ]]; do
            local index=1
            local line
            for line in ${lines[@]}; do
                printf "%6s %s\n" "[$index]" $line
                index=$(($index + 1))
            done
            echo
            echo -n "Select one: "
            unset choice
            read choice
            if [[ $choice -gt ${#lines[@]} || $choice -lt 1 ]]; then
                echo "Invalid choice"
                continue
            fi
            pathname=${lines[$(($choice-1))]}
        done
    else
        pathname=${lines[0]}
    fi
    cd $pathname
}


