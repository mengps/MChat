import QtQuick 2.7
import QtQuick.Controls 2.2
import an.chat 1.0
import "../MyWidgets"

Item
{
    id: root
    clip: true

    property FriendInfo other: FriendInfo{}

    function appendMsg(senderID, msg)
    {
        other.addTextMessage(senderID, msg);
    }

    Component
    {
        id: delegate

        Item
        {
            width: listView.width
            height: bubble.height
            property bool isOther: chatManager.username != senderID;

            CircularImage
            {
                id: headImage
                x: isOther ? 10 : parent.width - width - 10
                width: 32
                height: 32
                mipmap: true
                source: isOther ? other.headImage : chatManager.userInfo.headImage
            }

            BorderImage
            {
                id: bubble
                clip: true
                x: isOther ? headImage.x + headImage.width + 8 : headImage.x - width - 8
                source: isOther ? "qrc:/image/Bubble/bubble_小仓仓_left.png" : "qrc:/image/Bubble/bubble_大猫猫_right.png";
                width: tex.width + 30
                height: tex.height + 30
                border.left: isOther ? 15 : 26
                border.top: 22
                border.right: isOther ? 25 : 14
                border.bottom: 18

                MyTextEdit
                {
                    id: tex
                    anchors.centerIn: parent
                    text: message
                    textFormat: Text.RichText
                    selectByMouse: true
                    selectionColor: "#09A3DC"
                    readOnly: true
                    wrapMode: Text.WrapAnywhere
                    font.pointSize: 10
                    font.family: "微软雅黑"
                    leftPadding: 4
                    color: "red"
                    property real maxWidth: 400

                    onFocusChanged: select(0, 0)
                    onWidthChanged: if (width >= maxWidth) width = maxWidth;
                }
            }
        }
    }

    ListView
    {
        id: listView
        anchors.fill: parent
        spacing: 20
        model: other.messageList.messageList
        delegate: delegate
        highlightFollowsCurrentItem: false
        ScrollBar.vertical: ScrollBar
        {
            width: 15
            policy: ScrollBar.AlwaysOn
        }
        onModelChanged: listView.positionViewAtEnd();
    }
}
