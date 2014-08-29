/*
  Copyright (C) 2014 Andreas Heil
  Contact: Andreas Heil <info@aheil.de>
  All rights reserved.
*/

#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>

QString getMac()
{
    QString mac;
    QList<QNetworkInterface> lsnet = QNetworkInterface::allInterfaces();
    foreach (QNetworkInterface inet,lsnet) {
        if (!(inet.flags() & QNetworkInterface::IsLoopBack)) // && (inet.flags() & QNetworkInterface::IsRunning))
            mac = inet.hardwareAddress();
    }
    return mac;
}

QString deviceId() {
    QString mac = getMac();

    QByteArray hash = QCryptographicHash::hash(mac.toUtf8(), QCryptographicHash::Sha1);

    QString hashString = hash.toHex();

    hashString.insert(8, '-');
    hashString.insert(13, '-');
    hashString.insert(18, '-');
    hashString.insert(23, '-');
    hashString.insert(28, '-');
    hashString.insert(33, '-');
    hashString.insert(38, '-');

    hashString =  hashString.toUpper();

    return hashString;
}


int main(int argc, char *argv[])
{
        QString device_id = deviceId();

        QGuiApplication *app = SailfishApp::application(argc, argv);
        QQuickView *view = SailfishApp::createView();

        view->setSource(SailfishApp::pathTo("qml/Miataru.qml"));

        view->rootContext()->setContextProperty("deviceId", device_id);

        view->showFullScreen();

        int retVal = app->exec();

        delete view;
        delete app;

        return retVal;
}

