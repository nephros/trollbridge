# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.27
# 

Name:       harbour-trollbridge
Summary:    TRaveller's OLympus Bridge
Version:    0.1.2.1
Release:    1
Group:      Applications/Multimedia
License:    MIT
URL: https://github.com/bundyo/trollbridge/
#Source: https://github.com/bundyo/trollbridge/archive/v%%{version}.tar.gz
Source: %{name}-%{version}.tar.gz
Source1: go1.17.4.linux-armv6l.tar.gz
Source2: go1.17.4.linux-arm64.tar.gz
Source3: go1.17.4.linux-amd64.tar.gz
Source4: go_qml.v1.tar.gz
Source5: launchpad.net_xmlpath.tar.gz

#Requires:   mapplauncherd-booster-silica-qt5
#Requires:   nemo-qml-plugin-thumbnailer-qt5
Requires:   sailfishsilica-qt5
BuildRequires:  pkgconfig(sailfishapp)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Core)
#BuildRequires:  pkgconfig(qdeclarative5-boostable)
BuildRequires:  desktop-file-utils

%description
TRaveller's OLympus Bridge is an app for controlling Olympus OM-D/PEN/Air cameras with integrated WiFi.

%prep
# >> setup
#%%setup -q -n example-app-%%{version}
%setup -n %{name}-%{version}
rm -rf vendor
# << setup

%build
# >> build pre
GOPATH=$PWD

echo GOPATH is $GOPATH

## unpack the compiler tarball:
mkdir -p $HOME/gohome
pushd $HOME/gohome

echo "Unpacking go compiler package for %_arch"
%ifarch armv7hl
echo we are arm
gunzip -dc %{SOURCE1} | tar -xof -
export GOARCH=arm
%endif

%ifarch aarch64
echo we are arm64
gunzip -dc %{SOURCE2} | tar -xof -
export GOARCH=arm64
%endif

%ifarch %ix86
echo we are x86
gunzip -dc %{SOURCE3} | tar -xof -
export GOARCH=386
%endif

# install deps
pushd go
gunzip -dc %{SOURCE4} | tar -xof -
gunzip -dc %{SOURCE5} | tar -xof -
popd

popd

$HOME/gohome/go/bin/go version

GOROOT=~/gohome/go
export GOPATH GOROOT
#~/gohome/go/bin/go mod init
#~/gohome/go/bin/go env -w GO111MODULE=off
#~/gohome/go/bin/go list -m all
#~/gohome/go/bin/go get gopkg.in/qml.v1
#~/gohome/go/bin/go get launchpad.net/xmlpath
~/gohome/go/bin/go build -pkgdir $GOROOT/pkg/ -ldflags "-s" -o %{name}
# << build pre

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
install -d %{buildroot}%{_bindir}
install -p -m 0755 %(pwd)/%{name} %{buildroot}%{_bindir}/%{name}
install -d %{buildroot}%{_datadir}/applications
install -d %{buildroot}%{_datadir}/%{name}/qml
install -d %{buildroot}%{_datadir}/%{name}/qml/i18n
install -m 0444 -t %{buildroot}%{_datadir}/%{name}/qml *.qml
install -m 0444 -t %{buildroot}%{_datadir}/%{name}/qml/i18n i18n/*.qm
install -d %{buildroot}%{_datadir}/icons/hicolor/86x86/apps
install -m 0444 -t %{buildroot}%{_datadir}/icons/hicolor/86x86/apps data/%{name}.png
install -p %(pwd)/trollbridge.desktop %{buildroot}%{_datadir}/applications/%{name}.desktop
# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/applications/%{name}.desktop
%{_datadir}/%{name}/qml
%{_datadir}/%{name}/qml/i18n
%{_datadir}/icons/hicolor/86x86/apps
%{_bindir}
# >> files
# << files

%changelog
* Thu May 12 2016 version 0.1.2
- Fix occasional refresh issues (selection not showing)
- Add file type tags (JPG/ORF)
- Add proper RAW download support (indexes were wrong)
- Make download loader distinctive 

* Mon May 09 2016 version 0.1.1
- Add support for Olympus Air (image download only)
- Fix folder creation bug

* Sun May 01 2016 version 0.1
- Add support for remote shutter
- Add support for image download
- Add support for remote power off
