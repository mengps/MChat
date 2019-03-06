import QtQuick 2.12

Item
{
    id: root

    property bool hovered: false
    property bool checked: false
    property alias text: name.text
    property alias color: name.color
    property alias rectWidth: rect.width
    property alias rectHeight: rect.height

    Rectangle
    {
        id: rect
        border.color: hovered ? "#728965" : "#92BE6C";
        border.width: 1

        Image
        {
            anchors.fill: parent
            source: root.checked ? "qrc:/image/WidgetsImage/checked.png" : "";
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

    MouseArea
    {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true;
        onExited: root.hovered = false;
        onClicked: root.checked = !root.checked;
    }
}
