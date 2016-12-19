#!/bin/ksh
#
# A small tetris game wih the HUG abstraction layer (HUG-al)
#
# (c) Peter van Eerten, august 2008 - GPL.
#
# The 'tetris.mid' sound file originally was called 'Korobeiniki.mid' and was
# downloaded from Wikimedia. Here it is used for demonstrational purposes only.
#
# This is intended to be a demonstration program, and probably contains bugs.
#
# It is *not* allowed to sell this program, or to use it in any commercial way
# without written permission of the author.
#
# However, it is allowed to use this program for educational purposes without
# written permission of the author.
#
# If you like Tetris, obtain a copy from http://www.tetris.com/.
#
#--------------------------------------------------------------------- Embed HUG macros

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

# Now create global functionnames from HUG macros
if [[ ! -f $HOME/.hug4ksh || $CFG -nt $HOME/.hug4ksh ]]; then
    echo "#!/bin/ksh" > $HOME/.hug4ksh
    while read LINE
    do
	if [[ $LINE = MACRO* ]]; then
	    print "function ${LINE#* }" >> $HOME/.hug4ksh
	    print "{\nprint -p ${LINE#* } \$@" >> $HOME/.hug4ksh
	    print "read -p GTK\n}" >> $HOME/.hug4ksh
	fi
    done < $CFG
fi

# Declare global variables
typeset GTK NULL="NULL"
unset CFG LINE

#----------------------------------------------------------------------------------------

# Assignment function
function define { $2 $3 $4 $5 $6 $7; eval $1="\"$GTK\""; }

#----------------------------------------------------------------------------------------
#
# The '0000' piece - code 1
#
#----------------------------------------------------------------------------------------

function Define_or_Wipe_One
{
# Define these as local
typeset -i POS X Y

# Assign the arguments
X=$1; Y=$2

# Calculate position on board array
let POS=$X/20+$Y/2

# Determine position, then wipe or draw
if [[ $3 -eq 0 || $3 -eq 2 ]]
then
    let BOARD[$POS-1]=$4
    let BOARD[$POS]=$4
    let BOARD[$POS+1]=$4
    let BOARD[$POS+2]=$4

elif [[ $3 -eq 1 || $3 -eq 3 ]]
then
    let BOARD[$POS-10]=$4
    let BOARD[$POS]=$4
    let BOARD[$POS+10]=$4
    let BOARD[$POS+20]=$4
fi
}

function Action_One
{
# Define these as local
typeset -i POS STATUS=1

# Wipe the piece from array
Define_or_Wipe_One $CURX $CURY $CUR_ROTATION 0

# Check board boundaries
if [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && $NEWX -lt 20 ]]
then
    NEWX=20
fi
if [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && $NEWX -gt 140 ]]
then
    NEWX=140
fi
if [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && $NEWX -gt 180 ]]
then
    NEWX=180
fi
if [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && $NEWY -lt 20 ]]
then
    NEWY=20
fi
if [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && $NEWY -gt 480 ]]
then
    NEWY=480; STATUS=0
fi
if [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && $NEWY -gt 440 ]]
then
    NEWY=440; STATUS=0; CURY=$NEWY; CUR_ROTATION=$NEW_ROTATION
fi

# Calculate new position on board array
let POS=$NEWX/20+$NEWY/2

# Check if move to left or right was legal
if [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && ${BOARD[$POS-1]} -ne 0 && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && ${BOARD[$POS+2]} -ne 0 && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
elif [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && (${BOARD[$POS-10]} -ne 0 || ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+10]} -ne 0 || ${BOARD[$POS+20]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && (${BOARD[$POS-10]} -ne 0 || ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+10]} -ne 0 || ${BOARD[$POS+20]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
fi

# Recalculate new position on board array
let POS=$NEWX/20+$NEWY/2

# Now check if all new positions are available
if [[ $NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2 ]]
then
    if [[ ${BOARD[$POS-1]} -ne 0 || ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS+2]} -ne 0 ]]
    then
	STATUS=0
    fi

elif [[ $NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3 ]]
then
    if [[ ${BOARD[$POS-10]} -ne 0 || ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+10]} -ne 0 || ${BOARD[$POS+20]} -ne 0 ]]
    then
	STATUS=0
    fi
fi

# If all positions are available, draw piece '1' on new coordnates in array, set returnvalue
if [[ $STATUS -eq 1 ]]
then
    Define_or_Wipe_One $NEWX $NEWY $NEW_ROTATION 1
    PIECE=1
else
    # If not, draw piece '1' on old coordinates in array, set returnvalue
    Define_or_Wipe_One $CURX $CURY $CUR_ROTATION 1
    if [[ $CUR_ROTATION -eq $NEW_ROTATION ]]
    then
	PIECE=0
    else
	NEW_ROTATION=$CUR_ROTATION
    fi
fi
}

#----------------------------------------------------------------------------------------
#
# The  'OO' piece - code 2
#	'OO'
#----------------------------------------------------------------------------------------
#
# $1 = X, $2 = Y, $3 = ROTATION, $4 = 0/3
#

