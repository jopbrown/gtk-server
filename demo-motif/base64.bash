#!/usr/bin/bash
#
# Simple base64 converter in BASH and Motif.
#
# January 2017, PvE.
#------------------------------------------------------------------------

# Check if base64 is available
if [[ -z $(which base64 2>/dev/null) ]]
then
    echo "Binary 'base64' not found on this system! Exiting..."
    exit 1
fi

# Name of PIPE file
declare PI=/tmp/bash.gtk.$$

# Communication function; assignment function
function motif() { echo $1 > $PI; read MOTIF < $PI; }
function define() { $2 "$3"; eval $1=$MOTIF; }

# Start gtk-server in FIFO mode
gtk-server-motif -fifo=$PI -detach -debug
while [ ! -p $PI ]; do continue; done

function ConvertValue
{
    typeset VAL RESULT

    define VAL motif "XmTextGetString $ENTRY"

    RESULT=$(echo $VAL | base64)

    if [[ -n "$RESULT" ]]
    then
        motif "XmTextSetString $ENTRY2 $RESULT"
    fi
}

function DtkshAnchorTop
{
   echo "s:topAttachment e:XmATTACH_FORM s:topOffset i:${1:-0}"
}

function DtkshSpanWidth
{
   echo "s:leftAttachment e:XmATTACH_FORM s:leftOffset i:${1:-0} \
         s:rightAttachment e:XmATTACH_FORM s:rightOffset i:${2:-0}"
}

function DtkshUnder
{
   if [ $# -lt 1 ]; then
      return 1
   fi

   echo "s:topWidget i:$1 s:topAttachment e:XmATTACH_WIDGET s:topOffset i:${2:-0}"
}

define TOPLEVEL motif "gtk_server_toplevel"

motif "XtVaSetValues $TOPLEVEL s:title 's:Base64 conversion' NULL"

define FORM motif "XtVaCreateManagedWidget form xmFormWidgetClass $TOPLEVEL NULL"

define LABEL1 motif "XtVaCreateManagedWidget 'Enter your string:' xmLabelWidgetClass $FORM \
	$(DtkshAnchorTop 12) \
	s:XmNleftAttachment e:XmATTACH_FORM s:leftOffset i:10 NULL"

define ENTRY motif "XtVaCreateManagedWidget entry xmTextWidgetClass $FORM \
	s:columns i:30 \
	$(DtkshAnchorTop 6) \
	s:leftWidget w:$LABEL1 s:leftAttachment e:XmATTACH_WIDGET s:leftOffset i:10) \
	s:XmNrightAttachment e:XmATTACH_FORM s:rightOffset i:10 \
	s:navigationType e:XmEXCLUSIVE_TAB_GROUP NULL"

define SEP1 motif "XtVaCreateManagedWidget sep1 xmSeparatorWidgetClass $FORM \
	s:topWidget w:$ENTRY s:topAttachment e:XmATTACH_WIDGET s:topOffset i:10 \
	$(DtkshUnder $ENTRY 10) \
	$(DtkshSpanWidth 5 5) NULL"

define ENTRY2 motif "XtVaCreateManagedWidget entry2 xmTextWidgetClass $FORM \
	s:columns i:30 \
	s:topWidget w:$SEP1 s:topAttachment e:XmATTACH_WIDGET s:topOffset i:1 \
	s:leftAttachment e:XmATTACH_POSITION s:leftPosition i:4 \
	s:XmNrightAttachment e:XmATTACH_FORM s:rightOffset i:10 \
	s:navigationType e:XmEXCLUSIVE_TAB_GROUP NULL"

motif "XmTextSetEditable $ENTRY2 0"

define SEP2 motif "XtVaCreateManagedWidget sep2 xmSeparatorWidgetClass $FORM \
	s:topWidget w:$ENTRY2 s:topAttachment e:XmATTACH_WIDGET s:topOffset i:10 \
	$(DtkshSpanWidth 5 5) NULL"

define EXITBUTTON motif "XtVaCreateManagedWidget Exit xmPushButtonWidgetClass $FORM \
	s:height i:30 \
	s:topWidget w:$SEP2 s:topAttachment e:XmATTACH_WIDGET s:topOffset i:10 \
	s:leftAttachment e:XmATTACH_POSITION s:leftPosition i:4 \
	s:rightAttachment e:XmATTACH_POSITION s:rightPosition i:24 \
	s:XmNbottomAttachment e:XmATTACH_FORM s:bottomOffset i:10 NULL"

motif "gtk_server_connect $EXITBUTTON activateCallback ExitCallback"

define CONVERTBUTTON motif "XtVaCreateManagedWidget Convert xmPushButtonWidgetClass $FORM \
	s:height i:30 \
	s:topWidget w:$SEP2 s:topAttachment e:XmATTACH_WIDGET s:topOffset i:10 \
	s:XmNrightAttachment e:XmATTACH_FORM s:rightOffset i:10 \
	s:XmNbottomAttachment e:XmATTACH_FORM s:bottomOffset i:10 NULL"

motif "gtk_server_connect $CONVERTBUTTON activateCallback ConvertValue"

motif "XtVaSetValues $FORM \
	s:initialFocus w:$ENTRY \
	s:navigationType e:XmEXCLUSIVE_TAB_GROUP NULL"

# Mainloop
until [[ $EVENT = "ExitCallback" ]]
do
    define EVENT motif "gtk_server_callback wait"
    
    if [[ $EVENT = "ConvertValue" ]]
    then
        ConvertValue
    fi
done

# Exit GTK-server
motif "gtk_server_exit"
