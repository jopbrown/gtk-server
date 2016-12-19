#!/bin/bash

# Name of PIPE file
declare PI=/tmp/bash.gtk.$$

# Communication function; assignment function
function gtk() { echo $1 > $PI; read GTK < $PI; }
function define() { $2 "$3"; eval $1=$GTK; }

#----------------------------------------------------------------------------------

# Define some constants
NULL="NULL"
FIRST_COL=0
SECOND_COL=1
NUM_COLS=2
TRUE=1

# Start gtk-server in FIFO mode
gtk-server -fifo=$PI &
while [ ! -p $PI ]; do continue; done

# Initialize GTK
gtk "gtk_init $NULL $NULL"

# Define main window and some attributes
define WINDOW gtk "gtk_window_new GTK_WINDOW_TOPLEVEL"
gtk "gtk_window_set_title $WINDOW 'Floats in lists'"
gtk "gtk_window_set_resizable $WINDOW 0"
gtk "gtk_window_set_icon_name $WINDOW gtk-info"
gtk "gtk_widget_set_size_request $WINDOW 200 200"

# Create a model
define VIEW gtk "gtk_tree_view_new"
gtk "gtk_tree_view_set_headers_clickable $VIEW $TRUE"
gtk "gtk_tree_view_set_grid_lines $VIEW 3"

# Create columns
define COLUMN1 gtk "gtk_tree_view_column_new"
gtk "gtk_tree_view_column_set_title $COLUMN1 Column1"
gtk "gtk_tree_view_append_column $VIEW $COLUMN1"
gtk "gtk_tree_view_column_set_resizable $COLUMN1 $TRUE"
gtk "gtk_tree_view_column_set_clickable $COLUMN1 $TRUE"

define COLUMN2 gtk "gtk_tree_view_column_new"
gtk "gtk_tree_view_column_set_title $COLUMN2 Column2"
gtk "gtk_tree_view_append_column $VIEW $COLUMN2"
gtk "gtk_tree_view_column_set_resizable $COLUMN2 $TRUE"
gtk "gtk_tree_view_column_set_clickable $COLUMN2 $TRUE"

# Create renderers to show contents
define RENDERER1 gtk "gtk_cell_renderer_text_new"
gtk "gtk_tree_view_column_pack_start $COLUMN1 $RENDERER1 $TRUE"
define RENDERER2 gtk "gtk_cell_renderer_text_new"
gtk "gtk_tree_view_column_pack_start $COLUMN2 $RENDERER2 $TRUE"

# Define the store where the actual data is kept
gtk "gtk_server_redefine gtk_list_store_new NONE WIDGET 3 INT INT INT"
define LST gtk "gtk_list_store_new 2 G_TYPE_DOUBLE G_TYPE_DOUBLE"

# Fill store with some data
define ITER gtk "gtk_server_opaque"
gtk "gtk_server_redefine gtk_list_store_set NONE NONE 5 WIDGET WIDGET INT DOUBLE INT"
gtk "gtk_list_store_append $LST $ITER"
gtk "gtk_list_store_set $LST $ITER $FIRST_COL 1.23456 -1"
gtk "gtk_list_store_set $LST $ITER $SECOND_COL 9.87654 -1"
gtk "gtk_list_store_append $LST $ITER"
gtk "gtk_list_store_set $LST $ITER $FIRST_COL 5.43210 -1"
gtk "gtk_list_store_set $LST $ITER $SECOND_COL 4.56789 -1"
gtk "gtk_list_store_append $LST $ITER"
gtk "gtk_list_store_set $LST $ITER $FIRST_COL 10.13578 -1"
gtk "gtk_list_store_set $LST $ITER $SECOND_COL 1.010101 -1"

# Attach store to model
gtk "gtk_tree_view_set_model $VIEW $LST"

# Make sure all memory is released when the model is destroyed
gtk "g_object_unref $LST"

# Set the mode of the view
define SEL gtk "gtk_tree_view_get_selection $VIEW"
gtk "gtk_tree_selection_set_mode $SEL GTK_SELECTION_SINGLE"

# Define a scrolled window
define SW gtk "gtk_scrolled_window_new $NULL $NULL"
gtk "gtk_scrolled_window_set_policy $SW 1 1"
gtk "gtk_scrolled_window_set_shadow_type $SW 1"
gtk "gtk_container_add $SW $VIEW"

# Now register a 'userfunction' for both columns - using different macros with different column number
gtk "gtk_server_define gtk_tree_view_column_set_cell_data_func NONE NONE 5 WIDGET WIDGET MACRO DATA NULL"
gtk "gtk_tree_view_column_set_cell_data_func $COLUMN1 $RENDERER1 GtkTreeCellDataFunc_1 $FIRST_COL $NULL"
gtk "gtk_tree_view_column_set_cell_data_func $COLUMN2 $RENDERER2 GtkTreeCellDataFunc_2 $SECOND_COL $NULL"

# Finish gui
gtk "gtk_container_add $WINDOW $SW"
gtk "gtk_widget_show_all $WINDOW"

# Set ordering variable
ORDER_FIRST=0
ORDER_SECOND=1

# MAINLOOP
until [[ $EVENT = $WINDOW ]]
do
    define EVENT gtk "gtk_server_callback wait"
    case $EVENT in

	$COLUMN1)
	    let ORDER_FIRST=1-$ORDER_FIRST
	    let ORDER_SECOND=1-$ORDER_SECOND
	    gtk "gtk_tree_sortable_set_sort_column_id $LST $FIRST_COL $ORDER_FIRST";;

        $COLUMN2)
	    let ORDER_FIRST=1-$ORDER_FIRST
	    let ORDER_SECOND=1-$ORDER_SECOND
	    gtk "gtk_tree_sortable_set_sort_column_id $LST $SECOND_COL $ORDER_SECOND";;

    esac
done

gtk "gtk_server_exit"
