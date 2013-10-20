#!/usr/bin/awk -f
#
#Generate c struct overview from ctags "tags" file
#Usage:
# 	awk.cstruct.awk "tags"
#"tags" should be output from:
# 	ctags -n --c-kinds=m file...
#

BEGIN {
	FS="\t"
}

/\ttyperef:/ {
	aLine=$0
	extract_field(aLine,aFields)

#union:qwer      => :qwer
#struct:qewr => :qwer
	sStartIdx=index(aFields["struct"], ":")
	newStruct = substr(aFields["struct"], sStartIdx)

	allFields[aFields["file"], newStruct, aFields["tag"]] = aLine
}

END {
	nField = asorti(allFields, fieldIdx)

#Make prevFields as a array!
	prevFields["zero"]=0
	delete prevFields["zero"]

	for (i=1; i<=nField; i++)
	{
		curLine=allFields[fieldIdx[i]]
		nextLine=allFields[fieldIdx[i+1]]

		extract_field(curLine,curFields)
		extract_field(nextLine,nextFields)

		switch_struct(curFields)
	}
}

function extract_field(aLine, aFields,  arr)
{
#css	cgroup.c	177;"	m	struct:css_id	typeref:struct:css_id::__rcu	file:
#addr	ioc4.h	46;"	m	struct:ioc4_misc_regs::ioc4_pci_err_addr_l::__anon4
	split(aLine, arr, "\t")
	aFields["tag"]=arr[1]
	aFields["file"]=arr[2]

#177;" => 177
	aFields["line"]=strtonum(substr(arr[3],1,length(arr[3])-2))

	aFields["type"]=arr[4]
	aFields["struct"]=arr[5]
	aFields["typeref"]=arr[6]
}

function extract_topstruct(aStruct)
{
#struct:ioc4_misc_regs::ioc4_pci_err_addr_l::__anon4 => ioc4_misc_regs
	sStartIdx = index(aStruct, ":")
	sEndIdx = index(aStruct, "::")
	sLength = sEndIdx==0?length(aStruct):sEndIdx-sStartIdx
	return substr(aStruct, sStartIdx+1, sLength-1)
}

function switch_file(curFile)
{
	if(curFile!=prevFile)
	{
		print "//******************************"
		print "//###", curFile ,"###"
		print "//******************************"
		prevFile=curFile
		return 1
	}
	return 0
}

function print_struct(newFields, newStruct,   lNewIdx,lIdx,lI,lStr,lStartIdx)
{
	print "struct ",newStruct,"{"

	lIdx = asorti(newFields, lNewIdx)
	for(lI=1; lI<=lIdx; lI++)
	{
		printf "/* %s */\t" ,lNewIdx[lI]
#lStr ===> typeref:struct:cg_cgroup_link::list_head:::cgrp_link_list
		lStr=newFields[lNewIdx[lI]]
		sub("typeref:","",lStr)

#lStr ===> struct:cg_cgroup_link::list_head:::cgrp_link_list
		lStartIdx=index(lStr, ":")
		printf "%s ",substr(lStr,1,lStartIdx-1)

#lStr ===> cg_cgroup_link::list_head:::cgrp_link_list
		lStartIdx=index(lStr, "::")
		lStr=substr(lStr,lStartIdx+2)
#lStr ===> list_head:::cgrp_link_list
		lStartIdx=index(lStr, ":::")
		printf "%s ",substr(lStr,1,lStartIdx-1)

#lStr ===> cgrp_link_list
		lStr=substr(lStr,lStartIdx+3)
		printf "%s;\n",lStr
	}

	print "};"
	print "\n"
}

function switch_struct(aFields)
{
	curStruct=extract_topstruct(aFields["struct"])
	if(curStruct != prevStruct)
	{
		if( length(prevFields) )
		{
			print_struct(prevFields, prevStruct)
		}
		switch_file(aFields["file"])

		delete prevFields
		prevStruct=""
	}

	prevFields[aFields["line"]]=sprintf("%s:::%s",aFields["typeref"],aFields["tag"])
	prevStruct=curStruct
}
