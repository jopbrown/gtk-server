#---------------------------------------------------------------------
# Communication function; assignment function
#---------------------------------------------------------------------
trap 'exit' SIGCHLD

function motif { print -p $1; read -p MOTIF; }
function define { $2 "$3"; eval $1="${MOTIF}" >/dev/null 2>&1 ; }

# Start GTK-server in STDIN mode
gtk-server-motif -stdin -log=log.txt |&

# Application - toplevel
define top motif "gtk_server_toplevel"

motif "gtk_server_redefine XtVaSetValues NONE NONE 4 WIDGET STRING STRING NULL"
motif "XtVaSetValues $top title 'This is a Motif Application' NULL"

# Window
define win motif "XtVaCreateManagedWidget window xmMainWindowWidgetClass $top NULL"

motif "gtk_server_redefine XtVaSetValues NONE NONE 4 WIDGET STRING INT NULL"
motif "XtVaSetValues $win XmNwidth 800 NULL"
motif "XtVaSetValues $win XmNheight 600 NULL"

# Fixed board
define layer motif "XtVaCreateManagedWidget layer xmBulletinBoardWidgetClass $win NULL"

# Button
define button motif "XtVaCreateManagedWidget button xmPushButtonWidgetClass $layer NULL"
motif "gtk_server_redefine XtVaSetValues NONE NONE 7 WIDGET STRING STRING STRING STRING INT NULL"
motif "XtVaSetValues $button XtVaTypedArg XmNlabelString XmRString 'Push the button' 15 NULL"

motif "gtk_server_redefine XtVaSetValues NONE NONE 4 WIDGET STRING INT NULL"
motif "XtVaSetValues $button XmNwidth 150 NULL"
motif "XtVaSetValues $button XmNheight 60 NULL"
motif "XtVaSetValues $button XmNx 640 NULL"
motif "XtVaSetValues $button XmNy 530 NULL"

# Label
define label motif "XtVaCreateManagedWidget lbl xmLabelWidgetClass $layer NULL"
motif "gtk_server_redefine XtVaSetValues NONE NONE 7 WIDGET STRING STRING STRING STRING INT NULL"
motif "XtVaSetValues $label XtVaTypedArg XmNlabelString XmRString 'This is a demo with Motif!' 26 NULL"

motif "gtk_server_redefine XtVaSetValues NONE NONE 4 WIDGET STRING INT NULL"
motif "XtVaSetValues $label XmNwidth 200 NULL"
motif "XtVaSetValues $label XmNheight 40 NULL"
motif "XtVaSetValues $label XmNx 20 NULL"
motif "XtVaSetValues $label XmNy 20 NULL"

# Combo
define combo motif "XmCreateDropDownComboBox $layer combo NULL 0"
define txt motif "XmStringCreateLocalized 'Some data'"
motif "XmComboBoxAddItem $combo $txt 0 0"
motif "XmStringFree $txt"

motif "gtk_server_redefine XtVaSetValues NONE NONE 4 WIDGET STRING INT NULL"
motif "XtVaSetValues $combo XmNwidth 200 NULL"
motif "XtVaSetValues $combo XmNheight 40 NULL"
motif "XtVaSetValues $combo XmNx 20 NULL"
motif "XtVaSetValues $combo XmNy 100 NULL"

# Make the combo visible
motif "XtManageChild $combo"

# Button reacts
motif "gtk_server_connect $button XmNactivateCallback click"

while true
do
    define EVENT motif "gtk_server_callback wait"

    if [[ $EVENT = $button ]]
    then
	echo "Button clicked"
	# works: motif "gtk_server_disconnect $button XmNactivateCallback click"
    fi

done

# Exit GTK-server
motif "gtk_server_exit"
