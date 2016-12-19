#!/usr/bin/perl -w
#
# Perl library demo with the GTK-server 2.0.6
# Tested with Perl 5.8.7 on Slackware Linux 10.2
#
# December 18, 2005 - PvE.
#
#------------------------ Main starts here

# Tell PERL we use the dynamic loader
use C::DynaLib;

# Setup GTK-server connection 
$lib = new C::DynaLib("libgtk-server.so");

# Import functions
$gtk = $lib->DeclareSub("gtk", "p", "Z*");

# Enable logging (optional)
&{$gtk}("log=/tmp/gtk-server.log");

# Setup GUI
&{$gtk}("gtk_init NULL NULL");
my $win = &{$gtk}("gtk_window_new 0");
&{$gtk}("gtk_window_set_title $win \"Perl GTK-server demo with LIBRARY\"");
&{$gtk}("gtk_window_set_default_size $win 400 200");
&{$gtk}("gtk_window_set_position $win 1");
my $tbl = &{$gtk}("gtk_table_new 10 10 1");
&{$gtk}("gtk_container_add $win $tbl");
my $but = &{$gtk}("gtk_button_new_with_label \"Click to Quit\"");
&{$gtk}("gtk_table_attach_defaults $tbl $but 5 9 5 9");
&{$gtk}("gtk_widget_show_all $win");

# Initialize event
my $event=0;

# Mainloop
until($event == $win || $event == $but){
	$event = &{$gtk}("gtk_server_callback wait");
}

# Exit GTK without waiting for an answer
&{$gtk}("gtk_exit 0");