function Define_or_Wipe_Two
{
# Define these as local
typeset -i POS X Y

# Assign the arguments
X=$1; Y=$2

# Calculate position on board array
let POS=$X/20+$Y/2

# Determine position, then wipe or draw
if [[ $3 -eq 0 || $3 -eq 2 ]]
then
    let BOARD[$POS]=$4
    let BOARD[$POS+1]=$4
    let BOARD[$POS+11]=$4
    let BOARD[$POS+12]=$4

elif [[ $3 -eq 1 || $3 -eq 3 ]]
then
    let BOARD[$POS]=$4
    let BOARD[$POS+9]=$4
    let BOARD[$POS+10]=$4
    let BOARD[$POS+19]=$4
fi
}

function Action_Two
{
# Define these as local
typeset -i POS STATUS=1

# Wipe the piece from array
Define_or_Wipe_Two $CURX $CURY $CUR_ROTATION 0

# Check board boundaries
if [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && $NEWX -gt 140 ]]
then
    NEWX=140
fi
if [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && $NEWX -gt 180 ]]
then
    NEWX=180
fi
if [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && $NEWX -lt 20 ]]
then
    NEWX=20
fi
if [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && $NEWY -gt 460 ]]
then
    NEWY=460; STATUS=0
fi
if [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && $NEWY -gt 440 ]]
then
    NEWY=440; STATUS=0; CURY=$NEWY; CUR_ROTATION=$NEW_ROTATION
fi

# Calculate new position on board array
let POS=$NEWX/20+$NEWY/2

# Check if move to left or right was legal
if [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS+11]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && (${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS+12]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
elif [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS+9]} -ne 0 || ${BOARD[$POS+19]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS+10]} -ne 0 || ${BOARD[$POS+19]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
fi

# Recalculate new position on board array
let POS=$NEWX/20+$NEWY/2

# Now check if all new positions are available
if [[ $NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2 ]]
then
    if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS+11]} -ne 0 || ${BOARD[$POS+12]} -ne 0 ]]
    then
	STATUS=0
    fi

elif [[ $NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3 ]]
then
    if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+9]} -ne 0 || ${BOARD[$POS+10]} -ne 0 || ${BOARD[$POS+19]} -ne 0 ]]
    then
	STATUS=0
    fi
fi

# If all positions are available, draw piece '2' on new coordnates in array, set returnvalue
if [[ $STATUS -eq 1 ]]
then
    Define_or_Wipe_Two $NEWX $NEWY $NEW_ROTATION 2
    PIECE=2
else
    # If not, draw piece '2' on old coordinates in array, set returnvalue
    Define_or_Wipe_Two $CURX $CURY $CUR_ROTATION 2
    if [[ $CUR_ROTATION -eq $NEW_ROTATION ]]
    then
	PIECE=0
    else
	NEW_ROTATION=$CUR_ROTATION
    fi
fi
}

#----------------------------------------------------------------------------------------
#
# The  'OO' piece - code 3
#     'OO'
#
#----------------------------------------------------------------------------------------
#
# $1 = X, $2 = Y, $3 = ROTATION, $4 = 0/3
#
function Define_or_Wipe_Three
{
# Define these as local
typeset -i POS X Y

# Assign the arguments
X=$1; Y=$2

# Calculate position on board array
let POS=$X/20+$Y/2

# Determine position, then wipe or draw
if [[ $3 -eq 0 || $3 -eq 2 ]]
then
    let BOARD[$POS]=$4
    let BOARD[$POS+1]=$4
    let BOARD[$POS-8]=$4
    let BOARD[$POS-9]=$4

elif [[ $3 -eq 1 || $3 -eq 3 ]]
then
    let BOARD[$POS]=$4
    let BOARD[$POS+10]=$4
    let BOARD[$POS+11]=$4
    let BOARD[$POS+21]=$4
fi
}

function Action_Three
{
# Define these as local
typeset -i POS STATUS=1

# Wipe the piece from array
Define_or_Wipe_Three $CURX $CURY $CUR_ROTATION 0

# Check board boundaries
if [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && $NEWX -gt 140 ]]
then
    NEWX=140
fi
if [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && $NEWX -gt 160 ]]
then
    NEWX=160
fi
if [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && $NEWY -gt 480 ]]
then
    NEWY=480; STATUS=0
fi
if [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && $NEWY -gt 440 ]]
then
    NEWY=440; STATUS=0; CURY=$NEWY; CUR_ROTATION=$NEW_ROTATION
fi

# Calculate new position on board array
let POS=$NEWX/20+$NEWY/2

# Check if move to left or right was legal
if [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS-9]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && (${BOARD[$POS-8]} -ne 0 || ${BOARD[$POS+1]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
elif [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS+10]} -ne 0 || ${BOARD[$POS+21]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS+11]} -ne 0 || ${BOARD[$POS+21]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
fi

# Recalculate new position on board array
let POS=$NEWX/20+$NEWY/2

# Now check if all new positions are available
if [[ $NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2 ]]
then
    if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS-8]} -ne 0 || ${BOARD[$POS-9]} -ne 0 ]]
    then
	STATUS=0
    fi

elif [[ $NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3 ]]
then
    if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+10]} -ne 0 || ${BOARD[$POS+11]} -ne 0 || ${BOARD[$POS+21]} -ne 0 ]]
    then
	STATUS=0
    fi
fi

# If all positions are available, draw piece '3' on new coordnates in array, set returnvalue
if [[ $STATUS -eq 1 ]]
then
    Define_or_Wipe_Three $NEWX $NEWY $NEW_ROTATION 3
    PIECE=3
