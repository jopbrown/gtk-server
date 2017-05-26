#-----------------------------------------------------------------------------
#
# Listen to Internet Radio. Tested with mpg123 version 1.22.4.
#
# (c) Peter van Eerten, May 2017 - GPL.
#
#-----------------------------------------------------------------------------

# Disable file globbing
set -f

# Save my directory
MYDIR="."
if [[ $0 = +(*/*) ]]
then
    MYDIR=${0%/*}
fi

#------------------------- Start MPG123

# Name of mpg123 PIPE file
typeset FIFO=/tmp/mpg.fifo.$$

# Verify availability of MPG123
MPG123=$(which mpg123 2>/dev/null)
if [[ -z $MPG123 ]]
then
    echo "ERROR: no 'mpg123' binary found! Please install mpg123 first. Exiting..."
    exit 1
fi

# Start mpg123
if [[ -p $FIFO ]]
then
    rm $FIFO
fi
$MPG123 -R --fifo $FIFO >/dev/null 2>&1 &

# Make sure the FIFO file is available
while [ ! -p $FIFO ]; do continue; done

#------------------------- Start GTK-server

# Start gtk-server
gtk-server-gtk3 -stdin |&

#------------------------- Check WGET

# Verify availability of WGET
WGET=$(which wget 2>/dev/null)
if [[ -z $WGET ]]
then
    echo "WARNING: no 'wget' binary found! Cannot show the name of current stream and .m3u .pls lists are not supported."
fi

typeset CFG=~/.radio.cfg

typeset -i COUNTER=0 TOGGLE=0

#------------------------ Communication functions for GTK-server

function gtk
{
    print -p $1
    read -p GTK
}

function define
{
    $2 "$3"
    eval $1="'$GTK'"
}

#------------------------ Read config in array

function read_config_from_file()
{
    let COUNTER=0

    if [[ -f $CFG ]]
    then
        while read LINE
        do
            if [[ $LINE = +(name=*) ]]
            then
                name[$COUNTER]=${LINE#*name=}
            fi
            if [[ $LINE = +(url=*) ]]
            then
                if [[ $LINE = +(*.m3u) || $LINE = +(*.pls) ]]
                then
                    if [[ -n $WGET ]]
                    then
                        link[$COUNTER]=$($WGET --timeout=1 --tries=1 ${LINE#*url=} -O - 2>/dev/null | grep http | head -1 | cut -d= -f2)
                        if [[ -z ${link[$COUNTER]} ]]
                        then
                            gtk "m_show $ERR"
                        fi
                    else
                        link[$COUNTER]=localhost
                    fi
                else
                    if [[ ${LINE} = +(*aac*) ]]
                    then
                        gtk "m_show $ERR"
                        name[$COUNTER]=
                    else
                        link[$COUNTER]=${LINE#*url=}
                    fi
                fi
            fi
            if [[ $LINE = +(#*) && -n ${link[$COUNTER]} ]]
            then
                ((COUNTER+=1))
            fi
        done < $CFG
    fi
}

#------------------------ Set configfile into a list

function add_stations_to_list()
{
    typeset -i CTR

    let CTR=0

    until [[ $CTR -eq $COUNTER ]]
    do
        if [[ -n ${name[$CTR]} ]]
        then
            gtk "m_list_text $LST \"'${name[$CTR]}'\""
        fi
        ((CTR+=1))
    done
}

#------------------------ Save all stations to config in alphabetical order

function save_stations_to_file()
{
    typeset -i CTR SORT IDX
    typeset NAME

    rm -f $CFG

    let SORT=0

    while [[ $SORT -lt $COUNTER ]]
    do
        let CTR=0

        until [[ $CTR -eq $COUNTER ]]
        do
            if [[ -n ${name[$CTR]} ]]
            then
                break
            else
                ((CTR+=1))
            fi
        done
        
        NAME=${name[$CTR]}

        let IDX=$CTR

        let CTR=0
            
        until [[ $CTR -eq $COUNTER ]]
        do
            if [[ -n ${name[$CTR]} && ${name[$CTR]} < $NAME ]]
            then
                NAME=${name[$CTR]}
                IDX=$CTR
            fi
            ((CTR+=1))
        done

        echo "name=${name[$IDX]}" | tr -d '\r' >> $CFG
        name[$IDX]=
        echo "url=${link[$IDX]}" | tr -d '\r' >> $CFG
        link[$IDX]=
        echo "#" >> $CFG

        ((SORT+=1))
    done
}

#------------------------ Obtain stream title

function get_title_from_stream()
{
    typeset DATA TITLE RESULT

    if [[ -n $WGET ]]
    then
        DATA=$($WGET --timeout=1 --tries=1 --header='Icy-Metadata: 1' ${link[$CURRENT]} -O - 2>/dev/null | head -c 65536 | strings)
        if [[ $DATA == *StreamTitle* ]]
        then
            TITLE=${DATA##*StreamTitle=}
            RESULT=$(echo ${TITLE%%;*} | tr -d '\042\047')
        else
            RESULT=${link[$CURRENT]}
        fi
    else
        RESULT=${link[$CURRENT]}
    fi

    if [[ ${#RESULT} -le 2 ]]
    then
        RESULT=${link[$CURRENT]}
    fi

    echo "'$RESULT'"
}
#------------------------ Main starts here

# Define GUI - mainwindow
define WIN gtk "m_window \"'GTK-server Internet Radio'\" 400 320"
# Attach frame #1
define FRAME1 gtk "m_frame 220 260"
gtk "m_attach $WIN $FRAME1 5 5"
gtk "m_frame_text $FRAME1 \"' Stations '\""
# Define list
define LST gtk "m_list 200 190"
gtk "m_attach $WIN $LST 15 25"
# Buttons
define ADD gtk "m_stock gtk-add 90 30"
gtk "m_attach $WIN $ADD 15 225"
define DEL gtk "m_stock gtk-delete 90 30"
gtk "m_attach $WIN $DEL 125 225"
# Attach frame #2
define FRAME2 gtk "m_frame 165 60"
gtk "m_attach $WIN $FRAME2 230 5"
gtk "m_frame_text $FRAME2 \"' Control '\""
define PLAY gtk "m_stock gtk-media-play 50 30"
gtk "m_attach $WIN $PLAY 240 25"
define PAUSE gtk "m_stock gtk-media-pause 50 30"
gtk "m_attach $WIN $PAUSE 310 25"
# Attach frame #3
define FRAME3 gtk "m_frame 165 60"
gtk "m_attach $WIN $FRAME3 230 205"
gtk "m_frame_text $FRAME3 \"' Info '\""
define ABOUT gtk "m_stock gtk-about 50 30"
gtk "m_attach $WIN $ABOUT 240 225"
define EXIT gtk "m_stock gtk-quit 50 30"
gtk "m_attach $WIN $EXIT 320 225"

# Config panel
define CONFIG gtk "m_window \"'Add Station'\" 300 180"
gtk "m_hide $CONFIG"
# Attach frame #4
define FRAME4 gtk "m_frame 290 60"
gtk "m_attach $CONFIG $FRAME4 5 5"
gtk "m_frame_text $FRAME4 \"' Name '\""
# Entry for name
define INP gtk "m_entry \"''\" 280 50"
gtk "m_attach $CONFIG $INP 10 15"
# Attach frame #5
define FRAME5 gtk "m_frame 290 60"
gtk "m_attach $CONFIG $FRAME5 5 75"
gtk "m_frame_text $FRAME5 \"' URL '\""
# Entry for url
define URL gtk "m_entry \"''\" 280 50"
gtk "m_attach $CONFIG $URL 10 85"
# Ok button
define OK gtk "m_stock gtk-ok 50 30"
gtk "m_attach $CONFIG $OK 5 145"
# Cancel button
define CANCEL gtk "m_stock gtk-cancel 50 30"
gtk "m_attach $CONFIG $CANCEL 100 145"

# About dialogue
define VER gtk "gtk_server_version"
define ABD gtk "m_dialog \"' About this program '\" \"'In memory of Qradio. Running with GTK-server $VER !'\" 300 100"

# Error dialogue
define ERR gtk "m_dialog \"' ERROR '\" \"'Provided link cannot be opened! Skipping it...'\" 300 100"

# Attach frame #6
define FRAME6 gtk "m_frame 390 45"
gtk "m_attach $WIN $FRAME6 5 270"
gtk "m_frame_text $FRAME6 \"' Stream Title '\""
define LABEL gtk "m_label \"''\" 370 40 0.5 0.5 50"
gtk "m_attach $WIN $LABEL 10 280"

# Attach frame #7
define FRAME7 gtk "m_frame 165 130"
gtk "m_attach $WIN $FRAME7 230 70"
define CANVAS gtk "m_canvas 155 100"
gtk "m_attach $WIN $CANVAS 235 90"
gtk "m_out \"'Back to Qradio'\" #0000FF #CACACA 10 80"
gtk "m_image \"'$MYDIR/radio.png'\""

read_config_from_file
add_stations_to_list

# Set a timeout 15 sec to update name of stream
gtk "m_timeout $LABEL 15000"

# Mainloop
CURRENT="-1"
while [[ $EVENT != $WIN && $EVENT != $EXIT ]]
do
    define EVENT gtk "m_event"

    case $EVENT in
        $ABOUT)
            gtk "m_show $ABD";;
        $ABD)
            gtk "m_hide $ABD";;
        $ERR)
            gtk "m_hide $ERR";;
        $ADD)
            gtk "m_show $CONFIG";;
        $DEL)
            define SEL gtk "m_list_get $LST"
            name[$SEL]=""
            link[$SEL]=""
            gtk "m_list_text $LST \"''\""
            save_stations_to_file
            read_config_from_file
            add_stations_to_list;;
        $OK)
            define name[$COUNTER] gtk "m_entry_grab $INP"
            define link[$COUNTER] gtk "m_entry_grab $URL"
            ((COUNTER+=1))
            gtk "m_list_text $LST \"''\""
            save_stations_to_file
            read_config_from_file
            add_stations_to_list
            gtk "m_hide $CONFIG";;
        $CANCEL)
            gtk "m_entry_text $INP \"''\""
            gtk "m_entry_text $URL \"''\""
            gtk "m_hide $CONFIG";;
        $PAUSE)
            if [[ $TOGGLE -eq 0 ]]
            then
                echo "PAUSE" >> $FIFO
                TOGGLE=1
            fi;;
        $PLAY)
            if [[ $TOGGLE -eq 1 ]]
            then
                echo "PAUSE" >> $FIFO
                TOGGLE=0
            fi;;
        $LABEL)
            if [[ $CURRENT != "-1" ]]
            then
                gtk "m_label_text $LABEL \"$(get_title_from_stream)\""
            fi;;
        $EXIT)
            break;;
        # Ignore keyboard and mouse
        key-press-event|motion-notify|button-press|button-release)
            ;;
        *)
            gtk "m_event update"

            TOGGLE=0

            define SEL gtk "m_list_get $LST"

            # Only take action if list was changed
            if [[ $CURRENT != $SEL ]]
            then
                CURRENT=$SEL
                if [[ -p $FIFO ]]
                then
                    echo "SILENCE" >> $FIFO
                    echo "LOAD ${link[$CURRENT]}" >> $FIFO
                    gtk "m_label_text $LABEL \"$(get_title_from_stream)\""
                else
                    echo "No interface to 'mpg123' found! Restart this program and try again."
                fi
            fi;;
    esac
done

# Stop and exit
echo "QUIT" >> $FIFO
rm -f $FIFO

# Save configuration
save_stations_to_file

gtk "m_end"
