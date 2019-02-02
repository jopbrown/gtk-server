prefix =	/mingw64
exec_prefix =	${prefix}
BINDIR =	${exec_prefix}/bin
LIBDIR = 	${exec_prefix}/lib
INCL =		${prefix}/include
SYSCONFIG =	${prefix}/etc
datarootdir =	${prefix}/share
MANDIR =	${datarootdir}/man
CC =		gcc
STRIP =		strip
CFLAGS =	-Wall -pedantic -g -O2  -DHAVE_CONFIG_H -DLOCALCFG=\"$(SYSCONFIG)/gtk-server.cfg\" -IC:/msys64/mingw64/lib/libffi-3.2.1/include
LDFLAGS =	-export-dynamic -lws2_32 -ladvapi32 -lshlwapi -mwindows -LC:/msys64/mingw64/lib/../lib -lffi -ldl
OBJS =		gtk-server.o
INSTALL = 	/usr/bin/install -c
TARGET =	gtk-server-gtk2.exe
SOTARGET =	 libgtk-server-gtk2.so
DEFAULT = 	1
MACOSX =	no
GTK3_CFLAGS =   
GTK2_CFLAGS =   -mms-bitfields -pthread -mms-bitfields -IC:/msys64/mingw64/include/gtk-2.0 -IC:/msys64/mingw64/lib/gtk-2.0/include -IC:/msys64/mingw64/include/pango-1.0 -IC:/msys64/mingw64/include/fribidi -IC:/msys64/mingw64/include -IC:/msys64/mingw64/include/cairo -IC:/msys64/mingw64/include/atk-1.0 -IC:/msys64/mingw64/include/cairo -IC:/msys64/mingw64/include/pixman-1 -IC:/msys64/mingw64/include -IC:/msys64/mingw64/include/freetype2 -IC:/msys64/mingw64/include -IC:/msys64/mingw64/include/harfbuzz -IC:/msys64/mingw64/include/libpng16 -IC:/msys64/mingw64/include/gdk-pixbuf-2.0 -IC:/msys64/mingw64/include/libpng16 -IC:/msys64/mingw64/include -IC:/msys64/mingw64/lib/libffi-3.2.1/include -IC:/msys64/mingw64/include/glib-2.0 -IC:/msys64/mingw64/lib/glib-2.0/include -IC:/msys64/mingw64/include
GTK1_CFLAGS =   
XF_CFLAGS =     
MOTIF_CFLAGS =  
GTK3_LIBS =     
GTK2_LIBS =     -LC:/msys64/mingw64/lib -lgtk-win32-2.0 -lgdk-win32-2.0 -lgdi32 -limm32 -lshell32 -lole32 -Wl,-luuid -lpangowin32-1.0 -lpangocairo-1.0 -lpango-1.0 -latk-1.0 -lcairo -lgdk_pixbuf-2.0 -lgio-2.0 -lgobject-2.0 -lglib-2.0 -lintl
GTK1_LIBS =     
XF_LIBS =       
MOTIF_LIBS =    
SSLFLAGS =      
LINK =          gtk-server-gtk2.exe
SOLINK =        libgtk-server-gtk2.so

all : clean $(TARGET)

gtk-server-gtk3 : gtk-server.c
	$(CC) -DGTK_SERVER_GTK3x $(CFLAGS) $(GTK3_CFLAGS) -o $@ gtk-server.c $(GTK3_LIBS) $(SSLFLAGS) $(LDFLAGS)
	$(STRIP) $@

libgtk-server-gtk3.so : gtk-server.c
	$(CC) -DGTK_SERVER_GTK3x -DGTK_SERVER_LIBRARY -shared $(CFLAGS) $(GTK3_CFLAGS) -o $@ gtk-server.c $(GTK3_LIBS) $(LDFLAGS)

gtk-server-gtk2.exe : gtk-server.c
	$(CC) -DGTK_SERVER_GTK2x $(CFLAGS) $(GTK2_CFLAGS) -o $@ gtk-server.c $(GTK2_LIBS) $(SSLFLAGS) $(LDFLAGS)
	$(STRIP) $@

libgtk-server-gtk2.so : gtk-server.c
	$(CC) -DGTK_SERVER_GTK2x -DGTK_SERVER_LIBRARY -shared $(CFLAGS) $(GTK2_CFLAGS) -o $@ gtk-server.c $(GTK2_LIBS) $(LDFLAGS)

gtk-server-gtk1 : gtk-server.c
	$(CC) -DGTK_SERVER_GTK1x $(CFLAGS) $(GTK1_CFLAGS) -o $@ gtk-server.c $(GTK1_LIBS) $(SSLFLAGS) $(LDFLAGS)
	$(STRIP) $@

libgtk-server-gtk1.so : gtk-server.c
	$(CC) -DGTK_SERVER_GTK1x -DGTK_SERVER_LIBRARY -shared $(CFLAGS) $(GTK1_CFLAGS) -o $@ gtk-server.c $(GTK1_LIBS) $(LDFLAGS)

gtk-server-xf : gtk-server.c
	$(CC) -DGTK_SERVER_XF $(CFLAGS) $(XF_CFLAGS) -o $@ gtk-server.c $(XF_LIBS) $(SSLFLAGS) $(LDFLAGS)
	$(STRIP) $@

libgtk-server-xf.so : gtk-server.c
	$(CC) -DGTK_SERVER_XF -DGTK_SERVER_LIBRARY -shared $(CFLAGS) $(XF_CFLAGS) -o $@ gtk-server.c $(XF_LIBS) $(LDFLAGS)