else
    # If not, draw piece '3' on old coordinates in array, set returnvalue
    Define_or_Wipe_Three $CURX $CURY $CUR_ROTATION 3
    if [[ $CUR_ROTATION -eq $NEW_ROTATION ]]
    then
	PIECE=0
    else
	NEW_ROTATION=$CUR_ROTATION
    fi
fi
}

#----------------------------------------------------------------------------------------
#
# The  'OO' piece - code 4
#      'OO'
#
#----------------------------------------------------------------------------------------
#
# $1 = X, $2 = Y, $3 = ROTATION, $4 = 0/3
#
function Define_or_Wipe_Four
{
# Define these as local
typeset -i POS X Y

# Assign the arguments
X=$1; Y=$2

# Calculate position on board array
let POS=$X/20+$Y/2

# Wipe or draw
let BOARD[$POS]=$4
let BOARD[$POS+1]=$4
let BOARD[$POS+10]=$4
let BOARD[$POS+11]=$4
}

function Action_Four
{
# Define these as local
typeset -i POS STATUS=1

# Wipe the piece from array
Define_or_Wipe_Four $CURX $CURY $CUR_ROTATION 0

# Check board boundaries
if [[ $NEWX -gt 160 ]]
then
    NEWX=160
fi
if [[ $NEWY -gt 460 ]]
then
    NEWY=460; STATUS=0
fi

# Calculate new position on board array
let POS=$NEWX/20+$NEWY/2

# Check if move to left or right was legal
if [[ (${BOARD[$POS]} -ne 0 || ${BOARD[$POS+10]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ (${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS+11]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
fi

# Recalculate new position on board array
let POS=$NEWX/20+$NEWY/2

# Now check if all new positions are available
if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS+10]} -ne 0 || ${BOARD[$POS+11]} -ne 0 ]]
then
    STATUS=0
fi

# If all positions are available, draw piece '4' on new coordnates in array, set returnvalue
if [[ $STATUS -eq 1 ]]
then
    Define_or_Wipe_Four $NEWX $NEWY $NEW_ROTATION 4
    PIECE=4
else
    # If not, draw piece '4' on old coordinates in array, set returnvalue
    Define_or_Wipe_Four $CURX $CURY $CUR_ROTATION 4
    if [[ $CUR_ROTATION -eq $NEW_ROTATION ]]
    then
	PIECE=0
    else
	NEW_ROTATION=$CUR_ROTATION
    fi
fi
}

#----------------------------------------------------------------------------------------
#
# The  'OOO' piece - code 5
#       'O'
#
#----------------------------------------------------------------------------------------
#
# $1 = X, $2 = Y, $3 = ROTATION, $4 = 0/3
#
function Define_or_Wipe_Five
{
# Define these as local
typeset -i POS X Y

# Assign the arguments
X=$1; Y=$2

# Calculate position on board array
let POS=$X/20+$Y/2

# Determine position, then wipe or draw
if [[ $3 -eq 0 ]]
then
    let BOARD[$POS]=$4
    let BOARD[$POS+1]=$4
    let BOARD[$POS+2]=$4
    let BOARD[$POS+11]=$4

elif [[ $3 -eq 1 ]]
then
    let BOARD[$POS]=$4
    let BOARD[$POS+1]=$4
    let BOARD[$POS-9]=$4
    let BOARD[$POS+11]=$4

elif [[ $3 -eq 2 ]]
then
    let BOARD[$POS]=$4
    let BOARD[$POS+1]=$4
    let BOARD[$POS+2]=$4
    let BOARD[$POS-9]=$4

elif [[ $3 -eq 3 ]]
then
    let BOARD[$POS]=$4
    let BOARD[$POS+1]=$4
    let BOARD[$POS-10]=$4
    let BOARD[$POS+10]=$4
fi
}

function Action_Five
{
# Define these as local
typeset -i POS STATUS=1

# Wipe the piece from array
Define_or_Wipe_Five $CURX $CURY $CUR_ROTATION 0

# Check board boundaries
if [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && $NEWX -gt 140 ]]
then
    NEWX=140
fi
if [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && $NEWX -gt 160 ]]
then
    NEWX=160
fi
if [[ $NEW_ROTATION -eq 1 && $NEWY -lt 20 ]]
then
    NEWY=20
fi
if [[ $NEW_ROTATION -eq 0 && $NEWY -gt 460 ]]
then
    NEWY=460; STATUS=0
fi
if [[ $NEW_ROTATION -eq 2 && $NEWY -gt 480 ]]
then
    NEWY=480; STATUS=0
fi
if [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && $NEWY -gt 460 ]]
then
    NEWY=460; STATUS=0; CURY=$NEWY; CUR_ROTATION=$NEW_ROTATION
fi

# Calculate new position on board array
let POS=$NEWX/20+$NEWY/2

# Check if move to left or right was legal
if [[ $NEW_ROTATION -eq 0 && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS+11]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 0 && (${BOARD[$POS+2]} -ne 0 || ${BOARD[$POS+11]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 1 && (${BOARD[$POS-9]} -ne 0 || ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+11]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 1 && (${BOARD[$POS-9]} -ne 0 || ${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS+11]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 2 && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS-9]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 2 && (${BOARD[$POS+2]} -ne 0 || ${BOARD[$POS-9]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 3 && (${BOARD[$POS-10]} -ne 0 || ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+10]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 3 && (${BOARD[$POS-10]} -ne 0 || ${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS+10]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
fi

# Recalculate new position on board array
let POS=$NEWX/20+$NEWY/2

# Now check if all new positions are available
if [[ $NEW_ROTATION -eq 0 ]]
then
    if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS+2]} -ne 0 || ${BOARD[$POS+11]} -ne 0 ]]
    then
	STATUS=0
    fi

elif [[ $NEW_ROTATION -eq 1 ]]
then
    if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS-9]} -ne 0 || ${BOARD[$POS+11]} -ne 0 ]]
    then
	STATUS=0
    fi

