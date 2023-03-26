#!/usr/bin/python3
from binascii import a2b_base64
#import base64
import pyotherside
import pycurl

def downloadList (model, mode):


def writeImage (data , path):
    #rawdata = base64.b64decode(data)
    rawdata = a2b_base64(data)
    with open(path, 'wb') as f:
        f.write(rawdata)
    pyotherside.send("write done",)
