REM *************************************************************************************
REM
REM Module to reach the GTK-server for Scriptbasic.
REM
REM *************************************************************************************

MODULE gtk

DECLARE SUB ::gtk               ALIAS "_gtk"            LIB "gtk-server"

REM *************************************************************************************
REM
REM Example functions to wrap GTK into Scriptbasic.
REM
REM Only implementing the widgets which can be found on HTML forms to get started with
REM GUI programming. Implement more if you like.
REM
REM -windows
REM -normal buttons
REM -check buttons
REM -radio buttons
REM -text entries
REM -password entries
REM -labels
REM -drop down lists
REM -multiline text edits
REM -horizontal lines
REM -fieldsets
REM -lists
REM
REM Version 1.0
REM - Initial release (february 5, 2006)
REM Version 1.1
REM - Fixed bug with enabling logging (january 29, 2008)
REM
REM (c) Peter van Eerten, GPL license
REM
REM *************************************************************************************

GLOBAL GTK_INIT
GLOBAL GTK_CONTAINER
GLOBAL GTK_TYPE
GLOBAL GTK_START_ITER
GLOBAL GTK_END_ITER
GLOBAL GTK_TEXT_VIEW
GLOBAL GTK_COMBO_BOUND
GLOBAL GTK_LIST_STORE
GLOBAL GTK_LIST_ITER
GLOBAL GTK_LIST_SELECT
GLOBAL GTK_LIST_ARRAY

REM ************************************************************** Concat arguments to GTK

FUNCTION GUI(g0, g1, g2, g3, g4, g5, g6)

LOCAL result$

IF GTK_INIT = undef THEN
    IF g0 = "log" THEN
	gtk("gtk_server_cfg -log=gtk-server.log")
	g0 = "gtk_server_version"
    END IF
    IF LEN(gtk("gtk_check_version 2 6 0")) > 0 THEN
	PRINT "Your GTK installation is too old!\n"
	PRINT "GTK version 2.6.0 or higher is required. Exiting...\n"
	END
    END IF
    gtk("gtk_init NULL NULL")
    GTK_INIT = "done"
END IF

result$ = STR(g0) & " " & STR(g1) & " " & STR(g2) & " " & STR(g3) & " " & STR(g4) & " " & STR(g5) & " " & STR(g6)
GUI = gtk(result$)

END FUNCTION

REM ************************************************************** UTF-8 conversion for high ASCII

FUNCTION UTF8(st$)

LOCAL t, x, b1, b2

t = 1
WHILE t <= LEN(st$)
	x = ASC(MID(st$, t, 1))
	IF x > 127 THEN
		b1 = CHR((x AND 192) / 64 + 192)
		b2 = CHR((x AND 63) + 128)
		st$ = LEFT(st$, t - 1) & b1 & b2 & RIGHT(st$, LEN(st$) - t - 1)
		t+=1
	END IF
	t+=1
WEND

UTF8 = st$

END FUNCTION

REM ************************************************************** Window creation starts here

FUNCTION window(title, xsize, ysize)

LOCAL win$, fix$

win$ = GUI("gtk_window_new 0")
GUI("gtk_window_set_title", win$, "\"" & title & "\"")
GUI("gtk_widget_set_size_request", win$, xsize, ysize)
GUI("gtk_window_set_resizable", win$, 0)
GUI("gtk_widget_set_name", win$, win$)
GUI("gtk_widget_show", win$)

fix$ = GUI("gtk_fixed_new")
GUI("gtk_container_add", win$, fix$)
GUI("gtk_widget_show", fix$)

GTK_CONTAINER{win$} = fix$
GTK_TYPE{win$} = "window"

window = win$

END FUNCTION

REM ************************************************************** Parentize

FUNCTION attach(widget, parent, x, y)

LOCAL fix$

fix$ = GTK_CONTAINER{parent}
GUI("gtk_fixed_put", fix$, widget, x, y)

END FUNCTION

REM ************************************************************** Button creation starts here

FUNCTION button(text, xsize, ysize)

LOCAL but$

but$ = GUI("gtk_button_new_with_label \"" & text & "\"")
GUI("gtk_widget_set_size_request", but$, xsize, ysize)
GUI("gtk_widget_set_name", but$, but$)
GUI("gtk_widget_show", but$)

GTK_TYPE{but$} = "button"

button = but$

END FUNCTION

REM ************************************************************** Check Button creation starts here

FUNCTION check(text, xsize, ysize)

LOCAL chk$

chk$ = GUI("gtk_check_button_new_with_label \"" & text & "\"")
GUI("gtk_widget_set_size_request", chk$, xsize, ysize)
GUI("gtk_widget_set_name", chk$, chk$)
GUI("gtk_widget_show", chk$)

GTK_TYPE{chk$} = "check"

check = chk$

END FUNCTION

REM ************************************************************** Radio Button creation starts here

FUNCTION radio(text, xsize, ysize, group)

LOCAL rad$

rad$ = GUI("gtk_radio_button_new_with_label_from_widget", "\"" & STR(group) & "\"", "\"" & text & "\"")
GUI("gtk_widget_set_size_request", rad$, xsize, ysize)
GUI("gtk_widget_set_name", rad$, rad$)
GUI("gtk_widget_show", rad$)

GTK_TYPE{rad$} = "radio"

radio = rad$

END FUNCTION

REM ************************************************************** Entry creation starts here

FUNCTION entry(xsize, ysize)

LOCAL ent$

ent$ = GUI("gtk_entry_new")
GUI("gtk_widget_set_size_request", ent$, xsize, ysize)
GUI("gtk_widget_set_name", ent$, ent$)
GUI("gtk_widget_show", ent$)

GTK_TYPE{ent$} = "entry"

entry = ent$

END FUNCTION

REM ************************************************************** Password creation starts here

FUNCTION password(xsize, ysize)

LOCAL pwd$

pwd$ = GUI("gtk_entry_new")
GUI("gtk_widget_set_size_request", pwd$, xsize, ysize)
GUI("gtk_entry_set_visibility", pwd$, 0)
GUI("gtk_widget_set_name", pwd$, pwd$)
GUI("gtk_widget_show", pwd$)

GTK_TYPE{pwd$} = "password"

password = pwd$

END FUNCTION

REM ************************************************************** Label creation starts here

FUNCTION label(text, xsize, ysize)

LOCAL lab$

lab$ = GUI("gtk_label_new \"" & text & "\"")
GUI("gtk_widget_set_size_request", lab$, xsize, ysize)
GUI("gtk_widget_set_name", lab$, lab$)
GUI("gtk_widget_show", lab$)

GTK_TYPE{lab$} = "label"

label = lab$

END FUNCTION

REM ************************************************************** DropList creation starts here

FUNCTION droplist(text, xsize, ysize)

LOCAL drop$, i

drop$ = GUI("gtk_combo_box_new_text")

IF LBOUND(text) = undef THEN
	PRINT "WARNING: Pass an array to create a droplist!\n"
	GTK_COMBO_BOUND{drop$} = undef
ELSE
	FOR i = LBOUND(text) TO UBOUND(text)
		GUI("gtk_combo_box_append_text", drop$, "\"" & text[i] & "\"")
	NEXT i
	GTK_COMBO_BOUND{drop$} = UBOUND(text) - LBOUND(text)
END IF

GUI("gtk_combo_box_set_active", drop$, 0)
GUI("gtk_widget_set_size_request", drop$, xsize, ysize)
GUI("gtk_widget_set_name", drop$, drop$)
GUI("gtk_widget_show", drop$)

GTK_TYPE{drop$} = "droplist"

droplist = drop$

END FUNCTION

REM ************************************************************** Multiline text starts here

FUNCTION text(xsize, ysize)

LOCAL buf$, vw$, sw$

buf$ = GUI("gtk_text_buffer_new NULL")
vw$ = GUI("gtk_text_view_new_with_buffer", buf$)
GUI("gtk_text_view_set_wrap_mode", vw$, 1)
GUI("gtk_widget_set_name", vw$, vw$)
GUI("gtk_widget_show", vw$)

sw$ = GUI("gtk_scrolled_window_new NULL NULL")
GUI("gtk_scrolled_window_set_policy", sw$, 1, 1)
GUI("gtk_scrolled_window_set_shadow_type", sw$, 1)
GUI("gtk_container_add", sw$, vw$)
GUI("gtk_text_view_set_editable", vw$, 1)
GUI("gtk_text_view_set_wrap_mode", vw$, 2)
GUI("gtk_widget_set_size_request", sw$, xsize, ysize)
GUI("gtk_widget_show", sw$)

GTK_START_ITER{sw$} = GUI("gtk_server_opaque")
GTK_END_ITER{sw$} = GUI("gtk_server_opaque")
GTK_TEXT_VIEW{sw$} = vw$
GTK_CONTAINER{sw$} = buf$
GTK_TYPE{sw$} = "text"

text = sw$

END FUNCTION

REM ************************************************************** Separator creation starts here

FUNCTION separator(xsize)

LOCAL sep$

sep$ = GUI("gtk_hseparator_new")
GUI("gtk_widget_set_size_request", sep$, xsize, 0)
GUI("gtk_widget_set_name", sep$, sep$)
GUI("gtk_widget_show", sep$)

GTK_TYPE{sep$} = "separator"

separator = sep$

END FUNCTION

REM ************************************************************** Fieldset (frame) creation starts here

FUNCTION frame(text, xsize, ysize)

LOCAL frm$

frm$ = GUI("gtk_frame_new NULL")
GUI("gtk_frame_set_label", frm$, "\"" & text & "\"")
GUI("gtk_widget_set_size_request", frm$, xsize, ysize)
GUI("gtk_widget_set_name", frm$, frm$)
GUI("gtk_widget_show", frm$)

GTK_TYPE{frm$} = "frame"

frame = frm$

END FUNCTION

REM ************************************************************** List widget

FUNCTION list(text, xsize, ysize)

LOCAL lst$, iter$, tree$, column$, sel$, sw$, i

iter$ = GUI("gtk_server_opaque")
lst$ = GUI("gtk_list_store_new 1 64")
tree$ = GUI("gtk_tree_view_new_with_model", lst$)
GUI("gtk_tree_view_set_headers_visible", tree$, 0)
GUI("gtk_widget_set_name", tree$, tree$)
GUI("gtk_server_connect", tree$, "button-press-event", tree$, 1)

sel$ = GUI("gtk_tree_view_get_selection", tree$)
GUI("gtk_tree_selection_set_mode", sel$, 1)
column$ = GUI("gtk_tree_view_column_new_with_attributes", "dummy", GUI("gtk_cell_renderer_text_new"), "text", 0, "NULL")
GUI("gtk_tree_view_append_column", tree$, column$)

sw$ = GUI("gtk_scrolled_window_new NULL NULL")
GUI("gtk_scrolled_window_set_policy", sw$, 1, 1)
GUI("gtk_scrolled_window_set_shadow_type", sw$, 1)
GUI("gtk_container_add", sw$, tree$)

GUI("gtk_widget_set_size_request", sw$, xsize, ysize)
GUI("gtk_widget_show_all", sw$)

IF LBOUND(text) = undef THEN
	PRINT "WARNING: Pass an array to create a list!\n"
ELSE
	FOR i = LBOUND(text) TO UBOUND(text)
		GUI("gtk_list_store_append", lst$, iter$)
		GUI("gtk_list_store_set", lst$, iter$, 0, "\"" & text[i] & "\"", -1)
	NEXT i
	GTK_LIST_ARRAY{sw$} = text
END IF

GTK_LIST_STORE{sw$} = lst$
GTK_LIST_ITER{sw$} = iter$
GTK_LIST_SELECT{sw$} = sel$
GTK_CONTAINER{sw$} = tree$

GTK_TYPE{sw$} = "list"

list = sw$

END FUNCTION

REM ************************************************************** Get text from widget

FUNCTION get_text(widget)

LOCAL arr

IF GTK_TYPE{widget} = "window" THEN get_text = GUI("gtk_window_get_title", widget)
IF GTK_TYPE{widget} = "button" THEN get_text = GUI("gtk_button_get_label", widget)
IF GTK_TYPE{widget} = "check" THEN get_text = GUI("gtk_button_get_label", widget)
IF GTK_TYPE{widget} = "radio" THEN get_text = GUI("gtk_button_get_label", widget)
IF GTK_TYPE{widget} = "entry" THEN get_text = GUI("gtk_entry_get_text", widget)
IF GTK_TYPE{widget} = "password" THEN get_text = GUI("gtk_entry_get_text", widget)
IF GTK_TYPE{widget} = "label" THEN get_text = GUI("gtk_label_get_text", widget)
IF GTK_TYPE{widget} = "droplist" THEN get_text = GUI("gtk_combo_box_get_active_text", widget)
IF GTK_TYPE{widget} = "text" THEN
	GUI("gtk_text_buffer_get_start_iter", GTK_CONTAINER{widget}, GTK_START_ITER{widget})
	GUI("gtk_text_buffer_get_end_iter", GTK_CONTAINER{widget}, GTK_END_ITER{widget})
	get_text = GUI("gtk_text_buffer_get_text", GTK_CONTAINER{widget}, GTK_START_ITER{widget}, GTK_END_ITER{widget}, 1)
END IF
IF GTK_TYPE{widget} = "separator" THEN PRINT "WARNING: Cannot get text of " & GTK_TYPE{widget} & " widget!\n"
IF GTK_TYPE{widget} = "frame" THEN get_text = GUI("gtk_frame_get_label", widget)
IF GTK_TYPE{widget} = "list" THEN
	IF VAL(GUI("gtk_tree_selection_get_selected", GTK_LIST_SELECT{widget}, "NULL", GTK_LIST_ITER{widget})) THEN
		IF GTK_LIST_ARRAY{widget} <> undef THEN
			arr = GTK_LIST_ARRAY{widget}
			get_text = arr[LBOUND(arr) + VAL(GUI("gtk_tree_model_get_string_from_iter", GTK_LIST_STORE{widget}, GTK_LIST_ITER{widget}))]
		END IF
	END IF
END IF

END FUNCTION

REM ************************************************************** Set text in widget

FUNCTION set_text(widget, text)

LOCAL mark$, i

