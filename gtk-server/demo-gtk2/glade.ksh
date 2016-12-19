#!/bin/ksh
#
# Demonstration on how to use Glade and the GTK-server with KSH by STDIN.
# Tested with the AT&T KSH (1993-12-28) on Slackware Linux.
#
# Tested with GTK-server 2.0.8.
#------------------------------------------------
#
# Communication function; $1 contains the string to be send
function gtk
{
print -p $1
read -p RESULT
}

# Setup environment
export LC_ALL=nl_NL
export LD_LIBRARY_PATH=/usr/X11R6/lib

# Start GTK-server in STDIN mode
gtk-server stdin |&

gtk "gtk_init NULL NULL"
gtk "glade_init"

# Get Glade file
gtk "glade_xml_new glade.glade NULL NULL"
XML=$RESULT
gtk "glade_xml_signal_autoconnect $XML"

# Get main window ID and connect signal
gtk "glade_xml_get_widget $XML window"
gtk "gtk_server_connect $RESULT delete-event window"

# Get exit button ID and connect signal
gtk "glade_xml_get_widget $XML exit_button"
gtk "gtk_server_connect $RESULT clicked exit_button"

# Get print button ID and connect signal
gtk "glade_xml_get_widget $XML print_button"
gtk "gtk_server_connect $RESULT clicked print_button"

# Get entry ID
gtk "glade_xml_get_widget $XML entry"
ENTRY=$RESULT

# Initialize variables
EVENT=0

# Mainloop
while [[ $EVENT != "window" && $EVENT != "exit_button" ]]
do
    gtk "gtk_server_callback WAIT"
    EVENT=$RESULT

    if [[ $EVENT = "print_button" ]]
    then
	gtk "gtk_entry_get_text $ENTRY"
	print $RESULT
    fi
done

# Exit GTK
gtk "gtk_exit 0"
