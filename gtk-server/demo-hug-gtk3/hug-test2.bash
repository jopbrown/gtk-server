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
gtk-server-gtk3 -fifo=$PI &
while [ ! -p $PI ]; do continue; done

# Define GUI - mainwindow
define WIN gtk "m_window \"'Testing testing 123'\" 500 500"
gtk "m_bgcolor $WIN #aaE8aa"
# Define multiline textfield
define TXT gtk "m_text 480 200"
gtk "m_attach $WIN $TXT 10 10"
gtk "m_basecolor $TXT #AAAA00"
gtk "m_textcolor $TXT #FFFF33"
gtk "m_text_text $TXT \"'Start typing here...'\""
gtk "m_font $TXT \"'Monospace 12'\""
# Define a multiline list
define LIST gtk "m_list 480 220"
gtk "m_attach $WIN $LIST 10 220"
gtk "m_list_text $LIST Hello"
gtk "m_list_text $LIST \"'This is a list box'\""
gtk "m_list_text $LIST \"'1 2 3'\""
gtk "m_list_text $LIST \"'We can add many items here'\""
gtk "m_list_text $LIST \"'...and even more'\""
gtk "m_font $LIST \"'Serif 10'\""
gtk "m_basecolor $LIST #5555FF"
gtk "m_fgcolor $LIST #FFFF22"
# Create buttons
define GET gtk "m_stock gtk-info 100 40"
gtk "m_attach $WIN $GET 10 450"
define EXIT gtk "m_stock gtk-quit 100 40"
gtk "m_attach $WIN $EXIT 390 450"
# Create entry
define COMBO gtk "m_combo \"'bla 123'\" 200 30"
gtk "m_combo_text $COMBO \"'more text'\""
gtk "m_bgcolor $COMBO #00FF00 #00FF00 #00FF00 #00FF00 #00FF00"
gtk "m_textcolor $COMBO #FF00FF #FF00FF #FF00FF #FF00FF #FF00FF"
gtk "m_attach $WIN $COMBO 130 450"
gtk "m_combo_set $COMBO 0"
# Focus to textwidget
gtk "m_focus $TXT"

# Mainloop
while [[ $EVENT != $EXIT && $EVENT != $WIN ]]
do
    define EVENT gtk "m_event"

    case $EVENT in

	$GET)
	    define RESULT gtk "m_list_grab $LIST"
	    echo ${RESULT};;
	$COMBO)
	    define RESULT gtk "m_combo_grab $COMBO"
	    echo ${RESULT};;
    esac
done

gtk "m_end"
