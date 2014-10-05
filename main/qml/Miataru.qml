/*
  Copyright (C) 2014 Andreas Heil
  Contact: Andreas Heil <info@aheil.de>
  All rights reserved.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
}
