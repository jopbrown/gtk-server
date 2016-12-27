#!/bin/bash
#
# Graphical Disk Fill with HUG.
#   Using AWK for floatnumbers.
#
# May 2008 - Peter van Eerten - GPL.
#
#---------------------------------------------------------

# Name of PIPE file
declare PIPE=/tmp/bash.gtk.$$

# Communication function; assignment function
function gtk() { echo $1 > $PIPE; read GTK < $PIPE; }
function define() { $2 "$3"; eval $1="$GTK"; }

# Get all sizes of partitions
INFO=`df | awk '/\// {print $2,$3,$6}'`

AMOUNT=0
COUNT=0

# Put info in arrays
for i in $INFO
do
    if [[ $AMOUNT -eq 0 ]]; then
	SIZES[$COUNT]=$i
    fi
    if [[ $AMOUNT -eq 1 ]]; then
	USED[$COUNT]=$i
    fi
    if [[ $AMOUNT -eq 2 ]]; then
	NAMES[$COUNT]=$i
	((AMOUNT-=3))
	((COUNT+=1))
    fi
    ((AMOUNT+=1))
done

IDX=0
MAXSIZE=0

# Find maximum size
while [[ $IDX -lt ${#SIZES[@]} ]]
do
    if [[ ${SIZES[$IDX]} -ge $MAXSIZE ]]; then
	MAXSIZE=${SIZES[$IDX]}
    fi
    ((IDX+=1))
done

# Space between columns
MARGE=10
# Start of first column
XPOS=20
# Width of the columns
let WIDTH1=90
let WIDTH2=80

# Calculate widths depending on amount of mounts
let SCREENW=$WIDTH1*${#SIZES[@]}+$MARGE*${#SIZES[@]}+50
let FRAMEW=$SCREENW-10
let CANVASW=$SCREENW-30
let LINEW=$SCREENW-50

# Start gtk-server in FIFO mode
gtk-server -fifo=$PIPE &
while [ ! -p $PIPE ]; do continue; done

# Define GUI - mainwindow
define WIN gtk "u_window \"'Graphical Disk Fill'\" $SCREENW 400"
gtk "u_bgcolor $WIN #FFFFFF"
# Attach frame
define FRAME gtk "u_frame $FRAMEW 390"
gtk "u_bgcolor $FRAME #FFFFFF"
gtk "u_frame_text $FRAME \"' Disk Usage Graph '\""
gtk "u_attach $WIN $FRAME 5 5"
# Setup the drawing canvas, draw stuff
define CANVAS gtk "u_canvas $CANVASW 365"
gtk "u_attach $WIN $CANVAS 10 25"
# Draw axis
gtk "u_line #000000 20 340 $LINEW 340"

IDX=0
while [[ $IDX -lt ${#SIZES[@]} ]]
do
    # Draw columns
    HEIGHT=`awk -v M=$MAXSIZE -v S=${SIZES[$IDX]} 'BEGIN{print int(S/M*310)}'`
    let YPOS=340-$HEIGHT
    gtk "u_square #00FF11 $XPOS $YPOS $WIDTH1 $HEIGHT 1"
    gtk "u_square #000000 $XPOS $YPOS $WIDTH1 $HEIGHT 0"
    # Draw amount
    ((YPOS-=15))
    gtk "u_out ${SIZES[$IDX]} #007700 #FFFFFF $XPOS $YPOS"
    # Draw usage
    ((XPOS+=5))
    HEIGHT=`awk -v M=$MAXSIZE -v S=${USED[$IDX]} 'BEGIN{print int(S/M*310)}'`
    let YPOS=340-$HEIGHT
    gtk "u_square #FF1100 $XPOS $YPOS $WIDTH2 $HEIGHT 1"
    gtk "u_square #000000 $XPOS $YPOS $WIDTH2 $HEIGHT 0"
    # Draw text
    let YPOS=345
    gtk "u_out \"'${NAMES[$IDX]}'\" #0000FF #FFFFFF $XPOS $YPOS"
    let XPOS=$XPOS+$WIDTH1+$MARGE-5
    # Next column
    ((IDX+=1))
done

# Mainloop
until [[ $EVENT = $WIN ]]
do
    define EVENT gtk "u_event"
done

gtk "u_end"
