# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = Miataru

CONFIG += sailfishapp

SOURCES += src/Miataru.cpp

OTHER_FILES += qml/Miataru.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/Miataru.spec \
    rpm/Miataru.yaml \
    translations/*.ts \
    Miataru.desktop \
    qml/pages/SettingsDialog.qml \
    qml/pages/QRPage.qml \
    qml/pages/MapPage.qml \
    qml/pages/DevicesPage.qml \
    qml/pages/AddDeviceDialog.qml \
    rpm/Miataru.changes \
    qml/pages/Debug.qml \
    qml/pages/DeviceDetailDialog.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/Miataru-de.ts

RESOURCES += \
    pics.qrc

