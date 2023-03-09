TARGET = trollbridge
CONFIG += sailfishapp sailfishapp_i18n
INCLUDEPATH += .

lupdate_only {
SOURCES += \
    qml/$${TARGET}.qml \
    qml/pages/*.qml \
    qml/cover/*.qml \
    qml/components/*.qml

}


TRANSLATIONS += i18n/base.ts i18n/qml_de.ts

desktop.files = $${TARGET}.desktop
desktop.path = $$PREFIX/share/applications
INSTALLS += desktop

qml.files = qml
qml.path = $$PREFIX/share/$${TARGET}
INSTALLS += qml

OTHER_FILES += $$files(rpm/*)

