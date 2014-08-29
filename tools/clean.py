import os
import shutil
import tempfile

bakfile = "qml/pages/MapPage.qml.bak"
open (bakfile, "w").close ()
targetfile = "qml/pages/MapPage.qml"
print bakfile, "=>", targetfile

shutil.copy (bakfile, targetfile)
os.remove(bakfile)

#if os.path.isfile (filename2): print "Success"