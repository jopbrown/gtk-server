divert(-1)dnl
#--------------------------------------------------------------
# GTK-server demonstration with the M4 macro language 1.4.17
#
# Testing the new '-nonl' parameter. Peter van Eerten, Jan 2017
#--------------------------------------------------------------

syscmd(`gtk-server-console -fifo=/tmp/m4.fifo -detach -nonl')

define(mikmod, `syscmd(`echo `$@'>/tmp/m4.fifo')'`include(`/tmp/m4.fifo')')

#--------------------------------------------------------------

# Generic error with newline
define(error, `divert(0)$1
divert(-1)' `mikmod("gtk_server_exit")' `m4exit(0)')

# Open MikMod library
define(MM, mikmod("gtk_server_require libmikmod.so"))
ifelse(MM, ok, `',`error(No MikMod found on this system!)')

# Define some mikmod calls
mikmod("gtk_server_define MikMod_Init NONE BOOL 1 STRING")
mikmod("gtk_server_define MikMod_RegisterAllDrivers NONE NONE 0")
mikmod("gtk_server_define MikMod_RegisterAllLoaders NONE NONE 0")
mikmod("gtk_server_define MikMod_Update NONE NONE 0")
mikmod("gtk_server_define MikMod_Exit NONE NONE 0")
mikmod("gtk_server_define Player_Load NONE POINTER 3 STRING INT BOOL")
mikmod("gtk_server_define Player_Start NONE NONE 1 POINTER")
mikmod("gtk_server_define Player_Active NONE BOOL 0")
mikmod("gtk_server_define Player_Stop NONE NONE 0")
mikmod("gtk_server_define Player_Free NONE NONE 1 POINTER")

# Register all the drivers
mikmod("MikMod_RegisterAllDrivers")

# Register all the module loaders
mikmod("MikMod_RegisterAllLoaders")

# initialize the library
define(init, mikmod("MikMod_Init \"\""))
ifelse(init, 0, `', `error(Could not initialize sound!)')

# Load module using 64 channels
define(module, mikmod("Player_Load welcome.mod 64 0"))
ifelse(module, 0, `error(Could not play ``module!'')')

# Start module
mikmod("Player_Start module")

# We're playing
define(loop, define(`active', `mikmod("Player_Active")') `ifelse(active, 1, `mikmod("MikMod_Update")' `loop')')
loop

# Exit MikMod gracefully
mikmod("Player_Stop")
mikmod("Player_Free module")
mikmod("MikMod_Exit")

# Exit GTK-server
mikmod("gtk_server_exit")
