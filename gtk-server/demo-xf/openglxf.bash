#!/bin/bash
#
# Demo with XForms and the built-in OpenGL. This program can run with the
#  GTK-server for XForms.
#
# Tested with GTK-server 2.2.7 compiled with XForms, and BASH 3.1
#
# PvE - August 2008
# --------------------------------------------------------------------

#---------------------------------------------------------------------
# Communication function; assignment function
#---------------------------------------------------------------------

function xf() { echo $1 > $PI; read XF < $PI; }
function define() { $2 "$3"; eval $1="\"$XF\""; }

#---------------------------------------------------------------------
# Draw bitmapped text on the screen, character by character
#---------------------------------------------------------------------

function bitmap_text
{
let NR=0

while [[ $NR -lt ${#MSG1[@]} ]]
do
    xf "glutBitmapCharacter $GLUT_BITMAP_HELVETICA_18 ${MSG1[$NR]}"
    ((NR+=1))
done
}

#---------------------------------------------------------------------
# Draw stroked text on the screen, character by character
#---------------------------------------------------------------------

function stroke_text
{
let NR=0

while [[ $NR -lt ${#MSG2[@]} ]]
do
    xf "glutStrokeCharacter $GLUT_STROKE_ROMAN ${MSG2[$NR]}"
    ((NR+=1))
done
}

#---------------------------------------------------------------------
# Draw and expose the picture
#
# Note: colors in OpenGL are mostly defined as an array of floats.
# Such an array cannot be passed to the GTK-server, therefore we pass 
# a binary structure which is Base64 encoded. To create a Base64
# encoded float array structure, I used the following:
#
# newlisp -e '(base64-enc (pack "fff" 1 1 0))'
#
# In this example the float array {1.0 1.0 0.0} is shown in Base64 
# and can be passed to the GTK-server. Of course the datatype for the 
# argument in the GL-function in the configfile should be set to
# BASE64 also.
#
# NewLisp can be obtained for free from http://www.newlisp.org
#---------------------------------------------------------------------

function expose
{
# Define the drawing area
xf "fl_activate_glcanvas $CANVAS"

# Define clearing color
xf "glClearColor 0.5 1 1 0"
# Clear screen
((FLAG=$GL_COLOR_BUFFER_BIT|$GL_DEPTH_BUFFER_BIT))
xf "glClear $FLAG"
# Enable shading, depth and lighting
xf "glShadeModel $GL_SMOOTH"
xf "glEnable $GL_DEPTH_TEST"
xf "glEnable $GL_LIGHTING"
xf "glEnable $GL_LIGHT0"
# Setup lighting
xf "glLightfv $GL_LIGHT0 $GL_POSITION AAAAQAAAAEAAAADBAAAAAA=="
xf "glLightfv $GL_LIGHT0 $GL_DIFFUSE AACAPwAAgD8AAIA/AACAPw=="
xf "glLightfv $GL_LIGHT0 $GL_AMBIENT mpkZPpqZGT6amRk+"
xf "glLightfv $GL_LIGHT0 $GL_SPECULAR AACAPwAAgD8AAIA/AACAPw=="
# Setup reflected color of object
xf "glMaterialfv $GL_FRONT $GL_AMBIENT_AND_DIFFUSE zczMPTMzMz/NzMw9AAAAPw=="
# Make sure we see the model
xf "glMatrixMode $GL_MODELVIEW"
# Save current matrix
xf "glPushMatrix"
# Rotate
xf "glRotatef $ROTX 0 1 0"
xf "glRotatef $ROTY 1 0 0"
# Dump rotated image
xf "glutSolidTeapot $SIZE"
# Undo the last rotation
xf "glLoadIdentity"
# Setup reflected color of font
xf "glMaterialfv $GL_FRONT $GL_AMBIENT_AND_DIFFUSE AACAP83MzD4AAIA/AAAAAA=="
# Determine position of bitmapped text
xf "glRasterPos2f 0 -0.8"
# Draw some bitmapped text
bitmap_text
# Setup reflected color of font
xf "glMaterialfv $GL_FRONT $GL_AMBIENT_AND_DIFFUSE AAAAAAAAAAAAAIA/AAAAAA=="
# Determine position of STROKED text -> drawed so translate
xf "glTranslatef -0.9 0.8 0.0"
# Setup scaling -> stroked characters are large, make smaller
xf "glScalef 0.0005 0.0006 0"
# Draw some stroked text
stroke_text
# Now put back the matrix
xf "glPopMatrix"

# Now swap buffers and draw
define DISPLAY xf "fl_winget"
define ID xf "fl_get_canvas_id $CANVAS"
xf "glXSwapBuffers $DISPLAY $ID"
}

# Name of PIPE file
declare PI=/tmp/bash.gtk.$$

# Start GTK-server in FIFO mode
gtk-server -fifo=$PI -log=/tmp/$0.log &
while [ ! -p $PI ]; do continue; done

# Open additional GL libraries
define GL xf "gtk_server_require libGL.so.1"
if [[ $GL != "ok" ]]
then
    echo "No OpenGL found on this system! Exiting..."
    xf "gtk_server_exit"
fi
define GLUT xf "gtk_server_require libglut.so.3"
if [[ $GLUT != "ok" ]]
then
    echo "Please install GLUT from freeglut.sourceforge.net! Exiting..."
    xf "gtk_server_exit"
fi

# These hex values are retrieved from the GL header files
let GL_DEPTH_BUFFER_BIT=16#100
let GL_COLOR_BUFFER_BIT=16#4000

let GL_LIGHT0=16#4000
let GL_MODELVIEW=16#1700
let GL_POSITION=16#1203
let GL_AMBIENT=16#1200
let GL_DIFFUSE=16#1201
let GL_SPECULAR=16#1202
let GL_SMOOTH=16#1D01
let GL_DEPTH_TEST=16#0B71
let GL_LIGHTING=16#0B50
let GL_FRONT=16#0404
let GL_AMBIENT_AND_DIFFUSE=16#1602

# First message in ASCII characters: "OpenGL demo with BASH"
MSG1=(79 112 101 110 71 76 32 100 101 109 111 32 119 105 116 104 32 66 65 83 72)

# Second message in ASCII characters: "Using GTK-server with XForms fl_glcanvas"
MSG2=(85 115 105 110 103 32 71 84 75 45 115 101 114 118 101 114 32 119 105 116 104 32 88 70 111 114 109 115 32 102 108 95 103 108 99 97 110 118 97 115)

# Main program
define WINDOW xf "fl_bgn_form FL_BORDER_BOX 640 480"
define ABOUT xf "fl_add_button FL_NORMAL_BUTTON 10 430 80 40 About"
define EXIT xf "fl_add_button FL_NORMAL_BUTTON 550 430 80 40 Exit"
xf "fl_set_object_color $EXIT FL_RED FL_TOMATO"
define CANVAS xf "fl_add_glcanvas FL_NORMAL_CANVAS 10 10 620 410 Text"
define TIMER xf "fl_add_timer FL_HIDDEN_TIMER 100 40 40 40 Timer"
xf "fl_set_timer $TIMER 0.1"
xf "fl_end_form"
define MESSAGE xf "fl_bgn_form FL_BORDER_BOX 320 150"
xf "fl_add_text FL_NORMAL_TEXT 90 10 160 25 '*** OpenGL demo ***'"
xf "gtk_server_version"
xf "fl_add_text FL_NORMAL_TEXT 12 35 295 25 'Programmed with BASH and GTK-server $XF.'"
xf "fl_add_text FL_NORMAL_TEXT 15 60 290 25 'Visit http://www.gtk-server.org/ for more info!'"
define OK xf "fl_add_button FL_NORMAL_BUTTON 120 100 80 40 OK"
xf "fl_end_form"

xf "fl_show_form $WINDOW FL_PLACE_CENTER FL_FULLBORDER 'OpenGL and XForms'"

# Initialize variables
EVENT=0
ROTX=0
ROTY=330
# size of teapot
SIZE=0.5

# Initialize GLUT
xf "glutInit 1 ' '"

define GLUT_BITMAP_HELVETICA_18 xf "glutBitmapHelvetica18"
define GLUT_STROKE_ROMAN xf "glutStrokeRoman"

# Mainloop
until [[ $EVENT = $EXIT || $EVENT = *gtk_server_callback* ]]
do
    define EVENT xf "gtk_server_callback wait"

    # Rotate
    ((ROTX+=2))
    ((ROTY+=1))
    if [[ $ROTX -gt 359 ]]
    then
	ROTX=0
    fi
    if [[ $ROTX -lt 0 ]]
    then
	ROTX=360
    fi
    if [[ $ROTY -gt 359 ]]
    then
	ROTY=0
    fi
    if [[ $ROTY -lt 0 ]]
    then
	ROTY=360
    fi

    # Parse event
    case $EVENT in

	$ABOUT)
	    xf "fl_show_form $MESSAGE FL_PLACE_MOUSE FL_FULLBORDER 'OpenGL and XForms'";;

	$OK)
	    xf "fl_hide_form $MESSAGE";;

    	$TIMER)
	    xf "fl_set_timer $TIMER 0.1";;

    esac

    expose

done

# Make sure GTK-server cleans up the pipefile
xf "gtk_server_exit"
