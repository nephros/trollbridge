#!/usr/bin/python3
import os
import pyotherside
import pycurl # we use this instead of Requests because it is pre-installed on SFOS
from binascii import a2b_base64
#try:
#    from io import BytesIO
#except ImportError:
#    from StringIO import StringIO as BytesIO
#from StringIO import StringIO

curDLs = 0
maxDLs = 2
hostaddr = "http://192.168.0.10/"
qSize = 2048
downloadPath = ""

def setDownloadPath(p):
    global downloadPath
    downloadPath = p

def addDownload():
    global curDLs
    curDLs += 1
    pyotherside.send("queued", curDLs)

def delDownload():
    global curDLs
    curDLs += 1
    pyotherside.send("queued", curDLs)

def xhrbin(url, name, path):
    getAndWriteImage(url,path)

def downloadList (mode, imglist):
    global downloadPath
    #print ("NOT IMPLEMENTED.\n")
    print  ("model count", len(imglist))
    limit = min(len(imglist), maxDLs)
    for i in range(0,limit):
        e = imglist.pop(0)
        print("E:", e)
        url  = ""
        path = ""
        if (mode == "thumb"):
            url = hostaddr + "get_thumbnail.cgi?DIR=" + e.path + "/" + e.file
            path = e.trollPath
        if (mode == "imagesmall"):
            url = hostaddr + "get_resizeimg.cgi?DIR=" + e.path + "/" + e.file + "&size=" + qSize
            path = downloadPath
        if (mode == "image"):
            url = hostaddr + "file?DIR=" + e.path + "/" + e.file
            path = downloadPath
        addDownload()
        getAndWriteImage(url, path)
    pyotherside.send("dlModelChanged", imglist )

def assertPathExists(path):
    #pathlib.Path(path).mkdir(parents=True, exist_ok=True) # make sure target path exists
    os.makedirs(path, exist_ok=True) # make sure target path exists

def getAndWriteImage (url , path):
    assertPathExists(os.path.abspath(os.path.join(path,os.pardir)))
    #hbuf = StringIO.StringIO() # store response headers here
    with open(path, 'wb') as f:
        c = pycurl.Curl()
        c.setopt(c.URL, url)
        c.setopt(c.WRITEDATA,f)
        c.setopt(c.HTTPHEADER, ['User-Agent:', 'OlympusCameraKit' ])
        c.setopt(c.HTTPHEADER, ['Host:', '192.168.0.10' ])
        #c.setopt(c.HEADERFUNCTION, hbuf.write)
        c.perform
        c.close
        #header = hbuf.getvalue()
        #print (header)
        pyotherside.send("imgDLFinished", path)

def writeImage (data , path):
    #rawdata = base64.b64decode(data)
    rawdata = a2b_base64(data)
    with open(path, 'wb') as f:
        f.write(rawdata)
    pyotherside.send("write done",)
