#!/bin/gawk -f
#
# Demonstration on how to use the GTK-server with Gnu AWK by STDIN.
# Tested with Gnu AWK 3.1.5 on Zenwalk Linux.
# Tested with GNU Awk 4.1.3 on Linux Mint 18
#
# October 25, 2007 by Peter van Eerten.
# Adapted for GTK3 in December 2016 - PvE.
#------------------------------------------------

function GTK(str)
{
print str |& GTK_SERVER
GTK_SERVER |& getline TMP
return TMP
}

function main_gui(i)
{
# Setup list
GTK("gtk_init NULL NULL")
Iter = GTK("gtk_server_opaque")
List = GTK("gtk_list_store_new 1 64")
Tree = GTK("gtk_tree_view_new_with_model " List)
GTK("gtk_server_connect " Tree " button-press-event " Tree " 1")
GTK("gtk_tree_view_set_headers_visible " Tree " 0")
Sel = GTK("gtk_tree_view_get_selection " Tree)
Cell = GTK("gtk_cell_renderer_text_new")
Column = GTK("gtk_tree_view_column_new_with_attributes Server " Cell " text 0 NULL")
GTK("gtk_tree_view_append_column " Tree " " Column)
GTK("gtk_tree_view_column_set_resizable " Column " 1")
GTK("gtk_tree_view_column_set_clickable " Column " 1")
Sw = GTK("gtk_scrolled_window_new NULL NULL")
GTK("gtk_scrolled_window_set_policy " Sw " 1 1")
GTK("gtk_scrolled_window_set_shadow_type " Sw " 1")
GTK("gtk_widget_set_size_request " Sw " 1 120")
GTK("gtk_container_add " Sw " " Tree)
# Add the servers
for (i = 0; i < Amount_Servers; i++){
    GTK("gtk_list_store_append " List " " Iter)
    GTK("gtk_list_store_set " List " " Iter " 0 " Servers[i] " -1")
}
# Setup buttons
Back = GTK("gtk_button_new_from_stock gtk-go-back")
About = GTK("gtk_button_new_from_stock gtk-about")
Index = GTK("gtk_button_new_from_stock gtk-index")
# Top frame
Frame1 = GTK("gtk_frame_new NULL")
GTK("gtk_frame_set_label " Frame1 " \" DICT servers \"")
Hbox1 = GTK("gtk_hbox_new 0 0")
GTK("gtk_container_add " Frame1 " " Hbox1)
GTK("gtk_container_set_border_width " Hbox1 " 5")
Vbox1 = GTK("gtk_vbox_new 0 0")
GTK("gtk_box_pack_start " Vbox1 " " Index " 1 1 1")
GTK("gtk_box_pack_start " Vbox1 " " Back " 1 1 1")
GTK("gtk_box_pack_start " Vbox1 " " About " 1 1 1")
GTK("gtk_box_pack_start " Hbox1 " " Sw " 1 1 1")
GTK("gtk_box_pack_start " Hbox1 " " Vbox1 " 0 0 5")
# Setup entry box
Entry = GTK("gtk_entry_new")
# Middle frame
Frame2 = GTK("gtk_frame_new NULL")
GTK("gtk_frame_set_label " Frame2 " \" Lookup word \"")
Hbox2 = GTK("gtk_hbox_new 0 0")
GTK("gtk_container_add " Frame2 " " Hbox2)
GTK("gtk_container_set_border_width " Hbox2 " 5")
GTK("gtk_box_pack_start " Hbox2 " " Entry " 1 1 1")
# Setup multiline textedit
Txtbuf = GTK("gtk_text_buffer_new NULL")
Field = GTK("gtk_text_view_new_with_buffer " Txtbuf)
GTK("gtk_text_view_set_wrap_mode " Field " 1")
GTK("gtk_server_connect " Field " selection-received selection-received")
Tw = GTK("gtk_scrolled_window_new NULL NULL")
GTK("gtk_scrolled_window_set_policy " Tw " 2 1")
GTK("gtk_scrolled_window_set_shadow_type " Tw " 1")
GTK("gtk_container_add " Tw " " Field)
GTK("gtk_text_view_set_editable " Field " 0")
GTK("gtk_text_view_set_wrap_mode " Field " 2")
Startiter = GTK("gtk_server_opaque")
Enditer = GTK("gtk_server_opaque")
GTK("gtk_server_redefine gtk_text_buffer_create_tag NONE WIDGET 5 WIDGET STRING STRING STRING NULL")
GTK("gtk_text_buffer_create_tag " Txtbuf " blue foreground blue NULL")
GTK("gtk_text_buffer_create_tag " Txtbuf " green foreground DarkGreen NULL")
GTK("gtk_text_buffer_create_tag " Txtbuf " red foreground red NULL")
GTK("gtk_text_buffer_create_tag " Txtbuf " bold weight 700 NULL")
GTK("gtk_server_redefine gtk_text_buffer_insert_with_tags_by_name NONE NONE 7 WIDGET WIDGET STRING LONG STRING STRING NULL")
# Down frame
Frame3 = GTK("gtk_frame_new NULL")
GTK("gtk_frame_set_label " Frame3 " \" Results from dictionary \"")
Hbox3 = GTK("gtk_hbox_new 0 0")
GTK("gtk_container_add " Frame3 " " Hbox3)
GTK("gtk_container_set_border_width " Hbox3 " 5")
GTK("gtk_box_pack_start " Hbox3 " " Tw " 1 1 1")
# Main window
Window = GTK("gtk_window_new 0")
GTK("gtk_window_set_title " Window " \"GNU Awk DICT client\"")
GTK("gtk_widget_set_size_request " Window " 600 450")
GTK("gtk_window_set_position " Window " 1")
GTK("gtk_window_set_icon_name " Window " gdict")
Vbox = GTK("gtk_vbox_new 0 0")
GTK("gtk_box_pack_start " Vbox " " Frame1 " 0 0 1")
GTK("gtk_box_pack_start " Vbox " " Frame2 " 0 0 1")
GTK("gtk_box_pack_start " Vbox " " Frame3 " 1 1 1")
GTK("gtk_container_add " Window " " Vbox)
# Show everything
GTK("gtk_box_set_spacing " Vbox " 5")
GTK("gtk_container_set_border_width " Vbox " 5")
GTK("gtk_widget_show_all " Window)
GTK("gtk_widget_grab_focus " Entry)
# Create ABOUT button
Version = GTK("gtk_server_version")
Awk =  PROCINFO["version"]
Msg="'\t\t\t*** AWK Dict Client 1.1 ***\r\rProgrammed with GNU AWK " Awk " and GTK-server " Version ".\r\r\tVisit http://www.gtk-server.org/ for more info!'"
Dialog = GTK("gtk_message_dialog_new " Window " 0 0 2 %s " Msg)
GTK("gtk_window_set_title " Dialog " 'About this program'")
GTK("gtk_window_set_icon_name " Dialog " gdict")
}

