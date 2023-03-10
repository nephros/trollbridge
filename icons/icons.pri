TEMPLATE = aux
# Configures svg to png
THEMENAME = sailfish-default
INSTALLS += svg appicon

appicon.sizes = \
    86 \
    108 \
    128 \
    172 \
    256 \
    512 \
    1024

for(iconsize, appicon.sizes) {
    profile = $${iconsize}x$${iconsize}

    appicon.commands += /usr/bin/sailfish_svg2png \
        -z 1.0 -s 1 1 1 1 1 1 $${iconsize} \
        $${_PRO_FILE_PWD_}/icons/svgs \
        $${_PRO_FILE_PWD_}/icons/$${profile}/apps &&

    appicon.files += $${_PRO_FILE_PWD_}/icons/$${profile}
}
appicon.commands += true
appicon.path = $$PREFIX/share/icons/hicolor/

# also install SVG:
svg.path = $$PREFIX/share/icons/hicolor/scalable/apps
svg.files = $${_PRO_FILE_PWD_}/icons/svgs/$${TARGET}.svg
