#!/bin/ksh
#
# Demonstration on how to use the GTK-server with PDKSH by STDIN.
# Tested with the AT&T KSH (1993-12-28) on Slackware Linux 9.0.
#
# September 27, 2003 by Peter van Eerten.
# Revised for GTK-server 1.2 October 7, 2004
# Revised for GTK-server 1.3 December 4, 2004
# Revised at april 26, 2008 - PvE.
# Tested with GTK-server 2.4 in december 2016 - PvE
#------------------------------------------------
#
# Communication function; assignment function
function gtk { print -p $1; read -p GTK; }
function define { $2 "$3"; eval $1=$GTK; }

# Start GTK-server in STDIN mode
gtk-server -stdin -debug -log=/tmp/$0.log |&

# Define GUI
gtk "gtk_init NULL NULL"
define WINDOW gtk "gtk_window_new 0"
gtk "gtk_window_set_title $WINDOW 'This is a title'"
gtk "gtk_window_set_position $WINDOW 1"
define TABLE gtk "gtk_table_new 10 10 1"
gtk "gtk_container_add $WINDOW $TABLE"
define BUTTON gtk "gtk_button_new_with_label 'Click here!'"
gtk "gtk_table_attach_defaults $TABLE $BUTTON 5 9 7 9"
define CHECK gtk "gtk_check_button_new_with_label 'Check \t this \n out!'"
gtk "gtk_table_attach_defaults $TABLE $CHECK 1 6 1 2"
define ENTRY gtk "gtk_entry_new"
gtk "gtk_table_attach_defaults $TABLE $ENTRY 1 6 3 4"
gtk "gtk_window_set_type_hint $WINDOW GDK_WINDOW_TYPE_HINT_UTILITY"
gtk "gtk_widget_show_all $WINDOW"

# Mainloop
while [[ $EVENT != $BUTTON ]]
do
    define EVENT gtk "gtk_server_callback wait"

    if [[ $EVENT = $ENTRY ]]
    then
	gtk "gtk_entry_get_text $ENTRY"
	print $GTK
    fi
done

# Exit GTK
gtk "gtk_server_exit"
