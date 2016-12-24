#------------------------------------------------------------------------
#
# Simple demonstration with GtkSheet. December 2016 - PvE.
#
#------------------------------------------------------------------------

# Name of PIPE file
declare PIPE=/tmp/bash.gtk.$$

# Communicate with GTK-server
gtk()
{
    echo $@ > $PIPE
    read RESULT < $PIPE
    echo $RESULT
}

com()
{
    echo $@ > $PIPE
    read RESULT < $PIPE
}

#------------------------ Main starts here

# Start gtk-server
gtk-server -fifo=$PIPE -log=/tmp/gtk-server.log &

# Make sure the PIPE file is available
while [ ! -p $PIPE ]; do continue; done

# Get GtkSheet
REQ=$(gtk "gtk_server_require libgtkextra-x11-3.0.so")
if [[ $REQ != "ok" ]]
then
    echo "No GtkExtra library found!"
    exit 1
fi

# Import function
com "gtk_server_define gtk_sheet_new NONE WIDGET 3 INT INT STRING"

# Setup GUI
com "gtk_init NULL NULL"
WIN=$(gtk "gtk_window_new GTK_WINDOW_TOPLEVEL")
com "gtk_window_set_default_size $WIN 600 400"
BOX=$(gtk "gtk_vbox_new 0 1")
SCROLL=$(gtk "gtk_scrolled_window_new NULL NULL")
com "gtk_container_add $WIN $BOX"
com "gtk_box_pack_start $BOX $SCROLL 1 1 1"
SHEET=$(gtk "gtk_sheet_new 5 5 'Edit table'")
com "gtk_container_add $SCROLL $SHEET"
com "gtk_widget_show_all $WIN"

EVENT=0

while [[ $EVENT -ne $WIN ]]
do 
    EVENT=$(gtk "gtk_server_callback WAIT")
done

# Exit GTK
com "gtk_server_exit"
