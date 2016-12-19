#!/bin/bash
#
# Demo with XForms
# Tested with GTK-server 2.1.3 compiled for XForms and BASH 3.1
# PvE - January 2007
# -----------------------------------------------------------------

# Communication function; $1 contains the string to be send
xf()
{
echo $1 > /tmp/demo.bash
read RESULT < /tmp/demo.bash
}

# Setup environment
export LC_ALL=nl_NL
export LD_LIBRARY_PATH=/usr/lib

# Start GTK-server in STDIN mode
gtk-server -fifo=/tmp/demo.bash -log=/tmp/$0.log &
while [ ! -p $PI ]; do continue; done

xf "fl_bgn_form FL_BORDER_BOX 320 240"
WINDOW=$RESULT
xf "fl_add_box FL_NO_BOX 160 40 0 0 \"Do you want to Quit?\""
xf "fl_add_button FL_NORMAL_BUTTON 40 70 80 30 Yes"
YBUT=$RESULT
xf "fl_set_object_color $YBUT 2 3"
xf "fl_add_button FL_NORMAL_BUTTON 200 70 80 30 No"
NBUT=$RESULT
xf "fl_set_object_color $NBUT 3 2"
xf "fl_add_text FL_NORMAL_TEXT 40 120 160 30 \"Hello this is a demo\""
xf "fl_add_input FL_NORMAL_INPUT 70 160 130 30 Data:"
INPUT=$RESULT
xf "fl_set_input $INPUT \"Enter your info here\""
xf "fl_end_form"

xf "fl_show_form $WINDOW FL_PLACE_CENTER FL_FULLBORDER Question"

until [[ $EVENT = $YBUT ]]
do
    xf "gtk_server_callback wait"
    EVENT=$RESULT

    case $EVENT in

	$YBUT)
	    echo "YES button clicked";;

	$NBUT)
	    echo "NO button clicked";;
    esac

done

xf "fl_finish"

# Make sure GTK-server cleans up the pipefile
xf "gtk_server_exit"
