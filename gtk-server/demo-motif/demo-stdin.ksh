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
define layer motif "XtVaCreateManagedWidget layer xmDrawingAreaWidgetClass $win \
    s:XmNbackground e:Peru \
    NULL"
motif "gtk_server_connect $layer XmNinputCallback input"

# Label
define label motif "XtVaCreateManagedWidget lbl xmLabelWidgetClass $layer \
    s:XtVaTypedArg s:XmNlabelString s:XmRString 's:This is a demo with Motif!' i:26 \
    s:XmNx i:20 \
    s:XmNy i:20 \
    s:XmNbackground e:Peru \
    s:XmNforeground e:Yellow \
    s:XmNfontList w:$font1 \
    NULL"

# Radio box
define radio motif "XmCreateRadioBox $layer radio NULL 0"
motif "XtVaSetValues $radio \
    s:XmNbackground e:Peru \
    s:XmNx i:20 \
    s:XmNy i:100 \
    NULL"
define one motif "XtVaCreateManagedWidget One xmToggleButtonGadgetClass $radio s:XmNfontList w:$font3 NULL"
define two motif "XtVaCreateManagedWidget Two xmToggleButtonGadgetClass $radio s:XmNfontList w:$font3 NULL"
define three motif "XtVaCreateManagedWidget Three xmToggleButtonGadgetClass $radio s:XmNfontList w:$font3 NULL"

# Make the radio box visible
motif "XtManageChild $radio"

# Combo
define combo motif "XmCreateDropDownComboBox $layer combo NULL 0"
motif "XtVaSetValues $combo \
    s:XmNfontList w:$font3 \
    s:XmNbackground e:Peru \
    s:XmNwidth i:200 \
    s:XmNheight i:40 \
    s:XmNx i:20 \
    s:XmNy i:400 \
    NULL"

# Add an item
define txt motif "XmStringCreateLocalized 'Some data'"
motif "XmComboBoxAddItem $combo $txt 0 0"
motif "XmStringFree $txt"
define txt motif "XmStringCreateLocalized 'And more data'"
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
    s:XmNbackground e:Brown NULL"

# Button reacts
motif "gtk_server_connect $button XmNactivateCallback click"

# Verify timeout
motif "gtk_server_timeout 1000 $button XmNactivateCallback"

# Command dialog
define comm motif "XmCreateCommand $layer command NULL 0"
motif "XtVaSetValues $comm \
    s:XmNbackground e:Peru \
    s:XmNx i:400 \
    s:XmNy i:20 \
    NULL"
define comm_txt motif "XmCommandGetChild $comm XmDIALOG_COMMAND_TEXT"
motif "XtVaSetValues $comm_txt \
    s:XmNfontList w:$font3 \
    NULL"
define comm_work motif "XmCommandGetChild $comm XmDIALOG_HISTORY_LIST"
motif "XtVaSetValues $comm_work \
    s:XmNfontList w:$font3 \
    NULL"
motif "XtManageChild $comm"

# Xpm
define screen motif "XtScreen $layer"
define pixmap motif "XmGetPixmap $screen xlogo64 Black Peru" 
define labx motif "XtVaCreateWidget labx xmLabelGadgetClass $layer \
    s:XmNlabelType e:XmPIXMAP \
    s:XmNlabelPixmap w:$pixmap \
    s:XmNx i:200 \
    s:XmNy i:100 \
    NULL"
motif "XtManageChild $labx"

# Set focus to window
#motif "XtSetKeyboardFocus $top $layer"

msg="Button clicked by timeout"
while true
do
    define EVENT motif "gtk_server_callback wait"

    if [[ $EVENT = "click" ]]
    then
	echo $msg
        msg="Button clicked by user"
	# works: motif "gtk_server_disconnect $button XmNactivateCallback click"
    fi

    if [[ $EVENT = "input" ]]
    then
	define x motif "gtk_server_mouse 0"
	define y motif "gtk_server_mouse 1"
        echo "Xpos, Ypos: $x, $y"
	define butnr motif "gtk_server_mouse 2"
        echo "Button: $butnr"
        define special motif "gtk_server_state"
        echo "Special: $special"
    fi

done

# Exit GTK-server
motif "gtk_server_exit"
