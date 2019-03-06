import QtQuick 2.12
import QtGraphicalEffects 1.12

Item
{
    id: root
    width: 80
    height: 80

    property int radius: width * 0.5;    //默认宽度的一半
    property alias source: image.source;
    property alias mipmap: image.mipmap;
    property alias fillMode: image.fillMode;

    Image
    {
        id: image
        sourceSize: Qt.size(parent.width, parent.height)
        mipmap: true
        visible: false
    }

    Rectangle
    {
        id: mask
        anchors.fill: parent
        radius: root.radius
    }

    OpacityMask
    {
        anchors.fill: parent
        source: image
        maskSource: mask
    }
}
