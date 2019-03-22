import QtQuick 2.12
import QtQuick.Window 2.12
import an.window 1.0
import an.chat 1.0
import "../FlatWidgets"
import "../MyWidgets"

FramelessWindow
{
    id: root

    width: 360
    height: 260
    actualWidth: width + 24
    actualHeight: height + 24
    title: qsTr("添加好友")
    x: (Screen.desktopAvailableWidth - actualWidth) / 2
    y: (Screen.desktopAvailableHeight - actualHeight) / 2
    visible: true
    taskbarHint: true
    windowIcon: "qrc:/image/winIcon.png"

    property alias gradient: content.gradient

    Connections
    {
        target: networkManager
        onHasSearchResult:
        {
            friendInfo.info = info;
            friendInfo.visible = true;
        }
    }

    Image
    {
        id: background
        clip: true
        width: root.width - 8
        height: root.height - 8
        anchors.centerIn: parent
        antialiasing: true
        opacity: 0.95
        fillMode: Image.PreserveAspectCrop
        source: chatManager.userInfo.background;
    }

    GlowRectangle
    {
        id: content
        anchors.centerIn: parent
        width: root.width
        height: root.height
        color: "transparent"
        glowColor: background.status === Image.Null ? "#12F2D6" : "#AA12F2D6";
        radius: 6
        glowRadius: 5
        antialiasing: true
        Keys.onPressed:
            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) searchButton.clicked();
        Keys.onEscapePressed: root.close()

        MoveMouseArea
        {
            anchors.fill: parent
            target: root
        }

        Image
        {
            id: smallIcon
            width: 20
            height: 20
            mipmap: true
            source: "qrc:/image/winIcon.png"
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
        }

        Text
        {
            text: qsTr("添加好友")
            font.pointSize: 10
            font.family: "微软雅黑"
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.left: smallIcon.right
            anchors.leftMargin: 5
        }

        Row
        {
            id: controlButtons

            width: 68
            height: 40
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 4

            CusButton
            {
                id: minButton
                width: 32
                height: 32

                onClicked:
                {
                    root.hide();
                }
                Component.onCompleted:
                {
                    buttonNormalImage = "qrc:/image/ButtonImage/min_normal.png";
                    buttonPressedImage = "qrc:/image/ButtonImage/min_down.png";
                    buttonHoverImage = "qrc:/image/ButtonImage/min_hover.png";
                }
            }

            CusButton
            {
                id: closeButton
                width: 32
                height: 32

                onClicked:
                {
                    root.close();
                }
                Component.onCompleted:
                {
                    buttonNormalImage = "qrc:/image/ButtonImage/close_normal.png";
                    buttonPressedImage = "qrc:/image/ButtonImage/close_down.png";
                    buttonHoverImage = "qrc:/image/ButtonImage/close_hover.png";
                }
            }
        }

        Row
        {
            id: searchRow
            width: 234
            height: 32
            spacing: 7
            anchors.top: controlButtons.bottom
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter

            FlatInput
            {
                id: usernameField
                width: 195
                height: 30
                color: "red"
                font.pointSize: 11
                font.family: "微软雅黑"
                selectByMouse: true
                hoverEnabled: true
                clip: true
                placeholderText : qsTr("帐号")
                validator: RegExpValidator
                {
                    regExp: new RegExp("[a-zA-z0-9]*");
                }
            }

            CusButton
            {
                id: searchButton
                width: 32
                height: 32
                onClicked:
                {
                    if (usernameField.text.length != 0)
                        networkManager.requestUserInfo(usernameField.text);
                }
                Component.onCompleted:
                {
                    buttonNormalImage = "qrc:/image/WidgetsImage/search_normal.png";
                    buttonPressedImage = "qrc:/image/WidgetsImage/search_normal.png";
                    buttonHoverImage = "qrc:/image/WidgetsImage/search_normal.png";
                }

                MyToolTip
                {
                    visible: parent.hovered
                    text: "搜索 " + usernameField.text
                }
            }
        }

        Rectangle
        {
            id: friendInfo
            visible: false
            clip: true
            radius: 8
            color: "#55556677"
            width: 260
            anchors.top: searchRow.bottom
            anchors.topMargin: 15
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter

            property FriendInfo info: FriendInfo{}

            GlowCircularImage
            {
                id: infoHeadImage
                radius: width / 2
                glowColor: "black"
                glowRadius: 8
                width: 75
                height: 75
                source: friendInfo.info.headImage
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
            }

            Column
            {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: infoHeadImage.right
                anchors.leftMargin: 10
                spacing: 8

                Text
                {
                    horizontalAlignment: Text.AlignHCenter
                    text: "帐号：" + friendInfo.info.username
                }

                Text
                {
                    horizontalAlignment: Text.AlignHCenter
                    text: "昵称：" + friendInfo.info.nickname
                }

                Text
                {
                    horizontalAlignment: Text.AlignHCenter
                    text: "性别：" + friendInfo.info.gender
                }

                Text
                {
                    horizontalAlignment: Text.AlignHCenter
                    text: "生日：" + friendInfo.info.birthday
                }

                Text
                {
                    horizontalAlignment: Text.AlignHCenter
                    text: "签名：" + friendInfo.info.signature
                }

                MyButton
                {
                    id: sendButton
                    text: "添加好友"
                    widthMargin: 15
                    hoverColor: "#CCC"
                }
            }
        }
    }
}
