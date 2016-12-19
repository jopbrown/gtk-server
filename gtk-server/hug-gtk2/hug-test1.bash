#!/bin/bash
#
# Demo with HUG - this is how small your GUI code can be!
#
# April 2008 - Peter van Eerten - GPL.
#
#-------------------------------------------------------

# Name of PIPE file
declare PI=/tmp/bash.gtk.$$

# Define SIGUSR1 here and perform an exit if this
# signal occurs. Handy for debugging.
trap 'exit' SIGUSR1

# Communication function; assignment function
function gtk() { echo $1 > $PI; read GTK < $PI; }
function define() { $2 "$3"; eval $1="$GTK"; }

# Start gtk-server in FIFO mode
gtk-server -fifo=$PI -log=/tmp/$0.log &
while [ ! -p $PI ]; do continue; done

# Define GUI - mainwindow
define WIN gtk "u_window \"'HUG demo'\" 400 300"
# Attach frame
define FRAME gtk "u_frame 390 245"
gtk "u_attach $WIN $FRAME 5 5"
gtk "u_frame_text $FRAME \"' Draw on canvas '\""
# Create buttons
define EXIT gtk "u_button _Exit 70 40"
gtk "u_attach $WIN $EXIT 325 255"
define ABOUT gtk "u_button _Button 70 40 1"
gtk "u_attach $WIN $ABOUT 5 255"
gtk "u_bgcolor $ABOUT #00CC00 #009900 #00FF00"
# Label
define LABEL gtk "u_label \"'Created with HUG!'\" 220 20"
gtk "u_font $LABEL \"'Courier Italic 15'\""
gtk "u_fgcolor $LABEL #0000EE"
gtk "u_attach $WIN $LABEL 100 265"
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
done

gtk "u_end"
