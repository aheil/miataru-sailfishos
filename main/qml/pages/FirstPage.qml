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
    id: page

    function getDatabase() {
        return LocalStorage.openDatabaseSync("miataru", "1.0",
                                             "StorageDatabase", 10000)
    }

    function initialize() {
        var db = getDatabase()
        var ver

        // create tables
        db.transaction(function (tx) {
            tx.executeSql("DROP TABLE IF EXISTS version")
            tx.executeSql("DROP TABLE IF EXISTS debug")
            tx.executeSql("CREATE TABLE IF NOT EXISTS db_version(ver TEXT UNIQUE)")
            tx.executeSql("CREATE TABLE IF NOT EXISTS settings(id TEXT UNIQUE, value TEXT)")
            tx.executeSql("CREATE TABLE IF NOT EXISTS devices(id TEXT UNIQUE, name TEXT)")
            tx.executeSql("CREATE TABLE IF NOT EXISTS debug(id TEXT UNIQUE, value TEXT)")
        })

        db.transaction(function(tx) {
            // upgrade to db_version 0.1
            var rs = tx.executeSql("SELECT ver from db_version")
            if (rs.rows.length < 1) {
                tx.executeSql("INSERT INTO db_version VALUES (?)", ["0.1"])
            }

            rs = tx.executeSql("SELECT ver from db_version")   
            ver = rs.rows.item(0).ver
            //console.log('Miataru - I found database version = ' + ver)

            // upgrade to db_version 0.2
            if(ver === '0.1') {
                tx.executeSql("ALTER TABLE devices ADD COLUMN color TEXT")
                tx.executeSql("UPDATE db_version SET ver = (?)", ["0.2"])
            }

            rs = tx.executeSql("SELECT ver from db_version")
            ver = rs.rows.item(0).ver
            console.log('Miataru - I found database version = ' + ver)

        })

        db.transaction(function (tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE id = 'serverUrl'")
            if (rs.rows.length === 0) {
                tx.executeSql("INSERT OR REPLACE INTO settings VALUES (?,?)", ['serverUrl', 'http://service.miataru.com'])
             }
        })
        db.transaction(function(tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE id = 'dataRetentionTime'")
            if (rs.rows.length ===0) {
                tx.executeSql("INSERT OR REPLACE INTO settings VALUES(?,?)", ['dataRetentionTime', '15'])
            }
        })
    }
            //if (ver.rows.length < 1) {
                    // Table Version
            //
            //

                    // Table Settings
            //
            //        var rs = tx.executeSql("SELECT value FROM settings WHERE id = 'serverUrl'")
            //        if (rs.rows.length === 0) {
            //
            //      }

                  // Table Devices
            //

            //ver = tx.executeSql("SELECT ver from version")
            //if (ver.rows.item(0).ver === '0.1') {
            //
            //    tx.executeSql("DROP table version") // ver 0.1 contained an error, therefore we reset it
            //    tx.executeSql("INSERT INTO version VALUES (?)", ["0.2"])
            //}

            //ver = tx.executeSql("SELECT ver from version")
            //if (ver.rows.item(0).ver === '0.2') {
                 //tx.executeSql("UPDATE version SET ver = '0.3'")
            //}




    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Debug")
                onClicked: pageStack.push(Qt.resolvedUrl("Debug.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsDialog.qml"))
            }

            MenuItem {
                text: qsTr("QR")
                onClicked: pageStack.push(Qt.resolvedUrl("QRPage.qml"))
            }

            MenuItem   {
                text: qsTr("Map")
                onClicked: pageStack.push(Qt.resolvedUrl("MapPage.qml"))
            }
            MenuItem {
                text: qsTr("Devices")
                onClicked: pageStack.push(Qt.resolvedUrl("DevicesPage.qml"))
            }          
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Miataru")
            }
            Label {
                x: Theme.paddingLarge
                text: qsTr("Welcome")
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
            }
            Text {
                text: "Welcome to Miataru for SailfishOS, the native SailfishOS client for the Miataru open source location tracking service. Please be aware, this is an early alpha version of this client with an limited set of functionality under active development. For more information please refer to http://www.miataru.com."
                wrapMode: Text.WordWrap
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeTiny
                horizontalAlignment: Text.AlignJustify
                width: parent.width - 2 * Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter

            }
            Image {
                   source: "qrc:pics/miataru-start.png"
                   anchors.horizontalCenter: parent.horizontalCenter
            }

            Component.onCompleted: {
                 initialize()
            }


        }
    }
}


