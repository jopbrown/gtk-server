#!/usr/local/bin/slsh
%--------------------------------------------------------------------
%
% Demo for GTK-server 2.0.7 with S-Lang
%
% Tested with S-Lang 2.0.5 on Slackware 10 --- http://www.s-lang.org/
%
% Dec 17, 2005 - PvE.
%
%--------------------------------------------------------------------

import("gtk");

% Optionally enable GTK logging
() = gtk ("gtk_server_cfg log=/tmp/gtk-server.log");

% Declare variables
variable WIN, TBL, BUT, LAB, EVENT;

% Build GUI
() = gtk ("gtk_init NULL NULL");
WIN = gtk ("gtk_window_new 0");
() = gtk ("gtk_widget_set_usize " + WIN + " 300 100");
() = gtk ("gtk_window_set_title " + WIN + " \"S-Lang with GTK\"");
() = gtk ("gtk_window_set_position " + WIN + " 1");
TBL = gtk ("gtk_table_new 20 20 1");
() = gtk ("gtk_container_add " + WIN + " " + TBL);
BUT = gtk ("gtk_button_new_with_label \"Click to Quit\"");
() = gtk ("gtk_table_attach_defaults " + TBL + " " + BUT + " 12 19 12 19");
LAB = gtk ("gtk_label_new \"S-Lang uses GTK now!!\"");
() = gtk ("gtk_table_attach_defaults " + TBL + " " + LAB + " 1 15 1 10");
() = gtk ("gtk_widget_show_all " + WIN);

% Mainloop
do {
	EVENT = gtk("gtk_server_callback wait");
} while (EVENT != BUT and EVENT != WIN);

% Exit GTK-server
() = gtk ("gtk_exit 0");

% Exit
exit (0);
