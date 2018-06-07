import QtQuick 2.7
import QtGraphicalEffects 1.0

Item
{
    id: root
    width: 80
    height: 80

    property int radius: width >> 1;
    property alias source: imgae.source;
    property alias mipmap: imgae.mipmap;

    Image
    {
        id: imgae
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
        source: imgae
        maskSource: mask
    }
}
