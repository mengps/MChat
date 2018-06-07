import QtQuick 2.7
import QtQuick.Controls 2.2

ToolTip
{
    id: root
    opacity: 0

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
