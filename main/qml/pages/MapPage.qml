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

    property string m_serverUrl
    property string m_dataRetentionTime

    function getDatabase() {
        return LocalStorage.openDatabaseSync("miataru", "1.0", "StorageDatabase", 10000)
    }

    function saveDebug(id, value) {
        var db = getDatabase()
        db.transaction(function (tx) {
             tx.executeSql("INSERT OR REPLACE INTO debug VALUES (?,?)", [id, value])
        })
    }

    function loadSetting(id) {
        var retVal
        var db = getDatabase();
        db.transaction(function (tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE id = '" + id +"'")
            retVal = rs.rows.item(0).value
        })
        return retVal
    }

    function sendMiataruRequest(lon, lat, acu) {
        var http = new XMLHttpRequest()
        // var url = "http://service.miataru.com/v1/UpdateLocation"
        var url = m_serverUrl + "/v1/UpdateLocation"
        http.open("POST", url, true)

        var reqObj = {}

        var MiataruConfig = {}
        MiataruConfig.EnableLocationHistory = "False"
        MiataruConfig.LocationDataRetentionTime = m_dataRetentionTime //"15"

        var MiataruLocation = []

        var l = {}
        l.Device = deviceId
        l.Timestamp = new Date().getTime()
        l.Longitude = '' + lon + ''
        l.Latitude = '' + lat + ''

        if (acu === null | acu === 0) {
            l.HorizontalAccuracy = '50.0'
        } else {
            l.HorizontalAccuracy = '' + acu + ''
        }

        MiataruLocation.push(l)

        reqObj.MiataruConfig = MiataruConfig
        reqObj.MiataruLocation = MiataruLocation

        var body = JSON.stringify(reqObj)
        saveDebug('updateLocationRequest', body)

        http.setRequestHeader("Content-type", "application/json")
        http.setRequestHeader("Content-length", body.length)
        http.setRequestHeader("Connection", "close")

        //http.withCredentials = true
        http.onreadystatechange = function () {
            // Call a function when the state changes.
            if (http.readyState === XMLHttpRequest.DONE) {
                if (http.status == 200) {
                    //console.log("ok (200)")
                    //console.log(http.responseText)
                     saveDebug('updateLocationResponse', http.responseText)
                } else {
                    console.log("error: " + http.status)
                    console.log(http.responseText)
                }
            }
        }
        http.send(body)
    }

    function loadDevices() {
        var devices = []

        var db = getDatabase()
        db.transaction(function (tx) {
            var rs = tx.executeSql("SELECT * FROM devices")
            if (rs.rows.length > 0) {
                console.log("Devices found:" + rs.rows.length)
            } else {
                console.log("No devices found...")
            }

            for (var i = 0; i < rs.rows.length; i++) {
                devices.push({
                                 name: rs.rows.item(i).name,
                                 id: rs.rows.item(i).id,
                                 color: rs.rows.item(i).color,
                                 latitude: 0.0,
                                 longitude: 0.0
                             })
                console.log("loaded device (name, color): " + rs.rows.item(i).name + ", " + rs.rows.item(i).color)
            }
        })
        return devices
    }

    function getMiataruDeviceInformation() {
        var devices = loadDevices()
        console.log(devices.length + " devices loadet from databse")

        var MiataruGetLocation = []

        devices.forEach(function (d) {
            MiataruGetLocation.push({
                                        Device: d.id
                                    })
        })

        var reqObj = {}
        reqObj.MiataruGetLocation = MiataruGetLocation

        var body = JSON.stringify(reqObj)

        //console.log("+++ JSON Output:")
        //console.log(body)
        saveDebug('getLocationRequest', body)

        var http = new XMLHttpRequest()
        // var url = "http://service.miataru.com/v1/GetLocation"
        var url = m_serverUrl + "/v1/GetLocation"
        http.open("POST", url, true)

        http.setRequestHeader("Content-type", "application/json")
        http.setRequestHeader("Content-length", body.length)
        http.setRequestHeader("Connection", "close")

        http.onreadystatechange = function () {
            // Call a function when the state changes.
            if (http.readyState === XMLHttpRequest.DONE) {
                if (http.status == 200) {

                    //console.log("ok (200)")
                    //console.log(http.responseText)
                    saveDebug('getLocationResponse', http.responseText)

                    var request = JSON.parse(http.responseText)
                    var miataruLocation = request.MiataruLocation

                    miataruLocation.forEach(function(ml) {

                        if (ml !== null) {
                           //console.log("Color: " + d.color)

                            // TODO: here we could copy the location as well and use the location from the devices (especially when using timers later on)
                            var device
                            devices.forEach(function(d) {
                                if (d.id === ml.Device) {
                                    device = d;
                                }
                            })

                            var newCircle = Qt.createQmlObject('import QtQuick 2.0;import QtLocation 5.0; MapCircle {color: "'+ device.color +'"; opacity: 0.6; radius: 3000; }',map, ml.Device);
                            newCircle.center =  QtPositioning.coordinate(ml.Latitude, ml.Longitude)//map.toCoordinate(Qt.point(mouse.x,(mouse.y - titleBar.height)));

                            //Script.myCirclesArray.push(newCircle);
                            map.addMapItem(newCircle);
                        }
                    })
                } else {
                    console.log("error: " + http.status)
                    console.log(http.responseText)
                }
            }
        }
        http.send(body)
    }

    PositionSource {
        id: src
        active: true

        onPositionChanged: {
            // TODO: Update on time intervall
            var coord = src.position.coordinate;
            sendMiataruRequest(coord.longitude, coord.latitude, src.position.horizontalAccuracy * 1.0)
            getMiataruDeviceInformation()
        }
    }

    PageHeader {
        title: qsTr("Map")
    }

    Map {
        id: map
        anchors.fill: parent
        zoomLevel: 1

        center: QtPositioning.coordinate(latitude, longitude)

        Component.onCompleted: {
            m_serverUrl = loadSetting('serverUrl')
            m_dataRetentionTime = loadSetting('dataRetentionTime')

            src.start()
            map.center = src.position.coordinate;

            if (map.center.latitude === 0 && map.center.longitude === 0) {
                map.center.longitude =  8.4040
                map.center.latitude = 49.0092
            }

            sendMiataruRequest(map.center.longitude, map.center.latitude, 50.0)
            getMiataruDeviceInformation()
        }

        //connectivityMode: Map.OfflineMode;
        plugin: Plugin {
            id: plugin
            allowExperimental: true
            preferred: ["nokia", "osm"]
            required.mapping: Plugin.AnyMappingFeatures
            required.geocoding: Plugin.AnyGeocodingFeatures
            // TODO: Values should be replaced in build process from config file to be excluded from source code
            parameters: [
                PluginParameter {
                    name: "app_id"
                    value: "---app_id---"
                },
                PluginParameter {
                    name: "token"
                    value: "---token---"
                }
            ]
        }
    }
}
