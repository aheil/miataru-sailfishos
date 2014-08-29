import os
import shutil
import tempfile

originalfile = "qml/pages/MapPage.qml"
open (originalfile, "w").close ()
bakfile = "qml/pages/MapPage.qml.bak"
print originalfile, "=>", bakfile

shutil.copy (originalfile, bakfile)

#if os.path.isfile (bakfile): print "Success"