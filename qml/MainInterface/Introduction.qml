import QtQuick 2.12
import an.window 1.0
import "../MyWidgets"

FramelessWindow
{
    id: root
    width: 250
    height: 120
    actualHeight: height
    actualWidth: width
    topHint: true
    visible: true

    property var info;  //ItemInfo info

    function fadeAway()
    {
        fadingAnimation.start();
    }

    Component.onCompleted:
    NumberAnimation
    {
        target: root
        property: "opacity"
        from: 0
        to: 1
        duration: 300
    }

    NumberAnimation
    {
        id: fadingAnimation
        target: root
        running: false
        property: "opacity"
        to: 0
        duration: 300
        onStopped: root.close();
    }

    Image
    {
        id: img
        source: info.headImage
        width: root.height
        height: width
        mipmap: true
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle
    {
        anchors.left: img.right
        anchors.right: parent.right
        height: parent.height

        Text
        {
            id: nickname
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 8
            color: "#ED1C24"
            font.pointSize: 14
            font.family: "微软雅黑"
            text: info.nickname
        }

        Text
        {
            id: signature
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.top: nickname.bottom
            anchors.topMargin: 5
            color: "#ED5124"
            font.pointSize: 10
            font.family: "微软雅黑"
            text: info.signature
            elide: Text.ElideRight
        }

        Text
        {
            id: level
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: signature.bottom
            anchors.topMargin: 5
            color: "#ED5124"
            font.pointSize: 10
            font.family: "微软雅黑"
            text: qsTr("等级：")
        }

        MyLevel
        {
            level: info.level
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.top: level.bottom
        }
    }
}
