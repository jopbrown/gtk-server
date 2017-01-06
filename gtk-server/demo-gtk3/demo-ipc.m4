divert(-1)dnl
#-----------------------------------------------------------
# GTK-server demonstration with the M4 macro language
#
# Tested with GTK-server 2.1.6 and GNU M4 1.4.6
#
# (c) Peter van Eerten, september 22, 2007 - GPL
# Adapted for GTK-server 2.3.1 at January 4, 2009 - PvE.
#
# Rewritten, improved and tested with GTK-server 2.4.1
#  (using GTK3) in december 2016 - Peter van Eerten
#-----------------------------------------------------------

syscmd(`gtk-server -ipc=1 -debug -detach')

define(gtk, `esyscmd(`gtk-server -nonl -msg=1,`$@'')')

#-----------------------------------------------------------

gtk("gtk_init NULL NULL")

define(win, gtk("gtk_window_new 0"))
gtk("gtk_window_set_title win 'M4 demo with GTK'")
gtk("gtk_window_set_default_size win 400 200")
gtk("gtk_window_set_position win 1")

define(tbl, gtk("gtk_table_new 10 10 1"))
gtk("gtk_container_add win tbl")

define(button, gtk("gtk_button_new_from_icon_name window-close GTK_ICON_SIZE_DND"))
gtk("gtk_button_set_label button 'Quit this dialogue'")
gtk("gtk_table_attach_defaults tbl button 6 9 7 9")

define(entry, gtk("gtk_entry_new"))
gtk("gtk_table_attach_defaults tbl entry 1 6 1 3")

define(label, gtk("gtk_label_new 'GTK-server works with M4!'"))
gtk("gtk_table_attach_defaults tbl label 1 4 6 8")
gtk("gtk_widget_show_all win")

define(callback, `gtk("gtk_server_callback wait")')

define(entry_cb, `divert(0)'`Contents: gtk("gtk_entry_get_text entry")'`divert(-1)')
define(exit_cb, `gtk("gtk_server_exit")' `m4exit(0)')

define(event, `ifelse($1, entry, `entry_cb', $1, button, `exit_cb')')

define(mainloop, define(`cb',`callback') `event(cb)' `mainloop')

mainloop
