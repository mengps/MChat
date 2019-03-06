import QtQuick 2.12
import QtQuick.Controls 2.12
import an.chat 1.0
import "../MyWidgets"

Item
{
    id: root
    clip: true

    property FriendInfo other: FriendInfo{}

    function appendMsg(sender, msg)
    {
        other.addTextMessage(sender, msg);
    }

    Component
    {
        id: delegate

        Item
        {
            width: listView.width
            height: bubble.height
            property bool isOther: chatManager.username != sender;

            CircularImage
            {
                id: headImage
                x: isOther ? 10 : parent.width - width - 10
                width: 32
                height: 32
                mipmap: true
                source: isOther ? other.headImage : chatManager.userInfo.headImage
            }

            AnimatedImage
            {
                id: stateImage
                x: bubble.x - 24
                y: 12
                playing: true
                width: 16
                height: 16
                mipmap: true
                source:
                {
                    if (modelData.state === ChatMessageStatus.Success)
                        return "";
                    else if (modelData.state === ChatMessageStatus.Sending)
                        return "qrc:/image/LoadingImage/loading3.gif";
                    else return "qrc:/image/WidgetsImage/cross.png";
                }
                property bool hovered: false

                MyToolTip
                {
                    visible: stateImage.hovered && stateImage.source != "";
                    text:
                    {
                        if (modelData.state === ChatMessageStatus.Sending)
                            return "发送中...";
                        else if (modelData.state === ChatMessageStatus.Failure)
                            return "发送失败，请检查网络...\n   点击可重新发送";
                        else return "";
                    }
                }

                MouseArea
                {
                    hoverEnabled: true;
                    anchors.fill: parent
                    onEntered: parent.hovered = true;
                    onExited:  parent.hovered = false;
                    onPressed:
                    {
                        stateImage.x += 2;
                        stateImage.y += 2;
                    }
                    onReleased:
                    {
                        stateImage.x -= 2;
                        stateImage.y -= 2;
                        if (modelData.state === ChatMessageStatus.Failure)  //点击可重新发送
                            appendMsg(modelData.sender, modelData.message);
                    }
                }
            }

            BorderImage
            {
                id: bubble
                clip: true
                x: isOther ? headImage.x + headImage.width + 8 : headImage.x - width - 8
                source: isOther ? "qrc:/image/Bubble/bubble_mouse_left.png" : "qrc:/image/Bubble/bubble_cat_right.png";
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
        spacing: 18
        model: other.chatRecord.messageList
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
