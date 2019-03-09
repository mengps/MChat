import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import an.window 1.0
import an.chat 1.0
import "../MyWidgets"
import "../UserInformation"

FramelessWindow
{
    id: mainInterface
    width: 290
    height: 680
    actualWidth: width + 24    //边框 24 x 24
    actualHeight: height + 24
    topHint: true
    x: Screen.desktopAvailableWidth - actualWidth - 50
    y: 0
    minimumWidth: 290
    maximumWidth: 608
    minimumHeight: 528
    visible: true
    title: qsTr("主界面")
    windowIcon: "qrc:/image/winIcon.png";

    property var userInfomation: undefined;
    property var introduction: undefined;
    property bool isDock: false;
    property int dockState: Chat.UnDock;
    property point startPoint: Qt.point(0, 0)
    property point offsetPoint: Qt.point(0, 0)

    onEntered:
    {
        if (isDock)
        {
            switch(dockState)
            {
            case Chat.TopDock:
                dockAnimation.property = "y";
                dockAnimation.to = -10;
                mainInterface.requestActivate()
                dockAnimation.restart();
                break;
            case Chat.LeftDock:
                dockAnimation.property = "x";
                dockAnimation.to = -10;
                mainInterface.requestActivate()
                dockAnimation.restart();
                break;
            case Chat.RightDock:
                dockAnimation.property = "x";
                dockAnimation.to = Screen.desktopAvailableWidth - mainInterface.width - 10;
                mainInterface.requestActivate()
                dockAnimation.restart();
                break;
            default:
                break;
            }
        }
    }

    onExited:
    {
        if (isDock)
        {
            switch(dockState)
            {
            case Chat.TopDock:
                dockAnimation.property = "y";
                dockAnimation.to = -mainInterface.height - 10;
                dockAnimation.restart();
                break;
            case Chat.LeftDock:
                dockAnimation.property = "x";
                dockAnimation.to = -mainInterface.width - 10;
                dockAnimation.restart();
                break;
            case Chat.RightDock:
                dockAnimation.property = "x";
                dockAnimation.to = Screen.desktopAvailableWidth - 10;
                dockAnimation.restart();
                break;
            default:
                break;
            }
        }
    }

    function createUserInfomation()
    {
        var chatComp = Qt.createComponent("qrc:/qml/UserInformation/UserInformation.qml");
        if (chatComp.status === Component.Ready)
            var obj = chatComp.createObject(mainInterface, { "gradient" : content.gradient });
       return obj;
    }

    function createIntroduction(argY, info)
    {
        var x = mainInterface.x - 260;
        if (mainInterface.x <= 260)
            x = mainInterface.x + mainInterface.actualWidth + 5;
        var component = Qt.createComponent("Introduction.qml");
        if (component.status === Component.Ready)
            var obj = component.createObject(mainInterface,
                                             { "x" : x,
                                               "y" : argY + mainInterface.y + 10,
                                               "info" : info });
        return obj;
    }

    function display()
    {
        startAnimation.start();
    }

    function quit()
    {
        endAnimation.start();
    }

    Connections
    {
        target: networkManager
        onHasNewShake:
        {
            var window = chatManager.addChatWindow(sender);
            window.shakeWindow();
        }
    }

    NumberAnimation
    {
        id: dockAnimation
        running: false
        target: mainInterface
        duration: 500
        easing.type: Easing.InOutQuad
    }

    NumberAnimation
    {
        id: startAnimation
        running: false
        target: mainInterface
        property: "opacity"
        from: 0
        to: 1
        duration: 800
        easing.type: Easing.Linear
        onStopped: chatManager.show();
    }

    NumberAnimation
    {
        id: endAnimation
        running: false
        target: mainInterface
        property: "opacity"
        from: 1
        to: 0
        duration: 800
        easing.type: Easing.Linear
        onStopped: Qt.quit();
    }

    MouseArea
    {
        id: mainMouseAre
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onPressed:
        {
            cursorShape = Qt.SizeAllCursor;
            startPoint = Qt.point(mouseX, mouseY);
        }
        onPositionChanged:
        {
            if(pressed)
            {
                mainInterface.offsetPoint = Qt.point(mouse.x - mainInterface.startPoint.x, mouse.y - mainInterface.startPoint.y);
                mainInterface.x = mainInterface.x + mainInterface.offsetPoint.x;
                mainInterface.y = mainInterface.y + mainInterface.offsetPoint.y;

                if (mainInterface.y <= -10)     //顶端停靠
                {
                    isDock = true;
                    dockState = Chat.TopDock;
                    mainInterface.y = -10;
                }
                else if(mainInterface.x <= -10)     //左端停靠
                {
                    isDock = true;
                    dockState = Chat.LeftDock;
                    mainInterface.x = -10;
                }
                else if(mainInterface.x >= (Screen.desktopAvailableWidth - mainInterface.width - 10))   //右端停靠
                {
                    isDock = true;
                    dockState = Chat.RightDock;
                    mainInterface.x = Screen.desktopAvailableWidth - mainInterface.width - 10;
                }
                else isDock = false;
            }
        }
        onReleased: cursorShape = Qt.ArrowCursor;
    }

    Image
    {
        id: background
        clip: true
        width: mainInterface.width - 8
        height: mainInterface.height - 8
        anchors.centerIn: parent
        antialiasing: true
        opacity: 0.95
        fillMode: Image.PreserveAspectCrop
        source: chatManager.userInfo.background;
    }

    GlowRectangle
    {
        id: content
        color: "transparent"
        anchors.centerIn: parent
        width: mainInterface.width
        height: mainInterface.height
        glowColor: background.status == Image.Null ? "#12F2D6" : "#8812F2D6";
        radius: 6
        glowRadius: 6
        antialiasing: true
        opacity: 0.9
        gradient: Gradient
        {
            GradientStop
            {
               position: 0.000
               color: "#BBEEFA"
            }
            GradientStop
            {
               position: 0.500
               color: "#00EA75"
            }
            GradientStop
            {
               position: 1.000
               color: "#BBEEFA"
            }
        }

        ResizeMouseArea
        {
            moveable: false
            anchors.fill: parent
            target: mainInterface
        }

        Row
        {
            id: controlButtons
            width: 102
            height: 40
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 4

            CusButton
            {
                id: menuButton
                width: 32
                height: 32

                onClicked:
                {
                }
                Component.onCompleted:
                {
                    buttonNormalImage = "qrc:/image/ButtonImage/menu_normal.png";
                    buttonPressedImage = "qrc:/image/ButtonImage/menu_down.png";
                    buttonHoverImage = "qrc:/image/ButtonImage/menu_hover.png";
                }
            }

            CusButton
            {
                id: minButton
                width: 32
                height: 32

                onClicked:
                {
                    mainInterface.hide();
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
                    chatManager.quit();
                }
                Component.onCompleted:
                {
                    buttonNormalImage = "qrc:/image/ButtonImage/close_normal.png";
                    buttonPressedImage = "qrc:/image/ButtonImage/close_down.png";
                    buttonHoverImage = "qrc:/image/ButtonImage/close_hover.png";
                }
            }
        }

        HeadStatus
        {
            id: headStatus
            width: 75
            height: 75
            source: chatManager.userInfo.headImage
            anchors.top: controlButtons.bottom
            anchors.left: parent.left
            anchors.leftMargin: 10
            mouseEnable: true

            Timer
            {
                id: destroyTimer
                running: false
                triggeredOnStart: false
                interval: 800
                onTriggered: if (introduction != null) introduction.fadeAway();
            }

            onClicked:
            {
               if (userInfomation == undefined)
                   userInfomation = createUserInfomation();
               else userInfomation.show();
            }
            onEntered:
            {
                //250 150
                destroyTimer.stop()
                if (introduction == undefined)
                {
                    introduction = createIntroduction(content.y, chatManager.userInfo);
                    introduction.entered.connect(destroyTimer.stop);
                    introduction.exited.connect(destroyTimer.restart);
                }
                else introduction.show();
            }
            onExited:
            {
                if (introduction != undefined)
                    destroyTimer.restart();
            }
        }

        Status
        {
            z: 2
            model: [qsTr("在线"), qsTr("隐身"), qsTr("忙碌"), qsTr("离线")]
            focus: false
            anchors.top: headStatus.bottom
            anchors.topMargin: -14
            anchors.left: headStatus.right
            anchors.leftMargin: -14
        }

        Text
        {
            id: nickname
            width: 80
            height: 30
            anchors.left: headStatus.right
            anchors.leftMargin: 15
            anchors.top: headStatus.top
            anchors.topMargin: 5
            text: chatManager.userInfo.nickname
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 14
            font.family: "微软雅黑"
            font.bold: true
            color: "white"
            elide: Text.ElideRight
        }

        Rectangle
        {
            id: level
            width: leverlText.implicitWidth + 10
            height: leverlText.implicitHeight + 8
            radius: 2
            anchors.left: nickname.right
            anchors.leftMargin: 10
            anchors.top: nickname.top
            anchors.topMargin: 5
            color: hovered ? "#ACBBBBBB" : "transparent";
            property bool hovered: false

            Text
            {
                id: leverlText
                anchors.centerIn: parent
                antialiasing: true
                style: Text.Outline
                color: "#FFF200"
                styleColor: "#B86030"
                font.family: "Consolas"
                text: "LV" + chatManager.userInfo.level
            }

            MouseArea
            {
                hoverEnabled: true
                anchors.fill: parent
                onEntered: level.hovered = true;
                onExited: level.hovered = false;
            }

            MyToolTip
            {
                visible: level.hovered
                text: " 我的等级\n    等级: " + chatManager.userInfo.level + "级\n 剩余升级天数: 199年"
            }
        }

        SwipeView
        {
            id: swipeView
            width: parent.width
            clip: true
            focus: true
            interactive: false
            anchors.top: tabBar.bottom
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            currentIndex: tabBar.currentIndex
            opacity: 0.80

            Page
            {
                Contact
                {
                    id: contact
                    anchors.fill: parent
                }
            }

            Page
            {
                RecentMessage
                {
                    id: recentMessage
                    anchors.fill: parent
                }
            }     
        }

        TabBar
        {
            id: tabBar
            focus: true
            width: parent.width
            height: 40
            anchors.top: headStatus.bottom
            anchors.topMargin: 20
            opacity: 0.66
            focusPolicy: Qt.ClickFocus
            currentIndex: swipeView.currentIndex

            TabButton
            {
                antialiasing: true
                font.family: "微软雅黑"
                text: qsTr("联系人")
            }

            TabButton
            {
                antialiasing: true
                font.family: "微软雅黑"
                text: qsTr("聊天列表")
            }
        }

        Rectangle
        {
            id: toolBar
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            color: "#98AFAFAF"
            width: parent.width
            height: 36

            Row
            {
                width: 210
                height: parent.height
                spacing: 15
                anchors.centerIn: parent

                CusButton
                {
                    id: addFriend
                    width: 32
                    height: parent.height
                    onClicked:
                    {
                    }
                    Component.onCompleted:
                    {
                        buttonNormalImage = "qrc:/image/WidgetsImage/addFriend_normal.png";
                        buttonPressedImage = "qrc:/image/WidgetsImage/addFriend_down.png";
                        buttonHoverImage = "qrc:/image/WidgetsImage/addFriend_normal.png";
                    }

                    MyToolTip
                    {
                        visible: parent.hovered
                        text: "添加好友"
                    }
                }
            }
        }
    }
}
