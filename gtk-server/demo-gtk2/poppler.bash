#!/bin/bash
#
# (c) Peter van Eerten 2008, GPL license
#
# Using the Poppler library with GTK-server. Reading the pages in a PDF document.
#
# Homepage of the Poppler library: http://poppler.freedesktop.org/
#
# Tested with:
#   -GNU bash, version 3.1.17(2)-release (i486-slackware-linux-gnu)
#
#-------------------------------------------------------------------------------------------------

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
    echo "gtk-server -fifo=$PIPE &" >> $HOME/.gtk4bash
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

# Include the generated file to use embedded GTK functions
. ${HOME}/.gtk4bash

# Assignment function
function define() { $2 $3 $4 $5 $6 $7 $8 $9; eval $1="\"$GTK\""; }

#-------------------------------------------------------------------------------------------------

function PDF_Display
{
if [[ -n $DOC && $DOC != "0" ]]
then
    let PNR=$NR-1
    # Get the page
    define PAGE poppler_document_get_page $DOC $PNR
    # Free current pixbuf
    g_object_unref $PIX
    # Get the size of the page
    define SIZE poppler_page_get_size $PAGE 0 0
    define X lrint ${SIZE% *}
    define Y lrint ${SIZE#* }
    # Get zoom factor
    define ZOOM gtk_combo_box_get_active $COMBO
    ((ZOOM+=1))
    # Define new pixbuf
    let X=$X*$ZOOM
    let Y=$Y*$ZOOM
    define PIX gdk_pixbuf_new 0 0 8 $X $Y
    gtk_image_set_from_pixbuf $IMAGE $PIX
    poppler_page_render_to_pixbuf $PAGE 0 0 $X $Y $ZOOM 0 $PIX
fi
}

#-------------------------------------------------------------------------------------------------

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
gtk_window_set_title $WINDOW "'Bash PDF Reader'"
gtk_window_set_position $WINDOW 1
# Create the pixbuf
define PIX gdk_pixbuf_new 0 0 8 700 700 
# Create widget to display image
define IMAGE gtk_image_new
gtk_image_set_from_pixbuf $IMAGE $PIX
define EBOX gtk_event_box_new
gtk_container_add $EBOX $IMAGE
define SW gtk_scrolled_window_new $NULL $NULL
gtk_widget_set_size_request $SW 300 300
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
define COMBO gtk_combo_box_new_text
gtk_combo_box_append_text $COMBO "'zoom 1x'"
gtk_combo_box_append_text $COMBO "'zoom 2x'"
gtk_combo_box_append_text $COMBO "'zoom 3x'"
gtk_combo_box_append_text $COMBO "'zoom 4x'"
gtk_combo_box_append_text $COMBO "'zoom 5x'"
gtk_combo_box_set_active $COMBO 1
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

    # Refresh Pixmap to GtkImage widget
    gtk_widget_queue_draw $IMAGE

done

# Exit GTK
gtk_server_exit
