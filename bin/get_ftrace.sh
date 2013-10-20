#/system/bin/sh

sleep 6

mount -t debugfs none /d

#init filter
echo > /d/tracing/set_ftrace_filter
for fn in `cat /data/f.txt` 
do
	echo $fn >> /d/tracing/set_ftrace_filter
done

echo function > /d/tracing/current_tracer

echo 'begin tracing'

i=0;
while busybox [ $i -lt 20 ]
do
	date > /data/to/t$i.txt
	cat /proc/uptime >> /data/to/t$i.txt
	cat /d/tracing/trace >> /data/to/t$i.txt
	sleep 1
	i=$(($i+1))
done

echo nop > /d/tracing/current_tracer