elif [[ $NEW_ROTATION -eq 2 ]]
then
    if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS+2]} -ne 0 || ${BOARD[$POS-9]} -ne 0 ]]
    then
	STATUS=0
    fi

elif [[ $NEW_ROTATION -eq 3 ]]
then
    if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS-10]} -ne 0 || ${BOARD[$POS+10]} -ne 0 ]]
    then
	STATUS=0
    fi
fi

# If all positions are available, draw piece '5' on new coordnates in array, set returnvalue
if [[ $STATUS -eq 1 ]]
then
    Define_or_Wipe_Five $NEWX $NEWY $NEW_ROTATION 5
    PIECE=5
else
    # If not, draw piece '5' on old coordinates in array, set returnvalue
    Define_or_Wipe_Five $CURX $CURY $CUR_ROTATION 5
    if [[ $CUR_ROTATION -eq $NEW_ROTATION ]]
    then
	PIECE=0
    else
	NEW_ROTATION=$CUR_ROTATION
    fi
fi
}

#----------------------------------------------------------------------------------------
#
# The  'OOO' piece - code 6
#      'O'
#
#----------------------------------------------------------------------------------------
#
# $1 = X, $2 = Y, $3 = ROTATION, $4 = 0/3
#
function Define_or_Wipe_Six
{
# Define these as local
typeset -i POS X Y

# Assign the arguments
X=$1; Y=$2

# Calculate position on board array
let POS=$X/20+$Y/2

# Determine position, then wipe or draw
if [[ $3 -eq 0 ]]
then
    let BOARD[$POS]=$4
    let BOARD[$POS+1]=$4
    let BOARD[$POS+2]=$4
    let BOARD[$POS+10]=$4

elif [[ $3 -eq 1 ]]
then
    let BOARD[$POS]=$4
    let BOARD[$POS+1]=$4
    let BOARD[$POS+11]=$4
    let BOARD[$POS+21]=$4

elif [[ $3 -eq 2 ]]
then
    let BOARD[$POS]=$4
    let BOARD[$POS+1]=$4
    let BOARD[$POS+2]=$4
    let BOARD[$POS-8]=$4

elif [[ $3 -eq 3 ]]
then
    let BOARD[$POS]=$4
    let BOARD[$POS+10]=$4
    let BOARD[$POS+20]=$4
    let BOARD[$POS+21]=$4
fi
}

function Action_Six
{
# Define these as local
typeset -i POS STATUS=1

# Wipe the piece from array
Define_or_Wipe_Six $CURX $CURY $CUR_ROTATION 0

# Check board boundaries
if [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && $NEWX -gt 140 ]]
then
    NEWX=140
fi
if [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && $NEWX -gt 160 ]]
then
    NEWX=160
fi
if [[ $NEW_ROTATION -eq 2 && $NEWY -lt 40 ]]
then
    NEWY=40
fi
if [[ $NEW_ROTATION -eq 0 && $NEWY -gt 460 ]]
then
    NEWY=460; STATUS=0
fi
if [[ $NEW_ROTATION -eq 2 && $NEWY -gt 480 ]]
then
    NEWY=480; STATUS=0
fi
if [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && $NEWY -gt 440 ]]
then
    NEWY=440; STATUS=0; CURY=$NEWY; CUR_ROTATION=$NEW_ROTATION
fi

# Calculate new position on board array
let POS=$NEWX/20+$NEWY/2

# Check if move to left or right was legal
if [[ $NEW_ROTATION -eq 0 && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS+10]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 0 && (${BOARD[$POS+2]} -ne 0 || ${BOARD[$POS+10]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 1 && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS+11]} -ne 0 || ${BOARD[$POS+21]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 1 && (${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS+11]} -ne 0 || ${BOARD[$POS+21]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 2 && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS-8]} -ne 0 )&& $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 2 && (${BOARD[$POS+2]} -ne 0 || ${BOARD[$POS-8]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 3 && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS+10]} -ne 0 || ${BOARD[$POS+20]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 3 && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS+10]} -ne 0 || ${BOARD[$POS+21]} -ne 0 ) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
fi

# Recalculate new position on board array
let POS=$NEWX/20+$NEWY/2

# Now check if all new positions are available
if [[ $NEW_ROTATION -eq 0 ]]
then
    if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS+2]} -ne 0 || ${BOARD[$POS+10]} -ne 0 ]]
    then
	STATUS=0
    fi

elif [[ $NEW_ROTATION -eq 1 ]]
then
    if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS+11]} -ne 0 || ${BOARD[$POS+21]} -ne 0 ]]
    then
	STATUS=0
    fi

elif [[ $NEW_ROTATION -eq 2 ]]
then
    if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS+2]} -ne 0 || ${BOARD[$POS-8]} -ne 0 ]]
    then
	STATUS=0
    fi

