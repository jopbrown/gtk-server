#!/bin/bash
#
# Bash socket tcp demo on how to use the gtk-server - by nodep
#
# GNU bash, version 2.05b.0 needed for socket io
#
# Create as root: /dev/tcp/127.0.0.1/50000 and  chmod for user access
#  Revised for GTK-server 1.2 October 7, 2004
#  Revised for GTK-server 1.3 December 4, 2004
# Revised for GTK-server 2.1.4 at April 22, 2007
#------------------------------------------------

if [ ! -f /dev/tcp/127.0.0.1/50000 ]
then
	echo
	echo "As user root, create TCP device first:"
	echo
	echo "touch /dev/tcp/127.0.0.1/50000"
	echo "chmod 666 /dev/tcp/127.0.0.1/50000"
	echo
	exit
fi

gtk-server -tcp=127.0.0.1:50000 &

IO=/dev/tcp/127.0.0.1/50000; exec 3<>$IO

echo -e "gtk_init NULL NULL" >&3; read -r tmp <&3
echo -e "gtk_window_new 0" >&3; read -r win <&3
echo -e "gtk_window_set_title $win \"BASH GTK-SERVER\"" >&3; read -r tmp <&3
echo -e "gtk_table_new 10 10 1"	>&3; read -r tbl <&3
echo -e "gtk_container_add $win $tbl" >&3; read -r tmp <&3
echo -e "gtk_button_new_with_label \"Click to Quit\"" >&3; read -r but <&3
echo -e "gtk_table_attach_defaults $tbl $but 5 9 5 9" >&3; read -r tmp <&3
echo -e "gtk_widget_show_all $win" >&3; read -r tmp <&3

event="0"

while [ $event != $but ]; do 
	echo -e "gtk_server_callback WAIT" >&3; read -r event <&3
done

echo -e "gtk_exit 0" >&3

echo "Enjoy the day..."
