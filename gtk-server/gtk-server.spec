Summary: the GTK-server - Interpreted GUI Programming
Name: gtk-server
Version: 2.4.1
Release: 1
Source: gtk-server-2.4.1.tar.gz
URL: http://www.gtk-server.org/
Copyright: GPL
Packager: Peter van Eerten <peter AT gtk-server DOT org>
Group: Development/Tools
BuildRoot: /var/tmp/%{name}-buildroot

%description
The GTK-server enables GUI access to script- and
interpreted languages, using the famous GTK widget
set. It can be used with Bourne Shell, Korn Shell,
GNU Awk, CLisp, newLisp, Perl, CShell and many other
languages.

%prep
%setup

%build
cd
./configure --with-gtk3
make

%install
mkdir -p $RPM_BUILD_ROOT/usr/bin
install -s -m 755 src/gtk-server-gtk3 $RPM_BUILD_ROOT/usr/bin/gtk-server
install -m 755 src/stop-gtk-server $RPM_BUILD_ROOT/usr/bin/stop-gtk-server
mkdir -p $RPM_BUILD_ROOT/usr/lib
install -s -m 755 src/libgtk-server-gtk3.so $RPM_BUILD_ROOT/usr/bin/libgtk-server.so
mkdir -p $RPM_BUILD_ROOT/etc
install -m 644 src/gtk-server.cfg $RPM_BUILD_ROOT/etc/gtk-server.cfg
mkdir -p $RPM_BUILD_ROOT/usr/man/man1
install -m 644 documentation/gtk-server.1 $RPM_BUILD_ROOT/usr/man/man1/gtk-server.1
install -m 644 documentation/gtk-server.cfg.1 $RPM_BUILD_ROOT/usr/man/man1/gtk-server.cfg.1
install -m 644 documentation/stop-gtk-server.1 $RPM_BUILD_ROOT/usr/man/man1/stop-gtk-server.1
rm -rf $RPM_BUILD_ROOT

%post

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%doc CREDITS README.1ST INSTALL documentation/*
%config /etc/gtk-server.cfg

/usr/bin/gtk-server
/usr/bin/stop-gtk-server
/usr/lib/libgtk-server.so
/usr/man/man1/gtk-server.1.gz
/usr/man/man1/gtk-server.cfg.1.gz
/usr/man/man1/stop-gtk-server.1.gz

# end of file
