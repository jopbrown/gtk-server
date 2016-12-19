#!/usr/bin/newlisp
#
# Demonstration on how to use the GTK-server with newLisp by IPC
#   Tested with newLISP 9.0 and GTK-server 2.1.3 on Zenwalk Linux 3.0
#
# January 7, 2007 - GTK program by Peter van Eerten.
# Revised for newLisp 10 at december 21, 2008 - PvE.
#------------------------------------------------------------------

# Define communication function
(define (gtk str)
    (set 'result (exec (append {gtk-server -msg=1,"} str {"})))
    (if result (first result))
)

# Setup gtk-server with IPC
(! "gtk-server -ipc=1 -log=/tmp/gtk-server.log &")

# Connect to the GTK-server
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

# Mainloop starts here
(set 'event 0)
(while (and (!= event button1) (!= event win))
    (set 'event (gtk (append "gtk_server_callback wait")))
    (when (= event button2)
	(set 'tmp (gtk (append "gtk_entry_get_text " entry)))
	(println (append "This is the contents: " tmp))
    )
)

(gtk "gtk_server_exit")
(exit)