IF GTK_TYPE{widget} = "window" THEN GUI("gtk_window_set_title", widget,  "\"" & text & "\"")
IF GTK_TYPE{widget} = "button" THEN GUI("gtk_button_set_label", widget, "\"" & text & "\"")
IF GTK_TYPE{widget} = "check" THEN GUI("gtk_button_set_label", widget, "\"" & text & "\"")
IF GTK_TYPE{widget} = "radio" THEN GUI("gtk_button_set_label", widget, "\"" & text & "\"")
IF GTK_TYPE{widget} = "entry" THEN GUI("gtk_entry_set_text", widget, "\"" & text & "\"")
IF GTK_TYPE{widget} = "password" THEN GUI("gtk_entry_set_text", widget, "\"" & text & "\"")
IF GTK_TYPE{widget} = "label" THEN GUI("gtk_label_set_text", widget, "\"" & text & "\"")
IF GTK_TYPE{widget} = "droplist" THEN
	IF GTK_COMBO_BOUND{widget} <> undef THEN
		FOR i = 0 TO GTK_COMBO_BOUND{widget}
			GUI("gtk_combo_box_remove_text", widget, 0)
		NEXT i
	END IF
	IF LBOUND(text) = undef THEN
		PRINT "WARNING: Pass an array to recreate a droplist!\n"
		GTK_COMBO_BOUND{drop$} = undef
	ELSE
		FOR i = LBOUND(text) TO UBOUND(text)
			GUI("gtk_combo_box_append_text", widget, "\"" & text[i] & "\"")
		NEXT i
		GTK_COMBO_BOUND{drop$} = UBOUND(text) - LBOUND(text)
	END IF
	GUI("gtk_combo_box_set_active", widget, 0)
END IF
IF GTK_TYPE{widget} = "text" THEN
	GUI("gtk_text_buffer_set_text", GTK_CONTAINER{widget}, "\"" & text & "\"", -1)
	GUI("gtk_text_buffer_get_end_iter", GTK_CONTAINER{widget}, GTK_END_ITER{widget})
	mark$ = GUI("gtk_text_buffer_create_mark", GTK_CONTAINER{widget}, "mymark", GTK_END_ITER{widget}, 0)
	GUI("gtk_text_view_scroll_to_mark", GTK_TEXT_VIEW{widget}, mark$, 0, 1, 0.0, 1.0)
	GUI("gtk_text_buffer_delete_mark", GTK_CONTAINER{widget}, mark$)
END IF
IF GTK_TYPE{widget} = "separator" THEN PRINT "WARNING: Cannot set text of " & GTK_TYPE{widget} & " widget!\n"
IF GTK_TYPE{widget} = "frame" THEN GUI("gtk_frame_set_label", widget, "\"" & text & "\"")
IF GTK_TYPE{widget} = "list" THEN
	GUI("gtk_list_store_clear", GTK_LIST_STORE{widget})
	IF LBOUND(text) = undef THEN
		PRINT "WARNING: Pass an array to create a list!\n"
		GTK_LIST_ARRAY = undef
	ELSE
		FOR i = LBOUND(text) TO UBOUND(text)
			GUI("gtk_list_store_append", GTK_LIST_STORE{widget}, GTK_LIST_ITER{widget})
			GUI("gtk_list_store_set", GTK_LIST_STORE{widget}, GTK_LIST_ITER{widget}, 0, "\"" & text[i] & "\"", -1)
		NEXT i
		GTK_LIST_ARRAY{widget} = text
	END IF
END IF

END FUNCTION

REM ************************************************************** Find selection of chek/option button

FUNCTION get_value(widget)

IF GTK_TYPE{widget} = "check" THEN
	get_value = VAL(GUI("gtk_toggle_button_get_active", widget))
ELSE IF GTK_TYPE{widget} = "radio" THEN
	get_value = VAL(GUI("gtk_toggle_button_get_active", widget))
ELSE IF GTK_TYPE{widget} = "droplist" THEN
	get_value = VAL(GUI("gtk_combo_box_get_active", widget))
ELSE IF GTK_TYPE{widget} = "text" THEN
	get_value = VAL(GUI("gtk_text_buffer_get_line_count", GTK_CONTAINER{widget}))
ELSE IF GTK_TYPE{widget} = "list" THEN
	IF VAL(GUI("gtk_tree_selection_get_selected", GTK_LIST_SELECT{widget}, "NULL", GTK_LIST_ITER{widget})) THEN
		get_value = VAL(GUI("gtk_tree_model_get_string_from_iter", GTK_LIST_STORE{widget}, GTK_LIST_ITER{widget}))
	END IF
ELSE
	PRINT "WARNING: Cannot get status of " & GTK_TYPE{widget} & " widget!\n"
END IF

END FUNCTION

REM ************************************************************** Set selection of check/option button

FUNCTION set_value(widget, n)

LOCAL path, mark$

IF GTK_TYPE{widget} = "check" THEN
	GUI("gtk_toggle_button_set_active", widget, 1)
ELSE IF GTK_TYPE{widget} = "radio" THEN
	GUI("gtk_toggle_button_set_active", widget, 1)
ELSE IF GTK_TYPE{widget} = "droplist" THEN
	GUI("gtk_combo_box_set_active", widget, n)
ELSE IF GTK_TYPE{widget} = "text" THEN
	GUI("gtk_text_buffer_get_iter_at_line", GTK_CONTAINER{widget}, GTK_END_ITER{widget}, n)
	mark$ = GUI("gtk_text_buffer_create_mark", GTK_CONTAINER{widget}, "mymark", GTK_END_ITER{widget}, 0)
	GUI("gtk_text_view_scroll_to_mark", GTK_TEXT_VIEW{widget}, mark$, 0, 1, 0.0, 1.0)
	GUI("gtk_text_buffer_delete_mark", GTK_CONTAINER{widget}, mark$)
ELSE IF GTK_TYPE{widget} = "list" THEN
	path = GUI("gtk_tree_path_new_from_string", n)
	GUI("gtk_tree_selection_select_path", GTK_LIST_SELECT{widget}, path)
	GUI("gtk_tree_path_free", path)
ELSE
	PRINT "WARNING: Cannot activate " & GTK_TYPE{widget} & " widget!\n"
END IF

END FUNCTION

REM ************************************************************** Focus to widget

FUNCTION focus(widget)

GUI("gtk_widget_grab_focus", widget)

END FUNCTION

REM ************************************************************** Foreground colors

FUNCTION fg_color(widget, r, g, b)

LOCAL tmp$, gtksettings$

gtksettings$ = GUI("gtk_settings_get_default")

