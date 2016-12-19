#!/usr/bin/newlisp
#
# Demonstration on how to use the GTK-server with NEWLISP by STDIN.
# Tested with newLISP 8.2.3 on Slackware Linux 10 and Windows2000
#
# October 6, 2004 
#	GTK program by Peter van Eerten.
# 	The setup of communication pipes by Lutz Mueller.
# Revised for GTK-server 1.2 October 7, 2004
# Revised for GTK-server 1.3 December 5, 2004
# Revised at january 15, 2007 - PvE.
# Revised at april 22, 2008 - PvE.
# Revised for newLisp 10 at december 21, 2008 - PvE.
#------------------------------------------------------------------

# Define communication function
(define (gtk str)
    (write-line myout str)
    (read-line myin))

# Setup gtk-server
(map set '(myin gtkout) (pipe))
(map set '(gtkin myout) (pipe))
(process "/usr/bin/gtk-server -stdin" gtkin gtkout)

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
(until (or (= event button1) (= event win))
    (set 'event (gtk "gtk_server_callback wait"))
    (if (= event button2)
	(println "This is the contents: " (gtk (append "gtk_entry_get_text " entry)))
    )
)

(gtk "gtk_server_exit")

# Exit newLisp
(exit)
