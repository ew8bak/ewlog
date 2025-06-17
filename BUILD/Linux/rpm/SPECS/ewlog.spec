Name:           ewlog
Version:        __VERSION__
Release:        __RELEASE__
Summary:        EWLog Desktop HAM log
License:        GPL
URL:            https://ewlog.app
Source0:        ewlog
Source1:        ewlog.desktop
Source2:        callbook.db
Source3:        serviceLOG.db
Source4:        ewlog.png
Source5:        ewlog.en.po
Source6:        ewlog.ru.po
Requires:       hamlib, (libsqlite3x-devel or sqlite3-devel), openssl-devel, (sqlite-libs or libsqlite3-0)
BuildArch:      __ARCH__
BuildRoot:      %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

%description
Advanced logging program for hamradio operators

%install
install -D -pm 777 %{SOURCE0} %{buildroot}/usr/bin/ewlog
install -D -pm 666 %{SOURCE1} %{buildroot}/usr/share/applications/ewlog.desktop
install -D -pm 666 %{SOURCE2} %{buildroot}/usr/share/ewlog/callbook.db
install -D -pm 666 %{SOURCE3} %{buildroot}/usr/share/ewlog/serviceLOG.db
install -D -pm 666 %{SOURCE4} %{buildroot}/usr/share/icons/ewlog.png
install -D -pm 666 %{SOURCE5} %{buildroot}/usr/share/ewlog/locale/ewlog.en.po
install -D -pm 666 %{SOURCE6} %{buildroot}/usr/share/ewlog/locale/ewlog.ru.po

%files
/usr/bin/*
/usr/share/*

%clean
rm -rf $RPM_BUILD_ROOT

%post
HOMEDIR=$(eval echo ~${SUDO_USER})
DIR=$HOMEDIR/EWLog
EWDIR=/usr/share/ewlog
if [ ! -d "$DIR" ]; then
    mkdir $DIR
fi
chmod 777 $DIR
cp -rf $EWDIR/* $DIR
chmod -R a+w $DIR
/usr/bin/chmod 777 /usr/share/ewlog
update-desktop-database &> /dev/null ||:

%postun
if [ $1 -eq 0 ]; then
rm -rf /usr/share/ewlog
rm -f /usr/share/applications/ewlog.desktop
rm -f /usr/share/pixmaps/ewlog.png
update-desktop-database &> /dev/null ||:
fi

%changelog
* Mon Nov 08 2021 ew8bak
- change spec file