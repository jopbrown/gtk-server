#!/bin/gawk -f
#
# Demonstration on how to use the GTK-server with Gnu AWK by FIFO
# Tested with Gnu AWK 3.1.3 on Slackware Linux 10.
#
# March 15, 2004 by Peter van Eerten.
# Revised at july 29, 2004.
# Revised for GTK-server 1.2 October 7, 2004
# Revised for GTK-server 1.3 December 5, 2004
# Revised for GTK-server 2.0.6 at december 17, 2005
# Revised for GTK-server 2.0.8 at january 7, 2006
# Tested with GTK-server 2.4 in december 2016 - PvE
#-------------------------------------------

function pause(seconds, l_now)
{
l_now = systime()
while (systime() != l_now + seconds){}
}

#-------------------------------------------

function GUI(call)
{
print call >> "/tmp/demo"
close("/tmp/demo", "to")
getline < "/tmp/demo"
close("/tmp/demo", "from")
return $0
}

#-------------------------------------------

BEGIN{

# Start gtk-server using FIFO
system("gtk-server -fifo=/tmp/demo &")
pause(1)

# Build GUI
GUI("gtk_init NULL NULL")
WINDOW = GUI("gtk_window_new 0")
GUI("gtk_window_set_title " WINDOW " \"This is a title\"")
GUI("gtk_window_set_default_size " WINDOW " 100 100")
GUI("gtk_window_set_position " WINDOW " 1")
TABLE = GUI("gtk_table_new 30 30 1")
GUI("gtk_container_add " WINDOW " " TABLE)
BUTTON1 = GUI("gtk_button_new_with_label Exit")
GUI("gtk_table_attach_defaults " TABLE " " BUTTON1 " 17 28 20 25")
BUTTON2 = GUI("gtk_button_new_with_label \"Print text\"")
GUI("gtk_table_attach_defaults " TABLE " " BUTTON2 " 2 13 20 25")
ENTRY = GUI("gtk_entry_new")
GUI("gtk_table_attach_defaults " TABLE " " ENTRY " 2 28 5 15")
GUI("gtk_widget_show_all " WINDOW)

EVENT = 0

# This is the mainloop
do {
    EVENT = GUI("gtk_server_callback WAIT")
    if (EVENT == BUTTON2){
	TMP = GUI("gtk_entry_get_text " ENTRY)
	print "This is the contents: " TMP
    }
} while (EVENT != BUTTON1 && EVENT != WINDOW)

# Exit GTK
GUI("gtk_server_exit")
}
