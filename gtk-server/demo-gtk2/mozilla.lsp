#!/usr/bin/newlisp
#
# Testing GtkMozEmbed - PvE - april 22, 2008 GPL.
#
# A very minimal webbrowser! Use with GTK-server 2.2.4 or later.
# Change paths to configfile and/or GTK-server where necessary.
#
#-------------------------------------------------------------------

(global 'in 'out)

(set 'cfgfile (open "/etc/gtk-server.cfg" "read"))

(cond ((not cfgfile)(println "No GTK-server configfile found! Exiting...")(exit)))

(while (read-line cfgfile)
    (when (and (starts-with (current-line) "FUNCTION_NAME") (regex "gtk_+|gdk_+|g_+" (current-line)))
	(set 'func (chop ((parse (current-line) " ") 2)))
	(set 'lb (append {(lambda()(setq s "} func {")(dolist (x (args))(setq s (string s " " x)))(write-line s out)(read-line in))}))
	(constant (global (sym func)) (eval-string lb))))

(close cfgfile)

(constant (global 'NULL) "NULL")

# -------------------------------------------------------------------------------------
# IMPORTANT!
#
# The script 'run-mozilla.sh' sets some environment variables before executing the
# webbrowser binary. The 'gtkembedmoz' widget must be linked together with the other
# Mozilla libs using 'LD_LIBRARY_PATH' in order to be used successfully.
#
# This program does not work with GTK-server as a module.
# -------------------------------------------------------------------------------------

(set 'LIB ((exec "dirname `locate libgtkembedmoz.so -n 1`") 0))
(env "LD_LIBRARY_PATH" LIB)

# Setup standalone gtk-server using STDIN
(map set '(in gtkout) (pipe))
(map set '(gtkin out) (pipe))
(process "/usr/bin/gtk-server -stdin" gtkin gtkout)

# Define minimal GUI
(gtk_init NULL NULL)
(set 'win (gtk_window_new "0"))
(gtk_window_set_title win {"A minimal webbrowser!"})
(gtk_window_set_position win 1)
(gtk_window_set_default_size win 700 500)
(gtk_window_set_icon_name win "mozilla")

# Set the componentpath of gtkembedmoz also
(gtk_moz_embed_set_comp_path LIB)

# Store a temporary profile in /tmp so my profile will be save
(gtk_moz_embed_set_profile_path "/tmp" "mozilla")

# Create the widget
(set 'moz (gtk_moz_embed_new))
(gtk_container_add win moz)

# Load some URL
(gtk_moz_embed_load_url moz "http://www.newlisp.org")

# Show it all
(gtk_widget_show_all win)

# Mainloop
(do-until (= (gtk_server_callback "wait") win))

# Exit GTK and newLisp
(gtk_server_exit)
(exit)