IF GTK_TYPE{widget} = "window" THEN PRINT "WARNING: Cannot set foreground color of window widget!\n"
IF GTK_TYPE{widget} = "button" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { fg[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { fg[PRELIGHT] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { fg[ACTIVE] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & widget & "*\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "check" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { fg[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { fg[PRELIGHT] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { fg[ACTIVE] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & widget & "*\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "radio" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { fg[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { fg[PRELIGHT] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { fg[ACTIVE] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & widget & "*\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "entry" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { text[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { GtkWidget::cursor_color = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & widget & "\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "password" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { text[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { GtkWidget::cursor_color = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & widget & "\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "label" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { fg[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & widget & "\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "droplist" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { text[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { text[PRELIGHT] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & widget & "*\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "text" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { text[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { GtkWidget::cursor_color = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & GTK_TEXT_VIEW{widget} & "\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "separator" THEN PRINT "WARNING: Cannot set foreground color of separator widget!\n"
IF GTK_TYPE{widget} = "frame" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { fg[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & widget & "*\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "list" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { text[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & GTK_CONTAINER{widget} & "\\\" style \\\"" & widget & "\\\"\"")
END IF

GUI("gtk_rc_reset_styles", gtksettings$)

END FUNCTION

REM ************************************************************** Background colors

FUNCTION bg_color(widget, r, g, b)

LOCAL tmp$, gtksettings$

gtksettings$ = GUI("gtk_settings_get_default")

IF GTK_TYPE{widget} = "window" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { bg[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"" & widget & "\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "button" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { bg[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	IF r < 60415 THEN r = r + 5120 
	IF g < 60415 THEN g = g + 5120
	IF b < 60415 THEN b = b + 5120
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { bg[PRELIGHT] = {" & r & ", " & g & ", " & b & "} }\"")
	IF r > 5120 THEN r = r - 5120
	IF g > 5120 THEN g = g - 5120
	IF b > 5120 THEN b = b - 5120
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { bg[ACTIVE] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & widget & "*\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "check" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { bg[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	IF r < 60415 THEN r = r + 5120 
	IF g < 60415 THEN g = g + 5120
	IF b < 60415 THEN b = b + 5120
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { bg[PRELIGHT] = {" & r & ", " & g & ", " & b & "} }\"")
	IF r > 5120 THEN r = r - 5120
	IF g > 5120 THEN g = g - 5120
	IF b > 5120 THEN b = b - 5120
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { bg[ACTIVE] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & widget & "*\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "radio" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { bg[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	IF r < 60415 THEN r = r + 5120 
	IF g < 60415 THEN g = g + 5120
	IF b < 60415 THEN b = b + 5120
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { bg[PRELIGHT] = {" & r & ", " & g & ", " & b & "} }\"")
	IF r > 5120 THEN r = r - 5120
	IF g > 5120 THEN g = g - 5120
	IF b > 5120 THEN b = b - 5120
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { bg[ACTIVE] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & widget & "*\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "entry" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { base[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & widget & "\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "password" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { base[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & widget & "\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "text" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { base[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & GTK_TEXT_VIEW{widget} & "\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "droplist" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { bg[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	IF r < 60415 THEN r = r + 5120 
	IF g < 60415 THEN g = g + 5120
	IF b < 60415 THEN b = b + 5120
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { bg[PRELIGHT] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & widget & "*\\\" style \\\"" & widget & "\\\"\"")
END IF

IF GTK_TYPE{widget} = "label" THEN PRINT "WARNING: Cannot set background color of label widget!\n"
IF GTK_TYPE{widget} = "separator" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { bg[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & widget & "\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "frame" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { bg[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & widget & "\\\" style \\\"" & widget & "\\\"\"")
END IF
IF GTK_TYPE{widget} = "list" THEN
	GUI("gtk_rc_parse_string", "\"style \\\"" & widget & "\\\" { base[NORMAL] = {" & r & ", " & g & ", " & b & "} }\"")
	GUI("gtk_rc_parse_string \"widget \\\"*.*." & GTK_CONTAINER{widget} & "\\\" style \\\"" & widget & "\\\"\"")
END IF

GUI("gtk_rc_reset_styles", gtksettings$)

END FUNCTION

REM ************************************************************** Disable widget

FUNCTION disable(widget)

IF GTK_TYPE{widget} = "window" THEN PRINT "WARNING: Cannot disable " & GTK_TYPE{widget} & " widget!\n"
IF GTK_TYPE{widget} = "button" THEN GUI("gtk_widget_set_sensitive", widget, 0)
IF GTK_TYPE{widget} = "check" THEN GUI("gtk_widget_set_sensitive", widget, 0)
IF GTK_TYPE{widget} = "radio" THEN GUI("gtk_widget_set_sensitive", widget, 0)
IF GTK_TYPE{widget} = "entry" THEN GUI("gtk_widget_set_sensitive", widget, 0)
IF GTK_TYPE{widget} = "password" THEN GUI("gtk_widget_set_sensitive", widget, 0)
IF GTK_TYPE{widget} = "label" THEN PRINT "WARNING: Cannot disable " & GTK_TYPE{widget} & " widget!\n"
IF GTK_TYPE{widget} = "droplist" THEN GUI("gtk_widget_set_sensitive", widget, 0)
IF GTK_TYPE{widget} = "text" THEN GUI("gtk_text_view_set_editable", GTK_TEXT_VIEW{widget}, 0)
IF GTK_TYPE{widget} = "separator" THEN PRINT "WARNING: Cannot disable " & GTK_TYPE{widget} & " widget!\n"
IF GTK_TYPE{widget} = "frame" THEN PRINT "WARNING: Cannot disable " & GTK_TYPE{widget} & " widget!\n"
IF GTK_TYPE{widget} = "list" THEN GUI("gtk_widget_set_sensitive", widget, 0)

END FUNCTION

REM ************************************************************** Enable widget

FUNCTION enable(widget)

IF GTK_TYPE{widget} = "window" THEN PRINT "WARNING: Cannot enable " & GTK_TYPE{widget} & " widget!\n"
IF GTK_TYPE{widget} = "button" THEN GUI("gtk_widget_set_sensitive", widget, 1)
IF GTK_TYPE{widget} = "check" THEN GUI("gtk_widget_set_sensitive", widget, 1)
IF GTK_TYPE{widget} = "radio" THEN GUI("gtk_widget_set_sensitive", widget, 1)
IF GTK_TYPE{widget} = "entry" THEN GUI("gtk_widget_set_sensitive", widget, 1)
IF GTK_TYPE{widget} = "password" THEN GUI("gtk_widget_set_sensitive", widget, 1)
IF GTK_TYPE{widget} = "label" THEN PRINT "WARNING: Cannot enable " & GTK_TYPE{widget} & " widget!\n"
IF GTK_TYPE{widget} = "droplist" THEN GUI("gtk_widget_set_sensitive", widget, 1)
IF GTK_TYPE{widget} = "text" THEN GUI("gtk_text_view_set_editable", GTK_TEXT_VIEW{widget}, 1)
IF GTK_TYPE{widget} = "separator" THEN PRINT "WARNING: Cannot enable " & GTK_TYPE{widget} & " widget!\n"
IF GTK_TYPE{widget} = "frame" THEN PRINT "WARNING: Cannot enable " & GTK_TYPE{widget} & " widget!\n"
IF GTK_TYPE{widget} = "list" THEN GUI("gtk_widget_set_sensitive", widget, 1)

END FUNCTION

REM ************************************************************** Hide widget

FUNCTION hide(widget)

GUI("gtk_widget_hide", widget)

END FUNCTION

REM ************************************************************** Show widget

FUNCTION show(widget)

GUI("gtk_widget_show", widget)

END FUNCTION

REM ************************************************************** Synchronous mainloop here

FUNCTION event

event = GUI("gtk_server_callback wait")

END FUNCTION

REM ************************************************************** Asynchronous mainloop here

FUNCTION async

async = GUI("gtk_server_callback update")

END FUNCTION

REM ************************************************************** Get version

FUNCTION version

version = GUI("gtk_server_version")

END FUNCTION

REM ************************************************************** Get/set logging

FUNCTION logging

GUI("log")

END FUNCTION

END MODULE

REM ************************************************************** Embedded GTK
REM
REM Now you can also use the defined GTK functions from the GTK-server configfile
REM  directly into Scriptbasic. :-)
REM
REM October 21, 2006 - PvE.
REM
REM ***************************************************************************

FUNCTION gtk_window_new( arg1)
gtk_window_new=GTK::gtk("gtk_window_new \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_window_set_title( arg1, arg2)
gtk_window_set_title=GTK::gtk("gtk_window_set_title \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_window_get_title( arg1)
gtk_window_get_title=GTK::gtk("gtk_window_get_title \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_window_set_default_size( arg1, arg2, arg3)
gtk_window_set_default_size=GTK::gtk("gtk_window_set_default_size \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_window_set_position( arg1, arg2)
gtk_window_set_position=GTK::gtk("gtk_window_set_position \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_window_set_resizable( arg1, arg2)
gtk_window_set_resizable=GTK::gtk("gtk_window_set_resizable \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_window_set_transient_for( arg1, arg2)
gtk_window_set_transient_for=GTK::gtk("gtk_window_set_transient_for \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_window_set_modal( arg1, arg2)
gtk_window_set_modal=GTK::gtk("gtk_window_set_modal \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_window_maximize( arg1)
gtk_window_maximize=GTK::gtk("gtk_window_maximize \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_message_dialog_new( arg1, arg2, arg3, arg4, arg5, arg6)
gtk_message_dialog_new=GTK::gtk("gtk_message_dialog_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION gtk_message_dialog_new_with_markup( arg1, arg2, arg3, arg4, arg5, arg6)
gtk_message_dialog_new_with_markup=GTK::gtk("gtk_message_dialog_new_with_markup \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION gtk_window_set_icon_from_file( arg1, arg2, arg3)
gtk_window_set_icon_from_file=GTK::gtk("gtk_window_set_icon_from_file \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_window_set_keep_above( arg1, arg2)
gtk_window_set_keep_above=GTK::gtk("gtk_window_set_keep_above \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_window_set_keep_below( arg1, arg2)
gtk_window_set_keep_below=GTK::gtk("gtk_window_set_keep_below \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_about_dialog_set_version( arg1, arg2)
gtk_about_dialog_set_version=GTK::gtk("gtk_about_dialog_set_version \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_window_set_policy( arg1, arg2, arg3, arg4)
gtk_window_set_policy=GTK::gtk("gtk_window_set_policy \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_window_fullscreen( arg1)
gtk_window_fullscreen=GTK::gtk("gtk_window_fullscreen \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_window_unfullscreen( arg1)
gtk_window_unfullscreen=GTK::gtk("gtk_window_unfullscreen \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_window_set_icon_name( arg1, arg2)
gtk_window_set_icon_name=GTK::gtk("gtk_window_set_icon_name \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_window_add_accel_group( arg1, arg2)
gtk_window_add_accel_group=GTK::gtk("gtk_window_add_accel_group \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_table_new( arg1, arg2, arg3)
gtk_table_new=GTK::gtk("gtk_table_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_table_attach_defaults( arg1, arg2, arg3, arg4, arg5, arg6)
gtk_table_attach_defaults=GTK::gtk("gtk_table_attach_defaults \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION gtk_container_add( arg1, arg2)
gtk_container_add=GTK::gtk("gtk_container_add \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_container_remove( arg1, arg2)
gtk_container_remove=GTK::gtk("gtk_container_remove \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_container_set_border_width( arg1, arg2)
gtk_container_set_border_width=GTK::gtk("gtk_container_set_border_width \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_hbox_new( arg1, arg2)
gtk_hbox_new=GTK::gtk("gtk_hbox_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_vbox_new( arg1, arg2)
gtk_vbox_new=GTK::gtk("gtk_vbox_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_box_pack_start( arg1, arg2, arg3, arg4, arg5)
gtk_box_pack_start=GTK::gtk("gtk_box_pack_start \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gtk_box_pack_end( arg1, arg2, arg3, arg4, arg5)
gtk_box_pack_end=GTK::gtk("gtk_box_pack_end \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gtk_box_pack_start_defaults( arg1, arg2)
gtk_box_pack_start_defaults=GTK::gtk("gtk_box_pack_start_defaults \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_box_pack_end_defaults( arg1, arg2)
gtk_box_pack_end_defaults=GTK::gtk("gtk_box_pack_end_defaults \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_box_set_spacing( arg1, arg2)
gtk_box_set_spacing=GTK::gtk("gtk_box_set_spacing \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_button_new
gtk_button_new=GTK::gtk("gtk_button_new")
END FUNCTION

FUNCTION gtk_button_new_with_label( arg1)
gtk_button_new_with_label=GTK::gtk("gtk_button_new_with_label \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_button_new_from_stock( arg1)
gtk_button_new_from_stock=GTK::gtk("gtk_button_new_from_stock \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_button_new_with_mnemonic( arg1)
gtk_button_new_with_mnemonic=GTK::gtk("gtk_button_new_with_mnemonic \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_button_set_use_stock( arg1, arg2)
gtk_button_set_use_stock=GTK::gtk("gtk_button_set_use_stock \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_button_set_label( arg1, arg2)
gtk_button_set_label=GTK::gtk("gtk_button_set_label \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_button_set_relief( arg1, arg2)
gtk_button_set_relief=GTK::gtk("gtk_button_set_relief \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_hbutton_box_new
gtk_hbutton_box_new=GTK::gtk("gtk_hbutton_box_new")
END FUNCTION

FUNCTION gtk_button_box_set_layout( arg1, arg2)
gtk_button_box_set_layout=GTK::gtk("gtk_button_box_set_layout \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_bin_get_child( arg1)
gtk_bin_get_child=GTK::gtk("gtk_bin_get_child \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_button_clicked( arg1)
gtk_button_clicked=GTK::gtk("gtk_button_clicked \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_toggle_button_new
gtk_toggle_button_new=GTK::gtk("gtk_toggle_button_new")
END FUNCTION

FUNCTION gtk_toggle_button_new_with_label( arg1)
gtk_toggle_button_new_with_label=GTK::gtk("gtk_toggle_button_new_with_label \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_toggle_button_new_with_mnemonic( arg1)
gtk_toggle_button_new_with_mnemonic=GTK::gtk("gtk_toggle_button_new_with_mnemonic \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_toggle_button_get_active( arg1)
gtk_toggle_button_get_active=GTK::gtk("gtk_toggle_button_get_active \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_toggle_button_set_active( arg1, arg2)
gtk_toggle_button_set_active=GTK::gtk("gtk_toggle_button_set_active \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_check_button_new_with_label( arg1)
gtk_check_button_new_with_label=GTK::gtk("gtk_check_button_new_with_label \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_entry_new
gtk_entry_new=GTK::gtk("gtk_entry_new")
END FUNCTION

FUNCTION gtk_entry_get_text( arg1)
gtk_entry_get_text=GTK::gtk("gtk_entry_get_text \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_entry_set_text( arg1, arg2)
gtk_entry_set_text=GTK::gtk("gtk_entry_set_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_entry_set_visibility( arg1, arg2)
gtk_entry_set_visibility=GTK::gtk("gtk_entry_set_visibility \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_editable_delete_text( arg1, arg2, arg3)
gtk_editable_delete_text=GTK::gtk("gtk_editable_delete_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_editable_get_chars( arg1, arg2, arg3)
gtk_editable_get_chars=GTK::gtk("gtk_editable_get_chars \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_editable_set_editable( arg1, arg2)
gtk_editable_set_editable=GTK::gtk("gtk_editable_set_editable \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_editable_select_region( arg1, arg2, arg3)
gtk_editable_select_region=GTK::gtk("gtk_editable_select_region \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_editable_set_position( arg1, arg2)
gtk_editable_set_position=GTK::gtk("gtk_editable_set_position \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_editable_get_position( arg1)
gtk_editable_get_position=GTK::gtk("gtk_editable_get_position \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_editable_get_selection_bounds( arg1, arg2, arg3)
gtk_editable_get_selection_bounds=GTK::gtk("gtk_editable_get_selection_bounds \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_editable_insert_text( arg1, arg2, arg3, arg4)
gtk_editable_insert_text=GTK::gtk("gtk_editable_insert_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_new( arg1)
gtk_text_buffer_new=GTK::gtk("gtk_text_buffer_new \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_set_text( arg1, arg2, arg3)
gtk_text_buffer_set_text=GTK::gtk("gtk_text_buffer_set_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_insert_at_cursor( arg1, arg2, arg3)
gtk_text_buffer_insert_at_cursor=GTK::gtk("gtk_text_buffer_insert_at_cursor \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_get_insert( arg1)
gtk_text_buffer_get_insert=GTK::gtk("gtk_text_buffer_get_insert \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_get_start_iter( arg1, arg2)
gtk_text_buffer_get_start_iter=GTK::gtk("gtk_text_buffer_get_start_iter \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_get_end_iter( arg1, arg2)
gtk_text_buffer_get_end_iter=GTK::gtk("gtk_text_buffer_get_end_iter \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_get_bounds( arg1, arg2, arg3)
gtk_text_buffer_get_bounds=GTK::gtk("gtk_text_buffer_get_bounds \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_get_selection_bounds( arg1, arg2, arg3)
gtk_text_buffer_get_selection_bounds=GTK::gtk("gtk_text_buffer_get_selection_bounds \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_get_iter_at_offset( arg1, arg2, arg3)
gtk_text_buffer_get_iter_at_offset=GTK::gtk("gtk_text_buffer_get_iter_at_offset \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_get_text( arg1, arg2, arg3, arg4)
gtk_text_buffer_get_text=GTK::gtk("gtk_text_buffer_get_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_insert( arg1, arg2, arg3, arg4)
gtk_text_buffer_insert=GTK::gtk("gtk_text_buffer_insert \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_create_tag( arg1, arg2, arg3, arg4, arg5)
gtk_text_buffer_create_tag=GTK::gtk("gtk_text_buffer_create_tag \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_insert_with_tags_by_name( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
gtk_text_buffer_insert_with_tags_by_name=GTK::gtk("gtk_text_buffer_insert_with_tags_by_name \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\" \"" &  STR(arg7) & "\" \"" &  STR(arg8) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_apply_tag_by_name( arg1, arg2, arg3, arg4)
gtk_text_buffer_apply_tag_by_name=GTK::gtk("gtk_text_buffer_apply_tag_by_name \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_remove_tag_by_name( arg1, arg2, arg3, arg4)
gtk_text_buffer_remove_tag_by_name=GTK::gtk("gtk_text_buffer_remove_tag_by_name \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_remove_all_tags( arg1, arg2, arg3)
gtk_text_buffer_remove_all_tags=GTK::gtk("gtk_text_buffer_remove_all_tags \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_get_tag_table( arg1)
gtk_text_buffer_get_tag_table=GTK::gtk("gtk_text_buffer_get_tag_table \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_select_range( arg1, arg2, arg3)
gtk_text_buffer_select_range=GTK::gtk("gtk_text_buffer_select_range \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_get_selection_bound( arg1)
gtk_text_buffer_get_selection_bound=GTK::gtk("gtk_text_buffer_get_selection_bound \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_get_line_count( arg1)
gtk_text_buffer_get_line_count=GTK::gtk("gtk_text_buffer_get_line_count \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_create_mark( arg1, arg2, arg3, arg4)
gtk_text_buffer_create_mark=GTK::gtk("gtk_text_buffer_create_mark \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_get_iter_at_mark( arg1, arg2, arg3)
gtk_text_buffer_get_iter_at_mark=GTK::gtk("gtk_text_buffer_get_iter_at_mark \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_get_iter_at_line( arg1, arg2, arg3)
gtk_text_buffer_get_iter_at_line=GTK::gtk("gtk_text_buffer_get_iter_at_line \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_delete( arg1, arg2, arg3)
gtk_text_buffer_delete=GTK::gtk("gtk_text_buffer_delete \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_delete_mark( arg1, arg2)
gtk_text_buffer_delete_mark=GTK::gtk("gtk_text_buffer_delete_mark \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_delete_mark_by_name( arg1, arg2)
gtk_text_buffer_delete_mark_by_name=GTK::gtk("gtk_text_buffer_delete_mark_by_name \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_place_cursor( arg1, arg2)
gtk_text_buffer_place_cursor=GTK::gtk("gtk_text_buffer_place_cursor \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_copy_clipboard( arg1, arg2)
gtk_text_buffer_copy_clipboard=GTK::gtk("gtk_text_buffer_copy_clipboard \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_cut_clipboard( arg1, arg2, arg3)
gtk_text_buffer_cut_clipboard=GTK::gtk("gtk_text_buffer_cut_clipboard \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_text_buffer_paste_clipboard( arg1, arg2, arg3, arg4)
gtk_text_buffer_paste_clipboard=GTK::gtk("gtk_text_buffer_paste_clipboard \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_scrolled_window_new( arg1, arg2)
gtk_scrolled_window_new=GTK::gtk("gtk_scrolled_window_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_scrolled_window_set_policy( arg1, arg2, arg3)
gtk_scrolled_window_set_policy=GTK::gtk("gtk_scrolled_window_set_policy \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_scrolled_window_set_shadow_type( arg1, arg2)
gtk_scrolled_window_set_shadow_type=GTK::gtk("gtk_scrolled_window_set_shadow_type \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_scrolled_window_add_with_viewport( arg1, arg2)
gtk_scrolled_window_add_with_viewport=GTK::gtk("gtk_scrolled_window_add_with_viewport \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_scrolled_window_get_hadjustment( arg1)
gtk_scrolled_window_get_hadjustment=GTK::gtk("gtk_scrolled_window_get_hadjustment \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_scrolled_window_get_vadjustment( arg1)
gtk_scrolled_window_get_vadjustment=GTK::gtk("gtk_scrolled_window_get_vadjustment \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_scrolled_window_set_hadjustment( arg1, arg2)
gtk_scrolled_window_set_hadjustment=GTK::gtk("gtk_scrolled_window_set_hadjustment \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_scrolled_window_set_vadjustment( arg1, arg2)
gtk_scrolled_window_set_vadjustment=GTK::gtk("gtk_scrolled_window_set_vadjustment \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_scrolled_window_set_placement( arg1, arg2)
gtk_scrolled_window_set_placement=GTK::gtk("gtk_scrolled_window_set_placement \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_view_new_with_buffer( arg1)
gtk_text_view_new_with_buffer=GTK::gtk("gtk_text_view_new_with_buffer \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_text_view_set_wrap_mode( arg1, arg2)
gtk_text_view_set_wrap_mode=GTK::gtk("gtk_text_view_set_wrap_mode \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_view_set_editable( arg1, arg2)
gtk_text_view_set_editable=GTK::gtk("gtk_text_view_set_editable \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_view_set_border_window_size( arg1, arg2, arg3)
gtk_text_view_set_border_window_size=GTK::gtk("gtk_text_view_set_border_window_size \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_text_view_move_mark_onscreen( arg1, arg2)
gtk_text_view_move_mark_onscreen=GTK::gtk("gtk_text_view_move_mark_onscreen \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_view_scroll_to_mark( arg1, arg2, arg3, arg4, arg5, arg6)
gtk_text_view_scroll_to_mark=GTK::gtk("gtk_text_view_scroll_to_mark \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION gtk_text_view_scroll_mark_onscreen( arg1, arg2)
gtk_text_view_scroll_mark_onscreen=GTK::gtk("gtk_text_view_scroll_mark_onscreen \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_view_set_pixels_inside_wrap( arg1, arg2)
gtk_text_view_set_pixels_inside_wrap=GTK::gtk("gtk_text_view_set_pixels_inside_wrap \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_view_get_pixels_inside_wrap( arg1)
gtk_text_view_get_pixels_inside_wrap=GTK::gtk("gtk_text_view_get_pixels_inside_wrap \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_text_view_set_pixels_above_lines( arg1, arg2)
gtk_text_view_set_pixels_above_lines=GTK::gtk("gtk_text_view_set_pixels_above_lines \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_view_get_pixels_above_lines( arg1)
gtk_text_view_get_pixels_above_lines=GTK::gtk("gtk_text_view_get_pixels_above_lines \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_text_view_set_cursor_visible( arg1, arg2)
gtk_text_view_set_cursor_visible=GTK::gtk("gtk_text_view_set_cursor_visible \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_view_window_to_buffer_coords( arg1, arg2, arg3, arg4, arg5, arg6)
gtk_text_view_window_to_buffer_coords=GTK::gtk("gtk_text_view_window_to_buffer_coords \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION gtk_text_iter_forward_search( arg1, arg2, arg3, arg4, arg5, arg6)
gtk_text_iter_forward_search=GTK::gtk("gtk_text_iter_forward_search \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION gtk_text_iter_forward_visible_cursor_position( arg1)
gtk_text_iter_forward_visible_cursor_position=GTK::gtk("gtk_text_iter_forward_visible_cursor_position \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_text_iter_forward_to_line_end( arg1)
gtk_text_iter_forward_to_line_end=GTK::gtk("gtk_text_iter_forward_to_line_end \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_text_iter_set_line( arg1, arg2)
gtk_text_iter_set_line=GTK::gtk("gtk_text_iter_set_line \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_iter_set_line_offset( arg1, arg2)
gtk_text_iter_set_line_offset=GTK::gtk("gtk_text_iter_set_line_offset \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_iter_set_line_index( arg1, arg2)
gtk_text_iter_set_line_index=GTK::gtk("gtk_text_iter_set_line_index \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_iter_get_text( arg1, arg2)
gtk_text_iter_get_text=GTK::gtk("gtk_text_iter_get_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_iter_get_line( arg1)
gtk_text_iter_get_line=GTK::gtk("gtk_text_iter_get_line \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_text_view_new
gtk_text_view_new=GTK::gtk("gtk_text_view_new")
END FUNCTION

FUNCTION gtk_text_view_get_buffer( arg1)
gtk_text_view_get_buffer=GTK::gtk("gtk_text_view_get_buffer \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_text_tag_table_remove( arg1, arg2)
gtk_text_tag_table_remove=GTK::gtk("gtk_text_tag_table_remove \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_new( arg1, arg2)
gtk_text_new=GTK::gtk("gtk_text_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_set_editable( arg1, arg2)
gtk_text_set_editable=GTK::gtk("gtk_text_set_editable \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_insert( arg1, arg2, arg3, arg4, arg5, arg6)
gtk_text_insert=GTK::gtk("gtk_text_insert \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION gtk_text_set_adjustments( arg1, arg2, arg3)
gtk_text_set_adjustments=GTK::gtk("gtk_text_set_adjustments \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_text_get_length( arg1)
gtk_text_get_length=GTK::gtk("gtk_text_get_length \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_text_set_word_wrap( arg1, arg2)
gtk_text_set_word_wrap=GTK::gtk("gtk_text_set_word_wrap \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_backward_delete( arg1, arg2)
gtk_text_backward_delete=GTK::gtk("gtk_text_backward_delete \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_forward_delete( arg1, arg2)
gtk_text_forward_delete=GTK::gtk("gtk_text_forward_delete \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_text_set_point( arg1, arg2)
gtk_text_set_point=GTK::gtk("gtk_text_set_point \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gdk_font_load( arg1)
gdk_font_load=GTK::gtk("gdk_font_load \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gdk_pixmap_new( arg1, arg2, arg3, arg4)
gdk_pixmap_new=GTK::gtk("gdk_pixmap_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gdk_pixmap_unref( arg1)
gdk_pixmap_unref=GTK::gtk("gdk_pixmap_unref \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gdk_pixmap_create_from_xpm( arg1, arg2, arg3, arg4)
gdk_pixmap_create_from_xpm=GTK::gtk("gdk_pixmap_create_from_xpm \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gdk_pixmap_colormap_create_from_xpm( arg1, arg2, arg3, arg4, arg5)
gdk_pixmap_colormap_create_from_xpm=GTK::gtk("gdk_pixmap_colormap_create_from_xpm \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gdk_draw_rectangle( arg1, arg2, arg3, arg4, arg5, arg6, arg7)
gdk_draw_rectangle=GTK::gtk("gdk_draw_rectangle \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\" \"" &  STR(arg7) & "\"")
END FUNCTION

FUNCTION gdk_draw_arc( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
gdk_draw_arc=GTK::gtk("gdk_draw_arc \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\" \"" &  STR(arg7) & "\" \"" &  STR(arg8) & "\" \"" &  STR(arg9) & "\"")
END FUNCTION

FUNCTION gdk_draw_line( arg1, arg2, arg3, arg4, arg5, arg6)
gdk_draw_line=GTK::gtk("gdk_draw_line \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION gdk_draw_point( arg1, arg2, arg3, arg4)
gdk_draw_point=GTK::gtk("gdk_draw_point \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gdk_draw_layout( arg1, arg2, arg3, arg4, arg5)
gdk_draw_layout=GTK::gtk("gdk_draw_layout \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gdk_draw_layout_with_colors( arg1, arg2, arg3, arg4, arg5, arg6, arg7)
gdk_draw_layout_with_colors=GTK::gtk("gdk_draw_layout_with_colors \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\" \"" &  STR(arg7) & "\"")
END FUNCTION

FUNCTION gdk_draw_drawable( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
gdk_draw_drawable=GTK::gtk("gdk_draw_drawable \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\" \"" &  STR(arg7) & "\" \"" &  STR(arg8) & "\" \"" &  STR(arg9) & "\"")
END FUNCTION

FUNCTION gdk_gc_new( arg1)
gdk_gc_new=GTK::gtk("gdk_gc_new \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gdk_gc_set_rgb_fg_color( arg1, arg2)
gdk_gc_set_rgb_fg_color=GTK::gtk("gdk_gc_set_rgb_fg_color \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gdk_gc_set_rgb_bg_color( arg1, arg2)
gdk_gc_set_rgb_bg_color=GTK::gtk("gdk_gc_set_rgb_bg_color \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gdk_gc_set_foreground( arg1, arg2)
gdk_gc_set_foreground=GTK::gtk("gdk_gc_set_foreground \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gdk_gc_set_background( arg1, arg2)
gdk_gc_set_background=GTK::gtk("gdk_gc_set_background \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gdk_gc_set_colormap( arg1, arg2)
gdk_gc_set_colormap=GTK::gtk("gdk_gc_set_colormap \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gdk_color_alloc( arg1, arg2)
gdk_color_alloc=GTK::gtk("gdk_color_alloc \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gdk_color_parse( arg1, arg2)
gdk_color_parse=GTK::gtk("gdk_color_parse \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gdk_colormap_get_system
gdk_colormap_get_system=GTK::gtk("gdk_colormap_get_system")
END FUNCTION

FUNCTION gdk_colormap_alloc_color( arg1, arg2, arg3, arg4)
gdk_colormap_alloc_color=GTK::gtk("gdk_colormap_alloc_color \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gdk_get_default_root_window
gdk_get_default_root_window=GTK::gtk("gdk_get_default_root_window")
END FUNCTION

FUNCTION gdk_rgb_find_color( arg1, arg2)
gdk_rgb_find_color=GTK::gtk("gdk_rgb_find_color \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gdk_drawable_set_colormap( arg1, arg2)
gdk_drawable_set_colormap=GTK::gtk("gdk_drawable_set_colormap \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gdk_drawable_get_size( arg1, arg2, arg3)
gdk_drawable_get_size=GTK::gtk("gdk_drawable_get_size \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gdk_drawable_get_depth( arg1)
gdk_drawable_get_depth=GTK::gtk("gdk_drawable_get_depth \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gdk_keymap_translate_keyboard_state( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
gdk_keymap_translate_keyboard_state=GTK::gtk("gdk_keymap_translate_keyboard_state \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\" \"" &  STR(arg7) & "\" \"" &  STR(arg8) & "\"")
END FUNCTION

FUNCTION gdk_window_process_all_updates
gdk_window_process_all_updates=GTK::gtk("gdk_window_process_all_updates")
END FUNCTION

FUNCTION gdk_window_freeze_updates( arg1)
gdk_window_freeze_updates=GTK::gtk("gdk_window_freeze_updates \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gdk_window_thaw_updates( arg1)
gdk_window_thaw_updates=GTK::gtk("gdk_window_thaw_updates \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gdk_window_get_geometry( arg1, arg2, arg3, arg4, arg5, arg6)
gdk_window_get_geometry=GTK::gtk("gdk_window_get_geometry \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION gdk_screen_get_default
gdk_screen_get_default=GTK::gtk("gdk_screen_get_default")
END FUNCTION

FUNCTION gdk_screen_get_width( arg1)
gdk_screen_get_width=GTK::gtk("gdk_screen_get_width \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gdk_screen_get_height( arg1)
gdk_screen_get_height=GTK::gtk("gdk_screen_get_height \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gdk_screen_width
gdk_screen_width=GTK::gtk("gdk_screen_width")
END FUNCTION

FUNCTION gdk_screen_height
gdk_screen_height=GTK::gtk("gdk_screen_height")
END FUNCTION

FUNCTION gdk_flush
gdk_flush=GTK::gtk("gdk_flush")
END FUNCTION

FUNCTION gdk_init( arg1, arg2)
gdk_init=GTK::gtk("gdk_init \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gdk_display_get_default
gdk_display_get_default=GTK::gtk("gdk_display_get_default")
END FUNCTION

FUNCTION gdk_display_get_pointer( arg1, arg2, arg3, arg4, arg5)
gdk_display_get_pointer=GTK::gtk("gdk_display_get_pointer \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gdk_cursor_new( arg1)
gdk_cursor_new=GTK::gtk("gdk_cursor_new \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gdk_window_set_cursor( arg1, arg2)
gdk_window_set_cursor=GTK::gtk("gdk_window_set_cursor \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gdk_window_get_pointer( arg1, arg2, arg3, arg4)
gdk_window_get_pointer=GTK::gtk("gdk_window_get_pointer \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gdk_visual_get_best_depth
gdk_visual_get_best_depth=GTK::gtk("gdk_visual_get_best_depth")
END FUNCTION

FUNCTION gdk_visual_get_system
gdk_visual_get_system=GTK::gtk("gdk_visual_get_system")
END FUNCTION

FUNCTION gdk_visual_get_screen( arg1)
gdk_visual_get_screen=GTK::gtk("gdk_visual_get_screen \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_image_new
gtk_image_new=GTK::gtk("gtk_image_new")
END FUNCTION

FUNCTION gtk_image_new_from_pixmap( arg1, arg2)
gtk_image_new_from_pixmap=GTK::gtk("gtk_image_new_from_pixmap \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_image_new_from_pixbuf( arg1)
gtk_image_new_from_pixbuf=GTK::gtk("gtk_image_new_from_pixbuf \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_image_set_from_pixbuf( arg1, arg2)
gtk_image_set_from_pixbuf=GTK::gtk("gtk_image_set_from_pixbuf \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_image_set_from_pixmap( arg1, arg2, arg3)
gtk_image_set_from_pixmap=GTK::gtk("gtk_image_set_from_pixmap \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_image_set( arg1, arg2, arg3)
gtk_image_set=GTK::gtk("gtk_image_set \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_image_set_from_file( arg1, arg2)
gtk_image_set_from_file=GTK::gtk("gtk_image_set_from_file \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_image_new_from_file( arg1)
gtk_image_new_from_file=GTK::gtk("gtk_image_new_from_file \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_image_new_from_stock( arg1, arg2)
gtk_image_new_from_stock=GTK::gtk("gtk_image_new_from_stock \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_image_menu_item_new_from_stock( arg1, arg2)
gtk_image_menu_item_new_from_stock=GTK::gtk("gtk_image_menu_item_new_from_stock \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_pixmap_new( arg1, arg2)
gtk_pixmap_new=GTK::gtk("gtk_pixmap_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_drawing_area_new
gtk_drawing_area_new=GTK::gtk("gtk_drawing_area_new")
END FUNCTION

FUNCTION gtk_widget_queue_draw( arg1)
gtk_widget_queue_draw=GTK::gtk("gtk_widget_queue_draw \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_widget_get_colormap( arg1)
gtk_widget_get_colormap=GTK::gtk("gtk_widget_get_colormap \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_widget_get_parent_window( arg1)
gtk_widget_get_parent_window=GTK::gtk("gtk_widget_get_parent_window \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_widget_create_pango_layout( arg1, arg2)
gtk_widget_create_pango_layout=GTK::gtk("gtk_widget_create_pango_layout \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_vscrollbar_new( arg1)
gtk_vscrollbar_new=GTK::gtk("gtk_vscrollbar_new \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_label_new( arg1)
gtk_label_new=GTK::gtk("gtk_label_new \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_label_set_text( arg1, arg2)
gtk_label_set_text=GTK::gtk("gtk_label_set_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_label_get_text( arg1)
gtk_label_get_text=GTK::gtk("gtk_label_get_text \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_label_set_line_wrap( arg1, arg2)
gtk_label_set_line_wrap=GTK::gtk("gtk_label_set_line_wrap \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_label_set_selectable( arg1, arg2)
gtk_label_set_selectable=GTK::gtk("gtk_label_set_selectable \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_label_set_use_markup( arg1, arg2)
gtk_label_set_use_markup=GTK::gtk("gtk_label_set_use_markup \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_label_set_justify( arg1, arg2)
gtk_label_set_justify=GTK::gtk("gtk_label_set_justify \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_label_get_width_chars( arg1)
gtk_label_get_width_chars=GTK::gtk("gtk_label_get_width_chars \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_label_get_max_width_chars( arg1)
gtk_label_get_max_width_chars=GTK::gtk("gtk_label_get_max_width_chars \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_label_set_markup_with_mnemonic( arg1, arg2)
gtk_label_set_markup_with_mnemonic=GTK::gtk("gtk_label_set_markup_with_mnemonic \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_frame_new( arg1)
gtk_frame_new=GTK::gtk("gtk_frame_new \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_frame_set_label_align( arg1, arg2, arg3)
gtk_frame_set_label_align=GTK::gtk("gtk_frame_set_label_align \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_frame_set_label( arg1, arg2)
gtk_frame_set_label=GTK::gtk("gtk_frame_set_label \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_frame_get_label( arg1)
gtk_frame_get_label=GTK::gtk("gtk_frame_get_label \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_frame_get_label_widget( arg1)
gtk_frame_get_label_widget=GTK::gtk("gtk_frame_get_label_widget \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_aspect_frame_new( arg1, arg2, arg3, arg4, arg5)
gtk_aspect_frame_new=GTK::gtk("gtk_aspect_frame_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gtk_aspect_frame_set( arg1, arg2, arg3, arg4, arg5)
gtk_aspect_frame_set=GTK::gtk("gtk_aspect_frame_set \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gtk_frame_set_shadow_type( arg1, arg2)
gtk_frame_set_shadow_type=GTK::gtk("gtk_frame_set_shadow_type \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_radio_button_new( arg1)
gtk_radio_button_new=GTK::gtk("gtk_radio_button_new \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_radio_button_new_with_label( arg1, arg2)
gtk_radio_button_new_with_label=GTK::gtk("gtk_radio_button_new_with_label \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_radio_button_new_from_widget( arg1)
gtk_radio_button_new_from_widget=GTK::gtk("gtk_radio_button_new_from_widget \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_radio_button_new_with_label_from_widget( arg1, arg2)
gtk_radio_button_new_with_label_from_widget=GTK::gtk("gtk_radio_button_new_with_label_from_widget \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_notebook_new
gtk_notebook_new=GTK::gtk("gtk_notebook_new")
END FUNCTION

FUNCTION gtk_notebook_set_tab_pos( arg1, arg2)
gtk_notebook_set_tab_pos=GTK::gtk("gtk_notebook_set_tab_pos \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_notebook_popup_enable( arg1)
gtk_notebook_popup_enable=GTK::gtk("gtk_notebook_popup_enable \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_notebook_popup_disable( arg1)
gtk_notebook_popup_disable=GTK::gtk("gtk_notebook_popup_disable \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_notebook_get_n_pages( arg1)
gtk_notebook_get_n_pages=GTK::gtk("gtk_notebook_get_n_pages \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_notebook_get_nth_page( arg1, arg2)
gtk_notebook_get_nth_page=GTK::gtk("gtk_notebook_get_nth_page \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_notebook_append_page( arg1, arg2, arg3)
gtk_notebook_append_page=GTK::gtk("gtk_notebook_append_page \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_notebook_insert_page( arg1, arg2, arg3, arg4)
gtk_notebook_insert_page=GTK::gtk("gtk_notebook_insert_page \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_notebook_remove_page( arg1, arg2)
gtk_notebook_remove_page=GTK::gtk("gtk_notebook_remove_page \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_notebook_get_current_page( arg1)
gtk_notebook_get_current_page=GTK::gtk("gtk_notebook_get_current_page \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_notebook_get_menu_label( arg1, arg2)
gtk_notebook_get_menu_label=GTK::gtk("gtk_notebook_get_menu_label \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_notebook_set_page( arg1, arg2)
gtk_notebook_set_page=GTK::gtk("gtk_notebook_set_page \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_notebook_set_current_page( arg1, arg2)
gtk_notebook_set_current_page=GTK::gtk("gtk_notebook_set_current_page \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_notebook_set_tab_label_text( arg1, arg2, arg3)
gtk_notebook_set_tab_label_text=GTK::gtk("gtk_notebook_set_tab_label_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_notebook_set_scrollable( arg1, arg2)
gtk_notebook_set_scrollable=GTK::gtk("gtk_notebook_set_scrollable \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_notebook_set_tab_reorderable( arg1, arg2, arg3)
gtk_notebook_set_tab_reorderable=GTK::gtk("gtk_notebook_set_tab_reorderable \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_adjustment_new( arg1, arg2, arg3, arg4, arg5, arg6)
gtk_adjustment_new=GTK::gtk("gtk_adjustment_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION gtk_adjustment_get_value( arg1)
gtk_adjustment_get_value=GTK::gtk("gtk_adjustment_get_value \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_adjustment_set_value( arg1, arg2)
gtk_adjustment_set_value=GTK::gtk("gtk_adjustment_set_value \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_adjustment_clamp_page( arg1, arg2, arg3)
gtk_adjustment_clamp_page=GTK::gtk("gtk_adjustment_clamp_page \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_range_get_adjustment( arg1)
gtk_range_get_adjustment=GTK::gtk("gtk_range_get_adjustment \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_range_get_value( arg1)
gtk_range_get_value=GTK::gtk("gtk_range_get_value \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_range_set_value( arg1, arg2)
gtk_range_set_value=GTK::gtk("gtk_range_set_value \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_scale_set_draw_value( arg1, arg2)
gtk_scale_set_draw_value=GTK::gtk("gtk_scale_set_draw_value \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_scale_set_value_pos( arg1, arg2)
gtk_scale_set_value_pos=GTK::gtk("gtk_scale_set_value_pos \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_hscale_new( arg1)
gtk_hscale_new=GTK::gtk("gtk_hscale_new \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_hscale_new_with_range( arg1, arg2, arg3)
gtk_hscale_new_with_range=GTK::gtk("gtk_hscale_new_with_range \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_vscale_new_with_range( arg1, arg2, arg3)
gtk_vscale_new_with_range=GTK::gtk("gtk_vscale_new_with_range \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_spin_button_new( arg1, arg2, arg3)
gtk_spin_button_new=GTK::gtk("gtk_spin_button_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_spin_button_new_with_range( arg1, arg2, arg3)
gtk_spin_button_new_with_range=GTK::gtk("gtk_spin_button_new_with_range \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_spin_button_get_value_as_int( arg1)
gtk_spin_button_get_value_as_int=GTK::gtk("gtk_spin_button_get_value_as_int \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_spin_button_get_value( arg1)
gtk_spin_button_get_value=GTK::gtk("gtk_spin_button_get_value \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_spin_button_set_wrap( arg1, arg2)
gtk_spin_button_set_wrap=GTK::gtk("gtk_spin_button_set_wrap \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_spin_button_set_value( arg1, arg2)
gtk_spin_button_set_value=GTK::gtk("gtk_spin_button_set_value \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_arrow_new( arg1, arg2)
gtk_arrow_new=GTK::gtk("gtk_arrow_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_file_chooser_dialog_new( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
gtk_file_chooser_dialog_new=GTK::gtk("gtk_file_chooser_dialog_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\" \"" &  STR(arg7) & "\" \"" &  STR(arg8) & "\"")
END FUNCTION

FUNCTION gtk_file_chooser_widget_new( arg1)
gtk_file_chooser_widget_new=GTK::gtk("gtk_file_chooser_widget_new \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_dialog_run( arg1)
gtk_dialog_run=GTK::gtk("gtk_dialog_run \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_file_chooser_get_filename( arg1)
gtk_file_chooser_get_filename=GTK::gtk("gtk_file_chooser_get_filename \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_file_chooser_get_uri( arg1)
gtk_file_chooser_get_uri=GTK::gtk("gtk_file_chooser_get_uri \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_file_chooser_get_current_folder( arg1)
gtk_file_chooser_get_current_folder=GTK::gtk("gtk_file_chooser_get_current_folder \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_file_chooser_set_filename( arg1, arg2)
gtk_file_chooser_set_filename=GTK::gtk("gtk_file_chooser_set_filename \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_file_filter_new
gtk_file_filter_new=GTK::gtk("gtk_file_filter_new")
END FUNCTION

FUNCTION gtk_file_filter_add_pattern( arg1, arg2)
gtk_file_filter_add_pattern=GTK::gtk("gtk_file_filter_add_pattern \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_file_filter_set_name( arg1, arg2)
gtk_file_filter_set_name=GTK::gtk("gtk_file_filter_set_name \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_file_chooser_add_filter( arg1, arg2)
gtk_file_chooser_add_filter=GTK::gtk("gtk_file_chooser_add_filter \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_file_chooser_set_select_multiple( arg1, arg2)
gtk_file_chooser_set_select_multiple=GTK::gtk("gtk_file_chooser_set_select_multiple \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_font_selection_dialog_new( arg1)
gtk_font_selection_dialog_new=GTK::gtk("gtk_font_selection_dialog_new \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_font_selection_dialog_get_font_name( arg1)
gtk_font_selection_dialog_get_font_name=GTK::gtk("gtk_font_selection_dialog_get_font_name \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_font_selection_new
gtk_font_selection_new=GTK::gtk("gtk_font_selection_new")
END FUNCTION

FUNCTION gtk_font_selection_get_font_name( arg1)
gtk_font_selection_get_font_name=GTK::gtk("gtk_font_selection_get_font_name \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_font_selection_set_font_name( arg1, arg2)
gtk_font_selection_set_font_name=GTK::gtk("gtk_font_selection_set_font_name \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_color_selection_new
gtk_color_selection_new=GTK::gtk("gtk_color_selection_new")
END FUNCTION

FUNCTION gtk_color_selection_set_has_opacity_control( arg1, arg2)
gtk_color_selection_set_has_opacity_control=GTK::gtk("gtk_color_selection_set_has_opacity_control \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_color_selection_set_current_color( arg1, arg2)
gtk_color_selection_set_current_color=GTK::gtk("gtk_color_selection_set_current_color \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_color_selection_get_current_color( arg1, arg2)
gtk_color_selection_get_current_color=GTK::gtk("gtk_color_selection_get_current_color \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_color_selection_set_color( arg1, arg2)
gtk_color_selection_set_color=GTK::gtk("gtk_color_selection_set_color \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_menu_bar_new
gtk_menu_bar_new=GTK::gtk("gtk_menu_bar_new")
END FUNCTION

FUNCTION gtk_menu_shell_append( arg1, arg2)
gtk_menu_shell_append=GTK::gtk("gtk_menu_shell_append \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_menu_item_new
gtk_menu_item_new=GTK::gtk("gtk_menu_item_new")
END FUNCTION

FUNCTION gtk_menu_item_new_with_label( arg1)
gtk_menu_item_new_with_label=GTK::gtk("gtk_menu_item_new_with_label \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_menu_item_new_with_mnemonic( arg1)
gtk_menu_item_new_with_mnemonic=GTK::gtk("gtk_menu_item_new_with_mnemonic \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_tearoff_menu_item_new
gtk_tearoff_menu_item_new=GTK::gtk("gtk_tearoff_menu_item_new")
END FUNCTION

FUNCTION gtk_separator_menu_item_new
gtk_separator_menu_item_new=GTK::gtk("gtk_separator_menu_item_new")
END FUNCTION

FUNCTION gtk_menu_new
gtk_menu_new=GTK::gtk("gtk_menu_new")
END FUNCTION

FUNCTION gtk_menu_set_title( arg1, arg2)
gtk_menu_set_title=GTK::gtk("gtk_menu_set_title \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_menu_item_set_right_justified( arg1, arg2)
gtk_menu_item_set_right_justified=GTK::gtk("gtk_menu_item_set_right_justified \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_menu_item_set_submenu( arg1, arg2)
gtk_menu_item_set_submenu=GTK::gtk("gtk_menu_item_set_submenu \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_check_menu_item_new_with_label( arg1)
gtk_check_menu_item_new_with_label=GTK::gtk("gtk_check_menu_item_new_with_label \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_check_menu_item_new_with_mnemonic( arg1)
gtk_check_menu_item_new_with_mnemonic=GTK::gtk("gtk_check_menu_item_new_with_mnemonic \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_check_menu_item_get_active( arg1)
gtk_check_menu_item_get_active=GTK::gtk("gtk_check_menu_item_get_active \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_check_menu_item_set_active( arg1, arg2)
gtk_check_menu_item_set_active=GTK::gtk("gtk_check_menu_item_set_active \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_menu_popup( arg1, arg2, arg3, arg4, arg5, arg6, arg7)
gtk_menu_popup=GTK::gtk("gtk_menu_popup \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\" \"" &  STR(arg7) & "\"")
END FUNCTION

FUNCTION gtk_progress_bar_new
gtk_progress_bar_new=GTK::gtk("gtk_progress_bar_new")
END FUNCTION

FUNCTION gtk_progress_bar_set_text( arg1, arg2)
gtk_progress_bar_set_text=GTK::gtk("gtk_progress_bar_set_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_progress_bar_set_fraction( arg1, arg2)
gtk_progress_bar_set_fraction=GTK::gtk("gtk_progress_bar_set_fraction \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_progress_bar_pulse( arg1)
gtk_progress_bar_pulse=GTK::gtk("gtk_progress_bar_pulse \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_progress_bar_set_pulse_step( arg1, arg2)
gtk_progress_bar_set_pulse_step=GTK::gtk("gtk_progress_bar_set_pulse_step \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_progress_configure( arg1, arg2, arg3, arg4)
gtk_progress_configure=GTK::gtk("gtk_progress_configure \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_progress_set_value( arg1, arg2)
gtk_progress_set_value=GTK::gtk("gtk_progress_set_value \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_statusbar_new
gtk_statusbar_new=GTK::gtk("gtk_statusbar_new")
END FUNCTION

FUNCTION gtk_statusbar_get_context_id( arg1, arg2)
gtk_statusbar_get_context_id=GTK::gtk("gtk_statusbar_get_context_id \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_statusbar_push( arg1, arg2, arg3)
gtk_statusbar_push=GTK::gtk("gtk_statusbar_push \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_statusbar_pop( arg1, arg2)
gtk_statusbar_pop=GTK::gtk("gtk_statusbar_pop \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_statusbar_remove( arg1, arg2, arg3)
gtk_statusbar_remove=GTK::gtk("gtk_statusbar_remove \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_statusbar_set_has_resize_grip( arg1, arg2)
gtk_statusbar_set_has_resize_grip=GTK::gtk("gtk_statusbar_set_has_resize_grip \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_event_box_new
gtk_event_box_new=GTK::gtk("gtk_event_box_new")
END FUNCTION

FUNCTION gtk_combo_box_new_text
gtk_combo_box_new_text=GTK::gtk("gtk_combo_box_new_text")
END FUNCTION

FUNCTION gtk_combo_box_append_text( arg1, arg2)
gtk_combo_box_append_text=GTK::gtk("gtk_combo_box_append_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_combo_box_insert_text( arg1, arg2, arg3)
gtk_combo_box_insert_text=GTK::gtk("gtk_combo_box_insert_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_combo_box_prepend_text( arg1, arg2)
gtk_combo_box_prepend_text=GTK::gtk("gtk_combo_box_prepend_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_combo_box_remove_text( arg1, arg2)
gtk_combo_box_remove_text=GTK::gtk("gtk_combo_box_remove_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_combo_box_get_active( arg1)
gtk_combo_box_get_active=GTK::gtk("gtk_combo_box_get_active \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_combo_box_set_active( arg1, arg2)
gtk_combo_box_set_active=GTK::gtk("gtk_combo_box_set_active \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_combo_box_get_active_text( arg1)
gtk_combo_box_get_active_text=GTK::gtk("gtk_combo_box_get_active_text \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_vseparator_new
gtk_vseparator_new=GTK::gtk("gtk_vseparator_new")
END FUNCTION

FUNCTION gtk_hseparator_new
gtk_hseparator_new=GTK::gtk("gtk_hseparator_new")
END FUNCTION

FUNCTION gtk_editable_copy_clipboard( arg1)
gtk_editable_copy_clipboard=GTK::gtk("gtk_editable_copy_clipboard \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_editable_cut_clipboard( arg1)
gtk_editable_cut_clipboard=GTK::gtk("gtk_editable_cut_clipboard \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_editable_paste_clipboard( arg1)
gtk_editable_paste_clipboard=GTK::gtk("gtk_editable_paste_clipboard \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gdk_atom_intern( arg1, arg2)
gdk_atom_intern=GTK::gtk("gdk_atom_intern \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_clipboard_get( arg1)
gtk_clipboard_get=GTK::gtk("gtk_clipboard_get \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_clipboard_set_text( arg1, arg2, arg3)
gtk_clipboard_set_text=GTK::gtk("gtk_clipboard_set_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_clipboard_wait_for_text( arg1)
gtk_clipboard_wait_for_text=GTK::gtk("gtk_clipboard_wait_for_text \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_clist_new( arg1)
gtk_clist_new=GTK::gtk("gtk_clist_new \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_clist_set_column_title( arg1, arg2, arg3)
gtk_clist_set_column_title=GTK::gtk("gtk_clist_set_column_title \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_clist_column_titles_show( arg1)
gtk_clist_column_titles_show=GTK::gtk("gtk_clist_column_titles_show \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_clist_append( arg1, arg2)
gtk_clist_append=GTK::gtk("gtk_clist_append \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_clist_set_text( arg1, arg2, arg3, arg4)
gtk_clist_set_text=GTK::gtk("gtk_clist_set_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_fixed_new
gtk_fixed_new=GTK::gtk("gtk_fixed_new")
END FUNCTION

FUNCTION gtk_fixed_put( arg1, arg2, arg3, arg4)
gtk_fixed_put=GTK::gtk("gtk_fixed_put \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_fixed_move( arg1, arg2, arg3, arg4)
gtk_fixed_move=GTK::gtk("gtk_fixed_move \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_list_store_new( arg1, arg2)
gtk_list_store_new=GTK::gtk("gtk_list_store_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_list_store_append( arg1, arg2)
gtk_list_store_append=GTK::gtk("gtk_list_store_append \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_list_store_set( arg1, arg2, arg3, arg4, arg5)
gtk_list_store_set=GTK::gtk("gtk_list_store_set \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gtk_list_store_set_value( arg1, arg2, arg3, arg4)
gtk_list_store_set_value=GTK::gtk("gtk_list_store_set_value \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_list_store_clear( arg1)
gtk_list_store_clear=GTK::gtk("gtk_list_store_clear \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_list_store_remove( arg1, arg2)
gtk_list_store_remove=GTK::gtk("gtk_list_store_remove \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_list_store_move_before( arg1, arg2, arg3)
gtk_list_store_move_before=GTK::gtk("gtk_list_store_move_before \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_list_store_move_after( arg1, arg2, arg3)
gtk_list_store_move_after=GTK::gtk("gtk_list_store_move_after \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_list_store_insert( arg1, arg2, arg3)
gtk_list_store_insert=GTK::gtk("gtk_list_store_insert \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_list_store_insert_with_values( arg1, arg2, arg3, arg4, arg5, arg6)
gtk_list_store_insert_with_values=GTK::gtk("gtk_list_store_insert_with_values \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION gtk_cell_renderer_text_new
gtk_cell_renderer_text_new=GTK::gtk("gtk_cell_renderer_text_new")
END FUNCTION

FUNCTION gtk_tree_view_new_with_model( arg1)
gtk_tree_view_new_with_model=GTK::gtk("gtk_tree_view_new_with_model \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_tree_view_column_new
gtk_tree_view_column_new=GTK::gtk("gtk_tree_view_column_new")
END FUNCTION

FUNCTION gtk_tree_view_column_new_with_attributes( arg1, arg2, arg3, arg4, arg5)
gtk_tree_view_column_new_with_attributes=GTK::gtk("gtk_tree_view_column_new_with_attributes \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gtk_tree_view_column_pack_start( arg1, arg2, arg3)
gtk_tree_view_column_pack_start=GTK::gtk("gtk_tree_view_column_pack_start \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_tree_view_append_column( arg1, arg2)
gtk_tree_view_append_column=GTK::gtk("gtk_tree_view_append_column \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_tree_view_set_headers_visible( arg1, arg2)
gtk_tree_view_set_headers_visible=GTK::gtk("gtk_tree_view_set_headers_visible \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_tree_view_set_headers_clickable( arg1, arg2)
gtk_tree_view_set_headers_clickable=GTK::gtk("gtk_tree_view_set_headers_clickable \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_tree_view_get_selection( arg1)
gtk_tree_view_get_selection=GTK::gtk("gtk_tree_view_get_selection \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_tree_view_get_hadjustment( arg1)
gtk_tree_view_get_hadjustment=GTK::gtk("gtk_tree_view_get_hadjustment \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_tree_view_get_vadjustment( arg1)
gtk_tree_view_get_vadjustment=GTK::gtk("gtk_tree_view_get_vadjustment \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_tree_view_column_set_resizable( arg1, arg2)
gtk_tree_view_column_set_resizable=GTK::gtk("gtk_tree_view_column_set_resizable \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_tree_view_column_set_clickable( arg1, arg2)
gtk_tree_view_column_set_clickable=GTK::gtk("gtk_tree_view_column_set_clickable \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_tree_view_scroll_to_cell( arg1, arg2, arg3, arg4, arg5, arg6)
gtk_tree_view_scroll_to_cell=GTK::gtk("gtk_tree_view_scroll_to_cell \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION gtk_tree_view_set_grid_lines( arg1, arg2)
gtk_tree_view_set_grid_lines=GTK::gtk("gtk_tree_view_set_grid_lines \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_tree_selection_get_selected( arg1, arg2, arg3)
gtk_tree_selection_get_selected=GTK::gtk("gtk_tree_selection_get_selected \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_tree_selection_get_tree_view( arg1)
gtk_tree_selection_get_tree_view=GTK::gtk("gtk_tree_selection_get_tree_view \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_tree_selection_select_iter( arg1, arg2)
gtk_tree_selection_select_iter=GTK::gtk("gtk_tree_selection_select_iter \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_tree_selection_select_path( arg1, arg2)
gtk_tree_selection_select_path=GTK::gtk("gtk_tree_selection_select_path \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_tree_selection_path_is_selected( arg1, arg2)
gtk_tree_selection_path_is_selected=GTK::gtk("gtk_tree_selection_path_is_selected \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_tree_selection_set_mode( arg1, arg2)
gtk_tree_selection_set_mode=GTK::gtk("gtk_tree_selection_set_mode \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_tree_model_get( arg1, arg2, arg3, arg4, arg5)
gtk_tree_model_get=GTK::gtk("gtk_tree_model_get \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gtk_tree_model_get_iter( arg1, arg2, arg3)
gtk_tree_model_get_iter=GTK::gtk("gtk_tree_model_get_iter \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_tree_model_get_string_from_iter( arg1, arg2)
gtk_tree_model_get_string_from_iter=GTK::gtk("gtk_tree_model_get_string_from_iter \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_tree_model_get_iter_first( arg1, arg2)
gtk_tree_model_get_iter_first=GTK::gtk("gtk_tree_model_get_iter_first \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_tree_path_new_from_string( arg1)
gtk_tree_path_new_from_string=GTK::gtk("gtk_tree_path_new_from_string \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_tree_path_free( arg1)
gtk_tree_path_free=GTK::gtk("gtk_tree_path_free \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_tree_path_prev( arg1)
gtk_tree_path_prev=GTK::gtk("gtk_tree_path_prev \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_tree_path_next( arg1)
gtk_tree_path_next=GTK::gtk("gtk_tree_path_next \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_tree_sortable_set_sort_column_id( arg1, arg2, arg3)
gtk_tree_sortable_set_sort_column_id=GTK::gtk("gtk_tree_sortable_set_sort_column_id \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_expander_new( arg1)
gtk_expander_new=GTK::gtk("gtk_expander_new \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_expander_new_with_mnemonic( arg1)
gtk_expander_new_with_mnemonic=GTK::gtk("gtk_expander_new_with_mnemonic \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_expander_set_expanded( arg1, arg2)
gtk_expander_set_expanded=GTK::gtk("gtk_expander_set_expanded \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_expander_get_expanded( arg1)
gtk_expander_get_expanded=GTK::gtk("gtk_expander_get_expanded \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_expander_set_spacing( arg1, arg2)
gtk_expander_set_spacing=GTK::gtk("gtk_expander_set_spacing \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_expander_get_spacing( arg1)
gtk_expander_get_spacing=GTK::gtk("gtk_expander_get_spacing \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_tooltips_new
gtk_tooltips_new=GTK::gtk("gtk_tooltips_new")
END FUNCTION

FUNCTION gtk_tooltips_enable( arg1)
gtk_tooltips_enable=GTK::gtk("gtk_tooltips_enable \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_tooltips_disable( arg1)
gtk_tooltips_disable=GTK::gtk("gtk_tooltips_disable \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_tooltips_set_tip( arg1, arg2, arg3, arg4)
gtk_tooltips_set_tip=GTK::gtk("gtk_tooltips_set_tip \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_tooltips_force_window( arg1)
gtk_tooltips_force_window=GTK::gtk("gtk_tooltips_force_window \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_calendar_get_date( arg1, arg2, arg3, arg4)
gtk_calendar_get_date=GTK::gtk("gtk_calendar_get_date \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_init( arg1, arg2)
gtk_init=GTK::gtk("gtk_init \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_widget_show( arg1)
gtk_widget_show=GTK::gtk("gtk_widget_show \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_widget_show_all( arg1)
gtk_widget_show_all=GTK::gtk("gtk_widget_show_all \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_widget_realize( arg1)
gtk_widget_realize=GTK::gtk("gtk_widget_realize \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_widget_unrealize( arg1)
gtk_widget_unrealize=GTK::gtk("gtk_widget_unrealize \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_widget_hide( arg1)
gtk_widget_hide=GTK::gtk("gtk_widget_hide \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_widget_destroy( arg1)
gtk_widget_destroy=GTK::gtk("gtk_widget_destroy \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_widget_grab_focus( arg1)
gtk_widget_grab_focus=GTK::gtk("gtk_widget_grab_focus \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_widget_set_size_request( arg1, arg2, arg3)
gtk_widget_set_size_request=GTK::gtk("gtk_widget_set_size_request \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_widget_size_request( arg1, arg2)
gtk_widget_size_request=GTK::gtk("gtk_widget_size_request \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_widget_set_usize( arg1, arg2, arg3)
gtk_widget_set_usize=GTK::gtk("gtk_widget_set_usize \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_widget_modify_base( arg1, arg2, arg3)
gtk_widget_modify_base=GTK::gtk("gtk_widget_modify_base \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_widget_modify_text( arg1, arg2, arg3)
gtk_widget_modify_text=GTK::gtk("gtk_widget_modify_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_widget_modify_bg( arg1, arg2, arg3)
gtk_widget_modify_bg=GTK::gtk("gtk_widget_modify_bg \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_widget_modify_fg( arg1, arg2, arg3)
gtk_widget_modify_fg=GTK::gtk("gtk_widget_modify_fg \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_widget_modify_font( arg1, arg2)
gtk_widget_modify_font=GTK::gtk("gtk_widget_modify_font \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_widget_set_sensitive( arg1, arg2)
gtk_widget_set_sensitive=GTK::gtk("gtk_widget_set_sensitive \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_widget_add_accelerator( arg1, arg2, arg3, arg4, arg5, arg6)
gtk_widget_add_accelerator=GTK::gtk("gtk_widget_add_accelerator \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION gtk_widget_get_parent( arg1)
gtk_widget_get_parent=GTK::gtk("gtk_widget_get_parent \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_widget_set_name( arg1, arg2)
gtk_widget_set_name=GTK::gtk("gtk_widget_set_name \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_widget_get_size_request( arg1, arg2, arg3)
gtk_widget_get_size_request=GTK::gtk("gtk_widget_get_size_request \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_settings_get_default
gtk_settings_get_default=GTK::gtk("gtk_settings_get_default")
END FUNCTION

FUNCTION gtk_misc_set_alignment( arg1, arg2, arg3)
gtk_misc_set_alignment=GTK::gtk("gtk_misc_set_alignment \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_main
gtk_main=GTK::gtk("gtk_main")
END FUNCTION

FUNCTION gtk_main_iteration
gtk_main_iteration=GTK::gtk("gtk_main_iteration")
END FUNCTION

FUNCTION gtk_main_iteration_do( arg1)
gtk_main_iteration_do=GTK::gtk("gtk_main_iteration_do \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_events_pending
gtk_events_pending=GTK::gtk("gtk_events_pending")
END FUNCTION

FUNCTION gtk_exit( arg1)
gtk_exit=GTK::gtk("gtk_exit \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_main_quit
gtk_main_quit=GTK::gtk("gtk_main_quit")
END FUNCTION

FUNCTION gtk_rc_parse( arg1)
gtk_rc_parse=GTK::gtk("gtk_rc_parse \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_rc_parse_string( arg1)
gtk_rc_parse_string=GTK::gtk("gtk_rc_parse_string \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_rc_reparse_all
gtk_rc_reparse_all=GTK::gtk("gtk_rc_reparse_all")
END FUNCTION

FUNCTION gtk_rc_reset_styles( arg1)
gtk_rc_reset_styles=GTK::gtk("gtk_rc_reset_styles \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_rc_add_default_file( arg1)
gtk_rc_add_default_file=GTK::gtk("gtk_rc_add_default_file \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_check_version( arg1, arg2, arg3)
gtk_check_version=GTK::gtk("gtk_check_version \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_drag_source_set( arg1, arg2, arg3, arg4, arg5)
gtk_drag_source_set=GTK::gtk("gtk_drag_source_set \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gtk_drag_dest_set( arg1, arg2, arg3, arg4, arg5)
gtk_drag_dest_set=GTK::gtk("gtk_drag_dest_set \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gtk_drag_finish( arg1, arg2, arg3, arg4)
gtk_drag_finish=GTK::gtk("gtk_drag_finish \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_drag_set_icon_stock( arg1, arg2, arg3, arg4)
gtk_drag_set_icon_stock=GTK::gtk("gtk_drag_set_icon_stock \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_get_current_event_time
gtk_get_current_event_time=GTK::gtk("gtk_get_current_event_time")
END FUNCTION

FUNCTION gtk_signal_emit_by_name( arg1, arg2)
gtk_signal_emit_by_name=GTK::gtk("gtk_signal_emit_by_name \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_invisible_new
gtk_invisible_new=GTK::gtk("gtk_invisible_new")
END FUNCTION

FUNCTION gtk_target_list_new( arg1, arg2)
gtk_target_list_new=GTK::gtk("gtk_target_list_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_target_list_add( arg1, arg2, arg3, arg4)
gtk_target_list_add=GTK::gtk("gtk_target_list_add \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_target_table_new_from_list( arg1, arg2)
gtk_target_table_new_from_list=GTK::gtk("gtk_target_table_new_from_list \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_alignment_new( arg1, arg2, arg3, arg4)
gtk_alignment_new=GTK::gtk("gtk_alignment_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gtk_alignment_set( arg1, arg2, arg3, arg4, arg5)
gtk_alignment_set=GTK::gtk("gtk_alignment_set \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gtk_alignment_set_padding( arg1, arg2, arg3, arg4, arg5)
gtk_alignment_set_padding=GTK::gtk("gtk_alignment_set_padding \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gtk_alignment_get_padding( arg1, arg2, arg3, arg4, arg5)
gtk_alignment_get_padding=GTK::gtk("gtk_alignment_get_padding \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gtk_object_set_data( arg1, arg2, arg3)
gtk_object_set_data=GTK::gtk("gtk_object_set_data \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_object_get_data( arg1, arg2)
gtk_object_get_data=GTK::gtk("gtk_object_get_data \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_object_ref( arg1)
gtk_object_ref=GTK::gtk("gtk_object_ref \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_accel_group_new
gtk_accel_group_new=GTK::gtk("gtk_accel_group_new")
END FUNCTION

FUNCTION gdk_pixbuf_new_from_file( arg1, arg2)
gdk_pixbuf_new_from_file=GTK::gtk("gdk_pixbuf_new_from_file \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gdk_pixbuf_new_from_file_at_size( arg1, arg2, arg3, arg4)
gdk_pixbuf_new_from_file_at_size=GTK::gtk("gdk_pixbuf_new_from_file_at_size \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gdk_pixbuf_new_from_file_at_scale( arg1, arg2, arg3, arg4, arg5)
gdk_pixbuf_new_from_file_at_scale=GTK::gtk("gdk_pixbuf_new_from_file_at_scale \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gdk_pixbuf_rotate_simple( arg1, arg2)
gdk_pixbuf_rotate_simple=GTK::gtk("gdk_pixbuf_rotate_simple \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gdk_pixbuf_get_height( arg1)
gdk_pixbuf_get_height=GTK::gtk("gdk_pixbuf_get_height \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gdk_pixbuf_get_width( arg1)
gdk_pixbuf_get_width=GTK::gtk("gdk_pixbuf_get_width \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gdk_pixbuf_scale_simple( arg1, arg2, arg3, arg4)
gdk_pixbuf_scale_simple=GTK::gtk("gdk_pixbuf_scale_simple \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION gdk_pixbuf_new( arg1, arg2, arg3, arg4, arg5)
gdk_pixbuf_new=GTK::gtk("gdk_pixbuf_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION g_object_unref( arg1)
g_object_unref=GTK::gtk("g_object_unref \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION g_object_get( arg1, arg2, arg3, arg4)
g_object_get=GTK::gtk("g_object_get \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION g_object_set( arg1, arg2, arg3, arg4)
g_object_set=GTK::gtk("g_object_set \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION g_locale_to_utf8( arg1, arg2, arg3, arg4, arg5)
g_locale_to_utf8=GTK::gtk("g_locale_to_utf8 \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION g_locale_from_utf8( arg1, arg2, arg3, arg4, arg5)
g_locale_from_utf8=GTK::gtk("g_locale_from_utf8 \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION g_free( arg1)
g_free=GTK::gtk("g_free \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION g_printf( arg1, arg2)
g_printf=GTK::gtk("g_printf \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION g_io_channel_unix_new( arg1)
g_io_channel_unix_new=GTK::gtk("g_io_channel_unix_new \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION g_io_channel_read_line_string( arg1, arg2, arg3, arg4)
g_io_channel_read_line_string=GTK::gtk("g_io_channel_read_line_string \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION pango_font_description_from_string( arg1)
pango_font_description_from_string=GTK::gtk("pango_font_description_from_string \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION pango_font_description_free( arg1)
pango_font_description_free=GTK::gtk("pango_font_description_free \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_server_version
gtk_server_version=GTK::gtk("gtk_server_version")
END FUNCTION

FUNCTION gtk_server_ffi
gtk_server_ffi=GTK::gtk("gtk_server_ffi")
END FUNCTION

FUNCTION gtk_server_callback( arg1)
gtk_server_callback=GTK::gtk("gtk_server_callback \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_server_callback_value( arg1, arg2)
gtk_server_callback_value=GTK::gtk("gtk_server_callback_value \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_server_connect( arg1, arg2, arg3)
gtk_server_connect=GTK::gtk("gtk_server_connect \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_server_connect_after( arg1, arg2, arg3)
gtk_server_connect_after=GTK::gtk("gtk_server_connect_after \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_server_disconnect
gtk_server_disconnect=GTK::gtk("gtk_server_disconnect")
END FUNCTION

FUNCTION gtk_server_enable_c_string_escaping
gtk_server_enable_c_string_escaping=GTK::gtk("gtk_server_enable_c_string_escaping")
END FUNCTION

FUNCTION gtk_server_disable_c_string_escaping
gtk_server_disable_c_string_escaping=GTK::gtk("gtk_server_disable_c_string_escaping")
END FUNCTION

FUNCTION gtk_server_set_c_string_escaping( arg1)
gtk_server_set_c_string_escaping=GTK::gtk("gtk_server_set_c_string_escaping \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_server_mouse( arg1)
gtk_server_mouse=GTK::gtk("gtk_server_mouse \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_server_define( arg1)
gtk_server_define=GTK::gtk("gtk_server_define " & STR(arg1) )
END FUNCTION

FUNCTION gtk_server_redefine( arg1)
gtk_server_redefine=GTK::gtk("gtk_server_redefine " & STR(arg1) )
END FUNCTION

FUNCTION gtk_server_require( arg1)
gtk_server_require=GTK::gtk("gtk_server_require \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_server_timeout( arg1, arg2, arg3)
gtk_server_timeout=GTK::gtk("gtk_server_timeout \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_server_timeout_remove( arg1)
gtk_server_timeout_remove=GTK::gtk("gtk_server_timeout_remove \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_server_echo( arg1)
gtk_server_echo=GTK::gtk("gtk_server_echo \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_server_cfg( arg1)
gtk_server_cfg=GTK::gtk("gtk_server_cfg " & STR(arg1) )
END FUNCTION

FUNCTION gtk_server_exit
gtk_server_exit=GTK::gtk("gtk_server_exit")
END FUNCTION

FUNCTION gtk_server_pid
gtk_server_pid=GTK::gtk("gtk_server_pid")
END FUNCTION

FUNCTION gtk_server_key
gtk_server_key=GTK::gtk("gtk_server_key")
END FUNCTION

FUNCTION gtk_server_macro( arg1, arg2)
gtk_server_macro=GTK::gtk("gtk_server_macro \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_server_opaque
gtk_server_opaque=GTK::gtk("gtk_server_opaque")
END FUNCTION

FUNCTION glade_init
glade_init=GTK::gtk("glade_init")
END FUNCTION

FUNCTION glade_xml_new_from_buffer( arg1, arg2, arg3, arg4)
glade_xml_new_from_buffer=GTK::gtk("glade_xml_new_from_buffer \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION glade_xml_new( arg1, arg2, arg3)
glade_xml_new=GTK::gtk("glade_xml_new \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION glade_xml_signal_autoconnect( arg1)
glade_xml_signal_autoconnect=GTK::gtk("glade_xml_signal_autoconnect \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION glade_xml_get_widget( arg1, arg2)
glade_xml_get_widget=GTK::gtk("glade_xml_get_widget \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_moz_embed_new
gtk_moz_embed_new=GTK::gtk("gtk_moz_embed_new")
END FUNCTION

FUNCTION gtk_moz_embed_set_comp_path( arg1)
gtk_moz_embed_set_comp_path=GTK::gtk("gtk_moz_embed_set_comp_path \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_moz_embed_set_profile_path( arg1, arg2)
gtk_moz_embed_set_profile_path=GTK::gtk("gtk_moz_embed_set_profile_path \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_moz_embed_load_url( arg1, arg2)
gtk_moz_embed_load_url=GTK::gtk("gtk_moz_embed_load_url \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_moz_embed_open_stream( arg1, arg2, arg3)
gtk_moz_embed_open_stream=GTK::gtk("gtk_moz_embed_open_stream \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_moz_embed_append_data( arg1, arg2, arg3)
gtk_moz_embed_append_data=GTK::gtk("gtk_moz_embed_append_data \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION gtk_gl_init( arg1, arg2)
gtk_gl_init=GTK::gtk("gtk_gl_init \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gtk_widget_set_gl_capability( arg1, arg2, arg3, arg4, arg5)
gtk_widget_set_gl_capability=GTK::gtk("gtk_widget_set_gl_capability \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\"")
END FUNCTION

FUNCTION gdk_gl_config_new_by_mode( arg1)
gdk_gl_config_new_by_mode=GTK::gtk("gdk_gl_config_new_by_mode \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_widget_get_gl_context( arg1)
gtk_widget_get_gl_context=GTK::gtk("gtk_widget_get_gl_context \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_widget_get_gl_window( arg1)
gtk_widget_get_gl_window=GTK::gtk("gtk_widget_get_gl_window \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gdk_gl_drawable_gl_begin( arg1, arg2)
gdk_gl_drawable_gl_begin=GTK::gtk("gdk_gl_drawable_gl_begin \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION gdk_gl_drawable_gl_end( arg1)
gdk_gl_drawable_gl_end=GTK::gtk("gdk_gl_drawable_gl_end \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gdk_gl_drawable_swap_buffers( arg1)
gdk_gl_drawable_swap_buffers=GTK::gtk("gdk_gl_drawable_swap_buffers \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_gl_area_new( arg1)
gtk_gl_area_new=GTK::gtk("gtk_gl_area_new \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_gl_area_make_current( arg1)
gtk_gl_area_make_current=GTK::gtk("gtk_gl_area_make_current \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gtk_gl_area_swap_buffers( arg1)
gtk_gl_area_swap_buffers=GTK::gtk("gtk_gl_area_swap_buffers \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gdk_gl_choose_visual( arg1)
gdk_gl_choose_visual=GTK::gtk("gdk_gl_choose_visual \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION gdk_gl_get_info
gdk_gl_get_info=GTK::gtk("gdk_gl_get_info")
END FUNCTION

FUNCTION glutInit( arg1, arg2)
glutInit=GTK::gtk("glutInit \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION glutSolidTeapot( arg1)
glutSolidTeapot=GTK::gtk("glutSolidTeapot \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION glutSwapBuffers
glutSwapBuffers=GTK::gtk("glutSwapBuffers")
END FUNCTION

FUNCTION glutBitmapCharacter( arg1, arg2)
glutBitmapCharacter=GTK::gtk("glutBitmapCharacter \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION glutBitmap9By15
glutBitmap9By15=GTK::gtk("glutBitmap9By15")
END FUNCTION

FUNCTION glutBitmap8By13
glutBitmap8By13=GTK::gtk("glutBitmap8By13")
END FUNCTION

FUNCTION glutBitmapTimesRoman10
glutBitmapTimesRoman10=GTK::gtk("glutBitmapTimesRoman10")
END FUNCTION

FUNCTION glutBitmapTimesRoman24
glutBitmapTimesRoman24=GTK::gtk("glutBitmapTimesRoman24")
END FUNCTION

FUNCTION glutBitmapHelvetica10
glutBitmapHelvetica10=GTK::gtk("glutBitmapHelvetica10")
END FUNCTION

FUNCTION glutBitmapHelvetica12
glutBitmapHelvetica12=GTK::gtk("glutBitmapHelvetica12")
END FUNCTION

FUNCTION glutBitmapHelvetica18
glutBitmapHelvetica18=GTK::gtk("glutBitmapHelvetica18")
END FUNCTION

FUNCTION glutStrokeCharacter( arg1, arg2)
glutStrokeCharacter=GTK::gtk("glutStrokeCharacter \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION glutStrokeRoman
glutStrokeRoman=GTK::gtk("glutStrokeRoman")
END FUNCTION

FUNCTION glutStrokeMonoRoman
glutStrokeMonoRoman=GTK::gtk("glutStrokeMonoRoman")
END FUNCTION

FUNCTION glClearColor( arg1, arg2, arg3, arg4)
glClearColor=GTK::gtk("glClearColor \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION glClear( arg1)
glClear=GTK::gtk("glClear \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION glEnable( arg1)
glEnable=GTK::gtk("glEnable \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION glShadeModel( arg1)
glShadeModel=GTK::gtk("glShadeModel \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION glLightfv( arg1, arg2, arg3)
glLightfv=GTK::gtk("glLightfv \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION glMaterialfv( arg1, arg2, arg3)
glMaterialfv=GTK::gtk("glMaterialfv \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION glMatrixMode( arg1)
glMatrixMode=GTK::gtk("glMatrixMode \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION glPushMatrix
glPushMatrix=GTK::gtk("glPushMatrix")
END FUNCTION

FUNCTION glPopMatrix
glPopMatrix=GTK::gtk("glPopMatrix")
END FUNCTION

FUNCTION glFlush
glFlush=GTK::gtk("glFlush")
END FUNCTION

FUNCTION glRotatef( arg1, arg2, arg3, arg4)
glRotatef=GTK::gtk("glRotatef \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION glLoadIdentity
glLoadIdentity=GTK::gtk("glLoadIdentity")
END FUNCTION

FUNCTION glRasterPos2f( arg1, arg2)
glRasterPos2f=GTK::gtk("glRasterPos2f \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION glTranslatef( arg1, arg2, arg3)
glTranslatef=GTK::gtk("glTranslatef \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION glScalef( arg1, arg2, arg3)
glScalef=GTK::gtk("glScalef \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION glViewport( arg1, arg2, arg3, arg4)
glViewport=GTK::gtk("glViewport \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION glXSwapBuffers( arg1, arg2)
glXSwapBuffers=GTK::gtk("glXSwapBuffers \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION poppler_document_new_from_file( arg1, arg2, arg3)
poppler_document_new_from_file=GTK::gtk("poppler_document_new_from_file \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION poppler_document_get_n_pages( arg1)
poppler_document_get_n_pages=GTK::gtk("poppler_document_get_n_pages \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION poppler_document_get_page( arg1, arg2)
poppler_document_get_page=GTK::gtk("poppler_document_get_page \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION poppler_page_render_to_pixbuf( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
poppler_page_render_to_pixbuf=GTK::gtk("poppler_page_render_to_pixbuf \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\" \"" &  STR(arg7) & "\" \"" &  STR(arg8) & "\"")
END FUNCTION

FUNCTION poppler_page_get_size( arg1, arg2, arg3)
poppler_page_get_size=GTK::gtk("poppler_page_get_size \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION fl_bgn_form( arg1, arg2, arg3)
fl_bgn_form=GTK::gtk("fl_bgn_form \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION fl_end_form
fl_end_form=GTK::gtk("fl_end_form")
END FUNCTION

FUNCTION fl_show_form( arg1, arg2, arg3, arg4)
fl_show_form=GTK::gtk("fl_show_form \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION fl_hide_form( arg1)
fl_hide_form=GTK::gtk("fl_hide_form \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_prepare_form_window( arg1, arg2, arg3, arg4)
fl_prepare_form_window=GTK::gtk("fl_prepare_form_window \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION fl_show_form_window( arg1)
fl_show_form_window=GTK::gtk("fl_show_form_window \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_set_form_position( arg1, arg2, arg3)
fl_set_form_position=GTK::gtk("fl_set_form_position \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION fl_add_box( arg1, arg2, arg3, arg4, arg5, arg6)
fl_add_box=GTK::gtk("fl_add_box \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION fl_add_button( arg1, arg2, arg3, arg4, arg5, arg6)
fl_add_button=GTK::gtk("fl_add_button \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION fl_set_button( arg1, arg2)
fl_set_button=GTK::gtk("fl_set_button \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_get_button( arg1)
fl_get_button=GTK::gtk("fl_get_button \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_add_checkbutton( arg1, arg2, arg3, arg4, arg5, arg6)
fl_add_checkbutton=GTK::gtk("fl_add_checkbutton \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION fl_add_roundbutton( arg1, arg2, arg3, arg4, arg5, arg6)
fl_add_roundbutton=GTK::gtk("fl_add_roundbutton \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION fl_add_round3dbutton( arg1, arg2, arg3, arg4, arg5, arg6)
fl_add_round3dbutton=GTK::gtk("fl_add_round3dbutton \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION fl_add_slider( arg1, arg2, arg3, arg4, arg5, arg6)
fl_add_slider=GTK::gtk("fl_add_slider \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION fl_set_slider_value( arg1, arg2)
fl_set_slider_value=GTK::gtk("fl_set_slider_value \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_set_slider_bounds( arg1, arg2, arg3)
fl_set_slider_bounds=GTK::gtk("fl_set_slider_bounds \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION fl_get_slider_value( arg1)
fl_get_slider_value=GTK::gtk("fl_get_slider_value \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_add_valslider( arg1, arg2, arg3, arg4, arg5, arg6)
fl_add_valslider=GTK::gtk("fl_add_valslider \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION fl_set_slider_step( arg1, arg2)
fl_set_slider_step=GTK::gtk("fl_set_slider_step \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_set_slider_precision( arg1, arg2)
fl_set_slider_precision=GTK::gtk("fl_set_slider_precision \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_add_text( arg1, arg2, arg3, arg4, arg5, arg6)
fl_add_text=GTK::gtk("fl_add_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION fl_add_clock( arg1, arg2, arg3, arg4, arg5, arg6)
fl_add_clock=GTK::gtk("fl_add_clock \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION fl_add_input( arg1, arg2, arg3, arg4, arg5, arg6)
fl_add_input=GTK::gtk("fl_add_input \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION fl_set_input( arg1, arg2)
fl_set_input=GTK::gtk("fl_set_input \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_set_input_color( arg1, arg2, arg3)
fl_set_input_color=GTK::gtk("fl_set_input_color \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION fl_get_input( arg1)
fl_get_input=GTK::gtk("fl_get_input \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_add_frame( arg1, arg2, arg3, arg4, arg5, arg6)
fl_add_frame=GTK::gtk("fl_add_frame \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION fl_add_labelframe( arg1, arg2, arg3, arg4, arg5, arg6)
fl_add_labelframe=GTK::gtk("fl_add_labelframe \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION fl_add_timer( arg1, arg2, arg3, arg4, arg5, arg6)
fl_add_timer=GTK::gtk("fl_add_timer \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION fl_set_timer( arg1, arg2)
fl_set_timer=GTK::gtk("fl_set_timer \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_get_timer( arg1)
fl_get_timer=GTK::gtk("fl_get_timer \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_suspend_timer( arg1)
fl_suspend_timer=GTK::gtk("fl_suspend_timer \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_resume_timer( arg1)
fl_resume_timer=GTK::gtk("fl_resume_timer \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_add_choice( arg1, arg2, arg3, arg4, arg5, arg6)
fl_add_choice=GTK::gtk("fl_add_choice \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION fl_clear_choice( arg1)
fl_clear_choice=GTK::gtk("fl_clear_choice \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_addto_choice( arg1, arg2)
fl_addto_choice=GTK::gtk("fl_addto_choice \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_delete_choice( arg1, arg2)
fl_delete_choice=GTK::gtk("fl_delete_choice \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_replace_choice( arg1, arg2, arg3)
fl_replace_choice=GTK::gtk("fl_replace_choice \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION fl_get_choice( arg1)
fl_get_choice=GTK::gtk("fl_get_choice \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_get_choice_text( arg1)
fl_get_choice_text=GTK::gtk("fl_get_choice_text \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_get_choice_item_text( arg1, arg2)
fl_get_choice_item_text=GTK::gtk("fl_get_choice_item_text \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_get_choice_maxitems( arg1)
fl_get_choice_maxitems=GTK::gtk("fl_get_choice_maxitems \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_add_browser( arg1, arg2, arg3, arg4, arg5, arg6)
fl_add_browser=GTK::gtk("fl_add_browser \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION fl_clear_browser( arg1)
fl_clear_browser=GTK::gtk("fl_clear_browser \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_add_browser_line( arg1, arg2)
fl_add_browser_line=GTK::gtk("fl_add_browser_line \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_addto_browser( arg1, arg2)
fl_addto_browser=GTK::gtk("fl_addto_browser \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_addto_browser_chars( arg1, arg2)
fl_addto_browser_chars=GTK::gtk("fl_addto_browser_chars \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_insert_browser_line( arg1, arg2, arg3)
fl_insert_browser_line=GTK::gtk("fl_insert_browser_line \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION fl_delete_browser_line( arg1, arg2)
fl_delete_browser_line=GTK::gtk("fl_delete_browser_line \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_replace_browser_line( arg1, arg2, arg3)
fl_replace_browser_line=GTK::gtk("fl_replace_browser_line \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION fl_get_browser_line( arg1, arg2)
fl_get_browser_line=GTK::gtk("fl_get_browser_line \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_get_browser( arg1)
fl_get_browser=GTK::gtk("fl_get_browser \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_select_browser_line( arg1, arg2)
fl_select_browser_line=GTK::gtk("fl_select_browser_line \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_deactivate_object( arg1)
fl_deactivate_object=GTK::gtk("fl_deactivate_object \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_activate_object( arg1)
fl_activate_object=GTK::gtk("fl_activate_object \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_set_icm_color( arg1, arg2, arg3, arg4)
fl_set_icm_color=GTK::gtk("fl_set_icm_color \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\"")
END FUNCTION

FUNCTION fl_set_focus_object( arg1, arg2)
fl_set_focus_object=GTK::gtk("fl_set_focus_object \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_get_focus_object( arg1)
fl_get_focus_object=GTK::gtk("fl_get_focus_object \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_bgn_group
fl_bgn_group=GTK::gtk("fl_bgn_group")
END FUNCTION

FUNCTION fl_end_group
fl_end_group=GTK::gtk("fl_end_group")
END FUNCTION

FUNCTION fl_addto_group( arg1)
fl_addto_group=GTK::gtk("fl_addto_group \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_show_message( arg1, arg2, arg3)
fl_show_message=GTK::gtk("fl_show_message \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION fl_hide_object( arg1)
fl_hide_object=GTK::gtk("fl_hide_object \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_show_object( arg1)
fl_show_object=GTK::gtk("fl_show_object \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_set_object_color( arg1, arg2, arg3)
fl_set_object_color=GTK::gtk("fl_set_object_color \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\"")
END FUNCTION

FUNCTION fl_set_object_lsize( arg1, arg2)
fl_set_object_lsize=GTK::gtk("fl_set_object_lsize \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_set_object_lcol( arg1, arg2)
fl_set_object_lcol=GTK::gtk("fl_set_object_lcol \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_set_object_lstyle( arg1, arg2)
fl_set_object_lstyle=GTK::gtk("fl_set_object_lstyle \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_set_object_label( arg1, arg2)
fl_set_object_label=GTK::gtk("fl_set_object_label \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_set_font_name( arg1, arg2)
fl_set_font_name=GTK::gtk("fl_set_font_name \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\"")
END FUNCTION

FUNCTION fl_set_idle_delta( arg1)
fl_set_idle_delta=GTK::gtk("fl_set_idle_delta \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_finish
fl_finish=GTK::gtk("fl_finish")
END FUNCTION

FUNCTION fl_add_glcanvas( arg1, arg2, arg3, arg4, arg5, arg6)
fl_add_glcanvas=GTK::gtk("fl_add_glcanvas \"" & STR(arg1) & "\" \"" &  STR(arg2) & "\" \"" &  STR(arg3) & "\" \"" &  STR(arg4) & "\" \"" &  STR(arg5) & "\" \"" &  STR(arg6) & "\"")
END FUNCTION

FUNCTION fl_activate_glcanvas( arg1)
fl_activate_glcanvas=GTK::gtk("fl_activate_glcanvas \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION fl_winget
fl_winget=GTK::gtk("fl_winget")
END FUNCTION

FUNCTION fl_get_canvas_id( arg1)
fl_get_canvas_id=GTK::gtk("fl_get_canvas_id \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION lrint( arg1)
lrint=GTK::gtk("lrint \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION toascii( arg1)
toascii=GTK::gtk("toascii \"" & STR(arg1) & "\"")
END FUNCTION

FUNCTION putchar( arg1)
putchar=GTK::gtk("putchar \"" & STR(arg1) & "\"")
END FUNCTION
