#!/bin/ksh
#
# Demo with HUG - this is how small your GUI code can be!
#
# April 2008 - Peter van Eerten - GPL.
#
#-------------------------------------------------------

# Define SIGUSR1 here and perform an exit if this
# signal occurs. Handy for debugging.
trap 'exit' 10

# Communication function; assignment function
function gtk { print -p $1; read -p GTK; }
function define { $2 "$3"; eval $1=$GTK; }

# Start GTK-server in STDIN mode
gtk-server -stdin -log=/tmp/hug-test1.log |&

# Define GUI - mainwindow
define WIN gtk "u_window \"'HUG demo'\" 400 300"
# Attach frame
define FRAME gtk "u_frame 390 245"
gtk "u_attach $WIN $FRAME 5 5"
gtk "u_frame_text $FRAME \"' Draw on canvas '\""
# Create buttons
define EXIT gtk "u_button _Exit 70 40"
gtk "u_attach $WIN $EXIT 325 255"
define ABOUT gtk "u_button _Button 70 40"
gtk "u_attach $WIN $ABOUT 5 255"
gtk "u_bgcolor $ABOUT #00CC00 #009900 #00FF00"
gtk "u_fgcolor $ABOUT #FFFF00 #FFFF00 #FFFF00"
# Label
define LABEL gtk "u_label \"'Created with HUG!'\" 220 20"
gtk "u_font $LABEL \"'Courier Italic 12'\""
gtk "u_fgcolor $LABEL #0000EE"
gtk "u_attach $WIN $LABEL 100 275"
# Check button
define CHECK gtk "u_check \"'Check button'\" 200 20"
gtk "u_bgcolor $CHECK #00CC00 #009900 #00FF00"
gtk "u_fgcolor $CHECK #0000EE #0000EE #0000EE"
gtk "u_attach $WIN $CHECK 100 255"
# Setup the drawing canvas, draw stuff
define CANVAS gtk "u_canvas 380 225"
gtk "u_attach $WIN $CANVAS 10 20"
gtk "u_circle #FF0000 100 100 100 100 1"
gtk "u_square #FFFF00 200 50 60 60 1"
gtk "u_line #0000FF 10 180 60 60"
gtk "u_font $CANVAS \"'Arial Italic 18'\""
gtk "u_out \"'Hello cruel world'\" #0000FF #e0e000 10 10"

# Mainloop
while [[ $EVENT != $EXIT && $EVENT != $WIN ]]
do
    define EVENT gtk "u_event"

    case $EVENT in
	"button-press")
	    define MBUT gtk "u_mouse 2"
	    define X gtk "u_mouse 0"
	    define Y gtk "u_mouse 1"
	    echo "Mouse button $MBUT pressed at coords $X, $Y";;
	"scroll-event")
	    define MBUT gtk "u_mouse 3"
	    define X gtk "u_mouse 0"
	    define Y gtk "u_mouse 1"
	    echo "Mouse scroll $MBUT used at coords $X, $Y";;
    esac

done

gtk "u_end"
