#!/bin/ksh
#
# And now for something completely different. :-)
#
# With the GTK-server it is possible to open any library from a shellscript,
# without using configfile, as is shown below.
#
# Enjoy nice music from www.modarchive.org!
#
# September 2008, PvE - tested with GTK-server 2.2.8 on Linux.
# December 2016, PvE - tested with GTK-server 2.4 on Linux Mint 18.
#
#---------------------------------------------------------------------

# File to load and play
FILE="welcome.mod"

#---------------------------------------------------------------------
# Communication function; assignment function
#---------------------------------------------------------------------
function mikmod { print -p $1; read -p MIKMOD; }
function define { $2 "$3"; eval $1="${MIKMOD}" >/dev/null 2>&1 ; }

# Start GTK-server in STDIN mode
gtk-server -stdin -log=/tmp/gtk-server.log |&

# Open MikMod library
define MM mikmod "gtk_server_require libmikmod.so"
if [[ $MM != "ok" ]]
then
    echo "No MikMod found on this system! Please install from http://mikmod.raphnet.net/. Exiting..."
    mikmod "gtk_server_exit"
    exit 1
fi

# Define some mikmod calls
mikmod "gtk_server_define MikMod_Init NONE BOOL 1 STRING"
mikmod "gtk_server_define MikMod_RegisterAllDrivers NONE NONE 0"
mikmod "gtk_server_define MikMod_RegisterAllLoaders NONE NONE 0"
mikmod "gtk_server_define MikMod_Update NONE NONE 0"
mikmod "gtk_server_define MikMod_Exit NONE NONE 0"
mikmod "gtk_server_define Player_Load NONE POINTER 3 STRING INT BOOL"
mikmod "gtk_server_define Player_Start NONE NONE 1 POINTER"
mikmod "gtk_server_define Player_Active NONE BOOL 0"
mikmod "gtk_server_define Player_Stop NONE NONE 0"
mikmod "gtk_server_define Player_Free NONE NONE 1 POINTER"

# Register all the drivers
mikmod "MikMod_RegisterAllDrivers"

# Register all the module loaders
mikmod "MikMod_RegisterAllLoaders"

# initialize the library
define init mikmod "MikMod_Init ''"
if [[ $init -ne 0 ]]
then
    echo "Could not initialize sound."
    mikmod "gtk_server_exit"
    exit
fi

# Load module using 64 channels
define module mikmod "Player_Load $FILE 64 0"

# Play music
if [[ $module -gt 0 ]]
then
    # Start module
    mikmod "Player_Start $module"

    define active mikmod "Player_Active"

    # We're playing
    while [[ $active -gt 0 ]]
    do
	define active mikmod "Player_Active"
	# Lower the sleep value if your sound stutters
	#sleep 1
	mikmod "MikMod_Update"
    done

    mikmod "Player_Stop"
    mikmod "Player_Free $module"
else
    echo "Could not play module!"
fi

# Give up
mikmod "MikMod_Exit"

# Exit GTK-server
mikmod "gtk_server_exit"
