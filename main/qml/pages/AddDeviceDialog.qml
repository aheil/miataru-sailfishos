/*
  Copyright (C) 2014 Andreas Heil
  Contact: Andreas Heil <info@aheil.de>
  All rights reserved.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: addDeviceDialog
    property string deviceName
    property string deviceIdentifier
    property string deviceColor;

    anchors.fill: parent

    DialogHeader {
        title: qsTr("Add a Device")
    }

    TextField {    
        id: deviceNameField
        width: parent.width
        placeholderText: qsTr("Enter Device Name")
        label: qsTr("Device Name")

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
    }

    TextArea {
        id: deviceIdentifierField
        width: parent.width
        placeholderText: qsTr("Enter Device ID")
        label: qsTr("Device ID")

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: deviceNameField.bottom
            topMargin: 10
        }
    }

    onDone: {
        if (result == DialogResult.Accepted) {
            deviceName = deviceNameField.text
            deviceIdentifier = deviceIdentifierField.text
            deviceColor = "red" // it's our default color
        }
    }
}


