#!/usr/bin/scriba

REM ****************************************************************************
REM
REM This is a port of my old ScriptBasic GTK demoprogram to the GTK-server.
REM
REM Originally published at july 20, 2002.
REM Rewritten at december 26, 2005 - PvE.
REM
REM Tested with Scriptbasic 2.0 and the GTK-server module 2.0.7 for Scriptbasic
REM Tested with Scriptbasic 2.0 and the GTK-server module 2.2.7 for Scriptbasic
REM ****************************************************************************

IMPORT gtk.bas

GLOBAL CONST nl = "\n"
GLOBAL CONST FAKE = 12345
GLOBAL CONST EMPTY = 0
GLOBAL CONST WHITE = -1
GLOBAL CONST BLACK = 1
GLOBAL CONST GROUPIDSTART = 10
GLOBAL CONST CANVAS_WIDTH = 275
GLOBAL CONST CANVAS_HEIGHT = 246

REM ************************************************************** Main program

REM GTK::gtk_log(1)

CALL Initialize_Global
CALL Create_Gopanel
CALL Draw_Board

REPEAT
    event = GUI("gtk_server_callback wait")
    IF event = newbutton THEN CALL New_Board
    IF event = "stone" THEN CALL Put_Stone
    IF event = buttoncapt THEN CALL Show_Prisoners
UNTIL event = quitbutton

GUI("gtk_exit 0")
END

REM ************************************************************** Concat arguments to GTK

FUNCTION GUI(g0, g1, g2, g3, g4, g5, g6, g7, g8, g9)

LOCAL result$

result$ = STR(g0) & " " & STR(g1) & " " & STR(g2) & " " & STR(g3) & " " & STR(g4) & " " & STR(g5) & " " & STR(g6) & " " & STR(g7) & " " & STR(g8) & " " & STR(g9)
GUI = GTK::gtk(result$)

END FUNCTION

REM ************************************************************** Initialize global parameters

SUB Initialize_Global
    GTK::gtk("log=/tmp/log.txt")
    GTK::gtk("gtk_init NULL NULL")
    REM This array keeps the current go-board, wipe Go playing board
    FOR j = 1 TO 9
    FOR i = 1 TO 9
	board[i,j] = EMPTY
    NEXT i
    NEXT j
    REM These keep the coordinates of the last move played
    lastmovex = 0
    lastmovey = 0
    REM These keep the total amount of captured stones for each color
    capturedbywhite = 0
    capturedbyblack = 0
END SUB

REM ************************************************************** Create Go panel

