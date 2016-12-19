#!/bin/bash
#
# Run GTK-server in socket mode.
#
# 1) /etc/services: add the line 'demo 50000/tcp'
# 2) /etc/inetd.conf: add the line 'demo stream tcp nowait nobody /some/dir/demo-sock.bash'
# 3) kill -HUP on the inetd daemon
# 4) from some other machine or local machine run: gtk-server -sock=host:50000
#
# Run a GUI from a server on a localmachine. Nov 9 2009 - (c) PvE.
#
#------------------------------------------------

function gtk()
{
echo $@
read GTK
}

# Setup GUI
gtk "gtk_init NULL NULL"
gtk "gtk_window_new 0"
WIN=$GTK
gtk "gtk_window_set_title $WIN 'Bourne GTK-SERVER demo'"
gtk "gtk_window_set_default_size $WIN 400 200"
gtk "gtk_window_set_position $WIN 1"
gtk "gtk_table_new 10 10 1"
TBL=$GTK
gtk "gtk_container_add $WIN $TBL"
gtk "gtk_button_new_with_label 'Click to Quit'"
BUT=$GTK
gtk "gtk_table_attach_defaults $TBL $BUT 5 9 5 9"
gtk "gtk_widget_show_all $WIN"

# Mainloop
until [[ $EVENT = $BUT ]]
do 
    gtk "gtk_server_callback wait"
    EVENT=$GTK
done

# Exit GTK
echo "gtk_server_exit"