elif [[ $NEW_ROTATION -eq 3 ]]
then
    if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+10]} -ne 0 || ${BOARD[$POS+20]} -ne 0 || ${BOARD[$POS+21]} -ne 0 ]]
    then
	STATUS=0
    fi
fi

# If all positions are available, draw piece '6' on new coordnates in array, set returnvalue
if [[ $STATUS -eq 1 ]]
then
    Define_or_Wipe_Six $NEWX $NEWY $NEW_ROTATION 6
    PIECE=6
else
    # If not, draw piece '6' on old coordinates in array, set returnvalue
    Define_or_Wipe_Six $CURX $CURY $CUR_ROTATION 6
    if [[ $CUR_ROTATION -eq $NEW_ROTATION ]]
    then
	PIECE=0
    else
	NEW_ROTATION=$CUR_ROTATION
    fi
fi
}

#----------------------------------------------------------------------------------------
#
# The  'OOO' piece - code 7
#        'O'
#
#----------------------------------------------------------------------------------------
#
# $1 = X, $2 = Y, $3 = ROTATION, $4 = 0/3
#
function Define_or_Wipe_Seven
{
# Define these as local
typeset -i POS X Y

# Assign the arguments
X=$1; Y=$2

# Calculate position on board array
let POS=$X/20+$Y/2

# Determine position, then wipe or draw
if [[ $3 -eq 0 ]]
then
    let BOARD[$POS]=$4
    let BOARD[$POS+1]=$4
    let BOARD[$POS+2]=$4
    let BOARD[$POS+12]=$4

elif [[ $3 -eq 1 ]]
then
    let BOARD[$POS]=$4
    let BOARD[$POS+1]=$4
    let BOARD[$POS-9]=$4
    let BOARD[$POS-19]=$4

elif [[ $3 -eq 2 ]]
then
    let BOARD[$POS]=$4
    let BOARD[$POS+10]=$4
    let BOARD[$POS+11]=$4
    let BOARD[$POS+12]=$4

elif [[ $3 -eq 3 ]]
then
    let BOARD[$POS]=$4
    let BOARD[$POS+1]=$4
    let BOARD[$POS+10]=$4
    let BOARD[$POS+20]=$4
fi
}

function Action_Seven
{
# Define these as local
typeset -i POS STATUS=1

# Wipe the piece from array
Define_or_Wipe_Seven $CURX $CURY $CUR_ROTATION 0

# Check board boundaries
if [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && $NEWX -gt 140 ]]
then
    NEWX=140
fi
if [[ ($NEW_ROTATION -eq 1 || $NEW_ROTATION -eq 3) && $NEWX -gt 160 ]]
then
    NEWX=160
fi
if [[ ($NEW_ROTATION -eq 0 || $NEW_ROTATION -eq 2) && $NEWY -gt 460 ]]
then
    NEWY=460; STATUS=0
fi
if [[ $NEW_ROTATION -eq 1 && $NEWY -lt 40 ]]
then
    NEWY=40
fi
if [[ $NEW_ROTATION -eq 1 && $NEWY -gt 480 ]]
then
    NEWY=480; STATUS=0
fi
if [[ $NEW_ROTATION -eq 3 && $NEWY -gt 440 ]]
then
    NEWY=440; STATUS=0; CURY=$NEWY; CUR_ROTATION=$NEW_ROTATION
fi

# Calculate new position on board array
let POS=$NEWX/20+$NEWY/2

# Check if move to left or right was legal
if [[ $NEW_ROTATION -eq 0 && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS+12]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 0 && (${BOARD[$POS+2]} -ne 0 || ${BOARD[$POS+12]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 1 && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS-9]} -ne 0 || ${BOARD[$POS-19]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 1 && (${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS-9]} -ne 0 || ${BOARD[$POS-19]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 2 && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS+10]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 2 && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS+12]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 3 && (${BOARD[$POS]} -ne 0 || ${BOARD[$POS+10]} -ne 0 || ${BOARD[$POS+20]} -ne 0) && $NEWX -lt $CURX ]]
then
    NEWX=$CURX
elif [[ $NEW_ROTATION -eq 3 && (${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS+10]} -ne 0 || ${BOARD[$POS+20]} -ne 0) && $NEWX -gt $CURX ]]
then
    NEWX=$CURX
fi

# Recalculate new position on board array
let POS=$NEWX/20+$NEWY/2

# Now check if all new positions are available
if [[ $NEW_ROTATION -eq 0 ]]
then
    if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS+2]} -ne 0 || ${BOARD[$POS+12]} -ne 0 ]]
    then
	STATUS=0
    fi

elif [[ $NEW_ROTATION -eq 1 ]]
then
    if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS-9]} -ne 0 || ${BOARD[$POS-19]} -ne 0 ]]
    then
	STATUS=0
    fi

elif [[ $NEW_ROTATION -eq 2 ]]
then
    if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+10]} -ne 0 || ${BOARD[$POS+11]} -ne 0 || ${BOARD[$POS+12]} -ne 0 ]]
    then
	STATUS=0
    fi

elif [[ $NEW_ROTATION -eq 3 ]]
then
    if [[ ${BOARD[$POS]} -ne 0 || ${BOARD[$POS+1]} -ne 0 || ${BOARD[$POS+10]} -ne 0 || ${BOARD[$POS+20]} -ne 0 ]]
    then
	STATUS=0
    fi
fi

