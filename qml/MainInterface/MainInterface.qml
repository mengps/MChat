import QtQuick 2.7
import QtQuick.Window 2.3
import QtQuick.Controls 2.2
import an.framelessWindow 1.0
import an.chat 1.0
import "../MyWidgets"
import "../UserInformation"

FramelessWindow
{
    id: mainInterface
    width: 280
    height: 680
    actualWidth: width + 20    //边框 20 x 20
    actualHeight: height + 20
    topHint: true
    x: Screen.desktopAvailableWidth - actualWidth - 50
    y: 0
    minimumWidth: 280
    maximumWidth: 608
    minimumHeight: 528
    visible: true
    title: qsTr("主界面")
    windowIcon: "qrc:/image/winIcon.png"

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
        var chatComp = Qt.createComponent("qrc:/image/UserInformation/UserInformation.qml");
        if (chatComp.status === Component.Ready)
            var obj = chatComp.createObject(mainInterface);
       return obj;
    }

    function createIntroduction(argY, info)
    {
        var x = mainInterface.x - 245;
        if (mainInterface.x <= 245)
            x = mainInterface.x + mainInterface.actualWidth - 5;
        var component = Qt.createComponent("Introduction.qml");
        if (component.status === Component.Ready)
            var obj = component.createObject(mainInterface,
                { "x" : x, "y" : argY + mainInterface.y + 10, "info" : info });
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
            var window = chatManager.addChatWindow(senderID);
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
        onStopped: mainInterface.close();
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


    ResizeMouseArea
    {
        moveable: false
        width: parent.actualWidth
        height: parent.actualHeight
        target: mainInterface
    }

    Rectangle
    {
        id: content
        radius: 8
        width: mainInterface.width
        height: mainInterface.height
        anchors.centerIn: parent

        Image
        {
            id: background
            anchors.fill: parent
            mipmap: true
            fillMode: Image.PreserveAspectCrop
            source: chatManager.userInfo.background;
        }

        Row
        {
            id: controlButtons
            width: 102
            height: 40
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.top: parent.top
            anchors.topMargin: 6

            CusButton
            {
                id: menuButton
                width: 34
                height: 24

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
                width: 34
                height: 24

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
                width: 34
                height: 24

                onClicked:
                {
                    chatManager.quit();
                }
                Component.onCompleted:
                {
                    buttonNormalImage = "qrc:/image/ButtonImage/close_normal.png";
                    buttonPressedImage = "qrc:/image/ButtonImage/close_down.png";
                    buttonHoverImage = "qrc:/image/ButtonImage/close_hover.png";
                    buttonDisableImage = "qrc:/image/ButtonImage/close_disable.png";
                }
            }
        }

        HeadStatus
        {
            id: headStatus
            anchors.top: controlButtons.bottom
            anchors.left: parent.left
            anchors.leftMargin: 10
            mouseEnable: true
            image: chatManager.userInfo.headImage

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
            font.pointSize: 13
            font.family: "微软雅黑"
            font.bold: true
            color: "#FF0080"
            elide: Text.ElideRight
        }

        Rectangle
        {
            id: level
            width: 32
            height: 15
            radius: 2
            anchors.left: nickname.right
            anchors.leftMargin: 10
            anchors.top: nickname.top
            anchors.topMargin: 5
            color: hovered ? "#88333333" : "#00FFFFFF";
            property bool hovered: false

            Text
            {
                anchors.centerIn: parent
                style: Text.Outline
                color: "#FFF200"
                styleColor: "#B86030"
                font.family: "新宋体"
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
            opacity: 0.8

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
            focusPolicy: Qt.ClickFocus
            width: parent.width
            height: 40
            opacity: 0.66
            anchors.top: headStatus.bottom
            anchors.topMargin: 20
            currentIndex: swipeView.currentIndex

            TabButton
            {
                text: qsTr("联系人")
            }

            TabButton
            {
                text: qsTr("聊天列表")
            }
        }

        Column
        {
            height: 30
            width: parent.width

            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            Image
            {
                id: name
                width: 20
                height: width
                mipmap: true
                source: "qrc:/image/WidgetsImage/addFriend_normal.png";
            }
        }
    }
}
