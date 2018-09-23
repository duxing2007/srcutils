#
# Makefile for the trace utility.
#
# M. Tim Jones <mtj@mtjones.com>
#


all: libpvtrace.so off hello

libpvtrace.so: instrument.c
	gcc -Wall -fPIC  -shared -o libpvtrace.so instrument.c

off: off.c
	gcc -Wall  -o off off.c


hello: hello.cpp
	g++ -Wall -g -finstrument-functions -L.  $< -o $@ libpvtrace.so

clean:
	rm -f hello off libpvtrace.so
