#!/usr/bin/python3
import os
from pathlib import Path
import json
import pprint
#import collections
import pyotherside
from olympuswifi.camera import OlympusCamera, RequestError, ResultError
from olympuswifi.download import download_photos

def info():
    # this prints to stdout:  "Connected to..."
    camera.report_model()
    pprint.pprint(camera.get_commands(), indent=2, depth=1)
    infodata = {
        'model':      camera.get_camera_info()["model"],
        'headers':    camera.HEADERS,
        'url_prefix': camera.URL_PREFIX,
        'versions':   camera.get_versions(),
        'modes':      list(camera.get_supported()),
        #'commands':   camera.get_commands(),
        'commands':   list(camera.get_commands().keys()),
        'propertyInfo': camera.get_settable_propnames_and_values(),
    }
    print("Connection Mode:", getConnectMode())
    pyotherside.send("camerainfo", json.dumps(infodata, default=parseCmdDescr))

# simple parse helper for OlympusCamera.CmdDescr, just discard the method
# parameter and return args
def parseCmdDescr(o):
    if isinstance(o, OlympusCamera.CmdDescr):
        return (o.args)
    return super().default(o)

def getOptions(command):
    list = camera.get_commands()
    options = list[command].args
    return json.dumps(options)

def listImages(path):
    ilist = camera.list_images(path)
    return json.dumps(ilist, default=lambda o: o.__dict__)

def getThumbnail(path, out):
    print("Want thumb from", path, "to", out)
    data = camera.download_thumbnail(path)
    writeImage (data , out)
    pyotherside.send("thumbdownloaded")

def downloadImage( path, out, index, small):
    if small:
        print("Want small image from", path, "to", out)
        data = camera.send_command('get_resizeimg', DIR=path, size='2048').content
        writeImage (data , out)
    else:
        print("Want image from", path, "to", out)
        data = camera.download_image(path)
        writeImage (data , out)
    pyotherside.send("downloaded", index, small)

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

def getConnectMode():
    return camera.xml_query("get_connectmode")

def setClock():
    camera.set_clock()

def getFreeSpace():
    return camera.xml_query('get_unusedcapacity')

def writeImage (data , path):
    os.makedirs(Path(path).parent, mode=0o755, exist_ok=True)
    with open(path, 'wb') as f:
        f.write(data)

camera = OlympusCamera()


### QML image provider for Slideshow:
def image_provider(req_id, req_size):
    data = camera.send_command('get_resizeimg', DIR=req_id, size='1024').content
    return bytearray(data), (1024, 1024), pyotherside.format_data

pyotherside.set_image_provider(image_provider)


