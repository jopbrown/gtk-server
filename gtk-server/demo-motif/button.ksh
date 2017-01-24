#!/usr/bin/env ksh
#
# This script is here for nostalgia sake. It is the first script I ever made to create a GUI.
# It was written on a Tru64 Unix 4.0f system in a Common Desktop Environment (CDE) using Motif.
#
# It was the very inspiration to start the GTK-server project.
#
# Peter van Eerten, Jan 2017.
#
#----------------------------------------------- Original script from 2001 here.
#
# !/usr/dt/bin/dtksh
#
# activateCB()
# {
# echo "Pushbutton activated; normal termination."
# exit 0
# }
#
# XtInitialize TOPLEVEL dttest1 Dtksh $0
#
# XtSetValues $TOPLEVEL title:"Test1"
#
# XtCreateManagedWidget BBOARD bboard XmBulletinBoard $TOPLEVEL \
#	resizePolicy:RESIZE_NONE height:150 width:250 \
#	background:SkyBlue
#
# XtCreateManagedWidget BUTTON pushbutton XmPushButton $BBOARD \
#	background:goldenrod \
#	foreground:MidnightBlue \
#	labelString:"Push Here" \
#	height:30 width:100 x:75 y:60 shadowThickness:3
#
# XtAddCallback $BUTTON activateCallback activateCB
#
# XtRealizeWidget $TOPLEVEL
#
# XtMainLoop
#
#----------------------------------------------- Port to GTK-server and Kornshell here.

# GTK-server dead? Exit script
trap 'exit' SIGCHLD

# Communication functions
function motif { print -p $1; read -p MOTIF; }
function define { $2 "$3"; eval $1="${MOTIF}" >/dev/null 2>&1 ; }

# Start GTK-server in STDIN mode
gtk-server-motif -stdin -log=/tmp/log.txt -debug |&

# Application - toplevel
define TOPLEVEL motif "gtk_server_toplevel"

# Tell GTK-server how to use 'XtVaSetValues'
motif "gtk_server_redefine XtVaSetValues NONE NONE 4 WIDGET STRING STRING NULL"
# Use it
motif "XtVaSetValues $TOPLEVEL title 'Test1' NULL"

# Tell GTK-server how to use 'XtVaCreateManagedWidget'
motif "gtk_server_redefine XtVaCreateManagedWidget NONE WIDGET 12 STRING CLASS WIDGET STRING INT STRING INT STRING INT STRING INT NULL"
# Use it
define BBOARD motif "XtVaCreateManagedWidget bboard xmBulletinBoardWidgetClass $TOPLEVEL \
	resizePolicy XmRESIZE_NONE height 150 width 250 \
	background SkyBlue NULL"

# Tell GTK-server how to use 'XtVaCreateManagedWidget'
motif "gtk_server_redefine XtVaCreateManagedWidget NONE WIDGET 19 STRING CLASS WIDGET STRING STRING STRING STRING INT STRING INT STRING INT STRING INT STRING INT STRING INT NULL"
# Use it
define BUTTON motif "XtVaCreateManagedWidget button xmPushButtonWidgetClass $BBOARD \
	XtVaTypedArg XmNlabelString XmRString 'Push Here' 9 \
	height 30 width 100 x 75 y 60 shadowThickness 3 NULL"

# Connect signal
motif "gtk_server_connect $BUTTON activateCallback activateCB"

# Mainloop
until [[ $EVENT = "activateCB" ]]
do
    define EVENT motif "gtk_server_callback wait"
done

# Exit message
echo "Pushbutton activated; normal termination."

# Exit GTK-server
motif "gtk_server_exit"
