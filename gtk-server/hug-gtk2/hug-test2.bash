#!/bin/bash
#
# Testing the multiline text widget and list widget
#----------------------------------------------------

# Name of PIPE file
declare PI=/tmp/bash.gtk.$$

# Communication function; assignment function
function gtk() { echo $1 > $PI; read GTK < $PI; }
function define() { $2 "$3"; eval $1="\"$GTK\""; }

# Start gtk-server in FIFO mode
gtk-server -fifo=$PI &
while [ ! -p $PI ]; do continue; done

# Define GUI - mainwindow
define WIN gtk "u_window \"'Testing testing 123'\" 500 500"
gtk "u_bgcolor $WIN #aaE8aa"
# Define multiline textfield
define TXT gtk "u_text 480 200"
gtk "u_attach $WIN $TXT 10 10"
gtk "u_basecolor $TXT #AAAA00"
gtk "u_textcolor $TXT #FFFF33"
gtk "u_text_text $TXT \"'Start typing here...'\""
gtk "u_font $TXT \"'Monospace 12'\""
# Define a multiline list
define LIST gtk "u_list 480 220"
gtk "u_attach $WIN $LIST 10 220"
gtk "u_list_text $LIST Hello"
gtk "u_list_text $LIST \"'This is a list box'\""
gtk "u_list_text $LIST \"'1 2 3'\""
gtk "u_list_text $LIST \"'We can add many items here'\""
gtk "u_list_text $LIST \"'...and even more'\""
gtk "u_font $LIST \"'Serif 10'\""
gtk "u_basecolor $LIST #5555FF"
gtk "u_fgcolor $LIST #FFFF22"
# Create buttons
define GET gtk "u_stock gtk-info 100 40"
gtk "u_attach $WIN $GET 10 450"
define EXIT gtk "u_stock gtk-quit 100 40"
gtk "u_attach $WIN $EXIT 390 450"
# Create entry
define COMBO gtk "u_combo \"'bla 123'\" 200 30"
gtk "u_combo_text $COMBO \"'more text'\""
gtk "u_bgcolor $COMBO #00FF00 #00FF00 #00FF00 #00FF00 #00FF00"
gtk "u_textcolor $COMBO #FF00FF #FF00FF #FF00FF #FF00FF #FF00FF"
gtk "u_attach $WIN $COMBO 130 450"
# Focus to textwidget
gtk "u_focus $TXT"

# Mainloop
while [[ $EVENT != $EXIT && $EVENT != $WIN ]]
do
    define EVENT gtk "u_event"

    case $EVENT in

	$GET)
	    define RESULT gtk "u_list_grab $LIST"
	    echo ${RESULT};;
    esac
done

gtk "u_end"
