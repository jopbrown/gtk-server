#!/bin/bash
#
# Testing GtkMozEmbed - PvE - april 22, 2008 GPL.
#
#------------------------------------------------

# Name of PIPE file
declare PI=/tmp/bash.gtk.$$

#---------------------------------------------------------------------
# Communication function; assignment function
#---------------------------------------------------------------------

function gtk() { echo $1 > $PI; read GTK < $PI; }
function define() { $2 "$3"; eval $1="$GTK"; }

# -------------------------------------------------------------------------------------
# IMPORTANT!
#
# The script 'run-mozilla.sh' sets some environment variables before executing the
# webbrowser binary. The 'gtkembedmoz' widget must be linked together with the other
# Mozilla libs using 'LD_LIBRARY_PATH' in order to be used successfully.
# -------------------------------------------------------------------------------------

LIB=`locate -n 1 libgtkembedmoz.so`
if [[ -z $LIB ]]
then
    echo "No Mozilla library found!"
    exit 1
else
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${LIB%/*}
fi

# Start gtk-server in FIFO mode
gtk-server -fifo=$PI &
while [ ! -p $PI ]; do continue; done

# Define GUI
gtk "gtk_init NULL NULL"
define WINDOW gtk "gtk_window_new 0"
gtk "gtk_window_set_title $WINDOW 'My own webbrowser'"
gtk "gtk_window_set_position $WINDOW 1"
gtk "gtk_widget_set_size_request $WINDOW 700 500"
gtk "gtk_window_set_icon_name $WINDOW mozilla"

# Set the componentpath of gtkembedmoz also
gtk "gtk_moz_embed_set_comp_path ${LIB%/*}"

# Store a temporary profile in /tmp so my profile will be save
gtk "gtk_moz_embed_set_profile_path /tmp mozilla"

# Create the widget
define MOZ gtk "gtk_moz_embed_new"
gtk "gtk_container_add $WINDOW $MOZ"

# Load some URL
gtk "gtk_moz_embed_load_url $MOZ 'http://www.gtk-server.org'"
gtk "gtk_widget_show_all $WINDOW"

# Load external file example.
#gtk "gtk_moz_embed_open_stream $MOZ \"file://\" \"text/html\""
#while read LINE
#do
#    gtk "gtk_moz_embed_append_data $MOZ '$LINE' ${#LINE}"
#done < somepage.html

# Mainloop
while [[ $EVENT != $WINDOW ]]
do
    define EVENT gtk "gtk_server_callback WAIT"
done

# Exit GTK
gtk "gtk_server_exit"
