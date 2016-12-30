#!/usr/bin/m4
divert(-1)dnl

#-----------------------------------------------------------
# GTK-server demonstration with the M4 macro language
#
# Tested with GTK-server 2.1.6 and GNU M4 1.4.6
#
# (c) Peter van Eerten, september 22, 2007 - GPL
# Adapted for GTK-server 2.3.1 at January 4, 2009 - PvE.
#-----------------------------------------------------------

syscmd(`gtk-server -ipc=1 -debug -detach')

define(`get', `defn(format(``get[%s]'', `$1'))')
define(`set', `define(format(``get[%s]'', `$1'), `$2')')

define(`gtk', `esyscmd(`gtk-server -msg=1,`$@'')' )

define(`repeat',`$1 ifelse(eval($2),0,`repeat(`$1',`$2')')')

#-----------------------------------------------------------

gtk("gtk_init NULL NULL")
set(`win', gtk("gtk_window_new 0"))
gtk(format("gtk_window_set_title %s 'M4 demo with GTK'", get(`win')))
gtk(format("gtk_window_set_default_size %s 400 200", get(`win')))
gtk(format("gtk_window_set_position %s 1", get(`win')))
set(`tbl', gtk("gtk_table_new 10 10 1"))
gtk(format("gtk_container_add %s %s", get(`win'), get(`tbl')))
set(`but', gtk("gtk_button_new_with_label 'Exit button \n click here'"))
gtk(format("gtk_table_attach_defaults %s %s 5 9 5 9", get(`tbl'), get(`but')))
set(`entry', gtk("gtk_entry_new"))
gtk(format("gtk_table_attach_defaults %s %s 1 6 1 3", get(`tbl'), get(`entry')))
set(`label', gtk("gtk_label_new 'GTK-server is very cool!'"))
gtk(format("gtk_table_attach_defaults %s %s 1 4 6 8", get(`tbl'), get(`label')))
gtk(format("gtk_widget_show_all %s", get(`win')))

# This is the mainloop
define(`text',`Contents: gtk(format("gtk_entry_get_text %s", get(`entry')))')
define(`entry', `ifelse(get(`cb'), get(`entry'),`text')')
define(`callback', `set(`cb', gtk("gtk_server_callback wait"))')
define(`body', `callback' `entry')

divert(0)dnl
repeat(`body', `get(`cb')==get(`but')||get(`cb')==get(`win')')dnl

gtk("gtk_server_exit")dnl
