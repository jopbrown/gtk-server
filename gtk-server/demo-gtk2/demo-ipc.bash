#!/bin/bash
#
# Bourne shell IPC demo with the GTK-server
#
# November 12, 2006 - (c) Peter van Eerten
#
# As unique communication channel the current PID
# number '$$' is used.
# Adjusted with demonstrations for GTK-server 2.2.1
#   at october 15, 2007 - PvE.
# Optimized code at april 26, 2008 - PvE.
#-------------------------------------------------

# Communication function; assignment function
function gtk() { GTK=`gtk-server msg=$$,"$@"`; }
function define() { $2 "$3"; eval $1=$GTK; }

#------------------------ Main starts here

# Start gtk-server in IPC mode
gtk-server -ipc=$$ -log=/tmp/$0.log &
sleep 1

# Setup GUI
gtk "gtk_init NULL NULL"
# The window macro
define WIN gtk "gtk_window_new GTK_WINDOW_TOPLEVEL"
gtk "gtk_widget_set_size_request $WIN 400 200"
gtk "gtk_window_set_title $WIN 'Bourne GTK-SERVER demo'"
gtk "gtk_widget_add_events $WIN GDK_BUTTON_PRESS_MASK"
gtk "gtk_window_set_position $WIN GTK_WIN_POS_CENTER"
# Connect key-press event to window 
gtk "gtk_server_connect $WIN key-press-event key-press-event"
gtk "gtk_server_connect $WIN button-press-event button-press-event"
# Other widgets
define TBL gtk "gtk_table_new 10 10 1"
gtk "gtk_container_add $WIN $TBL"
define LAB gtk "gtk_label_new 'Press a key and also try to keep special keys pressed!'"
gtk "gtk_table_attach_defaults $TBL $LAB 0 9 2 4"
define INF gtk "gtk_button_new_with_label 'Show info'"
gtk "gtk_table_attach_defaults $TBL $INF 1 4 6 9"
define BUT gtk "gtk_button_new_with_label 'Click to Quit'"
gtk "gtk_table_attach_defaults $TBL $BUT 6 9 6 9"
gtk "gtk_widget_show_all $WIN"
# Demonstration of the dialog macro - see configfile
define DIA gtk "u_dialog Information \"'Attack of the macros!'\" 200 150"
# Hide the widget - universal interface
gtk "u_hide $DIA"

# Mainloop
until [[ $EVENT -eq $BUT || $EVENT -eq $WIN ]]
do 
    define EVENT gtk "gtk_server_callback wait"

    case $EVENT in
	$DIA)
	    gtk "gtk_widget_hide $DIA";;
	$INF)
	    gtk "gtk_widget_show_all $DIA";;
	"exit")
	    gtk "gtk_widget_hide $DIA";;
    esac

    # Check if key pressed
    define KEY gtk "gtk_server_key"
    if [[ $KEY -ne 0 ]]
    then
	echo "Normal key: $KEY"
	if [[ $KEY -eq 32 ]]
	then
	    gtk "gtk_server_disconnect $INF clicked"
	    echo "Button 'Show info' has been disconnected!"
	fi
    fi

    # Check if some special key continuously is being pressed
    gtk "gtk_server_mouse 2"
    if [[ $GTK -ne 0 ]]
    then
	echo "Special key: $GTK"
    fi
done

# Exit GTK
gtk "gtk_server_exit"
