Name:       harbour-trollbridge
Summary:    TRaveller's OLympus Bridge
Version:    0.2.0
Release:    1
Group:      Applications/Multimedia
License:    MIT
#Source0: https://github.com/example/app/archive/v%{version}.tar.gz
Requires:   libsailfishapp-launcher
BuildRequires:  qt5-qttools-linguist
BuildRequires:  qt5-qmake
BuildRequires:  sailfish-svg2png
BuildRequires:  qml-rpm-macros
BuildRequires:  desktop-file-utils

%description
TRaveller's OLympus Bridge is an app for controlling Olympus OM-D/PEN/Air cameras with integrated WiFi.
%if "%{?vendor}" == "chum"
PackageName: Troll Bridge
Type: desktop-application
DeveloperName: Bundyo, nephros
DeveloperLogin: nephros
PackagerName: nephros
Categories:
 - Media
Custom:
  Repo: %{url}
Icon: %{url}/master/icons/template.svg
Screenshots:
 - %{url}/raw/metadata/screenshots/screenshot1.png
 - %{url}/raw/metadata/screenshots/screenshot2.png
 - %{url}/raw/metadata/screenshots/screenshot3.png
Url:
  Homepage: %{url}
  Help: %{url}/discussions
  Bugtracker: %{url}/issues
  Donations:
    - https://noyb.eu/en/donations-other-support-options
    - https://my.fsfe.org/donate
    - https://supporters.eff.org/donate/join-4
    - https://openrepos.net/donate
%endif

%prep

%
%qmake5 

make %{?_smp_mflags}

build

%install
rm -rf %{buildroot}
#%%qmake5_install
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
