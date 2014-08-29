
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
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0

Page {
    function getDatabase() {
        return LocalStorage.openDatabaseSync("miataru", "1.0",
                                             "StorageDatabase", 10000)
    }

    function loadDevices() {

        var db = getDatabase()
        db.transaction(function (tx) {
            var rs = tx.executeSql("SELECT * FROM devices")
            if (rs.rows.length > 0) {
                console.log("Devices found:" + rs.rows.length)
            } else {
                console.log("No devices found...")
            }

            for (var i = 0; i < rs.rows.length; i++) {
                devicesListView.model.append({
                                                 item_name: rs.rows.item(i).name,
                                                 item_id: rs.rows.item(i).id,
                                                 item_color: rs.rows.item(i).color
                                             })
            }
        })
    }

    function saveDevice(d) {
        var db = getDatabase()
        db.transaction(function (tx) {
            var rs = tx.executeSql(
                        "INSERT OR REPLACE INTO devices VALUES (?,?,?)",
                        [d.item_id, d.item_name, d.item_color])
            if (rs.rowsAffected > 0) {
                console.log('Device saved')
            } else {
                console.log('Device not saved...')
            }
        })
    }

    Component.onCompleted: {
        //initialize()
        loadDevices()
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        id: devicesPage

        PageHeader {
            title: qsTr("Devices")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Add this Jolla")
                onClicked: {
                    for (var i = 0; i < devicesModel.count; i++) {
                        if (devicesModel.get(i).item_id === deviceId)
                            return;
                    }

                    // TODO: This code is duplicated below, refactore!
                    devicesModel.append({
                                            item_name: qsTr("this Jolla"),
                                            item_id: deviceId,
                                            item_color: "red"

                    })
                    saveDevice({
                                            item_name: qsTr("this Jolla"),
                                            item_id: deviceId,
                                            item_color: "red"
                    })
                }
            }

            MenuItem {
                text: qsTr("Add Device")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl(
                                                    "AddDeviceDialog.qml"))
                    dialog.accepted.connect(function () {
                        devicesModel.append({
                                                item_name: dialog.deviceName,
                                                item_id: dialog.deviceIdentifier,
                                                item_color: dialog.deviceColor

                                            })
                        saveDevice({
                                       item_name: dialog.deviceName,
                                       item_id: dialog.deviceIdentifier,
                                       item_color: dialog.deviceColor
                                   })
                    })
                }
            }
        }

        SilicaListView {
            id: devicesListView
            property Item contextMenu

            model: ListModel {
                id: devicesModel
            }

            anchors.fill: parent

            header: PageHeader {
                title: qsTr("Devices")
            }

            ViewPlaceholder {
                enabled: devicesListView.count == 0
                text: qsTr("No Devices to display")
            }

            delegate: ListItem {
                id: contentItem
                menu: contextMenu
                width: parent.width

                    function remove() {
                        remorseAction("Deleting", function() {
                            var id = devicesModel.get(index).item_id;
                            var db = getDatabase();
                            db.transaction(function (tx) {
                                var rs = tx.executeSql(
                                            "DELETE FROM devices WHERE id = ?",
                                            [id]);
                            })
                            devicesModel.remove(index)
                        });
                    }

                    function openDetails() {
                        var id = devicesModel.get(index).item_id
                        var name = devicesModel.get(index).item_name
                        var color = devicesModel.get(index).item_color
                        var dialog = pageStack.push(Qt.resolvedUrl(
                                                        "DeviceDetailDialog.qml"), {
                                                        originalDeviceIdentifier: id,
                                                        deviceIdentifier:  id,
                                                        deviceName: name,
                                                        deviceColor: color
                                                    })

                        dialog.accepted.connect(function () {
                            devicesModel.setProperty(index, "item_name", dialog.deviceName)
                            devicesModel.setProperty(index, "item_color", dialog.deviceColor.toString())
                            saveDevice(devicesModel.get(index))
                        })
                    }

                    Row {
                        id: row
                        width: parent.width
                        spacing: Theme.paddingLarge

                        Label {
                            id: itemLabel
                            truncationMode: TruncationMode.Fade
                            anchors {
                                        verticalCenter: colorIndicator.verticalCenter
                                        left: parent.left
                                        right: colorIndicator.left
                                        margins: Theme.paddingLarge
                        }
                            text: item_name
                            color: contentItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        }


                        Rectangle {
                            id: colorIndicator
                            color: item_color
                            radius: 10
                            opacity: 0.6
                            width: 1.6 * (Theme.itemSizeSmall - 2*Theme.paddingSmall)
                            height: Theme.itemSizeSmall - 2*Theme.paddingSmall
                            border.color: Theme.primaryColor
                            anchors {
                                right: parent.right
                                margins: Theme.paddingLarge

                            }
                        }
                    } // Row

                    Component {
                        id: contextMenu
                        ContextMenu {
                            MenuItem {
                                text: qsTr("Details")
                                onClicked: openDetails()
                            }

                            MenuItem {
                                text: qsTr("Remove")
                                onClicked: remove()
                            }
                        }
                    } // Component

                } // ListItem


            }


           // } // Item

            VerticalScrollDecorator {
            }
        }
    }

