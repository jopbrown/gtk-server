#------------------------------------------------------------------------
#
# Simple demonstration with GtkSheet. December 2016 - PvE.
#
#------------------------------------------------------------------------

# Name of PIPE file
declare PIPE=/tmp/bash.gtk.$$

function gtk
{
    echo $@ > $PIPE
    read RESULT < $PIPE

    if [[ $RESULT != "ok" || $@ = +(*gtk_server_require*) ]]
    then
        echo $RESULT
    fi
}

#------------------------ Main starts here

# Start gtk-server
gtk-server-gtk2 -fifo=$PIPE -log=/tmp/gtk-server.log -detach

# Make sure the PIPE file is available
while [ ! -p $PIPE ]; do continue; done

# Get GtkSheet
REQ=$(gtk "gtk_server_require libgtkextra-x11-3.0.so")
if [[ $REQ != "ok" ]]
then
    echo "No GtkExtra library found!"
    exit 1
fi

# Import functions
gtk "gtk_server_define gtk_sheet_new activate WIDGET 3 INT INT STRING"
gtk "gtk_server_define gtk_sheet_get_selection NONE BOOL 3 WIDGET PTR_INT PTR_BASE64"

# Important: define data format for PTR_BASE64
gtk "gtk_server_data_format %i%i%i%i"

# Setup GUI
gtk "gtk_init NULL NULL"
WIN=$(gtk "gtk_window_new GTK_WINDOW_TOPLEVEL")
gtk "gtk_window_set_default_size $WIN 600 400"
BOX=$(gtk "gtk_vbox_new 0 1")
SCROLL=$(gtk "gtk_scrolled_window_new NULL NULL")
gtk "gtk_container_add $WIN $BOX"
gtk "gtk_box_pack_start $BOX $SCROLL 1 1 1"
SHEET=$(gtk "gtk_sheet_new 5 5 'Edit table'")
gtk "gtk_container_add $SCROLL $SHEET"
gtk "gtk_widget_show_all $WIN"

EVENT=0

# Mainloop
while [[ $EVENT -ne $WIN ]]
do 
    EVENT=$(gtk "gtk_server_callback WAIT")

    # At each event obtain the cell selected, use dummy args
    CHECK=$(gtk "gtk_sheet_get_selection ${SHEET} 0 0")

    # Decode returned range
    echo $(gtk "gtk_server_unpack %i%i%i%i ${CHECK##* }")
done

# Exit GTK
gtk "gtk_server_exit"
