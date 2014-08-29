/*
  Copyright (C) 2014 Andreas Heil
  Contact: Andreas Heil <info@aheil.de>
  All rights reserved.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.0
import QtLocation 5.0
import QtQuick.LocalStorage 2.0

Page {
    id: page

    function getDatabase() {
        return LocalStorage.openDatabaseSync("miataru", "1.0",
                                             "StorageDatabase", 10000)
    }

    function loadDebug(id) {
        var retVal
        var db = getDatabase()
        db.transaction(function (tx) {
            var rs = tx.executeSql("SELECT * FROM debug WHERE id ='" + id + "'")
            retVal = rs.rows.item(0).value
        })
        return retVal
    }

    PositionSource {
        id: src
        active: true

        onPositionChanged: {
            var coord = src.position.coordinate
            console.log("Coordinate:", coord.longitude, coord.latitude)

            lon.text = "Longitude: " + coord.longitude
            lat.text = "Latitude: " + coord.latitude
            acu.text = "Accuracy: " + src.position.horizontalAccuracy
        }
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height
        VerticalScrollDecorator { flickable: flickable }
        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Debug Information")
            }

            Text {
                id: lon
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeTiny
                horizontalAlignment: Text.AlignJustify
                width: parent.width - 2 * Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Longitude: "
            }

            Text {
                id: lat
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeTiny
                horizontalAlignment: Text.AlignJustify
                width: parent.width - 2 * Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Latitude: "
            }

            Text {
                id: accuracy
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeTiny
                horizontalAlignment: Text.AlignJustify
                width: parent.width - 2 * Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Accuracy: "
            }

            Text {
                id: id
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeTiny
                horizontalAlignment: Text.AlignLeft
                width: parent.width - 2 * Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Device ID: " + deviceId
            }

            Text {
                id: updateLocationRequest
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeTiny
                horizontalAlignment: Text.AlignLeft
                width: parent.width - 2 * Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: "updateLocationRequest: " + loadDebug(
                          'updateLocationRequest')
            }

            Text {
                id: updateLocationResponse
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeTiny
                horizontalAlignment: Text.AlignLeft
                width: parent.width - 2 * Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: "updateLocationResponse: " + loadDebug(
                          'updateLocationResponse')
            }

            Text {
                id: getLocationRequest
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeTiny
                horizontalAlignment: Text.AlignLeft
                width: parent.width - 2 * Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: "getLocationRequest: " + loadDebug('getLocationRequest')
            }

            Text {
                id: getLocationResponse
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeTiny
                horizontalAlignment: Text.AlignLeft
                width: parent.width - 2 * Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: "getLocationResponse: " + loadDebug('getLocationResponse')
            }
        }
    }
}
