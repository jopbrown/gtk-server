#!/bin/ksh
#
# Demonstration on how to use the GTK-server with KSH by IPC.
#
# November 12, 2005 - (c) Peter van Eerten
#
# Tested with GTK-server 2.4 in december 2016 - PvE
#
# As unique communication channel the current PID number '$$' is used.
# Tested with GTK-server 2.4 in december 2016 - PvE
#----------------------------------------------------------------

# Communication function; $@ contains the string to be sent
function gtk
{
    RESULT=$(gtk-server-gtk2 -msg=$$,"$@")
}

# Start GTK-server in IPC mode
gtk-server-gtk2 -detach -debug -ipc=$$ -log=/tmp/gtk-server.log

# Define GUI
gtk "gtk_init NULL NULL"
gtk "gtk_window_new 0"
WINDOW=$RESULT
gtk "gtk_window_set_title $WINDOW 'KSH demo using IPC'"
gtk "gtk_window_set_position $WINDOW 1"
gtk "gtk_table_new 10 10 1"
TABLE=$RESULT
gtk "gtk_container_add $WINDOW $TABLE"
gtk "gtk_button_new_with_label 'Click \n here'"
BUTTON=$RESULT
gtk "gtk_table_attach_defaults $TABLE $BUTTON 5 9 7 9"
gtk "gtk_check_button_new_with_label 'Check this out!'"
CHECK=$RESULT
gtk "gtk_table_attach_defaults $TABLE $CHECK 1 6 1 2"
gtk "gtk_entry_new"
ENTRY=$RESULT
gtk "gtk_table_attach_defaults $TABLE $ENTRY 1 6 3 4"
gtk "gtk_widget_show_all $WINDOW"

# Initialize variables
EVENT=0

# Mainloop
while [ $EVENT -ne $BUTTON ]
do
    gtk "gtk_server_callback WAIT"
    EVENT=$RESULT

    if [ $RESULT -eq $ENTRY ]
    then
	gtk "gtk_entry_get_text $ENTRY"
	print $RESULT
    fi
done

# Exit GTK
gtk "gtk_server_exit"
