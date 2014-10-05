/*
  Copyright (C) 2014 Andreas Heil
  Contact: Andreas Heil <info@aheil.de>
  All rights reserved.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    PageHeader {
        title: qsTr("Device QR Code")
    }

    // Using http://qrickit.com/qrickit_apps/qrickit_api.php

    Image {
        id: qrImage

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        source: "http://qrickit.com/api/qr?d=" + deviceId
    }

    Text {
        id: qrString
        text: deviceId;
        color: Theme.primaryColor
        horizontalAlignment: Text.AlignCenter
        font.pointSize: qrLabel.font.pointSize * 0.6

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: qrImage.bottom
            topMargin: 10
        }
    }

    Text {
        id: qrLabel
        text: qsTr("Scan the above QR Code to add this device to the Device List.")
        color: Theme.primaryColor
        width: parent.width
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: qrString.bottom
            topMargin: 40

        }
    }
}
