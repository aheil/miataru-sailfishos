import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {

    function getDatabase() {
        return LocalStorage.openDatabaseSync("miataru", "1.0",
                                             "StorageDatabase", 10000)
    }

    function setTitle(text) {
        header.title = qsTr("Details: " + text)
    }

    id: deviceDetailDialog

    property string originalDeviceIdentifier
    property string deviceIdentifier
    property string deviceName
    property color deviceColor

    anchors.fill: parent

    Column {
        id: column
        width: parent.width
        spacing: Theme.paddingLarge

        DialogHeader {
            id: header
        }

        TextField {
            id: deviceNameField
            width: parent.width
            label: qsTr("Device Name")

            onTextChanged: {
                setTitle(deviceNameField.text)
            }
        }

        TextArea {
            id: deviceIdentifierField
            readOnly: true
            width: parent.width
            label: qsTr("Device ID")
        }

        Rectangle {
            id: deviceColorIndicator
            color: deviceColor
            radius: 10
            opacity: 0.6
            width: parent.width - 2*Theme.paddingLarge
            height: Theme.itemSizeSmall
            border.color: Theme.primaryColor
            anchors.margins: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter

            MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var dialog = pageStack.push("Sailfish.Silica.ColorPickerDialog")
                                dialog.accepted.connect(function() {
                                    deviceColorIndicator.color = dialog.color
                                })
                    }
                }
        }
    }

    Component.onCompleted: {        
        setTitle(deviceName)
        deviceNameField.text = deviceName
        deviceIdentifierField.text = deviceIdentifier
    }

    onAccepted: {
        deviceColor = deviceColorIndicator.color
        deviceName = deviceNameField.text
        deviceIdentifier = deviceIdentifierField.text
    }
}
