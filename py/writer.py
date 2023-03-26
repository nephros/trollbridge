from binascii import a2b_base64
import pyotherside

def writeImage (fname, type, path, data):
    rawdata = a2b_base64(data)
    with open(path + '/' + fname, 'wb') as f:
            f.write(rawdata)
    pyotherside.send("write done",)
