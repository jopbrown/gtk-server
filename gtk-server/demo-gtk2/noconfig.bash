#!/bin/bash
#
# Demonstration on how to use the GTK-server without configfile!
#
# 1) Check and open GTK library first with 'gtk_server_require'
# 2) Define the calls we need
#
# Tested with BASH 3.1 on Zenwalk Linux 5.2 and Slamd12
#
# July 20, 2008 PvE. GPL
#------------------------------------------------

# Name of PIPE file
declare PI=/tmp/bash.gtk.$$

# Communication function; assignment function
function gtk() { echo $1 > $PI; read GTK < $PI; }
function define() { $2 "$3"; eval $1="$GTK"; }

# Start gtk-server in FIFO mode
gtk-server -fifo=$PI -log=/tmp/$0.log &
while [ ! -p $PI ]; do continue; done

# Check and open GTK library first
PLATFORM=`uname`
if [[ "$PLATFORM" = "Darwin" ]]
then
    define AVAIL gtk "gtk_server_require /Library/Frameworks/Gtk.framework/Libraries/libgtk-quartz-2.0.0.dylib"
else
    define AVAIL gtk "gtk_server_require libgtk-x11-2.0.so"
fi

if [[ $AVAIL != "ok" ]]
then
    echo "GTK 2.x not found on your system!"
    gtk "gtk_server_exit"
    exit
fi

# Define the GTK functions we need
gtk "gtk_server_define gtk_init NONE NONE 2 NULL NULL"
gtk "gtk_server_define gtk_window_new delete-event WIDGET 1 LONG"
gtk "gtk_server_define gtk_window_set_title NONE NONE 2 WIDGET STRING"
gtk "gtk_server_define gtk_window_set_position NONE NONE 2 WIDGET LONG"
gtk "gtk_server_define gtk_table_new NONE WIDGET 3 LONG LONG BOOL"
gtk "gtk_server_define gtk_container_add NONE NONE 2 WIDGET WIDGET"
gtk "gtk_server_define gtk_button_new_with_label clicked WIDGET 1 STRING"
gtk "gtk_server_define gtk_table_attach_defaults NONE NONE 6 WIDGET WIDGET LONG LONG LONG LONG"
gtk "gtk_server_define gtk_check_button_new_with_label clicked WIDGET 1 STRING"
gtk "gtk_server_define gtk_entry_new activate WIDGET 0"
gtk "gtk_server_define gtk_widget_show_all NONE NONE 1 WIDGET"
gtk "gtk_server_define gtk_entry_get_text NONE STRING 1 WIDGET"

# Now define GUI program
gtk "gtk_init NULL NULL"
define WINDOW gtk "gtk_window_new 0"
gtk "gtk_window_set_title $WINDOW 'This is a title'"
gtk "gtk_window_set_position $WINDOW 1"
define TABLE gtk "gtk_table_new 10 10 1"
gtk "gtk_container_add $WINDOW $TABLE"
define BUTTON gtk "gtk_button_new_with_label 'Click here!'"
gtk "gtk_table_attach_defaults $TABLE $BUTTON 5 9 7 9"
define CHECK gtk "gtk_check_button_new_with_label 'Without\nconfigfile!'"
gtk "gtk_table_attach_defaults $TABLE $CHECK 1 6 1 2"
define ENTRY gtk "gtk_entry_new"
gtk "gtk_table_attach_defaults $TABLE $ENTRY 1 6 3 4"
gtk "gtk_widget_show_all $WINDOW"

# Mainloop
while [[ $EVENT != $BUTTON ]]
do
    define EVENT gtk "gtk_server_callback WAIT"

    if [[ $EVENT = $ENTRY ]]
    then
	gtk "gtk_entry_get_text $ENTRY"
	echo $GTK
    fi
done

# Exit GTK
gtk "gtk_server_exit"
