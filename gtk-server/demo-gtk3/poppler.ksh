#!/bin/ksh
#
# (c) Peter van Eerten 2008, GPL license
#
# Adapted for GTK3 and Cairo in December 2016, PvE
#
# Using the Poppler library with GTK-server. Reading the pages in a PDF document.
#
# Homepage of the Poppler library: http://poppler.freedesktop.org/
#
# Tested with:
#   -PDKSH on Zenwalk 4.8, 5.2
#   -Korn93 on Slamd12
#   -MKSH R52 on Linux Mint 18.0
#
#-------------------------------------------------------------------------------------------------

# Cleanup
rm -f $HOME/.gtk4korn

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
if [[ ! -f $HOME/.gtk4korn || $CFG -nt $HOME/.gtk4korn ]]; then
    print "# Embedded GTK functions for KornShell" > $HOME/.gtk4korn
    while read LINE
    do
	if [[ $LINE == +(FUNCTION_NAME*) ]]; then
	    TMP=${LINE#*= }
	    print "function ${TMP%%,*}" >> $HOME/.gtk4korn
	    print "{\nprint -p ${TMP%%,*} \$@" >> $HOME/.gtk4korn
	    print "read -p GTK\n}" >> $HOME/.gtk4korn
	fi
    done < $CFG
fi

# Declare global variables
typeset GTK NULL="NULL"
unset CFG PIPE LINE

# Assignment function
function define { $2 $3 $4 $5 $6 $7 $8 $9; eval $1="\"$GTK\""; }

#-------------------------------------------------------------------------------------------------

function PDF_Display
{
if [[ -n $DOC && $DOC != "0" ]]
then
    let PNR=$NR-1
    # Get the page
    define PAGE poppler_document_get_page $DOC $PNR
    # Get the size of the page
    define SIZE poppler_page_get_size $PAGE 0 0
    define X lrint ${SIZE% *}
    define Y lrint ${SIZE#* }
    # Get zoom factor
    define ZOOM gtk_combo_box_get_active $COMBO
    ((ZOOM+=1))
    # Render to Cairo
    let X=$X*$ZOOM
    let Y=$Y*$ZOOM
    # New surface because of zoomlevel
    define CAIRO_S cairo_image_surface_create CAIRO_FORMAT_ARGB32 $X $Y
    define CAIRO_CR cairo_create $CAIRO_S
    # White background
    cairo_set_source_rgba $CAIRO_CR 1 1 1 1
    cairo_set_operator $CAIRO_CR CAIRO_OPERATOR_SOURCE
    cairo_paint $CAIRO_CR
    # Scale
    cairo_scale $CAIRO_CR $ZOOM $ZOOM
    poppler_page_render $PAGE $CAIRO_CR
    # Set the image
    gtk_image_set_from_surface $IMAGE $CAIRO_S
    # Flush all
    cairo_surface_flush $CAIRO_S
    cairo_surface_destroy $CAIRO_S
    cairo_destroy $CAIRO_CR
fi
}

#-------------------------------------------------------------------------------------------------

# Include the generated '.gtk4korn'-file in the shellscript to use embedded GTK functions
. $HOME/.gtk4korn

# Start GTK-server
gtk-server -stdin -log=/tmp/gtk-server.log |&

# Check availability of Poppler library first
define AVAIL gtk_server_require "libpoppler-glib.so"
if [[ $AVAIL != "ok" ]]
then
    echo "Install the poppler libraries from http://poppler.freedesktop.org first, then run this demo again."
    gtk_server_exit
    exit
fi

# Define GUI
gtk_init $NULL $NULL
define WINDOW gtk_window_new 0
gtk_window_set_title $WINDOW "'KornShell PDF Reader'"
gtk_window_set_position $WINDOW 1
# Create widget to display image
define IMAGE gtk_image_new
define CAIRO_S cairo_image_surface_create CAIRO_FORMAT_ARGB32 700 700
define CAIRO_CR cairo_create $CAIRO_S
# White background
cairo_set_source_rgba $CAIRO_CR 1 1 1 1
cairo_set_operator $CAIRO_CR CAIRO_OPERATOR_SOURCE
cairo_paint $CAIRO_CR
# Set the image
gtk_image_set_from_surface $IMAGE $CAIRO_S
# Flush all
cairo_surface_flush $CAIRO_S
cairo_surface_destroy $CAIRO_S
cairo_destroy $CAIRO_CR
# Events
define EBOX gtk_event_box_new
gtk_container_add $EBOX $IMAGE
define SW gtk_scrolled_window_new $NULL $NULL
gtk_widget_set_size_request $SW 720 720
gtk_scrolled_window_set_policy $SW 1 1
gtk_scrolled_window_set_shadow_type $SW 1
gtk_scrolled_window_add_with_viewport $SW $EBOX
# Connect scroll event
gtk_server_connect_after $EBOX "scroll-event" "scroll-event" 1
# Separator
define SEP gtk_hseparator_new
# Open button
define OPEN gtk_button_new_from_stock "gtk-open"
# Spin button - no floats in PDKSH
define COMBO gtk_combo_box_text_new
gtk_combo_box_text_append_text $COMBO "'zoom 1x'"
gtk_combo_box_text_append_text $COMBO "'zoom 2x'"
gtk_combo_box_text_append_text $COMBO "'zoom 3x'"
gtk_combo_box_text_append_text $COMBO "'zoom 4x'"
gtk_combo_box_text_append_text $COMBO "'zoom 5x'"
# Page number
define BW gtk_button_new
define BW_PIC gtk_image_new_from_stock "gtk-go-back" 4
gtk_widget_set_size_request $BW 40 30
gtk_container_add $BW $BW_PIC
define FRAME gtk_frame_new
let NR=0
define LABEL gtk_label_new "' $NR of 0 pages '"
gtk_container_add $FRAME $LABEL
define FW gtk_button_new
define FW_PIC gtk_image_new_from_stock "gtk-go-forward" 4
gtk_widget_set_size_request $FW 40 30
gtk_container_add $FW $FW_PIC
# Exit button
define EXIT gtk_button_new_from_stock "gtk-quit"
# Now arrange widgets on window using boxes
define HBOX gtk_hbox_new 0 0
gtk_box_pack_start $HBOX $OPEN 0 0 1
gtk_box_pack_start $HBOX $COMBO 0 0 1
gtk_box_pack_start $HBOX $BW 0 0 1
gtk_box_pack_start $HBOX $FRAME 0 0 1
gtk_box_pack_start $HBOX $FW 0 0 1
gtk_box_pack_end $HBOX $EXIT 0 0 1
define VBOX gtk_vbox_new 0 0
gtk_box_pack_start $VBOX $SW 1 1 1
gtk_box_pack_start $VBOX $SEP 0 0 1
gtk_box_pack_end $VBOX $HBOX 0 0 1
gtk_container_add $WINDOW $VBOX
# Create file open dialog
define FILEDIALOG gtk_window_new 0
gtk_window_set_title $FILEDIALOG "'Open PDF file'"
gtk_window_set_icon_name $FILEDIALOG "harddrive"
gtk_window_set_transient_for $FILEDIALOG $WINDOW
gtk_window_set_position $FILEDIALOG 4
gtk_window_set_default_size $FILEDIALOG 600 500
define SELECTOR gtk_file_chooser_widget_new 0
define FILTER gtk_file_filter_new
gtk_file_filter_set_name $FILTER "'PDF files (*.pdf)'"
gtk_file_filter_add_pattern $FILTER "'*.pdf'"
gtk_file_chooser_add_filter $SELECTOR $FILTER
define OKFILE gtk_button_new_from_stock "gtk-open"
define CANFILE gtk_button_new_from_stock "gtk-cancel"
# Arrange widgets on window
define VBOXFILE gtk_vbox_new 0 0
define HBOXFILE gtk_hbox_new 0 0
gtk_box_pack_end $HBOXFILE $OKFILE 0 0 1
gtk_box_pack_end $HBOXFILE $CANFILE 0 0 1
gtk_box_pack_start $VBOXFILE $SELECTOR 1 1 1
gtk_box_pack_start $VBOXFILE $HBOXFILE 0 0 1
gtk_container_add $FILEDIALOG $VBOXFILE
# Redefine the g_object_get call
gtk_server_redefine "g_object_get NONE NONE 4 WIDGET STRING PTR_DOUBLE NULL"

# Show all widgets
gtk_widget_show_all $WINDOW

# Set default zoomlevel
gtk_combo_box_set_active $COMBO 1

# Mainloop
while [[ $EVENT != $EXIT && $EVENT != $WINDOW ]]
do
    define EVENT gtk_server_callback "wait"

   case $EVENT in

	$OPEN)
	    let NR=1
	    gtk_widget_show_all $FILEDIALOG;;

	$FILEDIALOG)
	    gtk_widget_hide $FILEDIALOG;;

	$OKFILE)
	    define FILE gtk_file_chooser_get_filename $SELECTOR
	    gtk_widget_hide $FILEDIALOG
	    define DOC poppler_document_new_from_file "'file://localhost$FILE'" $NULL $NULL
	    if [[ $DOC != "0" ]]
	    then
		PDF_Display
		# Scroll up
		define ADJ gtk_scrolled_window_get_vadjustment $SW
		gtk_adjustment_set_value $ADJ 0
		define AMOUNT poppler_document_get_n_pages $DOC
		gtk_label_set_text $LABEL "' $NR of $AMOUNT pages '"
		gtk_window_set_title $WINDOW "'KornShell PDF Reader - ${FILE##*/}'"
	    fi;;

	$CANFILE)
	    gtk_widget_hide $FILEDIALOG;;
	
	$COMBO)
	    PDF_Display;;

	$BW)
	    if [[ -n $DOC && $DOC != "0" ]]
	    then
		define AMOUNT poppler_document_get_n_pages $DOC
		((NR-=1))
		if [[ $NR -lt 1 ]]
		then
		    let NR=$AMOUNT
		fi
		gtk_label_set_text $LABEL "' $NR of $AMOUNT pages '"
		PDF_Display
		# Scroll up
		define ADJ gtk_scrolled_window_get_vadjustment $SW
		gtk_adjustment_set_value $ADJ 0
	    fi;;

	$FW)
	    if [[ -n $DOC && $DOC != "0" ]]
	    then
		define AMOUNT poppler_document_get_n_pages $DOC
		((NR+=1))
		if [[ $NR -gt $AMOUNT ]]
		then
		    NR=1
		fi
		gtk_label_set_text $LABEL "' $NR of $AMOUNT pages '"
		PDF_Display
		# Scroll up
		define ADJ gtk_scrolled_window_get_vadjustment $SW
		gtk_adjustment_set_value $ADJ 0
	    fi;;

	"scroll-event")
	    if [[ -n $DOC && $DOC != "0" ]]
	    then
		# First get current value of slider
		define ADJ gtk_scrolled_window_get_vadjustment $SW
		define VAL gtk_adjustment_get_value $ADJ
		define VAL lrint $VAL
		# Now get current maximum possible value
		define UPPER g_object_get $ADJ "upper" 0 0
		define UPPER lrint ${UPPER}
		# Also get page size
		define PSIZE g_object_get $ADJ "page-size" 0 0
		define PSIZE lrint ${PSIZE}
		# Calculate limitation of Adjustment (see GTK doc)
		let DIFF=$UPPER-$PSIZE
		define AMOUNT poppler_document_get_n_pages $DOC
		define MOUSE gtk_server_mouse 3
		if [[ $MOUSE = "1" ]]
		then
		    if [[ $VAL -ge $DIFF ]]
		    then
			((NR+=1))
			if [[ $NR -gt $AMOUNT ]]
			then
			    NR=1
			fi
			gtk_label_set_text $LABEL "' $NR of $AMOUNT pages '"
			PDF_Display
			# Scroll up
			gtk_adjustment_set_value $ADJ 0
		    fi
		fi
		if [[ $MOUSE = "0" ]]
		then
		    if [[ $VAL -le 0 ]]
		    then
			((NR-=1))
			if [[ $NR -lt 1 ]]
			then
			    let NR=$AMOUNT
			fi
			gtk_label_set_text $LABEL "' $NR of $AMOUNT pages '"
			PDF_Display
			# Scroll down
			gtk_adjustment_set_value $ADJ $UPPER
		    fi
		fi
	    fi;;

    esac
done

# Exit GTK
gtk_server_exit
