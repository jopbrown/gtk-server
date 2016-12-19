#!/usr/bin/tclsh 
#
# Tcl demo with GTK-server 1.3 using STDIN
#
# Tested with Tcl 8.4.6 on Slackware Linux 10.1
#
# Feb 27, 2005 - PvE.
#---------------------------------------------------

# GTK communication function
proc gtk str {

	global IO

	puts $IO $str
	flush $IO
	gets $IO tmp
	return $tmp
}

# Create bidirectional pipe
set IO [open "| gtk-server stdin" r+]

# Build GUI
gtk "gtk_init NULL NULL"
set win [gtk "gtk_window_new 0"]
gtk "gtk_window_set_title $win \"Tcl GTK-server demo\""
gtk "gtk_widget_set_usize $win 300 100"
gtk "gtk_window_set_position $win 1"
set tbl [gtk "gtk_table_new 20 20 1"]
gtk "gtk_container_add $win $tbl" 
set but [gtk "gtk_button_new_with_label \"Click to Quit\""]
gtk "gtk_table_attach_defaults $tbl $but 12 19 12 19"
set lab [gtk "gtk_label_new \"Tcl uses GTK now!!\""]
gtk "gtk_table_attach_defaults $tbl $lab 1 15 1 10"
gtk "gtk_widget_show_all $win"

# Initialize
set event 0

# Mainloop
while { $event != $but & $event != $win} { 
	set event [gtk "gtk_server_callback WAIT"] 
}

# Exit GTK-server
gtk "gtk_exit 0"

# Close pipe
close $IO
