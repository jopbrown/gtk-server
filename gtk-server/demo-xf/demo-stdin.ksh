#!/bin/ksh
#
# Demo with XForms
# Tested with GTK-server 2.1.1 compiled for XForms and PDKSH 5.2.14
# -----------------------------------------------------------------

# Communication function; $1 contains the string to be send
function xf
{
print -p $1
read -p RESULT
}

# Start GTK-server in STDIN mode
gtk-server -stdin -log=/tmp/$0.log |&

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

EVENT="0"

until [[ $EVENT = $YBUT ]]
do
    xf "gtk_server_callback WAIT"
    EVENT=$RESULT

    case $EVENT in

	$YBUT)
	    echo "YES button clicked";;

	$NBUT)
	    echo "NO button clicked";;

    esac
done

xf "fl_finish"

# Exit server
xf "gtk_server_exit"
