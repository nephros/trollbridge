#!/usr/bin/python3
from binascii import a2b_base64
#import base64
import pyotherside
import pycurl # we use this instead of Requests because it is pre-installed on SFOS
import StringIO


def downloadList (model, mode):
    print "NOT IMPLEMENTED."

def getAndWriteImage (url , path):
    hbuf = StringIO.StringIO()
    with open(path, 'wb') as f:
        c = pycurl.Curl()
        c.setopt(c.URL, url)
        c.setopt(c.WRITEDATA,f)
        c.setopt(c.HTTPHEADER, ['User-Agent:', 'OlympusCameraKit' ])
        c.setopt(c.HTTPHEADER, ['Host:', '192.168.0.10' ])
        c.setopt(c.HEADERFUNCTION, hbuf.write)
        c.perform
        c.close
        header = hbuf.getvalue()
        print header

def writeImage (data , path):
    #rawdata = base64.b64decode(data)
    rawdata = a2b_base64(data)
    with open(path, 'wb') as f:
        f.write(rawdata)
    pyotherside.send("write done",)
