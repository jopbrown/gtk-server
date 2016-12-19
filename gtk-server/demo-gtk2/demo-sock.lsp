#!/usr/bin/newlisp
#
# Testing the -sock option and also defining macros on the fly
#
# newLisp 10 and GTK-server 2.3.1
#
# Nov 6 - Dec 21, 2008 - PvE.
#
#------------------------------------------------------------------------------------------------

(constant 'MAX_LEN 1024)

(define (gtk arg, buff)
    (net-send connection arg)
    (net-receive connection buff MAX_LEN "\n")
    buff)

(set 'port 60000)
(set 'listen (net-listen port))

(when (not listen)
    (println "Listening failed!")
    (exit))

(println "Start GTK-server as 'gtk-server -sock=localhost:60000'...")
(println "Waiting for connection on: " port)
(println)

(set 'connection (net-accept listen))

(if connection
    (begin
	# To test the '-init' parameter
	#(net-receive connection 'buff MAX_LEN "\n")
	#(print "INIT string: " buff)
	(print (gtk "gtk_server_version"))
	(print (gtk "gtk_server_ffi"))
	(print (gtk "gtk_server_toolkit"))
	(print (gtk "gtk_server_os"))
	(print (gtk "gtk_server_macro_define 'MACRO test\n$x : &abc\nscreensaver\nENDMACRO'"))
	(print (gtk "test"))
	(print (gtk "gtk_server_exit"))
    )
    (println "Could not connect!")
)

(exit)
