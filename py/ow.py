#!/usr/bin/python3
import os
import json
import pprint
#import collections
import pyotherside
from olympuswifi.camera import OlympusCamera, RequestError, ResultError
from olympuswifi.download import download_photos

def info():
    print(camera.report_model())
    print("Camera Info:")
    print("HEADERS:", camera.HEADERS)
    print("URL_PREFIX:", camera.URL_PREFIX)
    print("Versions:", camera.get_versions())
    print("Supported Modes:", camera.get_supported())
    #print("Commands:", json.dumps(camera.get_commands(), indent=2, default=lambda o: o.__dict__))
    print("Known Commands:")
    pprint.pprint(camera.get_commands(), indent=2, depth=1)
    print("Known properties:")
    pprint.pprint(camera.get_settable_propnames_and_values(), indent=2, depth=1)

def listImages(path):
    ilist = camera.list_images(path)
    return json.dumps(ilist, default=lambda o: o.__dict__)

def getThumbnail(path, out):
    print("Want thumb from", path, "to", out)
    data = camera.download_thumbnail(path)
    writeImage (data , out)
    pyotherside.send("thumb")

def downloadImage( path, out, index, small):
    if small:
        print("Want small image from", path, "to", out)
        data = camera.send_command('get_resizeimg', DIR=path, size='2048').content
        writeImage (data , out)
    else:
        print("Want image from", path, "to", out)
        data = camera.download_image(path)
        writeImage (data , out)
    pyotherside.send("downloaded", index)

def sendCommand(cmd, args):
    print("Command: ", cmd, "args", args)
    #cmddesc = camera.CmdDescr( "get", args)
    ret = None
    if camera.check_valid_command(cmd, args):
        ret = camera.xml_query(cmd, args)
    print(ret)
    return ret

def getProperty(name):
     return camera.get_camprop(name)

def getCameraModel():
    return camera.get_camera_info()

def getFreeSpace():
    #ret = camera.send_command('get_unusedcapacity').content
    ret = camera.xml_query('get_unusedcapacity')
    return ret

def writeImage (data , path):
    with open(path, 'wb') as f:
        f.write(data)

camera = OlympusCamera()
