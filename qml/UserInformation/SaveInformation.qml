import QtQuick 2.7
import an.framelessWindow 1.0
import "../MyWidgets"

FramelessWindow
{
    id: root

    width: 220
    height: 120
    actualWidth: width
    actualHeight: height
    visible: true
    topHint: true
    taskbarHint: true

    signal save();

    MoveMouseArea
    {
        anchors.fill: parent
        target: root
    }

    Rectangle
    {
        anchors.fill: parent
        color: "#88d3d2"
        radius: 8

        CusButton
        {
            id: closeButton
            width: 34
            height: 24
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
                buttonDisableImage = "qrc:/image/ButtonImage/close_disable.png";
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
