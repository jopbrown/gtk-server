#!/bin/bash
#
# Demo with gtkglext - April 2008, (c) PvE.
#
#---------------------------------------------------------------------
# Some constants
#---------------------------------------------------------------------

# Name of PIPE file
declare PI=/tmp/bash.gtk.$$

NULL="NULL"
ESCAPE=65307

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

# These are from the GtkGlExt enumerations
let GDK_GL_RGBA_TYPE=0
let GDK_GL_MODE_RGB=0
((GDK_GL_MODE_DOUBLE=1<<1))
((GDK_GL_MODE_DEPTH=1<<4))

# First message in ASCII characters: "OpenGL demo with BASH"
MSG1=(79 112 101 110 71 76 32 100 101 109 111 32 119 105 116 104 32 66 65 83 72)

# Second message in ASCII characters: "Using GTK-server with GtkGlExt!"
MSG2=(85 115 105 110 103 32 71 84 75 45 115 101 114 118 101 114 32 119 105 116 104 32 71 116 107 71 108 69 120 116 33)

#---------------------------------------------------------------------
# Communication function; assignment function
#---------------------------------------------------------------------

function gtk() { echo $1 > $PI; read GTK < $PI; }
function define() { $2 "$3"; eval $1=$GTK; }

#---------------------------------------------------------------------
# Draw bitmapped text on the screen, character by character
#---------------------------------------------------------------------

function bitmap_text
{
let NR=0

while [[ $NR -lt ${#MSG1[@]} ]]
do
    gtk "glutBitmapCharacter $GLUT_BITMAP_HELVETICA_18 ${MSG1[$NR]}"
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
    gtk "glutStrokeCharacter $GLUT_STROKE_ROMAN ${MSG2[$NR]}"
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
# Setup the drawing area
define GLCONTEXT gtk "gtk_widget_get_gl_context $DA"
define GLDRAWABLE gtk "gtk_widget_get_gl_window $DA"
gtk "gdk_gl_drawable_gl_begin $GLDRAWABLE $GLCONTEXT"


# Define clearing color
gtk "glClearColor 0.5 1 1 0"
# Clear screen
((FLAG=$GL_COLOR_BUFFER_BIT|$GL_DEPTH_BUFFER_BIT))
gtk "glClear $FLAG"
# Enable shading, depth and lighting
gtk "glShadeModel $GL_SMOOTH"
gtk "glEnable $GL_DEPTH_TEST"
gtk "glEnable $GL_LIGHTING"
gtk "glEnable $GL_LIGHT0"
# Setup lighting
gtk "glLightfv $GL_LIGHT0 $GL_POSITION AAAAQAAAAEAAAADBAAAAAA=="
gtk "glLightfv $GL_LIGHT0 $GL_DIFFUSE AACAPwAAgD8AAIA/AACAPw=="
gtk "glLightfv $GL_LIGHT0 $GL_AMBIENT mpkZPpqZGT6amRk+"
gtk "glLightfv $GL_LIGHT0 $GL_SPECULAR AACAPwAAgD8AAIA/AACAPw=="
# Setup reflected color of object
gtk "glMaterialfv $GL_FRONT $GL_AMBIENT_AND_DIFFUSE zczMPTMzMz/NzMw9AAAAPw=="
# Make sure we see the model
gtk "glMatrixMode $GL_MODELVIEW"
# Save current matrix
gtk "glPushMatrix"
# Rotate
gtk "glRotatef $ROTX 0 1 0"
gtk "glRotatef $ROTY 1 0 0"
# Dump rotated image
gtk "glutSolidTeapot $SIZE"
# Undo the last rotation
gtk "glLoadIdentity"
# Setup reflected color of font
gtk "glMaterialfv $GL_FRONT $GL_AMBIENT_AND_DIFFUSE AACAP83MzD4AAIA/AAAAAA=="
# Determine position of bitmapped text
gtk "glRasterPos2f 0 -0.8"
# Draw some bitmapped text
bitmap_text
# Setup reflected color of font
gtk "glMaterialfv $GL_FRONT $GL_AMBIENT_AND_DIFFUSE AAAAAAAAAAAAAIA/AAAAAA=="
# Determine position of STROKED text -> drawed so translate
gtk "glTranslatef -0.9 0.8 0.0"
# Setup scaling -> stroked characters are large, make smaller
gtk "glScalef 0.0005 0.0006 0"
# Draw some stroked text
stroke_text
# Now put back the matrix
gtk "glPopMatrix"


# Now swap buffers and draw
gtk "gdk_gl_drawable_swap_buffers $GLDRAWABLE"
gtk "gdk_gl_drawable_gl_end $GLDRAWABLE"
}

#---------------------------------------------------------------------
# Main program
#---------------------------------------------------------------------

# Start gtk-server in FIFO mode
gtk-server -fifo=$PI &
while [ ! -p $PI ]; do continue; done

# Check availability of GtkGlExt
define AVAIL gtk "gtk_server_require libgtkglext-x11-1.0.so.0"
if [[ $AVAIL != "ok" ]]
then
    echo "Install the GtkGlExt libraries from gtkglext.sourceforge.net first, and run this demo again."
    gtk "gtk_server_exit"
    exit
fi
define AVAIL gtk "gtk_server_require libglut.so.3"
if [[ $AVAIL != "ok" ]]
then
    echo "Install the GLUT libraries from freeglut.sourceforge.net first, and run this demo again."
    gtk "gtk_server_exit"
    exit
fi

# Define GUI
gtk "gtk_init $NULL $NULL"
gtk "gtk_gl_init $NULL $NULL"
# Window
define WINDOW gtk "gtk_window_new 0"
gtk "gtk_window_set_default_size $WINDOW 640 480"
gtk "gtk_window_set_title $WINDOW 'This is a teapot demo with BASH'"
gtk "gtk_window_set_position $WINDOW 1"
# Signal every 100 msecs
gtk "gtk_server_connect $WINDOW show idle"
gtk "gtk_server_timeout 75 $WINDOW show"
gtk "gtk_server_connect $WINDOW key-press-event key-press-event"
# Drawing area
define DA gtk "gtk_drawing_area_new"
gtk "gtk_container_add $WINDOW $DA"

((FLAG=$GDK_GL_MODE_RGB|$GDK_GL_MODE_DOUBLE|$GDK_GL_MODE_DEPTH))
define GLCONFIG gtk "gdk_gl_config_new_by_mode $FLAG"
gtk "gtk_widget_set_gl_capability $DA $GLCONFIG $NULL 1 $GDK_GL_RGBA_TYPE"
gtk "gtk_server_connect $DA expose-event expose"
gtk "gtk_widget_show_all $WINDOW"

# Initalize GLUT
gtk "glutInit 1 ' '"

# Initialize variables
ROTX=0
ROTY=330
# size of teapot
SIZE=0.5

define GLUT_BITMAP_HELVETICA_18 gtk "glutBitmapHelvetica18"
define GLUT_STROKE_ROMAN gtk "glutStrokeRoman"

# Mainloop
until [[ $EVENT = $WINDOW || $KEY = $ESCAPE ]]
do
    define EVENT gtk "gtk_server_callback wait"

    # Rotate
    ((ROTX+=3))
    ((ROTY+=2))
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

    # Check events
    case $EVENT in

	"idle")
	    expose
	    ;;
	"expose")
	    expose
	    ;;
	"key-press-event")
	    define KEY gtk "gtk_server_key"
	    ;;
    esac
done

# Exit GTK
gtk "gtk_server_exit"
