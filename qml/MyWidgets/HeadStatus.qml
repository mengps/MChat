import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import an.chat 1.0

GlowCircularImage
{
    id: root
    radius: width / 2
    glowColor: "black"
    glowRadius: 8

    property bool mouseEnable: false

    signal clicked();
    signal entered();
    signal exited();

    function toColor(arg)
    {
        switch (arg)
        {
        case "  在线":
            return "green";
        case "  隐身":
            return "yellow";
        case "  忙碌":
            return "red";
        case "  离线":
            return "gray";
        }
    }

    ComboBox
    {
        id: status
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 15
        height: width
        z: 1
        currentIndex: chatManager.chatStatus
        model: [qsTr("  在线"), qsTr("  隐身"), qsTr("  忙碌"), qsTr("  离线")]

        style: ComboBoxStyle
        {
            textColor: "#000"
            background: Rectangle
            {
                width: status.width
                height: width
                radius: width / 2
                border.color: Qt.darker(color);
                border.width: status.hovered ? 2 : 0
                //color: toColor(status.currentIndex)
            }
        }
       onActivated:
       {
           console.log("combox index :", index);
           chatManager.chatStatus = index;
       }
    }

    MouseArea
    {
        id: imageMouseAre
        enabled: root.mouseEnable
        anchors.fill: parent
        hoverEnabled: true

        onEntered:
        {
            cursorShape = Qt.PointingHandCursor;
            root.entered();
        }

        onExited:
        {
            cursorShape = Qt.ArrowCursor;
            root.exited();
        }

        onClicked:
        {
            root.clicked();
        }
    }
}