# If all positions are available, draw piece '7' on new coordnates in array, set returnvalue
if [[ $STATUS -eq 1 ]]
then
    Define_or_Wipe_Seven $NEWX $NEWY $NEW_ROTATION 7
    PIECE=7
else
    # If not, draw piece '7' on old coordinates in array, set returnvalue
    Define_or_Wipe_Seven $CURX $CURY $CUR_ROTATION 7
    if [[ $CUR_ROTATION -eq $NEW_ROTATION ]]
    then
	PIECE=0
    else
	NEW_ROTATION=$CUR_ROTATION
    fi
fi
}

#----------------------------------------------------------------------------------------
#
# Setup the board array
#
#----------------------------------------------------------------------------------------

function Init_Board
{
typeset -i COUNT=0

until [[ $COUNT -eq 250 ]]
do
    let BOARD[$COUNT]=0
    ((COUNT+=1))
done
}

#----------------------------------------------------------------------------------------
#
# Clear the cache
#
#----------------------------------------------------------------------------------------

function Clear_Cache
{
typeset -i COUNT=0

until [[ $COUNT -eq 250 ]]
do
    let CACHE[$COUNT]=-1
    ((COUNT+=1))
done
}

#----------------------------------------------------------------------------------------
#
# Draw BOARD array on canvas
#
#----------------------------------------------------------------------------------------

function Draw_Board
{
typeset -i X=0 Y=0 POS=0

# Set canvas to draw
u_draw $CANVAS

# Check each position
until [[ $Y -gt 500 ]]
do
    # Calculate position in array
    let POS=$X/20+$Y/2+10

    # If position is occupied, draw
    if [[ ${BOARD[$POS]} -ne ${CACHE[$POS]} ]]
    then
	# If position is occupied, draw
	case ${BOARD[$POS]} in

	    0)
		u_square "#FFFFFF" $X $Y 20 20 1;;
	    1)
		u_square "#22CCCC" $X $Y 19 19 1;;
	    2)
		u_square "#FF2222" $X $Y 19 19 1;;
	    3)
		u_square "#22FF22" $X $Y 19 19 1;;
	    4)
		u_square "#DDDD00" $X $Y 19 19 1;;
	    5)
		u_square "#FF22FF" $X $Y 19 19 1;;
	    6)
		u_square "#FFA500" $X $Y 19 19 1;;
	    7)
		u_square "#2222FF" $X $Y 19 19 1;;
	esac

	# Copy to cache board
	CACHE[$POS]=${BOARD[$POS]}
    fi

    # Go to next position in array
    ((X+=20))
    if [[ $X -gt 180 ]]
    then
        X=0
        ((Y+=20))
    fi
done

# Draw text on canvas if paused
if [[ $CONDITION -eq 1 ]]
then
    u_out "\"'Game paused'\"" "#0000FF" "#FFFFFF" 60 200
    u_out "\"'Press <p> to continue'\"" "#4444FF" "#FFFFFF" 35 240

# Game over
elif [[ $CONDITION -eq 2 ]]
then
    POS=200
    u_out "\"'Game over!'\"" "#0000FF" "#FFFFFF" 60 $POS

    # Check score
    define HIGH u_label_grab $HLABEL

    if [[ $HIGH -lt $SCORE ]]
    then
	((POS+=40))
	u_out "\"'New highscore: $SCORE'\"" "#4444FF" "#FFFFFF" 40 $POS
	# Save score
	echo $SCORE > $HOME/.tetris.sh
    fi

    ((POS+=40))
    u_out "\"'Press refresh to start again'\"" "#0000FF" "#FFFFFF" 20 $POS
fi
}

#----------------------------------------------------------------------------------------
#
# Generate new piece, $1 contains piece
#
#----------------------------------------------------------------------------------------

function Draw_New
{
# Set canvas to draw
u_draw $EXAMPLE

# Wipe the preview canvas
u_square "#FFFFFF" 0 0 100 60 1

# Select piece
case $1 in
    1)
	u_square "#22CCCC" 10 20 19 19 1
	u_square "#22CCCC" 30 20 19 19 1
	u_square "#22CCCC" 50 20 19 19 1
	u_square "#22CCCC" 70 20 19 19 1;;
    2)
	u_square "#FF2222" 20 10 19 19 1
	u_square "#FF2222" 40 10 19 19 1
	u_square "#FF2222" 40 30 19 19 1
	u_square "#FF2222" 60 30 19 19 1;;
    3)
	u_square "#22FF22" 20 30 19 19 1
	u_square "#22FF22" 40 30 19 19 1
	u_square "#22FF22" 40 10 19 19 1
	u_square "#22FF22" 60 10 19 19 1;;
    4)
	u_square "#DDDD00" 30 10 19 19 1
	u_square "#DDDD00" 50 10 19 19 1
	u_square "#DDDD00" 30 30 19 19 1
	u_square "#DDDD00" 50 30 19 19 1;;
    5)
	u_square "#FF22FF" 20 10 19 19 1
	u_square "#FF22FF" 40 10 19 19 1
	u_square "#FF22FF" 60 10 19 19 1
	u_square "#FF22FF" 40 30 19 19 1;;
    6)
	u_square "#FFA500" 20 10 19 19 1
	u_square "#FFA500" 40 10 19 19 1
	u_square "#FFA500" 60 10 19 19 1
	u_square "#FFA500" 20 30 19 19 1;;
    7)
	u_square "#2222FF" 20 10 19 19 1
	u_square "#2222FF" 40 10 19 19 1
	u_square "#2222FF" 60 10 19 19 1
	u_square "#2222FF" 60 30 19 19 1;;

