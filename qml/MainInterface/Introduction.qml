import QtQuick 2.12
import an.window 1.0
import "../MyWidgets"

FramelessWindow
{
    id: root
    width: 250
    height: 120
    actualHeight: height + 8
    actualWidth: width + 8
    topHint: true
    visible: true

    property var info;  //ItemInfo info
    property alias gradient: rect.gradient

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
        duration: 400
        easing.type: Easing.InQuad
        onStopped: root.close();
    }

    GlowRectangle
    {
        id: rect
        glowRadius: 4
        glowColor: "white"
        width: root.width
        height: root.height
        anchors.centerIn: parent

        Image
        {
            id: image
            source: info.headImage
            width: root.height
            height: width
            anchors.verticalCenter: parent.verticalCenter
            mipmap: true
            fillMode: Image.PreserveAspectCrop
        }

        Text
        {
            id: nickname
            anchors.left: image.right
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
            anchors.left: image.right
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
            anchors.left: image.right
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
            anchors.left: image.right
            anchors.leftMargin: 4
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.top: level.bottom
        }
    }
}
