import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.3
import an.chat 1.0
import an.window 1.0
import an.network 1.0
import an.utility 1.0
import "LoginInterface"
import "FlatWidgets"
import "MyWidgets"

FramelessWindow
{
    id: loginInterface
    width: 510
    height: 400
    actualWidth: width + 100
    actualHeight: height + 100
    x: (Screen.desktopAvailableWidth - actualWidth) / 2
    y: (Screen.desktopAvailableHeight - actualHeight) / 2
    visible: true
    title: qsTr("登录界面")
    windowIcon: "qrc:/image/winIcon.png"

    Component.onCompleted: startAnimation.restart();

    function logging()
    {
        chatManager.username = usernameEditor.username;
        chatManager.password = passwordEditor.password;
        chatManager.rememberPassword = remember.checked;
        chatManager.autoLogin = autoLogin.checked;
        chatManager.loginStatus = Chat.Logging;
    }

    function quit()
    {
        endAnimation.start();
    }

    NumberAnimation
    {
        id: startAnimation
        running: false
        target: loginInterface
        property: "opacity"
        from: 0
        to: 1
        duration: 600
        easing.type: Easing.InQuad
        onStopped: chatManager.show();
    }

    NumberAnimation
    {
        id: endAnimation
        running: false
        target: content
        property: "width"
        to: 0
        duration: 400
        easing.type: Easing.Linear
        onStarted: content.clip = true;
        onStopped:
        {
            if (chatManager.loginStatus === Chat.LoginSuccess)
            {
                chatManager.loginStatus = Chat.LoginFinished;
                loginInterface.close();
            }
            else Qt.quit();
        }
    }

    ParallelAnimation
    {
        id: loggingAnimation
        onStopped: loginInterface.logging();

        NumberAnimation
        {
            target: topRect
            property: "height"
            from: 120
            to: content.height - content.radius
            duration: 300
            easing.type: Easing.Linear
        }

        NumberAnimation
        {
            target: cancelLogin
            property: "opacity"
            from: 0
            to: 1
            duration: 300
            easing.type: Easing.Linear
        }
    }

    ParallelAnimation
    {
        id: cancelAnimation

        NumberAnimation
        {
            target: topRect
            property: "height"
            from: content.height - content.radius
            to: 120
            duration: 300
            easing.type: Easing.Linear
        }

        NumberAnimation
        {
            target: cancelLogin
            property: "opacity"
            from: 1
            to: 0
            duration: 300
            easing.type: Easing.Linear
        }
    }

    Rectangle
    {
        id: content
        width: loginInterface.width
        height: loginInterface.height
        focus: true
        radius: 6
        opacity: 0.95
        color: "#C4D6FA"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 50

        Keys.onPressed:
            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) logging();

        LoginFailure    //登录失败页面，在最高层，开始不可见
        {
            id: loginFailure
            z: 10
        }

        GlowCircularImage
        {
            id: background
            anchors.fill: parent
            glowColor: "#C4D6FA"
            radius: content.radius
            glowRadius: 12
            source: "qrc:/image/Background/timg.jpg"
            antialiasing: true
            opacity: 0.9
        }

        MagicPool
        {
            id: magicPool
            width: loginInterface.actualWidth
            height: loginInterface.actualHeight

            function randomMove()
            {
                var r_x = Math.random() * parent.width;
                var r_y = Math.random() * parent.height;
                magicPool.moveFish(r_x, r_y, false);
            }

            Timer
            {
                interval: 1500
                repeat: true
                running: true
                onTriggered:
                {
                    if (Math.random() > 0.6 && !magicPool.moving) magicPool.randomMove();
                }
            }

            Component.onCompleted: randomMove();
        }

        MoveMouseArea
        {
            anchors.fill: parent
            focus: true
            target: loginInterface

            onClicked:
            {
                focus = true;
                magicPool.moveFish(mouse.x, mouse.y, true)
            }
        }

        Rectangle
        {
            id: modeSelect
            focus: false
            width: 100
            height: 64
            visible: activeFocus
            radius: 4
            color: "#DDFEFEFE"
            x: cusButtons.x - 10
            y: cusButtons.y + cusButtons.height + 4

            MouseArea
            {
                //避免事件往下传递
                anchors.fill: parent
            }

            Column
            {
                width: 90
                spacing: 4
                anchors.centerIn: parent

                FlatRadioButton
                {
                    id: internet
                    width: parent.width
                    hoverColor: "#9920F5E7"
                    textColor: radioColor
                    font.pointSize: 9
                    checked: true
                    text: qsTr("互联网模式")
                    onCheckedChanged:
                    {
                        if (checked)
                        {
                            networkManager.mode = NetworkMode.Internet;
                            localInternet.checked = false;
                        }
                        else localInternet.checked = true;
                    }

                    MyToolTip
                    {
                        visible: parent.hovered
                        text: qsTr("  互联网模式\n你将会连接到服务器\n需要联网")
                    }
                }

                FlatRadioButton
                {
                    id: localInternet
                    width: parent.width
                    hoverColor: "#9920F5E7"
                    textColor: radioColor
                    font.pointSize: 9
                    text: qsTr("局域网模式")
                    onCheckedChanged:
                    {
                        if (checked)
                        {
                            networkManager.mode = NetworkMode.LocalInternet;
                            internet.checked = false;
                        }
                        else internet.checked = true;
                    }

                    MyToolTip
                    {
                        visible: parent.hovered
                        text: qsTr("  局域网模式\n你将不会连接到服务器\n但需要接入局域网")
                    }
                }
            }
        }

        Rectangle
        {
            id: topRect
            width: parent.width
            height: 120
            color: "transparent"
            anchors.top: parent.top
            anchors.topMargin: content.radius
            anchors.horizontalCenter: parent.horizontalCenter

            MyButton
            {
                id: cancelLogin
                opacity: 0
                text: qsTr("取消登陆")
                widthMargin: 14
                heightMargin: 6
                hoverColor: "#FFCCA0"
                glowColor: hoverColor
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 50

                onClicked:
                {
                    if (opacity >= 1.0)
                    {
                        chatManager.loginStatus = Chat.NoLogin;
                        networkManager.cancelLogin();
                        cancelAnimation.restart();
                    }
                }
            }

            Text
            {
                id: applicationName
                anchors.centerIn: parent
                text: "MChat"
                font.family: "Consolas"
                font.pointSize: 48
                style: Text.Sunken
                styleColor: "red"
                transform: rotation
                smooth: true
                property real angle: 0;

                Rotation
                {
                    id: rotation
                    origin.x: applicationName.width / 2;
                    origin.y: applicationName.height / 2;
                    axis { x: 0; y: 1; z: 0 }
                    angle: applicationName.angle
                }

                Timer
                {
                    interval: 30
                    repeat: true
                    running: true
                    onTriggered: applicationName.angle += 2;
                }
            }

            Row
            {
                id: cusButtons
                width: 102
                height: 40
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.top: parent.top
                anchors.topMargin: 6

                CusButton
                {
                    id: menuButton
                    width: 32
                    height: 32

                    Component.onCompleted:
                    {
                        buttonNormalImage = "qrc:/image/ButtonImage/menu_normal.png";
                        buttonPressedImage = "qrc:/image/ButtonImage/menu_down.png";
                        buttonHoverImage = "qrc:/image/ButtonImage/menu_hover.png";
                    }
                    onClicked:
                    {
                        modeSelect.focus = !modeSelect.focus;
                    }

                    MyToolTip
                    {
                        visible: menuButton.hovered
                        text: "打开模式菜单"
                    }
                }

                CusButton
                {
                    id: minButton
                    width: 32
                    height: 32

                    onClicked: loginInterface.hide();
                    Component.onCompleted:
                    {
                        buttonNormalImage = "qrc:/image/ButtonImage/min_normal.png";
                        buttonPressedImage = "qrc:/image/ButtonImage/min_down.png";
                        buttonHoverImage = "qrc:/image/ButtonImage/min_hover.png";
                    }

                    MyToolTip
                    {
                        visible: minButton.hovered
                        text: "最小化窗口"
                    }
                }

                CusButton
                {
                    id: closeButton
                    width: 32
                    height: 32

                    onClicked: chatManager.quit();
                    Component.onCompleted:
                    {
                        buttonNormalImage = "qrc:/image/ButtonImage/close_normal.png";
                        buttonPressedImage = "qrc:/image/ButtonImage/close_down.png";
                        buttonHoverImage = "qrc:/image/ButtonImage/close_hover.png";
                    }

                    MyToolTip
                    {
                        visible: closeButton.hovered
                        text: "关闭窗口"
                    }
                }
            }
        }

        Rectangle
        {
            id: clientInput
            radius: content.radius
            width: parent.width
            height: 290
            z: 0
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: topRect.horizontalCenter
            color: "transparent"

            HeadStatus
            {
                id: headStatus
                width: 75
                height: 75
                source: chatManager.headImage
                anchors.top: clientInput.top
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Status
            {
                z: 2
                model: [qsTr("在线"), qsTr("隐身"), qsTr("忙碌")]
                focus: false
                anchors.top: headStatus.bottom
                anchors.topMargin: -14
                anchors.left: headStatus.right
                anchors.leftMargin: -14
            }

            Item
            {
                id: usernameEditor
                width: 195
                height: 30
                anchors.top: headStatus.bottom
                anchors.topMargin: 30
                anchors.horizontalCenter: parent.horizontalCenter
                property alias username: usernameField.text

                FlatInput
                {
                    id: usernameField
                    anchors.fill: parent
                    font.pointSize: 11
                    font.family: "微软雅黑"
                    selectByMouse: true
                    hoverEnabled: true
                    clip: true
                    text: chatManager.username
                    placeholderText : qsTr("帐号")
                    validator: RegExpValidator
                    {
                        regExp: new RegExp("[a-zA-z0-9]*");
                    }
                }

                Image
                {
                    id: dropDownImage
                    focus: true
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    width: 22
                    height: 22
                    source: activeFocus ? "qrc:/image/WidgetsImage/topArrow.png" : "qrc:/image/WidgetsImage/bottomArrow.png";
                    property bool hovered: false

                    MyToolTip
                    {
                        visible: dropDownImage.hovered
                        text: "打开登录历史"
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked:
                        {
                            dropDownImage.focus = !parent.focus;
                            if (dropDownImage.activeFocus)
                                histroyListView.model = chatManager.getLoginHistory();
                        }
                        onEntered:
                        {
                            dropDownImage.hovered = true;
                            cursorShape = Qt.PointingHandCursor;
                        }
                        onExited:
                        {
                            dropDownImage.hovered = false;
                            cursorShape = Qt.ArrowCursor;
                        }
                    }
                }
            }

            Rectangle
            {
                z: 1
                id: dropDownBox
                visible: dropDownImage.activeFocus
                focus: true
                clip: true
                anchors.horizontalCenter: usernameEditor.horizontalCenter
                anchors.top: usernameEditor.bottom
                anchors.topMargin: 2
                radius: 4
                width: usernameEditor.width
                height: 100
                border.color: "gray"

                ListView
                {
                    id: histroyListView
                    visible: parent.visible
                    clip: true
                    anchors.top: parent.top
                    anchors.topMargin: 6
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 6
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    spacing: 2
                    delegate: Component
                    {
                        Rectangle
                        {
                            width: histroyListView.width
                            height: ListView.isCurrentItem ? 30 : 20
                            color: ListView.isCurrentItem ? "#D1D1D1" : "white"
                            property bool hovered: false

                            Text
                            {
                                anchors.centerIn: parent
                                text: qsTr(modelData)
                                font.pointSize: 11
                                font.family: "微软雅黑"
                            }

                            MouseArea
                            {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered:
                                {
                                    parent.hovered = true;
                                    histroyListView.currentIndex = index;
                                }
                                onExited: parent.hovered = false;
                                onClicked:
                                {
                                    dropDownImage.focus = false;
                                    chatManager.username = modelData;
                                    chatManager.readSettings();
                                }
                            }
                        }
                    }
                }
            }

            Item
            {
                id: signIn
                width: 60
                height: usernameEditor.height
                anchors.left: usernameEditor.right
                anchors.leftMargin: 12
                anchors.verticalCenter: usernameEditor.verticalCenter

                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    property bool hovered: false

                    onEntered:
                    {
                        cursorShape = Qt.PointingHandCursor;
                        hovered = true;
                    }
                    onExited: hovered = false;
                    //onClicked: Qt.openUrlExternally("https://");

                    Text
                    {
                        color: parent.hovered ? Qt.lighter("#007DA7") : "#007DA7";
                        anchors.centerIn: parent
                        font.pointSize: 10
                        font.family: "微软雅黑"
                        text: qsTr("注册账户")
                    }
                }
            }

            Item
            {
                id: passwordEditor
                width: 195
                height: 30
                anchors.top: usernameEditor.bottom
                anchors.topMargin: 6
                anchors.left: usernameEditor.left
                property alias password: passwordField.text

                FlatInput
                {
                    id: passwordField
                    anchors.fill: parent
                    placeholderText : qsTr("密码")
                    passwordCharacter: "●"
                    passwordMaskDelay: 800
                    echoMode: TextInput.Password
                    font.pointSize: 11
                    font.family: "微软雅黑"
                    selectByMouse: true
                    hoverEnabled: true
                    rightPadding : 30

                    validator: RegExpValidator
                    {
                        regExp: new RegExp("[a-zA-z0-9]*");
                    }
                    Item
                    {
                        id: keyboardRect
                        anchors.right: parent.right
                        anchors.rightMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        width: 22
                        height: 22
                        property bool hovered: false

                        MyToolTip
                        {
                            visible: keyboardRect.hovered
                            text: qsTr("打开小键盘")
                        }

                        Image
                        {
                            id: keyboard
                            anchors.fill: parent
                            antialiasing: true
                            mipmap: true
                            source: "qrc:/image/WidgetsImage/keyboard_normal.png"
                        }

                        MouseArea
                        {
                            anchors.fill: parent
                            hoverEnabled: true

                            onEntered:
                            {
                                keyboardRect.hovered = true;
                                keyboard.source = "qrc:/image/WidgetsImage/keyboard_hover.png";
                                cursorShape = Qt.PointingHandCursor;
                            }
                            onExited:
                            {
                                keyboardRect.hovered = false;
                                keyboard.source = "qrc:/image/WidgetsImage/keyboard_normal.png";
                                cursorShape = Qt.ArrowCursor;
                            }
                        }
                    }
                }
            }

            Item
            {
                id: forget
                width: 60
                height: passwordEditor.height
                anchors.left: passwordEditor.right
                anchors.leftMargin: 12
                anchors.verticalCenter: passwordEditor.verticalCenter
                property bool hovered: false

                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered:
                    {
                        cursorShape = Qt.PointingHandCursor;
                        parent.hovered = true;
                    }
                    onExited: parent.hovered = false;
                    //onClicked: Qt.openUrlExternally("https://");

                    Text
                    {
                        color: forget.hovered ? Qt.lighter("#007DA7") : "#007DA7"
                        anchors.centerIn: parent
                        font.pointSize: 10
                        font.family: "微软雅黑"
                        text: qsTr("忘记密码")
                    }
                }
            }

            MyCheckButton
            {
                id: remember
                width: 80
                height: 14
                rectWidth: 14
                rectHeight: 14
                color: Qt.lighter("#333")
                text: qsTr("记住密码")
                checked: chatManager.rememberPassword
                anchors.top: passwordEditor.bottom
                anchors.topMargin: 15
                anchors.left: passwordEditor.left
                anchors.leftMargin: 22
                onCheckedChanged:
                {
                    if (checked && passwordEditor.password === "")
                        passwordEditor.password = chatManager.password;
                }

                MyToolTip
                {
                    visible: parent.hovered
                    text: "是否记住密码？"
                }
            }

            MyCheckButton
            {
                id: autoLogin
                width: 80
                height: 14
                rectWidth: 14
                rectHeight: 14
                color: Qt.lighter("#333")
                text: qsTr("自动登录")
                checked: chatManager.autoLogin
                anchors.top: passwordEditor.bottom
                anchors.topMargin: 15
                anchors.left: remember.right
                anchors.leftMargin: 14

                MyToolTip
                {
                    visible: parent.hovered
                    text: "是否自动登录？"
                }
            }

            Item
            {
                id: loginIn
                width: 195
                height: 30
                anchors.bottom: clientInput.bottom
                anchors.bottomMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter

                GlowRectangle
                {
                    id: back
                    anchors.fill: parent
                    radius: 6
                    glowRadius: 6
                    color: "#09A3DC"
                    glowColor: color

                    Text
                    {
                        color: Qt.lighter("#FEFEFE", 1.2)
                        anchors.centerIn: parent
                        text: qsTr("登 录")
                        font.pointSize: 10
                        font.family: "微软雅黑"
                    }

                    transitions:
                    [
                        Transition
                        {
                            ColorAnimation
                            {
                                target: back
                                duration: 300;
                            }
                        }
                    ]

                    states:
                    [
                        State
                        {
                            name: "hovered"
                            PropertyChanges { target: back; color: Qt.lighter("#09A3DC", 1.2); }
                        },
                        State
                        {
                            name: "pressed"
                            PropertyChanges { target: back; color: Qt.darker("#09A3DC", 1.2); }
                        }
                    ]
                }

                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: back.state = "hovered";
                    onExited: back.state = "";
                    onPressed: back.state = "pressed";
                    onReleased:
                    {
                        back.state = "hovered";
                        loggingAnimation.restart();
                    }
                }
            }
        }
    }
}
