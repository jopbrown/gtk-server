#!/usr/bin/gawk -f
#
# Demonstration on how to use the GTK-server with Gnu AWK by TCP.
# Tested with Gnu AWK 3.1.3 on Slackware Linux 10.
#
# September 27, 2003 by Peter van Eerten.
# Revised for GTK-server 1.2 October 7, 2004
# Revised for GTK-server 1.3 December 5, 2004
# Revised for GTK-server 2.1.4 at April 22, 2007
# Tested with GTK-server 2.4.1 in december 2016 - PvE
#------------------------------------------------

BEGIN{
system("gtk-server -tcp=localhost:50001 -log=/tmp/log.txt -detach")
# Setup TCP socket to server
GTK = "/inet/tcp/0/localhost/50001"
# Now define the GUI
print "gtk_init NULL NULL" |& GTK; GTK |& getline TMP
print "gtk_window_new 0" |& GTK; GTK |& getline WINDOW
print "gtk_window_set_title " WINDOW " \"Using the TCP gtk-server\"" |& GTK; GTK |& getline TMP
print "gtk_window_set_default_size " WINDOW " 100 100" |& GTK; GTK |& getline TMP
print "gtk_window_set_position " WINDOW " 1" |& GTK; GTK |& getline TMP
print "gtk_table_new 30 30 1" |& GTK; GTK |& getline TABLE
print "gtk_container_add " WINDOW " " TABLE |& GTK; GTK |& getline TMP 
print "gtk_button_new_with_label Exit" |& GTK; GTK |& getline BUTTON1
print "gtk_table_attach_defaults " TABLE " " BUTTON1 " 17 28 20 25" |& GTK; GTK |& getline TMP 
print "gtk_button_new_with_label \"Print text\"" |& GTK; GTK |& getline BUTTON2
print "gtk_table_attach_defaults " TABLE " " BUTTON2 " 2 13 20 25" |& GTK; GTK |& getline TMP 
print "gtk_entry_new" |& GTK; GTK |& getline ENTRY
print "gtk_table_attach_defaults " TABLE " " ENTRY " 2 28 5 15" |& GTK; GTK |& getline TMP 
print "gtk_widget_show_all " WINDOW |& GTK; GTK |& getline TMP

do {
    print "gtk_server_callback WAIT" |& GTK; GTK |& getline EVENT
    if (EVENT == BUTTON2){
	print "gtk_entry_get_text " ENTRY |& GTK; GTK |& getline TMP
	print "This is the contents: " TMP
    }
} while (EVENT != BUTTON1)

print "gtk_server_exit" |& GTK
close(GTK)
}
