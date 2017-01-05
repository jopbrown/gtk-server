divert(-1)dnl
#-----------------------------------------------------------
# GTK-server demonstration with the M4 macro language 1.4.17
#
# Created for the FIFO interface with GTK-server 2.4.2
#  (using GTK3) in january 2017 - Peter van Eerten
#-----------------------------------------------------------

syscmd(`gtk-server -fifo=/tmp/m4.fifo -debug -detach')

define(gtk, `syscmd(`echo `$@'>/tmp/m4.fifo')'`include(`/tmp/m4.fifo')')

#-----------------------------------------------------------

gtk("gtk_init NULL NULL")

define(win, gtk("gtk_window_new 0"))
gtk("gtk_window_set_title win \"M4 demo with GTK\"")
gtk("gtk_window_set_default_size win 400 200")
gtk("gtk_window_set_position win 1")

define(tbl, gtk("gtk_table_new 10 10 1"))
gtk("gtk_container_add win tbl")

define(button, gtk("gtk_button_new_from_icon_name window-close GTK_ICON_SIZE_DND"))
gtk("gtk_button_set_label button \"Quit this dialogue\"")
gtk("gtk_table_attach_defaults tbl button 6 9 7 9")

define(entry, gtk("gtk_entry_new"))
gtk("gtk_table_attach_defaults tbl entry 1 6 1 3")

define(label, gtk("gtk_label_new \"GTK-server works with M4!\""))
gtk("gtk_table_attach_defaults tbl label 1 4 6 8")
gtk("gtk_widget_show_all win")

define(callback, `gtk("gtk_server_callback wait")')

define(entry_cb, `divert(0)'`Contents: gtk("gtk_entry_get_text entry")'`divert(-1)')
define(exit_cb, `gtk("gtk_server_exit")' `m4exit(0)')

define(event, `ifelse($1, entry, `entry_cb', $1, button, `exit_cb')')

define(mainloop, define(`cb', `callback') `event(cb)' `mainloop')

mainloop
