import QtQuick 2.12

Rectangle
{
    id: root
    width: 70
    height: 20
    radius: 2
    color: hovered ? hoverColor : "transparent"
    clip: true

    property bool hovered: false;
    property bool checked: false;
    property color hoverColor: "#BBB";
    property color radioColor: "#444";
    property alias text: name.text;
    property alias font: name.font;
    property alias textColor: name.color;

    MouseArea
    {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true;
        onExited: root.hovered = false;
        onClicked: root.checked = !root.checked;
    }

    Rectangle
    {
        id: circle1
        anchors.left: parent.left
        anchors.leftMargin: 3
        anchors.verticalCenter: parent.verticalCenter
        width: root.height - 6
        height: width
        antialiasing: true
        color: "transparent"
        border.color: root.radioColor

        Rectangle
        {
            visible: root.checked
            anchors.centerIn: parent
            width: parent.width * 0.5
            height: width
            color: parent.border.color
        }
    }

    Text
    {
        id: name
        anchors.left: circle1.right
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
    }
}
