import QtQuick 2.12
import QtQuick.Controls 2.12
import an.window 1.0
import an.chat 1.0

FramelessWindow
{
    id: root
    width: 240
    height: Math.min(240, myModel.count * 44 + 32 + 40)
    actualWidth: width + 10
    actualHeight: height + 10
    topHint: true

    property bool hovered: false;
    property var infoList: new Array;

    signal stopFlicker();

    onEntered:
    {
        hovered = true;
        stopTimer.stop();
        root.opacity = 1;
    }
    onExited:
    {
        hovered = false;
        stopTimer.restart();
    }

    function showWindow(argX, argY)
    {
        root.x = argX - width / 2;
        root.y = argY - height - 10;
        root.opacity = 1;
        root.show();
    }

    function hideWindow()
    {
        if (!stopTimer.running)
            stopTimer.restart();
    }

    function appendMessage(sender_info)
    {
        if (infoList.indexOf(sender_info) == -1)
        {
            myModel.append({ "info": sender_info });
            infoList.push(sender_info);
        }
    }

    function popbackMessage(sender_info)
    {
        var index = infoList.indexOf(sender_info);
        if (index != -1)
        {
            myModel.remove(index);
            infoList.pop(sender_info);
        }
    }

    NumberAnimation
    {
        id: stopTimer
        running: false
        target: root
        property: "opacity"
        from: 1
        to: 0
        duration: 800
        onStopped: if (!root.hovered) root.hide();
    }

    ListModel
    {
        id: myModel
    }

    Component
    {
        id: delegate

        Rectangle
        {
            id: wrapper
            clip: true
            width: root.width
            height: 40
            border.color: "#EAEAEA"
            color: hovered ? "#E2E2E2" : "#F5F5F5"
            property bool hovered: false

            CircularImage
            {
                id: head
                width: 35
                height: width
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                source: info.headImage
            }

            Text
            {
                id: sender
                anchors.top: parent.top
                anchors.topMargin: 2
                anchors.left: head.right
                anchors.leftMargin: 15
                font.family: "微软雅黑"
                font.pointSize: 11
                color: "red"
                text: info.nickname
            }

            Text
            {
                id: recentMessage
                anchors.top: sender.bottom
                anchors.topMargin: 4
                anchors.left: sender.left
                font.family: "微软雅黑"
                textFormat: Text.RichText
                text: info.lastMessage.message
            }

            Rectangle
            {
                id: messageTip
                radius: 8
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(messageCount.width + 2, height)
                height: messageCount.height + 2
                color: "#FD462A"

                Text
                {
                    id: messageCount
                    anchors.centerIn: parent
                    text: info.unreadMessage >= 100 ? "99+" : info.unreadMessage;
                    color: Qt.lighter("#FFF")
                    font.family: "Consolas"
                }
            }

            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: wrapper.hovered = true;
                onExited: wrapper.hovered = false;
                onClicked:
                {
                    chatManager.addChatWindow(info.username);
                    myModel.remove(index);
                    infoList.splice(index, 1);
                    root.hide();
                    if (myModel.count == 0)
                        stopFlicker();
                }
            }
        }
    }

    Rectangle
    {
        width: root.width
        height: root.height
        color: "#F5F5F5"
        radius: 4
        anchors.centerIn: parent

        Text
        {
            id: name
            height: 32
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: "微软雅黑"
            font.pointSize: 10
            text: chatManager.userInfo.nickname
            verticalAlignment: Text.AlignVCenter
        }

        ListView
        {
            id: listView
            clip: true
            focus: true
            spacing: 4
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: name.bottom
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 35
            model: myModel
            delegate: delegate
            ScrollBar.vertical: ScrollBar
            {
                width: 10
                policy: ScrollBar.AsNeeded
            }
        }
    }
}
