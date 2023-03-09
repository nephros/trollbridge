import QtQuick 2.1

QtObject {
    property var model
    property bool connected
    property bool downloading
    property string version
    function switchState(){}
    function switchMode(){}
    property bool opc
    function clearAllSelection(){}
    function downloadSelected(how) {}
    function setSelection(index, selected){}
    function shutterToggle(pressed){}
    function halfWayToggle(pressed){}
    function getFileList() {}
}

// vim: ft=javascript nu expandtab ts=4 sw=4 st=4
