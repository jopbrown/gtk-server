#!/usr/bin/gawk -f
#
# Demonstration on how to use the GTK-server with Gnu AWK by UDP.
# Tested with Gnu AWK 3.1.3 on Slackware Linux 10.
#
# July 28, 2004 by Peter van Eerten.
# Revised for GTK-server 1.2 October 8, 2004 by PvE.
# Revised for GTK-server 1.3 December 5, 2004 by PvE.
# Revised for GTK-server 2.1.4 at April 22, 2007 - PvE.
# Revised for GTK-server 2.3.1 to use handles at December 10, 2008 - PvE.
# Tested with GTK-server 2.4.1 in december 2016 - PvE
#
#----------------------------------------------------------------------
# 
# UDP Communication function
# Contains basic sync checking with -handle

function GTK(str)
{
HANDLE+=1

do {
    print HANDLE, str |& UDP
    if(str == "gtk_server_exit") exit
    UDP |& getline TMP
} while (int(substr(TMP, 1, index(TMP, " "))) != HANDLE)

return substr(TMP, index(TMP, " ")+1)
}

#----------------------------------------------------------------------

BEGIN{
system("gtk-server -udp=localhost:50002 -handle -detach -log=/tmp/gtk-server.log")

# Setup TCP socket to server
UDP = "/inet/udp/0/localhost/50002"

HANDLE = 0

# Now define the GUI
GTK("gtk_init NULL NULL")
WINDOW = GTK("gtk_window_new 0")
GTK("gtk_window_set_title " WINDOW " 'This is a title'")
GTK("gtk_window_set_default_size " WINDOW " 100 100")
GTK("gtk_window_set_position " WINDOW " 1")
TABLE = GTK("gtk_table_new 30 30 1")
GTK("gtk_container_add " WINDOW " " TABLE)
BUTTON1 = GTK("gtk_button_new_with_label Exit")
GTK("gtk_table_attach_defaults " TABLE " " BUTTON1 " 17 28 20 25")
BUTTON2 = GTK("gtk_button_new_with_label 'Print text'")
GTK("gtk_table_attach_defaults " TABLE " " BUTTON2 " 2 13 20 25")
ENTRY = GTK("gtk_entry_new")
GTK("gtk_table_attach_defaults " TABLE " " ENTRY " 2 28 5 15")
GTK("gtk_widget_show_all " WINDOW)

# Connect extra signal
GTK("gtk_server_connect " BUTTON1 " enter Blabla")
GTK("gtk_server_connect " BUTTON2 " enter 'Do not get here'")

# Mainloop
do {

    EVENT = GTK("gtk_server_callback wait")

    if (EVENT == BUTTON2){
	TMP = GTK("gtk_entry_get_text " ENTRY)
	print "This is the contents: " TMP
    }

    if (EVENT == "Blabla") print "Extra signal for EXIT button!"
    if (EVENT == "Do not get here") print "Extra signal for PRINT button!"

} while (EVENT != BUTTON1)

# Exit GTK
GTK("gtk_server_exit")
}
