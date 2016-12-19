#!/usr/bin/newlisp
#
# Demonstration on how to use the GTK-server with NEWLISP by TCP.
# Tested with newLISP 8.2.1 on Slackware Linux 10 and Windows2000.
#
# February 27, 2004 by Peter van Eerten.
# Revised for GTK-server 1.2 October 7, 2004
# Revised for GTK-server 1.3 December 5, 2004
# Revised for GTK-server 2.1.4 at April 22, 2007
# Revised for newLisp 10 at december 21, 2008 - PvE.
#------------------------------------------------

# Define communication function
(define (gtk str)
    (net-send socket str)
    (net-receive socket tmp 128)
    tmp)

# Start the gtk-server
(! "gtk-server -tcp=localhost:50001 &")
(sleep 500)

# Connect to the GTK-server
(set 'socket (net-connect "localhost" 50001))

# Setup GUI
(set 'tmp (gtk "gtk_init NULL NULL"))
(set 'win (gtk "gtk_window_new 0"))
(set 'tmp (gtk (append "gtk_window_set_title " win " \"This is a title\"")))
(set 'tmp (gtk (append "gtk_window_set_default_size " win " 100 100")))
(set 'tmp (gtk (append "gtk_window_set_position " win " 1")))
(set 'table (gtk "gtk_table_new 30 30 1"))
(set 'tmp (gtk (append "gtk_container_add " win " " table)))
(set 'button1 (gtk "gtk_button_new_with_label Exit"))
(set 'tmp (gtk (append "gtk_table_attach_defaults " table " " button1 " 17 28 20 25")))
(set 'button2 (gtk "gtk_button_new_with_label \"Print text\""))
(set 'tmp (gtk (append "gtk_table_attach_defaults " table " " button2 " 2 13 20 25")))
(set 'entry (gtk "gtk_entry_new"))
(set 'tmp (gtk (append "gtk_table_attach_defaults " table " " entry " 2 28 5 15")))
(set 'tmp (gtk (append "gtk_widget_show_all " win)))

# Mainloop
(until (or (= event button1) (= event win))
    (set 'event (gtk (append "gtk_server_callback WAIT")))
    (when (= event button2)
	(set 'tmp (gtk (append "gtk_entry_get_text " entry)))
	(print (append "This is the contents: " tmp))
    )
)
(set 'tmp (gtk "gtk_server_exit"))
(net-close socket)

# Exit newLisp
(exit)
