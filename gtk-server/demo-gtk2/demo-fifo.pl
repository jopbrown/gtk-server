#!/usr/bin/perl -w
#
# Perl named pipe demo with the GTK-server
# Tested with Perl 5.8 on Slackware Linux 9.1
#
# August 2, 2004 by Peter van Eerten
# Revised for GTK-server 1.2 October 7, 2004
# Revised for GTK-server 1.3 December 5, 2004
# Revised for GTK-server 2.0.6 at december 17, 2005
# Revised for GTK-server 2.0.8 at january 7, 2006
#---------------------------------------

# Communicate with GTK-server
sub gtk
{
open(GTK, ">/tmp/perl.gtk");
print GTK $_[0];
close GTK;

open(GTK, "/tmp/perl.gtk");
my $line = <GTK>;
close GTK;

return $line;
}

#------------------------ Main starts here

# Start gtk-server
system("gtk-server -fifo=/tmp/perl.gtk -log=/tmp/log.txt &");
sleep 1;

# Setup GUI
gtk "gtk_init NULL NULL";
my $win = gtk "gtk_window_new 0";
gtk "gtk_window_set_title $win 'Perl GTK-server demo with FIFO'";
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
    $event = gtk "gtk_server_callback wait";
}

# Exit GTK
gtk "gtk_exit 0";
