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
            height: textRect.height
            property bool isOther: chatManager.username != sender;

            GlowCircularImage
            {
                id: headImage
                x: isOther ? 16 : parent.width - width - 16
                width: 32
                height: 32
                glowColor: "black"
                radius: 16
                glowRadius: 4
                source: isOther ? other.headImage : chatManager.userInfo.headImage
            }

            AnimatedImage
            {
                id: stateImage
                x: textRect.x - 24
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

            GlowRectangle
            {
                id: textRect
                radius: 10
                glowRadius: 10
                color: "#88FFFFFF"
                glowColor: color
                x: isOther ? headImage.x + headImage.width + 8 : headImage.x - width - 8
                width: text.width + 10
                height: text.height + 6

                MyTextArea
                {
                    id: text
                    anchors.centerIn: parent
                    text: message
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
                    Component.onCompleted:
                    {
                        if (width >= maxWidth) width = maxWidth;
                    }
                }
            }
        }
    }

    ListView
    {
        id: listView
        anchors.fill: parent
        anchors.margins: 8
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
