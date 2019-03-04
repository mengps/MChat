import QtQuick 2.7
import QtQuick.Controls 2.5

ToolTip
{
    id: root
    font.family: "微软雅黑"
    opacity: 0
    background: Rectangle
    {
        border.color: "#888"
        border.width: 1
    }

    NumberAnimation
    {
        id: animation
        target: root
        running: false
        property: "opacity"
        from: 0
        to: 1
        duration: 700
        easing.type: Easing.InOutQuad
    }

    onVisibleChanged: if (visible) animation.restart();
}
