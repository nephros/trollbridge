Name:       harbour-trollbridge
Summary:    TRaveller's OLympus Bridge
Version:    0.2.0
Release:    1
Group:      Applications/Multimedia
License:    MIT
Source:     %{name}-%{version}.tar.gz
Requires:   libsailfishapp-launcher
BuildRequires:  qt5-qttools-linguist
BuildRequires:  qt5-qmake
BuildRequires:  sailfish-svg2png
BuildRequires:  qml-rpm-macros
BuildRequires:  desktop-file-utils
BuildArch: noarch

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
Icon: %{url}/master/icons/svgs/%{name}.svg
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
%setup -q -n %{name}-%{version}

%build
%qmake5 

#make %%{?_smp_mflags}


%install
rm -rf %{buildroot}
%qmake5_install

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/applications/*.desktop
%dir %{_datadir}/%{name}
%{_datadir}/%{name}/qml/*
%{_datadir}/%{name}/translations/%{name}-*.qm
%{_datadir}/icons/hicolor/*/apps/%{name}.png
%{_datadir}/icons/hicolor/*/apps/%{name}.svg

%changelog

* Fri Mar 10 2023 nephros 0.2.0
- rewrite Go parts in JavaScript

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