function lookup_index(Nr, Dict, Pth, Row)
{
if (Level == 0){
    # Get dictionary
    Nr = 0
    while (Nr < Amount_Servers){
	Pth = GTK("gtk_tree_path_new_from_string " Nr)
	Row = GTK("gtk_tree_selection_path_is_selected " Sel " " Pth)
	GTK("gtk_tree_path_free " Pth)
	if (Row == "1") break
	else Nr+=1
    }
    # Do nothing if there is no selection
    if (Nr == Amount_Servers) return
    # We are in the level of databases
    Level = 1
    # Clear the list
    GTK("gtk_list_store_clear " List)
    # Save the default server
    Default = Servers[Nr]
    Nr = 0
    # Setup connection to dictionary server
    Dict = "/inet/tcp/0/" Default "/2628"
    # Get the available databases
    print "SHOW DB" |& Dict
    while((Dict |& getline) > 0){
	if ($0 == "250 ok\r") break
	if(substr($0, 1, 3) != 220 && substr($0, 1, 3) != 110 && substr($0, 1, 1) != "." && substr($0, 1, 8) != "--exit--"){
	    GTK("gtk_list_store_append " List " " Iter)
	    gsub(/\"/, "'", $0)
	    GTK("gtk_list_store_set " List " " Iter " 0 \"" substr($0, 0, length($0) - 1) "\" -1")
	    Databases[Nr] = substr($0, 1, index($0, " "))
	    Nr += 1
	}
    }
    Amount_Databases = Nr
    print "QUIT" |& Dict
    fflush(Dict)
    close(Dict)
}
}

# Restore serverlist
function back_servers(i)
{
Level = 0
GTK("gtk_list_store_clear " List)
# Add the servers
for (i = 0; i < Amount_Servers; i++){
    GTK("gtk_list_store_append " List " " Iter)
    GTK("gtk_list_store_set " List " " Iter " 0 " Servers[i] " -1")
}
}

function lookup_word(Nr, Dict, Pth, Row, Txt)
{
# Clear textscreen
GTK("gtk_text_buffer_get_bounds " Txtbuf " " Startiter " " Enditer)
GTK("gtk_text_buffer_delete " Txtbuf " " Startiter " " Enditer)
# Announcement
GTK("gtk_text_buffer_insert_with_tags_by_name " Txtbuf " " Enditer " \"Looking up word, please wait...\" -1 bold green NULL")
#GTK("gtk_server_callback update")
if (Level == 0){
    # Get selected row
    Nr = 0
    while (Nr < Amount_Servers){
	Pth = GTK("gtk_tree_path_new_from_string " Nr)
	Row = GTK("gtk_tree_selection_path_is_selected " Sel " " Pth)
	GTK("gtk_tree_path_free " Pth)
	if (Row == "1") break
	else Nr+=1
    }
    # Do nothing if there is no selection
    if (Nr == Amount_Servers) {
	# Clear textscreen
	GTK("gtk_text_buffer_get_bounds " Txtbuf " " Startiter " " Enditer)
	GTK("gtk_text_buffer_delete " Txtbuf " " Startiter " " Enditer)
	# Announcement
	GTK("gtk_text_buffer_insert_with_tags_by_name " Txtbuf " " Enditer " \"Select a dictionary or server!\" -1 bold red NULL")
	return
    }
    # Save the search string
    Txt = GTK("gtk_entry_get_text " Entry)
    # Depending on the level refine
    Dict = "/inet/tcp/0/" Servers[Nr] "/2628"
    print "DEFINE * \"" Txt "\"" |& Dict
}
else {
    # Get selected row
    Nr = 0
    while (Nr < Amount_Databases){
	Pth = GTK("gtk_tree_path_new_from_string " Nr)
	Row = GTK("gtk_tree_selection_path_is_selected " Sel " " Pth)
	GTK("gtk_tree_path_free " Pth)
	if (Row == "1") break
	else Nr+=1
    }
    # Do nothing if there is no selection
    if (Nr == Amount_Databases) {
	# Clear textscreen
	GTK("gtk_text_buffer_get_bounds " Txtbuf " " Startiter " " Enditer)
	GTK("gtk_text_buffer_delete " Txtbuf " " Startiter " " Enditer)
	# Announcement
	GTK("gtk_text_buffer_insert_with_tags_by_name " Txtbuf " " Enditer " \"Select a dictionary or server!\" -1 bold red NULL")
	return
    }
    # Save the search string
    Txt = GTK("gtk_entry_get_text " Entry)
    # Connect to dictionary server
    Dict = "/inet/tcp/0/" Default "/2628"
    print "DEFINE " Databases[Nr] " \"" Txt "\"" |& Dict
}
# Clear textscreen
GTK("gtk_text_buffer_get_bounds " Txtbuf " " Startiter " " Enditer)
GTK("gtk_text_buffer_delete " Txtbuf " " Startiter " " Enditer)
# Retrieve answer and put it in textfield
while((Dict |& getline) > 0){
    if (substr($0, 1, 6) == "250 ok") break
    if (substr($0, 1, 12) == "552 no match") {
	GTK("gtk_text_buffer_get_end_iter " Txtbuf " " Enditer)
	GTK("gtk_text_buffer_insert_with_tags_by_name " Txtbuf " " Enditer " \"Item not found!\" -1 bold red NULL")
	break
    }
    if (substr($0, 1, 4) == "151 "){
	GTK("gtk_text_buffer_get_end_iter " Txtbuf " " Enditer)
	gsub(/\"/, "", $0)
	Tmp = substr($0, length(Txt) + 6)
	GTK("gtk_text_buffer_insert_with_tags_by_name " Txtbuf " " Enditer " \"" substr(Tmp, index(Tmp, " ")+1) "\" -1 bold blue NULL")
	GTK("gtk_text_buffer_get_end_iter " Txtbuf " " Enditer)
	GTK("gtk_text_buffer_insert " Txtbuf " " Enditer " \"------------------------------------------\n\" -1")
    }
    else if (substr($0, 1, 4) != "220 " && substr($0, 1, 4) != "150 ") {
	GTK("gtk_text_buffer_get_end_iter " Txtbuf " " Enditer)
	gsub(/\"/, "", $0)
	GTK("gtk_text_buffer_insert " Txtbuf " " Enditer " \"" $0 "\" -1")
    }
}
print "QUIT" |& Dict
fflush(Dict)
close(Dict)
}

BEGIN{

# Start GTK-server in STDIN mode
GTK_SERVER = "gtk-server -stdin -log=/tmp/gtk-server.log -debug -signal=9"

# Determine total amount of DICT servers
Servers[0] = "www.dict.org"
Servers[1] = "all.dict.org"
Amount_Servers = 2

# Determine level (0=server 1=database)
Level = 0

# Design GUI
main_gui()

# Mainloop
do {

    Event = GTK("gtk_server_callback wait")

    if (Event == About) GTK("gtk_widget_show_all " Dialog)
    if (Event == Dialog) GTK("gtk_widget_hide " Dialog)
    if (Event == Index) lookup_index()
    if (Event == Back) back_servers()
    if (Event == Entry) lookup_word()

    GTK("gtk_widget_grab_focus " Entry)

} while (Event != Window)

# Exit GTK without waiting
GTK("gtk_server_exit")
}
