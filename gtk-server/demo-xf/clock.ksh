#!/bin/ksh
#
# Demo with XForms and the predefined CLOCK widget
# (c) PvE, august 2008 - GPL
#
#----------------------------------------------------------------------

# Communication function; assignment function
function xf { print -p $1; read -p XF; }
function define { $2 "$3"; eval $1="\"$XF\""; }

# Start GTK-server in STDIN mode
gtk-server -stdin |&

# Define the window
define WINDOW xf "fl_bgn_form FL_UP_BOX 600 210"
xf "fl_add_box FL_NO_BOX 160 40 0 0 'Current time'"

# Add the clock
xf "fl_add_clock FL_ANALOG_CLOCK 10 10 280 180 ''"
define DIGITAL xf "fl_add_clock FL_DIGITAL_CLOCK 310 10 280 100 ''"
xf "fl_set_object_lsize $DIGITAL FL_HUGE_SIZE"
xf "fl_set_object_color $DIGITAL FL_DARKCYAN FL_BLUE"

# Create the buttons, set some colors and fonts
define ABOUT xf "fl_add_button FL_NORMAL_BUTTON 310 150 80 40 'About'"
xf "fl_set_object_lstyle $ABOUT, FL_SHADOW_STYLE"
xf "fl_set_object_lsize $ABOUT FL_MEDIUM_SIZE"
xf "fl_set_object_color $ABOUT FL_ORCHID FL_RED"
define BUTTON xf "fl_add_button FL_NORMAL_BUTTON 510 150 80 40 'Exit'"
xf "fl_set_object_lstyle $BUTTON, FL_MISCITALIC_STYLE"
xf "fl_set_object_lsize $BUTTON FL_MEDIUM_SIZE"
xf "fl_set_object_color $BUTTON FL_GREEN FL_RED"

# End definition, show main window
xf "fl_end_form"
xf "fl_show_form $WINDOW FL_PLACE_CENTER FL_FULLBORDER 'Showing the current time'"

# Main loop is here
until [[ $EVENT = $BUTTON ]]
do
    # Get result from 'do_forms'
    define EVENT xf "gtk_server_callback wait"

    # Has the 'ABOUT' button been pressed?
    if [[ $EVENT = $ABOUT ]]
    then
	xf "fl_show_message 'Demo with XForms and the CLOCK widget!\n' 'Created with Kornshell and GTK-server' ''"
    fi
done

# Exit
xf "gtk_server_exit"
