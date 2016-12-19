#!/usr/local/bin/tcsh
#
# Cshell named pipe demo with the GTK-server
# Tested with TCSH on Zenwalk 4.8.
#
# March 14, 2004 by Peter van Eerten
# Improved coding syntax at May 13, 2008
#------------------------------------------------

# Define communication function
alias gtk 'echo \!* > /tmp/gtk; set R = `cat /tmp/gtk`; if ($R != "ok") echo $R'

# Start GTK-server
gtk-server -fifo=/tmp/gtk -log=/tmp/gtk-server.log &

# Make sure the PIPE file is available
while ( ! -p /tmp/gtk)
    continue
end

# Main program
gtk "gtk_init NULL NULL"
set WINDOW = `gtk "gtk_window_new 0"`
gtk "gtk_window_set_title $WINDOW 'C-shell with GTK-server!'"
gtk "gtk_window_set_default_size $WINDOW 400 200"
gtk "gtk_window_set_position $WINDOW 1"
set TBL = `gtk "gtk_table_new 10 10 1"`
gtk "gtk_container_add $WINDOW $TBL"
set BUT = `gtk "gtk_button_new_with_label 'Click here to exit'"`
gtk "gtk_table_attach_defaults $TBL $BUT 5 9 5 9"
gtk "gtk_widget_show_all $WINDOW"

set EVENT="0"

# Mainloop
while (($EVENT != $BUT) && ($EVENT != $WINDOW))
    set EVENT = `gtk "gtk_server_callback wait"`
end

# Exit GTK
gtk "gtk_server_exit"
