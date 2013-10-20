#!/usr/bin/awk -f

/->/ {
# "get_menu_selection" -> "ui_text_visible" [style=solid];
	caller=$1
	callee=$3
	callstyle= ( $4 == "[style=solid];" ? "s" : "d")

	call_out[caller] = ( call_out[caller]  callee "," callstyle ";")
	call_in[callee] =  ( call_in[callee]  caller "," callstyle ";")

}

END {

	parse_arg()
	print "digraph callgraph {"
	if(out_level)
		bfs_out(1, funcname_center)
        if(in_level)
                bfs_in(1, funcname_center)
	print "}"
}

function split_call(callstring, callarr)
{
# "get_menu_selection" -> "ui_text_visible",s;"a2",d;
	split(callstring, inout ,";")
	for(i in inout)
	{
		idx = index(inout[i], ",")
		if(idx==0)
			continue
		callarr[substr(inout[i],1,idx-1)] = substr(inout[i],idx+1)
	}
	

}

function bfs_out(level,funcname)
{
	if(is_out[funcname])
		return
	is_out[funcname]=1

	if(!( funcname in call_out))
		return

	delete outs
	split_call(call_out[funcname], outs)

	for( fun2 in outs)
	{
		print funcname " -> " fun2 " " (outs[fun2]=="s" ? "[style=solid];":"[style=dotted];")
	}

	if(level<=verbose_out_level)
	{
		for(fun2 in outs)
		{
			bfs_in(in_level,fun2)
		}
	}

	level+=1
	if(level <out_level)
	{
		for(fun2 in outs)
		{
			bfs_out(level,fun2)
		}
	}

}

function bfs_in(level,funcname)
{
	if(is_in[funcname])
		return
	is_in[funcname]=1

	if(!( funcname in call_in))
		return

	delete ins
	split_call(call_in[funcname], ins)

	for( fun2 in ins)
	{
		print fun2 " -> " funcname " " (ins[fun2]=="s" ? "[style=solid];":"[style=dotted];")
	}

	if(level<=verbose_in_level)
	{
		for(fun2 in ins)
		{
			bfs_out(in_level,fun2)
		}
	}

	level+=1
	if(level <in_level)
	{
		for(fun2 in ins)
		{
			bfs_in(level,fun2)
		}
	}

}

function parse_arg()
{
	if(!f)
	{
		usage()
		exit
	}
	funcname_center= "\"" f "\""

	out_level = (o==-1)? 9999:o
	in_level = (i==-1)? 9999:i
	verbose_out_level = vo
	verbose_in_level = vi
}

function usage()
{
	print "awk -f egypt.awk -- i=[digit]  o=[digit] vi=[digit] vo=[digit] f=funcname egypt.output"
	print "i=[digit]:  call in level, -1 means all"
	print "o=[digit]:  call out level, -1 means all"
	print "vi=[digit]: verbose call in level"
	print "vo=[digit]: verbose call out level"
}
