#!/usr/bin/perl -w
#
# Perl 2-way pipe demo with the GTK-server 1.3
# Tested with Perl 5.8 on Slackware Linux 10
# Reported by Scott Crittenden to work on Win32 as well (28/4/2005).
#
# February 23, 2005 by Peter van Eerten
#---------------------------------------

# Communicate with GTK-server
sub gtk
{
print GTKOUT $_[0];
my $line = <GTKIN>;

return $line;
}

#------------------------ Main starts here

# Tell PERL we use pipe redirection
use IPC::Open2;

# Start GTK-server in STDIN mode
open2(*GTKIN, *GTKOUT, "gtk-server stdin");

# Setup GUI
gtk "gtk_init NULL NULL";
my $win = gtk "gtk_window_new 0";
gtk "gtk_window_set_title $win 'Perl GTK-server demo with STDIN'";
gtk "gtk_window_set_default_size $win 400 200";
gtk "gtk_window_set_position $win 1";
my $tbl = gtk "gtk_table_new 10 10 1";
gtk "gtk_container_add $win $tbl";
my $but = gtk "gtk_button_new_with_label 'Click to Quit'";
gtk "gtk_table_attach_defaults $tbl $but 5 9 5 9";
gtk "gtk_widget_show_all $win";

# Initialize event
my $event=0;

# Mainloop
until($event == $win || $event == $but){
	$event = gtk "gtk_server_callback WAIT";
}

# Exit GTK
gtk "gtk_server_exit";
