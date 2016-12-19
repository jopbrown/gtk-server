#!/usr/bin/newlisp
#
# Demonstration on how to use the GTK-server Shared Object with NEWLISP. 
# Tested with newLISP 9.0 on Zenwalk Linux 4.2
#
# December 17, 2005, PvE.
# Revised at january 15, 2007 - PvE.
#------------------------------------------------------------------

# Setup gtk-server
(if (= ostype "OSX")
    (import "libgtk-server.dylib" "gtk")
    (import "libgtk-server.so" "gtk")
)

# Optionally enable GTK logging
#(gtk "gtk_server_cfg -log=/tm/gtk-server.log -post=.")

# Connect to the GTK-server
(gtk "gtk_init NULL NULL")
(set 'win (get-string (gtk "gtk_window_new 0")))
(gtk (append "gtk_window_set_title " win " \"This is a title\""))
(gtk (append "gtk_window_set_default_size " win " 100 100"))
(gtk (append "gtk_window_set_position " win " 1"))
(set 'table (get-string (gtk "gtk_table_new 30 30 1")))
(gtk (append "gtk_container_add " win " " table))
(set 'button1 (get-string (gtk "gtk_button_new_with_label Exit")))
(gtk (append "gtk_table_attach_defaults " table " " button1 " 17 28 20 25"))
(set 'button2 (get-string (gtk "gtk_button_new_with_label \"Print text\"")))
(gtk (append "gtk_table_attach_defaults " table " " button2 " 2 13 20 25"))
(set 'entry (get-string (gtk "gtk_entry_new")))
(gtk (append "gtk_table_attach_defaults " table " " entry " 2 28 5 15"))
(gtk (append "gtk_widget_show_all " win))

# Mainloop starts here
(until (or (= event button1) (= event win))
    (set 'event (get-string (gtk "gtk_server_callback wait")))
    (if (= event button2)
	(println "This is the contents: " (get-string (gtk (append "gtk_entry_get_text " entry))))
    )
)

# Exit newLisp
(exit)
