#!/bin/ksh
#
# Demonstration on how to use the GTK-server with KSH by FIFO.
# Tested with KSH93-20011031 on Slackware Linux 9.1 kernel 2.4.22.
# Also with PDKSH 5.2.14 on Zenwalk Linux 4.2 kernel 2.6.18
#
# July 21, 2004 by Peter van Eerten.
# Revised for GTK-server 1.2 October 7, 2004
# Revised for GTK-server 1.3 December 4, 2004
# Revised for GTK-server 2.0.6 at december 17, 2005
# Revised for GTK-server 2.0.8 at january 7, 2006
# Revision at january 15, 2007 - PvE.
# Revision at april 26, 2008 - PvE.
#----------------------------------------------------------------

# Catch SIGUSR1 signal when GTK-server exits - check configfile
trap 'exit' 10

# Communication function; assignment function
function gtk { echo $@ > /tmp/demo; read GTK < /tmp/demo; }
function define { $2 "$3"; eval $1=$GTK; }

# Start GTK-server
gtk-server -fifo=/tmp/demo &

# Make sure the PIPE file is available
while [ ! -p /tmp/demo ]; do continue; done

# Define GUI
gtk "gtk_init NULL, NULL"
define WINDOW gtk "gtk_window_new 0"
gtk "gtk_window_set_title $WINDOW 'KSH demo using a Named Pipe'"
gtk "gtk_window_set_position $WINDOW 1"
define TABLE gtk "gtk_table_new 10 10 1"
gtk "gtk_container_add $WINDOW $TABLE"
define BUTTON gtk "gtk_button_new_with_label 'Click \n here'"
gtk "gtk_table_attach_defaults $TABLE $BUTTON 5 9 7 9"
define CHECK gtk "gtk_check_button_new_with_label 'Check this out!'"
gtk "gtk_table_attach_defaults $TABLE $CHECK 1 6 1 2"
define ENTRY gtk "gtk_entry_new"
gtk "gtk_table_attach_defaults $TABLE $ENTRY 1 6 3 4"
gtk "gtk_widget_show_all $WINDOW"

# Mainloop
while [[ $EVENT -ne $BUTTON ]]
do
    define EVENT gtk "gtk_server_callback WAIT"

    if [[ $EVENT -eq $ENTRY ]]
    then
	gtk "gtk_entry_get_text $ENTRY"
	print $GTK
    fi
done

# Exit GTK
gtk "gtk_server_exit"
