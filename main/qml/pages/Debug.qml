
/*
  Copyright (C) 2013 Jolla Ltd.
    Contact: Thomas Perl <thomas.perl@jollamobile.com>
      All rights reserved.

        You may use this file under the terms of BSD license as follows:

          Redistribution and use in source and binary forms, with or without
            modification, are permitted provided that the following conditions are met:
                * Redistributions of source code must retain the above copyright
                      notice, this list of conditions and the following disclaimer.
                          * Redistributions in binary form must reproduce the above copyright
                                notice, this list of conditions and the following disclaimer in the
                                      documentation and/or other materials provided with the distribution.
                                          * Neither the name of the Jolla Ltd nor the
                                                names of its contributors may be used to endorse or promote products
                                                      derived from this software without specific prior written permission.

                                                        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
                                                          ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
                                                            WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
                                                              DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
                                                                ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
                                                                  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
                                                                    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
                                                                      ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
                                                                        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
                                                                          SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
