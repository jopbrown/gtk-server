#---------------------------------------------------------------------
# Communication function; assignment function
#---------------------------------------------------------------------
trap 'exit' SIGCHLD

function motif { print -p $1; read -p MOTIF; }
function define { $2 "$3"; eval $1="${MOTIF}" >/dev/null 2>&1 ; }

# Start GTK-server in STDIN mode
gtk-server-motif -stdin -log=log.txt |&

# Define some Motif calls
motif "gtk_server_define XtVaCreateManagedWidget NONE WIDGET 4 STRING CLASS WIDGET NULL"
#motif "gtk_server_define XtVaCreateWidget NONE ADDRESS 4 STRING LONG WIDGET NULL"

# Application - toplevel
define top motif "gtk_server_toplevel"

motif "gtk_server_redefine XtVaSetValues NONE NONE 4 WIDGET STRING STRING NULL"
motif "XtVaSetValues $top title 'My First Motif App' NULL"

# Window
define win motif "XtVaCreateManagedWidget window xmMainWindowWidgetClass $top NULL"

motif "gtk_server_redefine XtVaSetValues NONE NONE 4 WIDGET STRING INT NULL"
motif "XtVaSetValues $win width 800 NULL"
motif "XtVaSetValues $win height 600 NULL"

# Fixed board
define layer motif "XtVaCreateManagedWidget layer xmBulletinBoardWidgetClass $win NULL"

# Button
define label motif "XmStringCreateLocalized 'Push the button.'"
define button motif "XtVaCreateManagedWidget button xmPushButtonWidgetClass $layer NULL"

motif "gtk_server_redefine XtVaSetValues NONE NONE 4 WIDGET STRING WIDGET NULL"
motif "XtVaSetValues $button labelString $label NULL"
motif "XmStringFree $label"

motif "gtk_server_redefine XtVaSetValues NONE NONE 4 WIDGET STRING INT NULL"
motif "XtVaSetValues $button width 150 NULL"
motif "XtVaSetValues $button height 60 NULL"
motif "XtVaSetValues $button x 640 NULL"
motif "XtVaSetValues $button y 530 NULL"

motif "gtk_server_connect $button activateCallback click"

while true
do
    define EVENT motif "gtk_server_callback wait"

    if [[ $EVENT = $button ]]
    then
	echo "Button clicked"
    fi

done

# Exit GTK-server
motif "gtk_server_exit"