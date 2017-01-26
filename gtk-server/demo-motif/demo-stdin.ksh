#---------------------------------------------------------------------
# Communication function; assignment function
#---------------------------------------------------------------------
trap 'exit' SIGCHLD

function motif { print -p $1; read -p MOTIF; }
function define { $2 "$3"; eval $1="${MOTIF}" >/dev/null 2>&1 ; }

# Start GTK-server in STDIN mode
gtk-server-motif -stdin -log=/tmp/log.txt -debug |&

# Application - toplevel
define top motif "gtk_server_toplevel"
motif "XtVaSetValues $top s:title 's:This is a Motif Application' NULL"

# Some fonts
define display motif "XtDisplay $top"
define model motif "XmFontListEntryLoad $display 12x24romankana XmFONT_IS_FONT tag"
define font1 motif "XmFontListAppendEntry NULL $model"
define model motif "XmFontListEntryLoad $display 8x16 XmFONT_IS_FONT tag"
define font2 motif "XmFontListAppendEntry NULL $model"
define model motif "XmFontListEntryLoad $display 8x13bold XmFONT_IS_FONT tag"
define font3 motif "XmFontListAppendEntry NULL $model"
#motif "XmFontListEntryFree $font"

# Window
define win motif "XtVaCreateManagedWidget window xmMainWindowWidgetClass $top \
    s:XmNwidth i:640 \
    s:XmNheight i:480 \
    NULL"

# Fixed board
define layer motif "XtVaCreateManagedWidget layer xmBulletinBoardWidgetClass $win \
        s:XmNbackground e:Peru \
        NULL"

# Label
define label motif "XtVaCreateManagedWidget lbl xmLabelWidgetClass $layer \
    s:XtVaTypedArg s:XmNlabelString s:XmRString 's:This is a demo with Motif!' i:26 \
    s:XmNx i:20 \
    s:XmNy i:20 \
    s:XmNbackground e:Peru \
    s:XmNforeground e:Yellow \
    s:XmNfontList w:$font1 \
    NULL"

# Combo
define combo motif "XmCreateDropDownComboBox $layer combo NULL 0"
motif "XtVaSetValues $combo \
    s:XmNfontList w:$font3 \
    s:XmNwidth i:200 \
    s:XmNheight i:40 \
    s:XmNx i:20 \
    s:XmNy i:100 \
    NULL"

# Add an item
define txt motif "XmStringCreateLocalized 'Some data'"
motif "XmComboBoxAddItem $combo $txt 0 0"
motif "XmStringFree $txt"

# Make the combo visible
motif "XtManageChild $combo"

# Button
define button motif "XtVaCreateManagedWidget button xmPushButtonWidgetClass $layer \
    s:XtVaTypedArg s:XmNlabelString s:XmRString 's:Push the button' i:15 \
    s:XmNfontList w:$font2 \
    s:XmNheight i:40 \
    s:XmNx i:470 \
    s:XmNy i:410 \
    NULL"

motif "XtVaSetValues $button \
    s:XmNbackground e:SkyBlue NULL"

# Button reacts
motif "gtk_server_connect $button XmNactivateCallback click"

while true
do
    define EVENT motif "gtk_server_callback wait"

    if [[ $EVENT = "click" ]]
    then
	echo "Button clicked"
	# works: motif "gtk_server_disconnect $button XmNactivateCallback click"
    fi

done

# Exit GTK-server
motif "gtk_server_exit"