gtk-server-motif : gtk-server.c
	$(CC) -DGTK_SERVER_MOTIF $(CFLAGS) $(MOTIF_CFLAGS) -o $@ gtk-server.c $(MOTIF_LIBS) $(SSLFLAGS) $(LDFLAGS)
	$(STRIP) $@

libgtk-server-motif.so : gtk-server.c
	$(CC) -DGTK_SERVER_MOTIF -DGTK_SERVER_LIBRARY -shared $(CFLAGS) $(MOTIF_CFLAGS) -o $@ gtk-server.c $(MOTIF_LIBS) $(LDFLAGS)

gtk-server-console : gtk-server.c
	$(CC) $(CFLAGS) -o $@ gtk-server.c $(SSLFLAGS) $(LDFLAGS)
	$(STRIP) $@

libgtk-server-console.so : gtk-server.c
	$(CC) -shared $(CFLAGS) -o $@ gtk-server.c $(LDFLAGS)

gtk-server.exe : $(OBJS)
	$(CC) -o $@ $(OBJS) $(LDFLAGS)
	$(STRIP) $@

install : $(TARGET) $(SOTARGET)
	mkdir -p $(BINDIR)
	$(INSTALL) $(TARGET) $(BINDIR)
	mkdir -p $(LIBDIR)
	$(INSTALL) $(SOTARGET) $(LIBDIR)
	mv $(BINDIR)/$(LINK) $(BINDIR)/gtk-server
	mv $(LIBDIR)/$(SOLINK) $(LIBDIR)/libgtk-server.so
	$(INSTALL) stop-gtk-server $(BINDIR)
	@awk ' \
            /BINDIR=/ {print "BINDIR=$(BINDIR)"} \
            /LIBDIR=/ {print "LIBDIR=$(LIBDIR)"} \
            !/BINDIR=|LIBDIR=/ {print} \
	    ' select-gtk-server > $(BINDIR)/select-gtk-server
	@echo "$(INSTALL) select-gtk-server $(BINDIR)"
	@chmod 755 $(BINDIR)/select-gtk-server
	mkdir -p $(SYSCONFIG)
	@echo -n "Creating GTK-server configfile... "
	@echo > $(SYSCONFIG)/gtk-server.cfg
	@if [ $(MACOSX) = "no" ]; then \
		awk ' \
		/LIB_NAME.*so/ {print substr($$0, 3)} \
		!/LIB_NAME/ {print} \
		' gtk-server.cfg > $(SYSCONFIG)/gtk-server.cfg; \
	fi;
	@if [ $(MACOSX) = "yes" ]; then \
		awk ' \
		/LIB_NAME.*dylib/ {print substr($$0, 3)} \
		!/LIB_NAME/ {print} \
		' gtk-server.cfg > $(SYSCONFIG)/gtk-server.cfg; \
	fi;
	@echo "done.";
	mkdir -p $(MANDIR)/man1
	$(INSTALL) -m 644 ../documentation/gtk-server.1 $(MANDIR)/man1
	$(INSTALL) -m 644 ../documentation/gtk-server.cfg.1 $(MANDIR)/man1
	$(INSTALL) -m 644 ../documentation/stop-gtk-server.1 $(MANDIR)/man1
	@if [ $(DEFAULT) -eq "3" ]; then \
		echo -n "Installing S-Lang module... "; \
		ln -sf $(LIBDIR)/$(SOLINK) $(LIBDIR)/gtk-module.so \
		echo "done."; \
	fi;
	@if [ $(DEFAULT) -eq "4" ]; then \
		echo -n "Installing Scriptbasic module... "; \
		ln -sf $(LIBDIR)/$(SOLINK) $(LIBDIR)/gtk-server.so; \
		mkdir -p $(INCL); \
		cp ../scriptbasic/gtk.bas $(INCL)/gtk.bas; \
		echo "done."; \
	fi

uninstall:
	cd $(BINDIR); \
	rm -f $(TARGET)
	cd $(LIBDIR); \
	rm -f $(SOTARGET)
	rm -f $(SYSCONFIG)/gtk-server.cfg
	rm -f $(BINDIR)/stop-gtk-server
	rm -f $(BINDIR)/select-gtk-server
	rm -f $(BINDIR)/gtk-server
	rm -f $(LIBDIR)/libgtk-server.so
	rm -f $(MANDIR)/man1/gtk-server.1
	rm -f $(MANDIR)/man1/gtk-server.cfg.1
	rm -f $(MANDIR)/man1/stop-gtk-server.1
	@if [ $(DEFAULT) -eq "3" ]; then \
		echo "Uninstalling S-Lang module..."; \
		rm -f /usr/lib/gtk-module.so; \
		echo "rm -f /usr/lib/gtk-module.so"; \
	fi;
	@if [ $(DEFAULT) -eq "4" ]; then \
		echo "Uninstalling Scriptbasic module..."; \
		rm -f $(LIBDIR)/gtk-server.so; \
		echo "rm -f $(LIBDIR)/gtk-server.so"; \
		rm -f $(INCL)/gtk.bas; \
		echo "rm -f $(INCL)/gtk.bas"; \
	fi

clean:
	rm -f $(TARGET) $(SOTARGET) *.a *.o *.log so_locations

delete:
	rm -rf autom4te.cache/
	rm -f $(TARGET) $(SOTARGET) *.a *.o *.log so_locations config.status config.h Makefile
