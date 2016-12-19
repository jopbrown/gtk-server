#!/bin/gawk -f
#
# Demonstration on how to use the GTK-server with Gnu AWK by IPC.
# Tested with Gnu AWK 3.1.5 on Zenwalk Linux 4.2.
#
# March 19, 2007 by Peter van Eerten.
#------------------------------------------------

function GTK(str)
{
    RESULT="gtk-server msg="PROCINFO["pid"]",\""str"\""
    RESULT |& getline
    close(RESULT)
    return $0
}

BEGIN{
    # Start GTK-server in IPC mode, use PID as unique number
    system("gtk-server ipc="PROCINFO["pid"])

    # Design GUI
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

    # Exit GTK without waiting
    GTK("gtk_exit 0")
}