esac
}

#----------------------------------------------------------------------------------------
#
# Generate new piece
#
#----------------------------------------------------------------------------------------

function New_Piece
{
# Define rotation of current piece
CUR_ROTATION=0; NEW_ROTATION=0; RAND=0

# Get random number
until [[ $RAND -ne 0 ]]
do
    ((RAND=${RANDOM}&7))
done

# Put current piece on BOARD array
case $RAND in
    1)
	FX=60; FY=0
	Draw_New 1;;

    2) 
	FX=80; FY=0
	Draw_New 2;;

    3)
	FX=80; FY=20
	Draw_New 3;;

    4)
	FX=80; FY=0
	Draw_New 4;;

    5)
	FX=80; FY=0
	Draw_New 5;;

    6)
	FX=80; FY=0
	Draw_New 6;;

    7)
	FX=80; FY=0
	Draw_New 7;;

esac

# Put back original timeout (if drop was active)
u_timeout $WINDOW ${LEVELS[$CURLEVEL]}
}

#----------------------------------------------------------------------------------------
#
# Check if there is a full row
#
#----------------------------------------------------------------------------------------

function Check_Row
{
typeset -i ROW X Z Y=1 POS=0 INC=10

# Go through all the rows
until [[ $Y -eq 25 ]]
do
    X=0; ROW=0
    until [[ $X -eq 10 ]]
    do
	let POS=$X+$Y*10
	if [[ ${BOARD[$POS]} -ne 0 ]]
	then
	    ((ROW+=1))
	fi
	((X+=1))
    done
    if [[ $ROW -eq 10 ]]
    then
	# More rows, higher level, more score!
	((SCORE+=$INC*$CURLEVEL))
	((INC+=$INC))
	((GAMELINES-=1))
	u_label_text $TLABEL $GAMELINES
	# Scroll field
	Z=$Y
	until [[ $Z -eq 0 ]]
	do
	    X=0
	    until [[ $X -eq 10 ]]
	    do
		let POS=$X+$Z*10
		BOARD[$POS]=${BOARD[$POS-10]}
		((X+=1))
	    done
	    ((Z-=1))
	done
    fi
    ((Y+=1))
done

# Check if next level is reached
if [[ $GAMELINES -le 0 ]]
then
    GAMELINES=10
    u_label_text $TLABEL $GAMELINES
    ((CURLEVEL+=1))
    u_label_text $LLABEL $CURLEVEL
    # Setup timeout on the wait-event
    u_timeout $WINDOW ${LEVELS[$CURLEVEL]}
fi
}

#--------------------------------------------------------------------- Main program

