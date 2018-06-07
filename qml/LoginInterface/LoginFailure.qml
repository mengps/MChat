import QtQuick 2.7
import "../MyWidgets"

Item
{
    id: root
    visible: false
    width: loginInterface.width
    height: 0
    anchors.centerIn: parent

    property string errorString;

    Connections
    {
        target: networkManager
        onLoginError:
        {
            root.errorString = error;
            root.visible = true;
            showAnimation.restart();
        }
    }

    NumberAnimation
    {
        id: showAnimation
        target: root
        to: loginInterface.height
        running: false
        property: "height"
        duration: 400
    }

    NumberAnimation
    {
        id: hideAnimation
        target: root
        to: 0
        running: false
        property: "height"
        duration: 300
        onStopped: root.visible = false;
    }

    MoveMouseArea
    {
        anchors.fill: parent
        target: loginInterface
    }

    Rectangle
    {
        anchors.fill: parent
        radius: 8
        color: "#F9F4D5"

        Text
        {
            color: Qt.lighter("#333")
            lineHeight : 1.6
            wrapMode: Text.WrapAnywhere
            anchors.fill: parent
            anchors.margins: 70
            font.family: "微软雅黑"
            font.pointSize: 10
            horizontalAlignment: Text.AlignHCenter
            text: root.errorString
        }
    }

    MyButton
    {
        id: forgetButton
        hoverColor: "#D0D0D0"
        anchors.bottom: cancelButton.bottom
        anchors.right:cancelButton.left
        anchors.rightMargin: 15
        text: qsTr("找回密码")
    }

    MyButton
    {
        id: cancelButton
        hoverColor: "#D0D0D0"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 15
        text: qsTr("取消")
        onReleased:
        {
            cancelLogin.clicked();
            hideAnimation.restart();
        }
    }
}
