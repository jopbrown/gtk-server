#!/bin/bash
#
# HEX/DEC/BIN converter - PvE, Oct. 10, 2008
#
#----------------------------------------------------------- Setup embedded GTK

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
    printf "\nfunction gtk()\n{\necho \$1 > $PIPE; read GTK < $PIPE;\n}\n" >> $HOME/.gtk4bash
fi
# Declare global variables
declare GTK NULL="NULL"
unset CFG PIPE LINE

# Include the generated file to use embedded GTK functions
. ${HOME}/.gtk4bash

#---------------------------------------------------------- Global inits

# GTK-server must go after an error in the script
trap 'echo "gtk_server_exit" > $PIPE' ERR

# Assignment function
function define() { $2 $3 $4 $5 $6 $7 $8 $9; eval $1="$GTK"; }

#---------------------------------------------------------- GUI realization

# Save my directory
MYDIR=${0%/*}

# Initialize libs
gtk_init
glade_init

# Get GUI definition
define XML glade_xml_new "$MYDIR/converter.glade" $NULL $NULL
glade_xml_signal_autoconnect $XML

# Get main window ID and connect signal
glade_xml_get_widget $XML "window"
gtk_server_connect "$GTK delete-event window"

# Get button ID's and connect signals
glade_xml_get_widget $XML "button0"
gtk_server_connect "$GTK clicked button0"
glade_xml_get_widget $XML "button1"
gtk_server_connect "$GTK clicked button1"
define button2 glade_xml_get_widget $XML "button2"
gtk_server_connect "$GTK clicked button2"
define button3 glade_xml_get_widget $XML "button3"
gtk_server_connect "$GTK clicked button3"
define button4 glade_xml_get_widget $XML "button4"
gtk_server_connect "$GTK clicked button4"
define button5 glade_xml_get_widget $XML "button5"
gtk_server_connect "$GTK clicked button5"
define button6 glade_xml_get_widget $XML "button6"
gtk_server_connect "$GTK clicked button6"
define button7 glade_xml_get_widget $XML "button7"
gtk_server_connect "$GTK clicked button7"
define button8 glade_xml_get_widget $XML "button8"
gtk_server_connect "$GTK clicked button8"
define button9 glade_xml_get_widget $XML "button9"
gtk_server_connect "$GTK clicked button9"
define buttonA glade_xml_get_widget $XML "buttonA"
gtk_server_connect "$buttonA clicked buttonA"
define buttonB glade_xml_get_widget $XML "buttonB"
gtk_server_connect "$buttonB clicked buttonB"
define buttonC glade_xml_get_widget $XML "buttonC"
gtk_server_connect "$buttonC clicked buttonC"
define buttonD glade_xml_get_widget $XML "buttonD"
gtk_server_connect "$buttonD clicked buttonD"
define buttonE glade_xml_get_widget $XML "buttonE"
gtk_server_connect "$buttonE clicked buttonE"
define buttonF glade_xml_get_widget $XML "buttonF"
gtk_server_connect "$buttonF clicked buttonF"
# Converter buttons
glade_xml_get_widget $XML "buttonHex"
gtk_server_connect "$GTK clicked buttonHex"
glade_xml_get_widget $XML "buttonDec"
gtk_server_connect "$GTK clicked buttonDec"
glade_xml_get_widget $XML "buttonClr"
gtk_server_connect "$GTK clicked buttonClr"
glade_xml_get_widget $XML "buttonBin"
gtk_server_connect "$GTK clicked buttonBin"
# Get entry ID
define ENTRY glade_xml_get_widget $XML "entry"
# Setup printf scanf for HEX conversion
gtk_server_define "snprintf NONE INT 4 POINTER INT STRING INT"
gtk_server_define "sscanf NONE NONE 3 STRING STRING PTR_INT"

#---------------------------------------------------------- Init variables

# Initialize MODE: 0=DEC 1=HEX 2=BIN
MODE=0
gtk_widget_set_sensitive $buttonA 0
gtk_widget_set_sensitive $buttonB 0
gtk_widget_set_sensitive $buttonC 0
gtk_widget_set_sensitive $buttonD 0
gtk_widget_set_sensitive $buttonE 0
gtk_widget_set_sensitive $buttonF 0

# Default value = 0
NUMBER="0"

# Claim memory
define BUFFER g_malloc 256

#---------------------------------------------------------- Functions

# Define action when 0 1 2 3 4 5 6 7 8 9 A B C D E F is pressed; requires argument
function number()
{
define NUMBER gtk_entry_get_text $ENTRY

if [[ $NUMBER = "0" ]]
then
    NUMBER=$1
else
    NUMBER="$NUMBER$1"
fi

gtk_server_redefine "gtk_entry_set_text NONE NONE 2 WIDGET STRING"
gtk_entry_set_text $ENTRY $NUMBER
}

#---------------------------------------------------------- Mainloop

until [[ $EVENT = "window" ]]
do

    define EVENT gtk_server_callback "wait"

    case $EVENT in
	"button0")
	    number 0;;
	"button1")
	    number 1;;
	"button2")
	    number 2;;
	"button3")
	    number 3;;
	"button4")
	    number 4;;
	"button5")
	    number 5;;
	"button6")
	    number 6;;
	"button7")
	    number 7;;
	"button8")
	    number 8;;
	"button9")
	    number 9;;
	"buttonA")
	    number "A";;
	"buttonB")
	    number "B";;
	"buttonC")
	    number "C";;
	"buttonD")
	    number "D";;
	"buttonE")
	    number "E";;
	"buttonF")
	    number "F";;
	"buttonClr")
	    gtk_server_redefine "gtk_entry_set_text NONE NONE 2 WIDGET STRING"
	    gtk_entry_set_text $ENTRY "0";;
	"buttonBin")
	    if [[ $MODE -eq 0 || $MODE -eq 1 ]]
	    then
		gtk_widget_set_sensitive $button2 0
		gtk_widget_set_sensitive $button3 0
		gtk_widget_set_sensitive $button4 0
		gtk_widget_set_sensitive $button5 0
		gtk_widget_set_sensitive $button6 0
		gtk_widget_set_sensitive $button7 0
		gtk_widget_set_sensitive $button8 0
		gtk_widget_set_sensitive $button9 0
		gtk_widget_set_sensitive $buttonA 0
		gtk_widget_set_sensitive $buttonB 0
		gtk_widget_set_sensitive $buttonC 0
		gtk_widget_set_sensitive $buttonD 0
		gtk_widget_set_sensitive $buttonE 0
		gtk_widget_set_sensitive $buttonF 0
		RESULT=""
		define NUMBER gtk_entry_get_text $ENTRY
		# Now create binary string
		if [[ ${#NUMBER} -gt 0 ]]
		then
		    # Convert to decimal if hex
		    if [[ $MODE -eq 1 ]]
		    then
			((NUMBER=(16#$NUMBER)))
		    fi
		    # Calculate digits
		    until [[ $NUMBER -eq 0 ]]
		    do
			((BIT=$NUMBER&1))
			if [[ $BIT -eq 1 ]]
			then
			    RESULT="1$RESULT"
			else
			    RESULT="0$RESULT"
			fi
			((NUMBER>>=1))
		    done
		    gtk_server_redefine "gtk_entry_set_text NONE NONE 2 WIDGET STRING"
		    gtk_entry_set_text $ENTRY $RESULT
		fi
		MODE=2
	    fi;;

	"buttonHex")
	    if [[ $MODE -eq 0 || $MODE -eq 2 ]]
	    then
		gtk_widget_set_sensitive $button2 1
		gtk_widget_set_sensitive $button3 1
		gtk_widget_set_sensitive $button4 1
		gtk_widget_set_sensitive $button5 1
		gtk_widget_set_sensitive $button6 1
		gtk_widget_set_sensitive $button7 1
		gtk_widget_set_sensitive $button8 1
		gtk_widget_set_sensitive $button9 1
		gtk_widget_set_sensitive $buttonA 1
		gtk_widget_set_sensitive $buttonB 1
		gtk_widget_set_sensitive $buttonC 1
		gtk_widget_set_sensitive $buttonD 1
		gtk_widget_set_sensitive $buttonE 1
		gtk_widget_set_sensitive $buttonF 1
		RESULT=0
		gtk_server_redefine "gtk_entry_set_text NONE NONE 2 WIDGET POINTER"
		define NUMBER gtk_entry_get_text $ENTRY
		# Now convert
		if [[ ${#NUMBER} -gt 0 ]]
		then
		    # If binary, convert to decimal first
		    if [[ $MODE -eq 2 ]]
		    then
			LEN=0
			until [[ $LEN -ge ${#NUMBER} ]]
			do
			    ((POS=${#NUMBER}-$LEN-1))
			    if [[ ${NUMBER:$POS:1} = "1" ]]
			    then
				((RESULT+=2**$LEN))
			    fi
			    ((LEN+=1))
			done
			NUMBER=$RESULT
		    fi
		    # Convert to HEX
		    gtk "snprintf $BUFFER 256 %X $NUMBER"
		    gtk_entry_set_text $ENTRY $BUFFER
		fi
		MODE=1
	    fi;;

	"buttonDec")
	    if [[ $MODE -eq 1 || $MODE -eq 2 ]]
	    then
		gtk_widget_set_sensitive $button2 1
		gtk_widget_set_sensitive $button3 1
		gtk_widget_set_sensitive $button4 1
		gtk_widget_set_sensitive $button5 1
		gtk_widget_set_sensitive $button6 1
		gtk_widget_set_sensitive $button7 1
		gtk_widget_set_sensitive $button8 1
		gtk_widget_set_sensitive $button9 1
		gtk_widget_set_sensitive $buttonA 0
		gtk_widget_set_sensitive $buttonB 0
		gtk_widget_set_sensitive $buttonC 0
		gtk_widget_set_sensitive $buttonD 0
		gtk_widget_set_sensitive $buttonE 0
		gtk_widget_set_sensitive $buttonF 0
		RESULT=0
		gtk_server_redefine "gtk_entry_set_text NONE NONE 2 WIDGET STRING"
		define NUMBER gtk_entry_get_text $ENTRY
		if [[ ${#NUMBER} -gt 0 ]]
		then
		    # If binary, convert to decimal
		    if [[ $MODE -eq 2 ]]
		    then
			LEN=0
			until [[ $LEN -ge ${#NUMBER} ]]
			do
			    ((POS=${#NUMBER}-$LEN-1))
			    if [[ ${NUMBER:$POS:1} = "1" ]]
			    then
				((RESULT+=2**$LEN))
			    fi
			    ((LEN+=1))
			done
			gtk_entry_set_text $ENTRY $RESULT
		    # If hex, convert to decimal
		    elif [[ $MODE -eq 1 ]]
		    then
			gtk "sscanf $NUMBER %x 1"
			gtk_entry_set_text $ENTRY $GTK
		    fi
		fi
		MODE=0
	    fi;;
    esac
done

# Exit GTK
gtk_server_exit