# Save my directory
MYDIR=${0%/*}

# Include the generated file to use embedded HUG functions
. ${HOME}/.hug4ksh

# Start GTK-server in STDIN mode
gtk-server -stdin |&

# Check if we can play music
TIMIDITY=`which timidity 2>/dev/null`
if [[ -z $TIMIDITY ]]
then
    echo "Timidity not found, no music!"
else
    # We can play music in the background
    $TIMIDITY -idl -A200 $MYDIR/tetris.mid >/dev/null &
    # Trap exitsignals to stop music
    trap 'kill -9 $!' QUIT EXIT TERM
fi

# Define the board array globally
set -A BOARD
Init_Board

# Define the board cache
set -A CACHE
Clear_Cache

# Define levels
set -A LEVELS 0 500 400 320 256 204 164 132 116 93 75 60 48

# Define some variables globally
typeset -i CURX CURY NEWX NEWY FX FY RAND
typeset -i GAMELINES=10 PIECE=0 CONDITION=1 SCORE=0 CURLEVEL=1 CUR_ROTATION=0 NEW_ROTATION=0

# Define GUI - mainwindow
define WINDOW u_window "\"'Korn-Tris using H.U.G.'\"" 335 500
u_bgcolor $WINDOW "#BBBBFF"
define FRAME1 u_frame 210 490
u_bgcolor $FRAME1 "#BBBBFF"
u_attach $WINDOW $FRAME1 5 5
define CANVAS u_canvas 200 480
u_attach $WINDOW $CANVAS 10 10
define FRAME2 u_frame 110 70
u_bgcolor $FRAME2 "#BBBBFF"
u_attach $WINDOW $FRAME2 220 5
define EXAMPLE u_canvas 100 60
u_attach $WINDOW $EXAMPLE 225 10
define FRAME7 u_frame 110 50
u_frame_text $FRAME7 "\"' Lines next level '\""
u_fgcolor $FRAME7 "#0000FF"
u_bgcolor $FRAME7 "#BBBBFF"
u_attach $WINDOW $FRAME7 220 80
define TLABEL u_label "10" 100 20 "0.5" "0.5"
u_fgcolor $TLABEL "#4444FF"
u_attach $WINDOW $TLABEL 225 105
define FRAME6 u_frame 110 50
u_frame_text $FRAME6 "\"' Level '\""
u_fgcolor $FRAME6 "#0000FF"
u_bgcolor $FRAME6 "#BBBBFF"
u_attach $WINDOW $FRAME6 220 140
define LLABEL u_label "1" 100 20 "0.5" "0.5"
u_fgcolor $LLABEL "#4444FF"
u_attach $WINDOW $LLABEL 225 165
define FRAME4 u_frame 110 50
u_frame_text $FRAME4 "\"' Score '\""
u_fgcolor $FRAME4 "#0000FF"
u_bgcolor $FRAME4 "#BBBBFF"
u_attach $WINDOW $FRAME4 220 200
define SLABEL u_label "0" 100 20 "0.5" "0.5"
u_fgcolor $SLABEL "#4444FF"
u_attach $WINDOW $SLABEL 225 225
define FRAME5 u_frame 110 50
u_frame_text $FRAME5 "\"' Highscore '\""
u_fgcolor $FRAME5 "#0000FF"
u_bgcolor $FRAME5 "#BBBBFF"
u_attach $WINDOW $FRAME5 220 260
define HLABEL u_label "0" 100 20 "0.5" "0.5"
u_fgcolor $HLABEL "#4444FF"
u_attach $WINDOW $HLABEL 225 285
define RESTART u_stock "gtk-refresh" 110 35
u_bgcolor $RESTART "#8888FF" "#8888FF" "#AAAAFF"
u_attach $WINDOW $RESTART 220 320
u_unfocus $RESTART
define FRAME3 u_frame 110 90
u_frame_text $FRAME3 "\"' Keys '\""
u_fgcolor $FRAME3 "#0000FF"
u_bgcolor $FRAME3 "#BBBBFF"
u_attach $WINDOW $FRAME3 220 360
define LABEL1 u_label "\"'cursor: move'\"" 100 20 "0.1" "0.5"
u_fgcolor $LABEL1 "#4444FF"
u_attach $WINDOW $LABEL1 225 385
define LABEL2 u_label "\"'space: drop'\"" 100 20 "0.1" "0.5"
u_fgcolor $LABEL2 "#4444FF"
u_attach $WINDOW $LABEL2 225 405
define LABEL3 u_label "\"'p key: pause'\"" 100 20 "0.1" "0.5"
u_fgcolor $LABEL3 "#4444FF"
u_attach $WINDOW $LABEL3 225 425
define EXIT u_stock "gtk-quit" 110 35
u_bgcolor $EXIT "#8888FF" "#8888FF" "#AAAAFF"
u_attach $WINDOW $EXIT 220 460
u_unfocus $EXIT

# Set highscore
if [[ -f $HOME/.tetris.sh ]]
then
    read VAL < $HOME/.tetris.sh
    u_label_text $HLABEL $VAL
fi

# Setup timeout on the wait-event
u_timeout $WINDOW ${LEVELS[$CURLEVEL]}

# Mainloop
until [[ $EVENT = $EXIT || $KEY = 65307 ]]
do
    define EVENT u_event

    # Determine event
    case $EVENT in

	"key-press-event")

	    define KEY u_key

	    # Determine action for a pressed key
	    case $KEY in

		"65362")
		    ((NEW_ROTATION=(${NEW_ROTATION}+1)&3));;
    
		"65364")
		    ((NEW_ROTATION=(${NEW_ROTATION}-1)&3));;

		"65363")
		    ((NEWX=$CURX+20));;

		"65361")
		    if [[ $CURX -ge 20 ]]
		    then
			((NEWX=$CURX-20))
		    fi;;

		# Toggle PAUSE condition
		"112")
		    if [[ $CONDITION -eq 1 ]]
		    then
			CONDITION=0
			Clear_Cache
		    elif [[ $CONDITION -eq 0 ]]
		    then
			CONDITION=1
		    fi;;

		# Drop the piece
		"32")
		    u_timeout $WINDOW 30;;

	    esac;;

	$WINDOW)
	    if [[ $CONDITION -eq 0 ]]
	    then
		((NEWX=$CURX))
		((NEWY=$CURY+20))
	    fi;;

	$RESTART)
	    PIECE=0
	    CONDITION=1
	    SCORE=0
	    CURLEVEL=1
	    u_label_text $LLABEL $CURLEVEL
	    GAMELINES=10
	    u_label_text $TLABEL $GAMELINES
	    if [[ -f $HOME/.tetris.sh ]]
	    then
		read VAL < $HOME/.tetris.sh
	    else
		VAL=0
	    fi
	    u_label_text $HLABEL $VAL
	    u_timeout $WINDOW ${LEVELS[$CURLEVEL]}
	    Init_Board
	    Clear_Cache;;
    esac

    # Put current piece on BOARD array
    case $PIECE in
	1) Action_One;;
	2) Action_Two;;
	3) Action_Three;;
	4) Action_Four;;
	5) Action_Five;;
	6) Action_Six;;
	7) Action_Seven;;
    esac

    # Assign the new coordinates
    if [[ $PIECE -gt 0 ]]
    then
        CURX=$NEWX
        CURY=$NEWY
	CUR_ROTATION=$NEW_ROTATION
	((ABLETOMOVE+=1))

    # Check end game, check row and we need a new piece
    else
	if [[ $ABLETOMOVE -eq 0 && $CONDITION -eq 0 ]]
	then
	    CONDITION=2
	fi
	Check_Row
	PIECE=$RAND
	CURX=$FX; CURY=$FY; NEWX=$CURX; NEWY=$CURY
	New_Piece
	if [[ $CONDITION -eq 1 ]]
	then
	    ((NEWY+=20))
	fi
	ABLETOMOVE=0
    fi

    # Finally, draw the array on the screen
    Draw_Board

    # Update score
    u_label_text $SLABEL $SCORE

done

# Release graphical resources
u_end
