#------------------------------------------------------------------------
#
# Simple demonstration with Webkit. December 2016 - PvE.
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
gtk-server-gtk3 -fifo=$PIPE -debug -detach

# Make sure the PIPE file is available
while [ ! -p $PIPE ]; do continue; done

# Get GtkSheet
REQ=$(gtk "gtk_server_require libwebkitgtk-3.0.so")
if [[ $REQ != "ok" ]]
then
    echo "No libwebkit library found!"
    exit 1
fi

# Import function
com "gtk_server_define webkit_web_view_new NONE WIDGET 0"
com "gtk_server_define webkit_web_view_load_uri NONE NONE 2 WIDGET STRING"

# Setup GUI
com "gtk_init NULL NULL"
WIN=$(gtk "gtk_window_new GTK_WINDOW_TOPLEVEL")
com "gtk_window_set_title $WIN 'Minimal Web Browser with BASH and GTK-server'"
com "gtk_window_set_default_size $WIN 1024 600"
BOX=$(gtk "gtk_vbox_new 0 0")
# Create entry to enter URL
URL=$(gtk "gtk_entry_new")
com "gtk_box_pack_start $BOX $URL 0 0 1"
# Create HTML renderer
HTML=$(gtk "webkit_web_view_new")
SCROLL=$(gtk "gtk_scrolled_window_new 0 0")
com "gtk_scrolled_window_set_policy $SCROLL 1 1"
com "gtk_scrolled_window_set_shadow_type $SCROLL 3"
com "gtk_container_add $SCROLL $HTML"
com "gtk_box_pack_start $BOX $SCROLL 1 1 1"
# Load gtk-server.org by default
com "gtk_entry_set_text $URL 'http://www.gtk-server.org'"
com "webkit_web_view_load_uri $HTML 'http://www.gtk-server.org'"
# Pack everything together and wait for event
com "gtk_container_add $WIN $BOX"
com "gtk_widget_show_all $WIN"

EVENT=0

while [[ $EVENT -ne $WIN ]]
do 
    EVENT=$(gtk "gtk_server_callback WAIT")

    if [[ $EVENT = $URL ]]
    then
	GO=$(gtk "gtk_entry_get_text $URL")
	if [[ $GO != +(http://*) ]]
	then
	    GO="http://$GO"
	    com "gtk_entry_set_text $URL $GO"
	fi
	com "webkit_web_view_load_uri $HTML $GO"
    fi
	
done

# Exit GTK
com "gtk_server_exit"
