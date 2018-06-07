import QtQuick 2.7
import QtQuick.Controls 2.2
import "../MyWidgets"

Item
{
    id: root

    Component
    {
        id: highlight

        Rectangle
        {
            width: root.width
            height: 50
            y: listView.currentItem.y;
            color: "#BBBBBB"
            Behavior on y { SpringAnimation { spring: 3; damping: 0.22 } }
        }
    }

    Component
    {
        id: delegate

        Rectangle
        {
            id: wrapper
            clip: true
            width: root.width
            height: 50
            color: "#00FFFFFF"
            property var introduction: undefined;

            CircularImage
            {
                id: headImage
                width: 35
                height: width
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                source: modelData.headImage
            }

            Text
            {
                id: name
                anchors.top: parent.top
                anchors.topMargin: 2
                anchors.left: headImage.right
                anchors.leftMargin: 15
                font.family: "微软雅黑"
                font.pointSize: 12
                color: "red"
                text: modelData.nickname
            }

            Text
            {
                id: message
                clip: true
                anchors.top: name.bottom
                anchors.topMargin: 4
                anchors.left: name.left
                anchors.right: messageTip.left
                font.family: "微软雅黑"
                textFormat: Text.RichText
                text: modelData.lastMessage.message;
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
                    text: modelData.unreadMessage
                    color: Qt.lighter("#FFF")
                    font.family: "Consolas"
                }
            }

            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                onDoubleClicked:
                {
                    chatManager.addChatWindow(modelData.username);
                }
                onEntered:
                {
                    wrapper.ListView.view.currentIndex = index;
                }
                onPositionChanged:
                {
                    if (headImage.contains(Qt.point(mouse.x - 10, mouse.y)))
                    {
                        if (wrapper.introduction == undefined)
                            wrapper.introduction = mainInterface.createIntroduction(
                                        listView.contentY + wrapper.y + 120, modelData);
                        else wrapper.introduction.show();
                    }
                    else if (wrapper.introduction != undefined)
                        wrapper.introduction.fadeAway();
                }
                onExited:
                {
                    if (wrapper.introduction != undefined)
                        wrapper.introduction.fadeAway();
                }
            }
        }
    }

    ListView
    {
        id: listView
        focus: true
        anchors.fill: parent
        anchors.topMargin: 10
        spacing: 4
        model: chatManager.recentMessageID
        delegate: delegate
        highlight: highlight
        highlightFollowsCurrentItem: false
        ScrollBar.vertical: ScrollBar
        {
            width: 12
            policy: ScrollBar.AsNeeded
        }
    }
}
