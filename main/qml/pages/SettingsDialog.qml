import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0

Dialog {
    function getDatabase() {
        return LocalStorage.openDatabaseSync("miataru", "1.0", "StorageDatabase", 10000)
    }

    function save(id, value) {
        var db = getDatabase();
        db.transaction(function (tx) {
            tx.executeSql("INSERT OR REPLACE INTO settings VALUES (?,?)", [id, value])
            console.log("saved into table settings (" + id, ", " + value + ")")
        })
    }

    Component.onCompleted: {
        var db = getDatabase();
        // load serverUrl
        db.transaction(function (tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE id = 'serverUrl'")
            serverUrlField.text = rs.rows.item(0).value
        })
        // load dataRetentionTime
        db.transaction(function (tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE id ='dataRetentionTime'")
            dataRetentionTimeField.text = rs.rows.item(0).value
        })
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.paddingLarge

        DialogHeader {
            id: header
            title: qsTr("Settings")
        }

        TextField {
            id: serverUrlField
            width: parent.width
            placeholderText: qsTr("Server-Url")
            label: qsTr("Server-Url")
        }

        TextField {
            id: dataRetentionTimeField
            width: parent.width
            validator: IntValidator { bottom: 15; top: 1440 }
            placeholderText: qsTr("Server Data Retention Time")
            label: qsTr("Server Data Retention Time")
        }
    }

    onDone:
    {
       // let's save it anyway
       //if (result === DialogResult.Accepted) {
        save('serverUrl', serverUrlField.text)
        save('dataRetentionTime', dataRetentionTimeField.text)
       //}
    }
}
