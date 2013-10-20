#!/bin/bash
#
#Generate all "C" tags in "C"allee files has been called in "C"aller files
#
#def2ref.sh definition_files... -- reference_files...
#

callee_files=()
caller_files=()
used_tags=()
tags_fname=/tmp/$RANDOM
greps_fname=/tmp/$RANDOM

function parse_args()
{
	local all_files=("$@")
	local i
	local is_callee=1
	for ((i=0; i<${#all_files[@]}; i++))
	do
		if [[ "${all_files[$i]}" == "--" ]]
		then
			is_callee=0
			continue
		fi

		if (( $is_callee ))
		then
			callee_files+=( "${all_files[$i]}" )
		else
			caller_files+=( "${all_files[$i]}" )
		fi
	done
}

function extract_used_tags()
{
	local atag
	for atag in `cat $tags_fname`
	do
		if grep -F $atag $greps_fname 1>/dev/null 2>&1
		then
			used_tags+=($atag)
		fi
	done
}


#print_array array_name ${array_name[@]}
function print_array()
{
	local arr=("$@")
	local i
	echo Array: ${arr[0]} ${#arr[@]}
	for ((i=1; i<${#arr[@]}; i++))
	do
		printf '"%s" ' ${arr[$i]}
	done
	printf '\n'
}

#print_tag_context greps_fname ${tags_array_name[@]}
function print_tag_context()
{
	local arr=("$@")
	local i
	for ((i=1; i<${#arr[@]}; i++))
	do
		grep -F ${arr[$i]} ${arr[0]}
	done
}

function main()
{
	parse_args "$@"

	#extract tags
	ctags -x --c-kinds=fp ${callee_files[@]} | awk '{print $1}' | sort | uniq >$tags_fname

	#grep all tags in all files
	grep -F -f $tags_fname ${caller_files[@]} >$greps_fname

	#extract used tags
	extract_used_tags

	#output used tags
	print_array used_tags ${used_tags[@]}

	echo '====='

	#output used tags context
	print_tag_context $greps_fname ${used_tags[@]}

	#clean up
	rm $greps_fname
	rm $tags_fname
}

main "$@"
