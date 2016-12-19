#!/usr/bin/newlisp
#
# Demonstration on how to use the GTK-server with NEWLISP by UDP.
# Tested with newLISP 8.1.0 on Slackware Linux 9.1.
#
# July 29, 2004 by Peter van Eerten.
# Revised at august 12, 2004
# Revised for GTK-server 1.2 October 8, 2004 by PvE.
# Revised for GTK-server 1.3 December 5, 2004 by PvE.
# Revised for GTK-server 2.1.4 at April 22, 2007 - PvE.
# Revised for newLisp 10 at december 21, 2008 - PvE.
#------------------------------------------------

(context 'GTK)

(constant 'net-buffer 128)

# Define communication function
(define (gtk str)
    (net-send-to "localhost" 50001 str socket)
    (net-receive socket tmp net-buffer)
    tmp)

# Start the gtk-server
(define (start)
    (! "gtk-server -udp=localhost:50001 &")
    (sleep 1000)
    (set 'socket (net-listen 50002 "localhost" "udp")))

# Stop the GTK-server
(define (stop)
    (net-send-to "localhost" 50001 "gtk_server_exit" socket)
    (net-close socket))

#------------------------------------------------

(context 'GUI)

# Setup the GUI
(define (setup)
    (GTK:gtk "gtk_init NULL NULL")
    (set 'win (GTK:gtk "gtk_window_new 0"))
    (GTK:gtk (append "gtk_window_set_title " win " \"This is a title\""))
    (GTK:gtk (append "gtk_window_set_default_size " win " 100 100"))
    (GTK:gtk (append "gtk_window_set_position " win " 1"))
    (set 'table (GTK:gtk "gtk_table_new 30 30 1"))
    (GTK:gtk (append "gtk_container_add " win " " table))
    (set 'button1 (GTK:gtk "gtk_button_new_with_label Exit"))
    (GTK:gtk (append "gtk_table_attach_defaults " table " " button1 " 17 28 20 25"))
    (set 'button2 (GTK:gtk "gtk_button_new_with_label \"Print text\""))
    (GTK:gtk (append "gtk_table_attach_defaults " table " " button2 " 2 13 20 25"))
    (set 'entry (GTK:gtk "gtk_entry_new"))
    (GTK:gtk (append "gtk_table_attach_defaults " table " " entry " 2 28 5 15"))
    (GTK:gtk (append "gtk_widget_show_all " win)))

# Define callback
(define (callbck)
    (set 'tmp (GTK:gtk (append "gtk_server_callback wait")))
    tmp)

# Retrieve info from ENTRY
(define (retrieve_txt)
    (set 'tmp (trim (GTK:gtk (append "gtk_entry_get_text " entry)) "\n"))
    tmp)

#------------------------------------------------

(context 'MAIN)

(GTK:start)
(GUI:setup)

(set 'event 0)

(while (and (!= event GUI:button1) (!= event GUI:win))
    (set 'event (GUI:callbck))
    (when (or (= event GUI:entry) (= event GUI:button2))
	(set 'tmp (GUI:retrieve_txt))
	(println (append "This is the contents: " tmp))
    )
)

(GTK:stop)
(exit)