SUB Create_Gopanel
    gopanel = GUI("gtk_window_new 0")
    GUI("gtk_window_set_title", gopanel, "\"The Go panel Revived\"")
    GUI("gtk_widget_set_size_request", gopanel, 300, 350)
    GUI("gtk_window_set_resizable", gopanel, 0)
    gogrid = GUI("gtk_table_new", 55, 50, 1)
    GUI("gtk_container_add", gopanel, gogrid)
    frame = GUI("gtk_frame_new NULL")
    GUI("gtk_table_attach_defaults", gogrid, frame, 1, 49, 1, 43)
    GUI("gtk_frame_set_shadow_type", frame, 3)
    canvas = GUI("gtk_image_new")
    REM Create eventbox to catch mouseclick
    ebox = GUI("gtk_event_box_new")
    GUI("gtk_container_add", ebox, canvas)
    GUI("gtk_table_attach_defaults", gogrid, ebox, 2, 48, 2, 42)
    REM Connect mouse button signal to image
    GUI("gtk_server_connect", ebox, "button-press-event stone")
    radioblack = GUI("gtk_radio_button_new_with_label_from_widget NULL Black")
    GUI("gtk_table_attach_defaults", gogrid, radioblack, 20, 30, 44, 47)
    radiowhite = GUI("gtk_radio_button_new_with_label_from_widget", radioblack, "White")
    GUI("gtk_table_attach_defaults", gogrid, radiowhite, 20, 30, 48, 51)
    buttoncapt = GUI("gtk_button_new_with_label \"Show\nprison\"")
    GUI("gtk_table_attach_defaults", gogrid, buttoncapt, 10, 18, 44, 50)
    newbutton = GUI("gtk_button_new_with_label \"New\"")
    GUI("gtk_table_attach_defaults", gogrid, newbutton, 1, 9, 44, 50)
    quitbutton = GUI("gtk_button_new_with_label \"Quit\"")
    GUI("gtk_table_attach_defaults", gogrid, quitbutton, 41, 49, 44, 50)
    gostatus = GUI("gtk_statusbar_new")
    GUI("gtk_table_attach_defaults", gogrid, gostatus, 0, 50, 52, 55)
    cid = GUI("gtk_statusbar_get_context_id", gostatus, gopanel)
    GUI("gtk_statusbar_push", gostatus, cid, "\"New game started!\"")
    GUI("gtk_widget_show_all", gopanel)
    REM Create the pixmap
    gdkwin = GUI("gtk_widget_get_parent_window", canvas)
    pix = GUI("gdk_pixmap_new", gdkwin, CANVAS_WIDTH, CANVAS_HEIGHT, -1)
    gc = GUI("gdk_gc_new", pix)
    GUI("gtk_image_set_from_pixmap", canvas, pix, "NULL")
    REM Allocate memory for GdkColor with some random widget
    color = GUI("gtk_frame_new NULL")
    REM Now set foreground and backgroundcolors to WHITE
    GUI("gdk_color_parse #ffffff", color)
    GUI("gdk_gc_set_rgb_bg_color", gc, color)
    GUI("gdk_gc_set_rgb_fg_color", gc, color)
    REM Clear the complete pixmap with WHITE
    GUI("gdk_draw_rectangle", pix, gc, 1, 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
END SUB

REM ************************************************************ Draw the Go board

SUB Draw_Board
    LOCAL xfactor, yfactor
    REM Calculate square size
    xfactor = INT(CANVAS_WIDTH/9)
    yfactor = INT(CANVAS_HEIGHT/9)
    REM Draw vertical axes
    GUI("gdk_color_parse #000000", color)
    GUI("gdk_gc_set_rgb_fg_color", gc, color)
    FOR i = xfactor/2 TO CANVAS_WIDTH - xfactor/2 STEP xfactor
    	GUI("gdk_draw_line", pix, gc, INT(i), INT(yfactor/2), INT(i), INT(yfactor/2)+yfactor*8)
    NEXT i
    REM Draw horizontal axes
    FOR i = yfactor/2 TO CANVAS_HEIGHT - yfactor/2 STEP yfactor
    	GUI("gdk_draw_line", pix, gc, INT(xfactor/2), INT(i), INT(xfactor/2)+xfactor*8, INT(i))
    NEXT i
    REM Draw the positions of the stones
    FOR i = 1 TO 9
	FOR j = 1 TO 9
	    IF board[i,j] = BLACK THEN
		GUI("gdk_color_parse #000000", color)
		GUI("gdk_gc_set_rgb_fg_color", gc, color)
		GUI("gdk_draw_arc", pix, gc, 1, (i-1)*xfactor, (j-1)*yfactor, xfactor-1, yfactor-1, 0, 360*64)
	    ELSE IF board[i,j] = WHITE THEN
		GUI("gdk_color_parse #ffffff", color)
		GUI("gdk_gc_set_rgb_fg_color", gc, color)
		GUI("gdk_draw_arc", pix, gc, 1, (i-1)*xfactor, (j-1)*yfactor, xfactor-1, yfactor-1, 0, 360*64)
		GUI("gdk_color_parse #000000", color)
		GUI("gdk_gc_set_rgb_fg_color", gc, color)
		GUI("gdk_draw_arc", pix, gc, 0, (i-1)*xfactor, (j-1)*yfactor, xfactor-1, yfactor-1, 0, 360*64)
	    END IF
	NEXT j
    NEXT i
    GUI("gtk_widget_queue_draw", canvas)
END SUB  

REM ************************************************************ Reset the board & draw

SUB New_Board
    FOR j = 1 to 9
	FOR i = 1 to 9
	    board[j,i] = EMPTY
	NEXT i
    NEXT j
    GUI("gdk_color_parse #ffffff", color)
    GUI("gdk_gc_set_rgb_fg_color", gc, color)
    GUI("gdk_draw_rectangle", pix, gc, 1, 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
    CALL Draw_Board
    lastmovex = 0
    lastmovey = 0
    capturedbywhite = 0
    capturedbyblack = 0
    GUI("gtk_statusbar_pop", gostatus, cid)
    GUI("gtk_statusbar_push", gostatus, cid, "\"New game started!\"")
END SUB

REM ************************************************************ Show captured stones

SUB Show_Prisoners
    GUI("gtk_statusbar_pop", gostatus, cid)
    GUI("gtk_statusbar_push", gostatus, cid, "\"Captured by white: " & capturedbywhite & " - Captured by black: " & capturedbyblack & "\"")
END SUB

REM ************************************************************ Put a stone & draw

SUB Put_Stone

    LOCAL mousex, mousey, xfactor, yfactor

    mousex = VAL(GUI("gtk_server_mouse 0"))
    mousey = VAL(GUI("gtk_server_mouse 1"))
    xfactor = INT(CANVAS_WIDTH/9)
    yfactor = INT(CANVAS_HEIGHT/9)

    FOR j = 1 TO 9
	FOR i = 1 TO 9
	    IF (mousex>(j-1)*xfactor) AND (mousex<(j-1)*xfactor+xfactor) THEN
		IF (mousey>(i-1)*yfactor) AND (mousey<((i-1)*yfactor+yfactor)) THEN
		    IF (GUI("gtk_toggle_button_get_active", radioblack) = "1") THEN
			IF board[j,i] = EMPTY THEN
			    board[j,i] = BLACK
			    GUI("gtk_statusbar_pop", gostatus, cid)
			    GUI("gtk_statusbar_push", gostatus, cid, "\"Black played.\"")
			    lastmovex = j
			    lastmovey = i
			ELSE
			    GUI("gtk_statusbar_pop", gostatus, cid)
			    GUI("gtk_statusbar_push", gostatus, cid, "\"Cannot play here!\"")
			END IF
		    ELSE
			IF board[j,i] = EMPTY THEN
			    board[j,i] = WHITE
			    GUI("gtk_statusbar_pop", gostatus, cid)
			    GUI("gtk_statusbar_push", gostatus, cid, "\"White played.\"")
			    lastmovex = j
			    lastmovey = i
			ELSE
			    GUI("gtk_statusbar_pop", gostatus, cid)
			    GUI("gtk_statusbar_push", gostatus, cid, "\"Cannot play here!\"")
			END IF
		    END IF
		END IF
	    END IF
	NEXT i
    NEXT j

    CALL Draw_Board
    CALL Captured_Stones
    CALL Determine_Suicide

END SUB

REM ************************************************************ Was last move suicide?

SUB Determine_Suicide
    LOCAL i, j, group, freedoms, counter, current
    REM Wipe groups board with fake value
    FOR j = 0 TO 10
	FOR i = 0 TO 10
	    groups[j,i] = FAKE
	NEXT i
    NEXT j
    REM Copy current playing board to groups board
    FOR j = 1 TO 9
	FOR i = 1 TO 9
	    groups[j,i] = board[j,i]
	NEXT i
    NEXT j
    REM Clear temp array's keeping stone positions
    FOR i = 1 to 81
	posx[i] = 0
	posy[i] = 0
    NEXT i
    REM Initialize local variables
    freedoms = 0
    counter = 1
    current = 1
    posx[current] = lastmovex
    posy[current] = lastmovey
    group = groups[lastmovex,lastmovey]
    groups[lastmovex,lastmovey] = -1*group
    DO
	IF groups[posx[current]-1,posy[current]] = EMPTY THEN
	    freedoms += 1
	ELSE IF groups[posx[current]-1,posy[current]] = group THEN
	    groups[posx[current]-1,posy[current]] = -1*group
	    counter += 1
	    posx[counter] = posx[current]-1
	    posy[counter] = posy[current]
	END IF
	IF groups[posx[current]+1,posy[current]] = EMPTY THEN
	    freedoms += 1
	ELSE IF groups[posx[current]+1,posy[current]] = group THEN
	    groups[posx[current]+1,posy[current]] = -1*group
	    counter += 1
	    posx[counter] = posx[current]+1
	    posy[counter] = posy[current]
	END IF
	IF groups[posx[current],posy[current]-1] = EMPTY THEN
	    freedoms += 1
	ELSE IF groups[posx[current],posy[current]-1] = group THEN
	    groups[posx[current],posy[current]-1] = -1*group
	    counter += 1
	    posx[counter] = posx[current]
	    posy[counter] = posy[current]-1
	END IF
	IF groups[posx[current],posy[current]+1] = EMPTY THEN
	    freedoms += 1
	ELSE IF groups[posx[current],posy[current]+1] = group THEN
	    groups[posx[current],posy[current]+1] = -1*group
	    counter += 1
	    posx[counter] = posx[current]
	    posy[counter] = posy[current]+1
	END IF
	current += 1
    LOOP UNTIL current > counter

    IF freedoms = 0 THEN 
	board[lastmovex, lastmovey] = EMPTY
	GUI("gdk_color_parse #ffffff", color)
	GUI("gdk_gc_set_rgb_fg_color", gc, color)
	GUI("gdk_draw_rectangle", pix, gc, 1, 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
	CALL Draw_Board
	GUI("gtk_statusbar_pop", gostatus, cid)
	GUI("gtk_statusbar_push", gostatus, cid, "\"This is an illegal move! Play again...\"")
    END IF
END SUB

REM ************************************************************ Find captured stones

SUB Captured_Stones
    LOCAL i, j, group, freedoms, counter, current, total
    REM Wipe groups board
    FOR j = 0 TO 10
	FOR i = 0 TO 10
	   groups[j,i] = FAKE
	NEXT i
    NEXT j
    REM Copy current playing board to groups board
    FOR j = 1 TO 9
	FOR i = 1 TO 9
	    groups[j,i] = board[j,i]
	NEXT i
    NEXT j
    REM Clear temp array's keeping stone positions
    FOR i = 1 to 81
	posx[i] = 0
	posy[i] = 0
    NEXT i
    REM Initialize used variables
    total = 0
    FOR j = 1 TO 9
	FOR i = 1 TO 9
	    REM Check: place is empty and is not the last color played
	    IF (ABS(groups[j,i]) <> EMPTY) AND (groups[j,i]<>board[lastmovex,lastmovey]) THEN
		freedoms = 0
		counter = 1
		current = 1
		posx[current] = j
		posy[current] = i
		group = groups[j,i]
		groups[j,i] = -5*group
		DO
		    IF groups[posx[current]-1,posy[current]] = EMPTY THEN
			freedoms += 1
		    ELSE IF groups[posx[current]-1,posy[current]] = group THEN
			groups[posx[current]-1,posy[current]] = -5*group
			counter += 1
			posx[counter] = posx[current]-1
			posy[counter] = posy[current]
		    END IF
		    IF groups[posx[current]+1,posy[current]] = EMPTY THEN
			freedoms += 1
		    ELSE IF groups[posx[current]+1,posy[current]] = group THEN
			groups[posx[current]+1,posy[current]] = -5*group
			counter += 1
			posx[counter] = posx[current]+1
			posy[counter] = posy[current]
		    END IF
		    IF groups[posx[current],posy[current]-1] = EMPTY THEN
			freedoms += 1
		    ELSE IF groups[posx[current],posy[current]-1] = group THEN
			groups[posx[current],posy[current]-1] = -5*group
			counter += 1
			posx[counter] = posx[current]
			posy[counter] = posy[current]-1
		    END IF
		    IF groups[posx[current],posy[current]+1] = EMPTY THEN
			freedoms += 1
		    ELSE IF groups[posx[current],posy[current]+1] = group THEN
			groups[posx[current],posy[current]+1] = -5*group
			counter += 1
			posx[counter] = posx[current]
			posy[counter] = posy[current]+1
		    END IF
		    current += 1
		LOOP UNTIL current > counter

		IF freedoms = 0 THEN 
		    counter = 1
		    current = 1
		    posx[current] = j
		    posy[current] = i
		    group = groups[j,i]
		    groups[j,i] = EMPTY
		    board[j,i] = EMPTY
		    DO
			IF groups[posx[current]-1,posy[current]] = group THEN
			    groups[posx[current]-1,posy[current]] = EMPTY
			    board[posx[current]-1,posy[current]] = EMPTY
			    counter += 1
			    posx[counter] = posx[current]-1
			    posy[counter] = posy[current]
			END IF
			IF groups[posx[current]+1,posy[current]] = group THEN
			    groups[posx[current]+1,posy[current]] = EMPTY
			    board[posx[current]+1,posy[current]] = EMPTY
			    counter += 1
			    posx[counter] = posx[current]+1
			    posy[counter] = posy[current]
			END IF
			IF groups[posx[current],posy[current]-1] = group THEN
			    groups[posx[current],posy[current]-1] = EMPTY
			    board[posx[current],posy[current]-1] = EMPTY
			    counter += 1
			    posx[counter] = posx[current]
			    posy[counter] = posy[current]-1
			END IF
			IF groups[posx[current],posy[current]+1] = group THEN
			    groups[posx[current],posy[current]+1] = EMPTY
			    board[posx[current],posy[current]+1] = EMPTY
			    counter += 1
			    posx[counter] = posx[current]
			    posy[counter] = posy[current]+1
			END IF
			current += 1
		    LOOP UNTIL current > counter
		    GUI("gdk_color_parse #ffffff", color)
		    GUI("gdk_gc_set_rgb_fg_color", gc, color)
		    GUI("gdk_draw_rectangle", pix, gc, 1, 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
		    CALL Draw_Board
		    total += counter
		END IF
	    END IF
	NEXT i
    NEXT j
    IF total > 0 THEN
	GUI("gtk_statusbar_pop", gostatus, cid)
	GUI("gtk_statusbar_push", gostatus, cid, "\"" & total & " stones captured!\"")
    END IF

    IF board[lastmovex, lastmovey] = WHITE THEN capturedbywhite += total
    IF board[lastmovex, lastmovey] = BLACK THEN capturedbyblack += total

END SUB
