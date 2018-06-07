import QtQuick 2.7

Item
{
    id: root
    property alias text: name.text
    property alias color: name.color
    property alias checked: rect.checked
    property alias rectWidth: rect.width
    property alias rectHeight: rect.height

    Rectangle
    {
        id: rect
        border.color: hovered ? "#728965" : "#92BE6C";
        border.width: 1
        property bool hovered: false
        property bool checked: false

        Image
        {
            anchors.fill: parent
            source: rect.checked ? "qrc:/image/WidgetsImage/checked.png" : "";
        }

        MouseArea
        {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: rect.hovered = true;
            onExited: rect.hovered = false;
            onClicked: rect.checked = !rect.checked;
        }
    }

    Text
    {
        id: name
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        height: rect.height
        font.pointSize: height / 1.5
        font.family: "微软雅黑"
        anchors.left: rect.right
        anchors.leftMargin: 8
        anchors.verticalCenter: rect.verticalCenter
    }
}
