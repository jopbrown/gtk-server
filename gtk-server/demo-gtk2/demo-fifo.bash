#!/bin/bash
#
# Bourne shell named pipe demo with the GTK-server
# Tested with BASH 3.1 on Zenwalk Linux 4.2
#
# March 14, 2004 by Peter van Eerten
# Revised at july 25, 2004
# Revised for GTK-server 1.2 October 7, 2004
# Revised for GTK-server 1.3 December 4, 2004
# Revised for GTK-server 2.0.6 at december 17, 2005
# Revised for GTK-server 2.0.8 at january 7, 2006
# Revision at january 15, 2007
#------------------------------------------------

# Define SIGUSR1 in configfile to catch the signal
trap 'exit' SIGUSR1

# Name of PIPE file
declare PIPE=/tmp/bash.gtk.$$

# Communicate with GTK-server
gtk()
{
echo $@ > $PIPE
read RESULT < $PIPE
}

#------------------------ Main starts here

# Start gtk-server
gtk-server -fifo=$PIPE -log=/tmp/gtk-server.log &

# Make sure the PIPE file is available
while [ ! -p $PIPE ]; do continue; done

# Setup GUI
gtk "gtk_init NULL NULL"
gtk "gtk_window_new 0"
WIN=$RESULT
gtk "gtk_window_set_title $WIN 'BASH GTK-server demo'"
gtk "gtk_window_set_default_size $WIN 400 200"
gtk "gtk_window_set_position $WIN 1"
gtk "gtk_table_new 10 10 1"
TBL=$RESULT
gtk "gtk_container_add $WIN $TBL"
gtk "gtk_button_new_with_label 'Show info'"
INF=$RESULT
gtk "gtk_table_attach_defaults $TBL $INF 1 4 6 9"
gtk "gtk_button_new_with_label 'Click to Quit'"
BUT=$RESULT
gtk "gtk_table_attach_defaults $TBL $BUT 6 9 6 9"
gtk "gtk_widget_show_all $WIN"
# Demonstration of the dialog macro - see configfile
gtk "u_dialog Information \"'Attack of the macros!'\" 200 130"
DIA=$RESULT

EVENT=0

# Mainloop
while [[ $EVENT -ne $BUT && $EVENT -ne $WIN ]]
do 
    gtk "gtk_server_callback WAIT"
    EVENT=$RESULT

    case $EVENT in
	$DIA)
	    gtk "gtk_widget_hide $DIA";;
	"exit")
	    gtk "gtk_widget_hide $DIA";;
	$INF)
	    gtk "gtk_widget_show_all $DIA";;
    esac

done

# Exit GTK
gtk "gtk_server_exit"
