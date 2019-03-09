import QtQuick 2.12
import an.window 1.0
import "../MyWidgets"

FramelessWindow
{
    id: root

    width: 220
    height: 120
    actualWidth: width + 14
    actualHeight: height + 14
    visible: true
    topHint: true
    taskbarHint: true

    signal save();

    MoveMouseArea
    {
        anchors.fill: parent
        target: root
    }

    GlowRectangle
    {
        id: content
        anchors.centerIn: parent
        width: root.width
        height: root.height
        color: "white"
        glowColor: "#12F2D6"
        radius: 6
        glowRadius: 5
        antialiasing: true
        opacity: 0.85

        CusButton
        {
            id: closeButton
            width: 32
            height: 32
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.top: parent.top
            anchors.topMargin: 6
            onClicked: root.close();
            Component.onCompleted:
            {
                buttonNormalImage = "qrc:/image/ButtonImage/close_normal.png";
                buttonPressedImage = "qrc:/image/ButtonImage/close_down.png";
                buttonHoverImage = "qrc:/image/ButtonImage/close_hover.png";
            }
        }

        Text
        {
            color: Qt.lighter("black")
            lineHeight : 1.6
            anchors.centerIn: parent
            font.family: "微软雅黑"
            font.pointSize: 10
            text: qsTr("有未保存的改变，是否保存？")
        }

        MyButton
        {
            id: saveButton
            text: qsTr("保存更改")
            hoverColor: "#F9ECEC"
            anchors.right: exitButton.left
            anchors.rightMargin: 15
            anchors.bottom: exitButton.bottom
            onClicked:
            {
                root.save();
                root.close();
            }
        }

        MyButton
        {
            id: exitButton
            text: qsTr("退出")
            hoverColor: "#F9ECEC"
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            onClicked:
            {
                root.closed();
                root.close();
            }
        }
    }
}
