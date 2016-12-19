#!/usr/bin/newlisp
#
# Demonstration on how to use the GTK-server with NEWLISP by FIFO.
# Tested with newLISP 9.0 on Zenwalk Linux 4.2.
#
# Also check the embedded GTK principle at http://www.gtk-server.org
#
# March 28, 2004 by Peter van Eerten.
# Revised for GTK-server 1.2 October 7, 2004
# Revised for GTK-server 1.3 December 5, 2004
# Revised for GTK-server 2.0.6 at december 17, 2005
# Revised for GTK-server 2.0.8 at january 7, 2006
# Revision at january 15, 2007 - PvE.
# Revised for newLisp 10 at december 21, 2008 - PvE.
#------------------------------------------------

(constant 'PIPE "/tmp/newlisp.gtk")

# Define exit function when error occurs
(signal 10 exit)

# Define communication function
(define (gtk str, handle tmp)
    (set 'handle (open PIPE "write"))
    (write-buffer handle str)
    (close handle)
    (set 'handle (open PIPE "read"))
    (read-buffer handle tmp 256)
    (close handle)
    (chop tmp)
)

# Start the gtk-server
(! (append "gtk-server -fifo=" PIPE " -log=/tmp/gtk-server.log &"))

# Make sure pipe exists
(while (not (file? PIPE)) (sleep 10))

# Design the GUI
(gtk "gtk_init NULL NULL")
(set 'win (gtk "gtk_window_new 0"))
(gtk (append "gtk_window_set_title " win " 'This is a title'"))
(gtk (append "gtk_window_set_default_size " win " 100 100"))
(gtk (append "gtk_window_set_position " win " 1"))
(set 'table (gtk "gtk_table_new 30 30 1"))
(gtk (append "gtk_container_add " win " " table))
(set 'button1 (gtk "gtk_button_new_with_label Exit"))
(gtk (append "gtk_table_attach_defaults " table " " button1 " 17 28 20 25"))
(set 'button2 (gtk "gtk_button_new_with_label 'Print text'"))
(gtk (append "gtk_table_attach_defaults " table " " button2 " 2 13 20 25"))
(set 'entry (gtk "gtk_entry_new"))
(gtk (append "gtk_table_attach_defaults " table " " entry " 2 28 5 15"))
(gtk (append "gtk_widget_show_all " win))

# This is the mainloop
(until (or (= event button1) (= event win))
    (set 'event (gtk "gtk_server_callback wait"))
    (if (= event button2)
	(println "This is the contents: " (gtk (append "gtk_entry_get_text " entry)))
    )
)

# Exit GTK
(gtk "gtk_server_exit")

# Exit newLISP
(exit)
