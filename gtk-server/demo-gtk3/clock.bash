#!/bin/bash
#
# Tested with:
#   -BASH 3.1.17 on Zenwalk 4.6
#   -BASH 4.3.42 on Linux Mint 18
#
# Demo with Bourne Again SHell (BASH)
#
# Created with GTK-server 2.1.4 by Peter van Eerten / august 17, 2007 (GPL)
# Beautification for assigning returnvalues to vars at april 26, 2008 - PvE.
# Adapted for GTK3 and Cairo in december 2016 - PvE.
#-------------------------------------------------------------------------------------------------

rm -f $HOME/.gtk4bash

# Remove old version
rm -f $HOME/.gtk4bash

# Pipe filename must be unique for your application
PIPE="/tmp/gtk.bash.\$$"

# Find GTK-server configfile first
if [[ -f gtk-server.cfg ]]; then
    CFG=gtk-server.cfg
elif [[ -f /etc/gtk-server.cfg ]]; then
    CFG=/etc/gtk-server.cfg
elif [[ -f /usr/local/etc/gtk-server.cfg ]]; then
    CFG=/usr/local/etc/gtk-server.cfg
else
    echo "No GTK-server configfile found! Please install GTK-server..."
    exit 1
fi
# Now create global functionnames from GTK API
if [[ ! -f $HOME/.gtk4bash || $CFG -nt $HOME/.gtk4bash ]]; then
    echo "#!/bin/bash" > $HOME/.gtk4bash
    echo "gtk-server -fifo=$PIPE -log=/tmp/gtk-server.log &" >> $HOME/.gtk4bash
    echo "while [ ! -p $PIPE ]; do continue; done" >> $HOME/.gtk4bash
    while read LINE
    do
	if [[ $LINE = FUNCTION_NAME* ]]; then
	    LINE=${LINE#*= }
	    printf "\nfunction ${LINE%%,*}\n" >> $HOME/.gtk4bash
	    printf "{\n/bin/echo ${LINE%%,*} \$@ > $PIPE" >> $HOME/.gtk4bash
	    printf "\nread GTK < $PIPE\n}\n" >> $HOME/.gtk4bash
	fi
    done < $CFG
fi
# Declare global variables
declare GTK NULL="NULL"
unset CFG PIPE LINE

# Include the generated '.gtk4bash'-file
. $HOME/.gtk4bash

# Assignment function
function define() { $2 $3 $4 $5 $6 $7 $8 $9; eval $1="$GTK"; }

# Window
gtk_init $NULL $NULL
define WIN gtk_window_new 0
gtk_window_set_title $WIN "'BASH Analog Clock'"
gtk_widget_set_size_request $WIN 300 350
gtk_window_set_position $WIN 1
gtk_window_set_resizable $WIN 0
gtk_window_set_icon_name $WIN "clock"
# Use async functionality, signal every second
gtk_server_connect $WIN "show" "time-update"
gtk_server_timeout 1000 $WIN "show"
# Create widget to display image
define IMAGE gtk_image_new
# Separator
define SEP gtk_hseparator_new
# About button
define ABOUT_BUTTON gtk_button_new_from_stock "gtk-about"
gtk_widget_set_size_request $ABOUT_BUTTON 90 30
# Exit button
define EXIT_BUTTON gtk_button_new_from_stock "gtk-quit"
gtk_widget_set_size_request $EXIT_BUTTON 90 30
# Now arrange widgets on window using boxes
define HBOX gtk_hbox_new 0 0
gtk_box_pack_start $HBOX $ABOUT_BUTTON 0 0 1
gtk_box_pack_end $HBOX $EXIT_BUTTON 0 0 1
define VBOX gtk_vbox_new 0 0
gtk_box_pack_start $VBOX $IMAGE 0 0 1
gtk_box_pack_start $VBOX $SEP 0 0 1
gtk_box_pack_end $VBOX $HBOX 0 0 1
gtk_container_add $WIN $VBOX
# Show all widgets
gtk_widget_show_all $WIN
# Create the canvas
define CAIRO_S cairo_image_surface_create CAIRO_FORMAT_ARGB32 300 315
define CAIRO_CR cairo_create $CAIRO_S
cairo_set_antialias $CAIRO_CR CAIRO_ANTIALIAS_BEST
cairo_set_source_rgba $CAIRO_CR 1 1 1 1
cairo_rectangle $CAIRO_CR 0 0 300 315
cairo_fill $CAIRO_CR
cairo_set_line_width $CAIRO_CR 1
cairo_set_source_rgba $CAIRO_CR 0 0 0 1
cairo_rectangle $CAIRO_CR 0 0 300 315
cairo_stroke $CAIRO_CR
cairo_arc $CAIRO_CR 150 150 140 0 6.28
cairo_stroke $CAIRO_CR
# Put some text on the canvas
cairo_set_source_rgba $CAIRO_CR 0 0 1 1
cairo_select_font_face $CAIRO_CR "Sans" CAIRO_FONT_SLANT_NORMAL CAIRO_FONT_WEIGHT_NORMAL
cairo_set_font_size $CAIRO_CR 12
cairo_move_to $CAIRO_CR 95 305
cairo_show_text $CAIRO_CR "'Show analog time'"
# Obtain the picture
gtk_image_set_from_surface $IMAGE $CAIRO_S

# Create ABOUT box
gtk_server_version
define DIALOG gtk_message_dialog_new $WIN 0 0 2 "'\t\t***  BASH Analog Clock ***\r\rBASH ${BASH_VERSION#* } with GTK-server $GTK.\r\r\tVisit http://www.gtk-server.org/ for more info!'" "''"
gtk_window_set_title $DIALOG "'About this program'"

# Coordinates for minute and seconds pointer
CO=(0 14 27 40 53 65 76 87 97 105 113 119 124 127 129 130)

# Coordinates for hour pointer
HO=(0 8 17 25 33 40 47 54 59 65 69 73 76 78 79 80)

# Mainloop
while [[ $EVENT != $WIN && $EVENT != $EXIT_BUTTON ]]
do
    # Get event
    define EVENT gtk_server_callback "wait"

    # Check events
    case $EVENT in

	# If about button is pressed
	$ABOUT_BUTTON)
	    gtk_widget_show $DIALOG;;

	$DIALOG)
	    gtk_widget_hide $DIALOG;;

	# If async signal occurs draw minute
	"time-update")
	    # Cleanup clock
	    cairo_set_source_rgba $CAIRO_CR 1 1 1 1
	    cairo_arc $CAIRO_CR 150 150 142 0 6.28
	    cairo_fill $CAIRO_CR
	    cairo_set_source_rgba $CAIRO_CR 0 0 0 1
	    cairo_arc $CAIRO_CR 150 150 140 0 6.28
	    cairo_stroke $CAIRO_CR

	    # Draw seconds pointer
	    SECOND=`date +%S`
	    # Bash interprets numbers beginning with 0 as octals. Remove the '0'.
	    let SECOND=${SECOND#0*}

	    if [[ $SECOND -lt 15 ]]
	    then
		let X=150+${CO[$SECOND]}
		let Y=145-${CO[15-$SECOND]}
	    elif [[ $SECOND -lt 30 ]]
	    then
		((SECOND-=15))
		let X=150+${CO[15-$SECOND]}
		let Y=145+${CO[$SECOND]}
	    elif [[ $SECOND -lt 45 ]]
	    then
		((SECOND-=30))
		let X=150-${CO[$SECOND]}
		let Y=145+${CO[15-$SECOND]}
	    elif [[ $SECOND -lt 60 ]]
	    then
		((SECOND-=45))
		let X=150-${CO[15-$SECOND]}
		let Y=145-${CO[$SECOND]}
	    fi
	    cairo_set_line_width $CAIRO_CR 0.5
	    cairo_move_to $CAIRO_CR 150 145
	    cairo_line_to $CAIRO_CR $X $Y
	    cairo_stroke $CAIRO_CR
	    cairo_set_line_width $CAIRO_CR 1

	    # Draw minute pointer
	    MINUTE=`date +%M`
	    # Bash interprets numbers beginning with 0 as octals. Remove the '0'.
	    let MINUTE=${MINUTE#0*}

	    if [[ $MINUTE -lt 15 ]]
	    then
		let X=150+${CO[$MINUTE]}
		let Y=145-${CO[15-$MINUTE]}
		cairo_move_to $CAIRO_CR 151 146
		cairo_line_to $CAIRO_CR $X $Y
		cairo_line_to $CAIRO_CR 149 144
		cairo_line_to $CAIRO_CR 151 146
		cairo_fill $CAIRO_CR
	    elif [[ $MINUTE -lt 30 ]]
	    then
		((MINUTE-=15))
		let X=150+${CO[15-$MINUTE]}
		let Y=145+${CO[$MINUTE]}
		cairo_move_to $CAIRO_CR 151 144
		cairo_line_to $CAIRO_CR $X $Y
		cairo_line_to $CAIRO_CR 149 146
		cairo_line_to $CAIRO_CR 151 144
		cairo_fill $CAIRO_CR
	    elif [[ $MINUTE -lt 45 ]]
	    then
		((MINUTE-=30))
		let X=150-${CO[$MINUTE]}
		let Y=145+${CO[15-$MINUTE]}
		cairo_move_to $CAIRO_CR 149 144
		cairo_line_to $CAIRO_CR $X $Y
		cairo_line_to $CAIRO_CR 151 146
		cairo_line_to $CAIRO_CR 149 144
		cairo_fill $CAIRO_CR
	    elif [[ $MINUTE -lt 60 ]]
	    then
		((MINUTE-=45))
		let X=150-${CO[15-$MINUTE]}
		let Y=145-${CO[$MINUTE]}
		cairo_move_to $CAIRO_CR 151 144
		cairo_line_to $CAIRO_CR $X $Y
		cairo_line_to $CAIRO_CR 149 146
		cairo_line_to $CAIRO_CR 151 144
		cairo_fill $CAIRO_CR
	    fi
	    # Draw hour pointer
	    HOUR=`date +%l`
	    # Bash interprets numbers beginning with 0 as octals. Substraction delivers decimal.
	    ((HOUR-=1))

	    MINUTE=`date +%M`
	    # Bash interprets numbers beginning with 0 as octals. Remove the '0'.
	    let MINUTE=${MINUTE#0*}

	    let HOUR=HOUR*5+${MINUTE}/12+5
	    if [[ $HOUR -ge 60 ]]
	    then
		((HOUR-=60))
	    fi
	    if [[ $HOUR -lt 15 ]]
	    then
		let X=150+${HO[$HOUR]}
		let Y=145-${HO[15-$HOUR]}
		cairo_move_to $CAIRO_CR 151 146
		cairo_line_to $CAIRO_CR $X $Y
		cairo_line_to $CAIRO_CR 149 144
		cairo_line_to $CAIRO_CR 151 146
		cairo_fill $CAIRO_CR
	    elif [[ $HOUR -lt 30 ]]
	    then
		((HOUR-=15))
		let X=150+${HO[15-$HOUR]}
		let Y=145+${HO[$HOUR]}
		cairo_move_to $CAIRO_CR 151 144
		cairo_line_to $CAIRO_CR $X $Y
		cairo_line_to $CAIRO_CR 149 146
		cairo_line_to $CAIRO_CR 151 144
		cairo_fill $CAIRO_CR
	    elif [[ $HOUR -lt 45 ]]
	    then
		((HOUR-=30))
		let X=150-${HO[$HOUR]}
		let Y=145+${HO[15-$HOUR]}
		cairo_move_to $CAIRO_CR 149 144
		cairo_line_to $CAIRO_CR $X $Y
		cairo_line_to $CAIRO_CR 151 146
		cairo_line_to $CAIRO_CR 149 144
		cairo_fill $CAIRO_CR
	    elif [[ $HOUR -lt 60 ]]
	    then
		((HOUR-=45))
		let X=150-${HO[15-$HOUR]}
		let Y=145-${HO[$HOUR]}
		cairo_move_to $CAIRO_CR 151 144
		cairo_line_to $CAIRO_CR $X $Y
		cairo_line_to $CAIRO_CR 149 146
		cairo_line_to $CAIRO_CR 151 144
		cairo_fill $CAIRO_CR
	    fi
	    # Draw centre
	    cairo_arc $CAIRO_CR 150 145 8 0 6.28
	    cairo_fill $CAIRO_CR
	    # Refresh screen
	    gtk_image_set_from_surface $IMAGE $CAIRO_S;;
    esac
done

# Exit GTK
gtk_server_exit
