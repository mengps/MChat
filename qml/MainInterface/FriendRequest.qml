import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import an.window 1.0
import "../MyWidgets"

FramelessWindow
{
    id: root

    width: 300
    height: 200
    actualWidth: width + 24
    actualHeight: height + 24
    title: qsTr("好友请求")
    x: (Screen.desktopAvailableWidth - actualWidth) / 2
    y: (Screen.desktopAvailableHeight - actualHeight) / 2
    visible: true
    taskbarHint: true
    windowIcon: "qrc:/image/winIcon.png"

    property alias gradient: content.gradient

    function addFriendRequest(username)
    {
        requestList.append({ "username" : username });
    }

    ListModel
    {
        id: requestList
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
        glowColor: background.status === Image.Null ? "#C4E7F8" : "#66C4E7F8";
        radius: 6
        glowRadius: 5
        antialiasing: true
        Keys.onPressed:
            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) searchButton.clicked();
        Keys.onEscapePressed: root.close();

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
            text: qsTr("好友请求")
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
                    root.showMinimized();
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

        Rectangle
        {
            id: listBackground
            clip: true
            radius: 8
            color: "#55556677"
            width: 260
            anchors.top: controlButtons.bottom
            anchors.topMargin: 15
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter

            ListView
            {
                id: listView
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.left: parent.left
                anchors.right: parent.right
                model: requestList
                spacing: 5
                delegate: Component
                {
                    Rectangle
                    {
                        width: listView.width
                        height: 32
                        radius: 2
                        border.color: "#777"
                        color: hovered ? "#559EF2FA" : "#55556677"
                        property bool hovered: false

                        MouseArea
                        {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.hovered = true;
                            onExited: parent.hovered = false;
                        }

                        RowLayout
                        {
                            width: parent.width
                            height: acceptButton.height + 4
                            Layout.alignment: Qt.AlignVCenter
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            Text
                            {
                                id: name
                                text: "  用户名：" + username + "  "
                            }

                            MyButton
                            {
                                id: acceptButton
                                text: "接受"
                                hoverColor: "#CCC"
                                onClicked:
                                {
                                    networkManager.acceptFriendRequest(username);
                                    requestList.remove(listView.currentIndex);
                                }
                            }

                            MyButton
                            {
                                id: rejectButton
                                text: "拒绝"
                                hoverColor: "#CCC"
                                onClicked:
                                {
                                    networkManager.rejectFriendRequest(username);
                                    requestList.remove(listView.currentIndex);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
