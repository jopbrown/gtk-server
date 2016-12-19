#!/usr/local/bin/ksh93
#
# Demonstration on how to use the GTK-server with Kornshell93.
# Tested with the AT&T KSH93 on Zenwalk 4.8.
#
# May 13, 2008 by Peter van Eerten.
#------------------------------------------------

# Import the function 'gtk'
builtin -f libgtk-server.so gtk

# Main program
gtk "gtk_init NULL NULL" > /dev/null
WINDOW=$(gtk "gtk_window_new 0")
gtk "gtk_window_set_title $WINDOW 'This is a title'" > /dev/null
gtk "gtk_window_set_position $WINDOW 1" > /dev/null
TABLE=$(gtk "gtk_table_new 10 10 1")
gtk "gtk_container_add $WINDOW $TABLE" > /dev/null
BUTTON=$(gtk "gtk_button_new_with_label 'Click here!'")
gtk "gtk_table_attach_defaults $TABLE $BUTTON 5 9 7 9" > /dev/null
CHECK=$(gtk "gtk_check_button_new_with_label 'Check \t this \n out!'")
gtk "gtk_table_attach_defaults $TABLE $CHECK 1 6 1 2" > /dev/null
ENTRY=$(gtk "gtk_entry_new")
gtk "gtk_table_attach_defaults $TABLE $ENTRY 1 6 3 4" > /dev/null
gtk "gtk_widget_show_all $WINDOW" > /dev/null

# Mainloop
while [[ $EVENT != $WINDOW && $EVENT != $BUTTON ]]
do
    EVENT=$(gtk "gtk_server_callback WAIT")
    if [[ $EVENT = $ENTRY ]]
    then
	gtk "gtk_entry_get_text $ENTRY"
    fi
done

# Exit GTK
gtk "gtk_server_exit"
