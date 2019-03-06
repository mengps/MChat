import QtQuick 2.12
import QtQuick.Controls 2.12

Item
{
    id: root
    focus: false
    width: focus ? 100 : status.width
    height: focus ? 100 : status.height

    property alias model: listView.model;

    function toColor(arg)
    {
        switch (arg)
        {
        case 0:
            return "#09F175";
        case 1:
            return "#FFAA31";
        case 2:
            return "#FD563C";
        case 3:
            return "#7A7A7A";
        }
    }

    function getDescription(arg)
    {
        switch (arg)
        {
        case 0:
            return "在线状态 希望接受消息\n声音: 开启\n消息提醒: 开启\n会话消息: 任务栏闪动";
        case 1:
            return "隐身状态 好友将看到你是离线的\n声音: 开启\n消息提醒: 开启\n会话消息: 任务栏闪动";
        case 2:
            return "忙碌状态 不希望被打扰\n声音: 关闭\n消息提醒: 开启\n会话消息: 任务栏闪动";
        case 3:
            return "离线状态\n断开服务器连接";
        }
    }

    GlowRectangle
    {
        id: status
        width: 14
        height: 14
        radius: 6
        color: root.toColor(chatManager.chatStatus);
        glowColor: color

        property bool hovered: false

        MouseArea
        {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.focus = !root.focus;
            onEntered: status.hovered = true;
            onExited: status.hovered = false;
        }

        MyToolTip
        {
            visible: status.hovered
            text: qsTr("状态切换")
        }
    }

    Component
    {
        id: delegate

        GlowRectangle
        {
            width: 56
            height: 20
            radius: 4
            clip: true
            color: hovered ? "#9920F5E7" : "transparent";
            glowColor: color
            property bool hovered: false

            MyToolTip
            {
                visible: parent.hovered
                text: getDescription(index)
            }

            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.hovered = true;
                onExited: parent.hovered = false;
                onClicked:
                {
                    root.focus = false;
                    chatManager.chatStatus = index;
                }
            }

            GlowRectangle
            {
                id: statusD
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                width: 12
                height: 12
                radius: 6
                color: root.toColor(index);
                glowColor: color
            }

            Item
            {
                width: 32
                height: 12
                anchors.left: statusD.right
                anchors.leftMargin: 2
                anchors.verticalCenter: statusD.verticalCenter

                Text
                {
                    antialiasing: true
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    anchors.fill: parent
                    text: modelData
                }
            }
        }
    }

    GlowRectangle
    {
        id: listRect
        anchors.left: status.left
        anchors.top: status.bottom
        anchors.topMargin: 4
        visible: root.activeFocus
        radius: 6
        width: listView.width + 8
        height: listView.height + 12
        color: "#CCFEFEFE"
        glowColor: color

        ListView
        {
            id: listView
            width: 56
            height: 20 * listView.count
            anchors.centerIn: parent
            delegate: delegate
            model: root.model
            ScrollBar.vertical: ScrollBar
            {
                width: 10
                policy: ScrollBar.AsNeeded
            }
        }
    }
}
