import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import an.framelessWindow 1.0
import an.chat 1.0
import "LoginInterface"
import "MyWidgets"

FramelessWindow
{
    id: loginInterface
    width: 430
    height: 330
    actualWidth: width + 80
    actualHeight: height + 80
    x: (Screen.desktopAvailableWidth - actualWidth) / 2
    y: (Screen.desktopAvailableHeight - actualHeight) / 2
    visible: true
    title: qsTr("登录界面")
    windowIcon: "qrc:/image/winIcon.png"

    Component.onCompleted: startAnimation.restart();

    function logging()
    {

        chatManager.username = userNameEditor.userName;
        chatManager.password = passWordEditor.passWord;
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

        onStopped: loginInterface.requestActivate();
    }

    ParallelAnimation
    {
        id: endAnimation
        running: false

        onStopped:
        {
            if (chatManager.loginStatus === Chat.LoginSuccess)
                chatManager.loginStatus = Chat.LoginFinished;
            loginInterface.close();
        }

        NumberAnimation
        {
            target: content
            property: "rotation"
            to: 540
            duration: 500
            easing.type: Easing.Linear
        }

        NumberAnimation
        {
            target: content
            property: "scale"
            to: 0
            duration: 500
            easing.type: Easing.Linear
        }
    }

    NumberAnimation
    {
        id: loggingAnimation
        target: topRect
        property: "height"
        from: 180
        to: content.height - content.radius
        duration: 300
        easing.type: Easing.InOutQuad

        onStopped:
        {
            cancelLogin.visible = true;
            topRect.radius = 8;
            loginInterface.logging();
        }
    }

    NumberAnimation
    {
        id: cancelAnimation
        target: topRect
        property: "height"
        from: content.height - content.radius
        to: 180
        duration: 300
        easing.type: Easing.InOutQuad

        onStopped: topRect.radius = 0;
    }

    Rectangle
    {
        id: content
        width: loginInterface.width
        height: loginInterface.height
        focus: true
        radius: 8
        color: "#FFCC99"
        anchors.centerIn: parent

        Keys.onPressed:
            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) logging();

        LoginFailure    //登录失败页面，在最高层，开始不可见
        {
            id: loginFailure
            z: 2
        }

        Rectangle
        {
            id: topRect
            width: parent.width
            height: 180
            z: 1
            anchors.top: parent.top
            anchors.topMargin: content.radius
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#FFCC99"

            MoveMouseArea
            {
                anchors.fill: parent
                target: loginInterface
            }

            MyParticle
            {
                id: particle
                anchors.fill: parent
            }

            MyButton
            {
                id: cancelLogin
                visible: false
                text: qsTr("取消登陆")
                hoverColor: "#55FFCC99"
                radius: 6
                widthMargin: 16
                heightMargin: 8
                border.color: "gray"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 30

                onClicked:
                {
                    chatManager.loginStatus = Chat.NoLogin;
                    networkManager.cancelLogin();
                    cancelLogin.visible = false;
                    cancelAnimation.restart();
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

                    onClicked: loginInterface.hide();
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

                    onClicked: chatManager.quit();
                    Component.onCompleted:
                    {
                        buttonNormalImage = "qrc:/image/ButtonImage/close_normal.png";
                        buttonPressedImage = "qrc:/image/ButtonImage/close_down.png";
                        buttonHoverImage = "qrc:/image/ButtonImage/close_hover.png";
                        buttonDisableImage = "qrc:/image/ButtonImage/close_disable.png";
                    }
                }
            }
        }

        Rectangle
        {
            id: clientInput
            radius: content.radius
            width: parent.width
            height: 150
            z: 0
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: topRect.horizontalCenter
            color: Qt.lighter("#F9F4D5", 1.3)

            HeadStatus
            {
                id: headStatus
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 42
            }

            Item
            {
                id: userNameEditor
                width: 195
                height: 30
                anchors.top: headStatus.top
                anchors.left: headStatus.right
                anchors.leftMargin: 13
                property alias userName: userNameField.text

                TextField
                {
                    id: userNameField
                    anchors.fill: parent
                    font.pointSize: 10
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
                    background : Rectangle
                    {
                        radius: 4
                        border.width: 2
                        border.color: parent.hovered ? "#1583DD" : "#E5E5E5";
                    }
                }
            }

            Item
            {
                id: signIn
                width: 60
                height: userNameEditor.height
                anchors.left: userNameEditor.right
                anchors.leftMargin: 12
                anchors.verticalCenter: userNameEditor.verticalCenter

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
                    onClicked: Qt.openUrlExternally("https://ssl.zc.qq.com/v3/index-chs.html");

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
                id: passWordEditor
                width: 195
                height: 30
                anchors.top: userNameEditor.bottom
                anchors.left: userNameEditor.left
                property alias passWord: passWordField.text

                TextField
                {
                    id: passWordField
                    anchors.fill: parent
                    text: chatManager.password
                    placeholderText : qsTr("密码")
                    passwordCharacter: "●"
                    passwordMaskDelay: 800
                    echoMode: TextInput.Password
                    font.pointSize: 10
                    font.family: "微软雅黑"
                    selectByMouse: true
                    hoverEnabled: true
                    rightPadding : 30

                    validator: RegExpValidator
                    {
                        regExp: new RegExp("[a-zA-z0-9]*");
                    }
                    background : Rectangle
                    {
                        radius: 4
                        border.width: 2
                        border.color: parent.hovered ? "#1583DD" : "#E5E5E5";

                        Rectangle
                        {
                            anchors.right: parent.right
                            anchors.rightMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                            width: 22
                            height: 22

                            Image
                            {
                                id: img
                                anchors.fill: parent
                                source: "qrc:/image/WidgetsImage/keyboard_normal.png"
                            }

                            MouseArea
                            {
                                anchors.fill: parent
                                hoverEnabled: true

                                onEntered:
                                {
                                    img.source = "qrc:/image/WidgetsImage/keyboard_hover.png";
                                    cursorShape = Qt.PointingHandCursor;
                                }
                                onExited:
                                {
                                    img.source = "qrc:/image/WidgetsImage/keyboard_normal.png";
                                    cursorShape = Qt.ArrowCursor;
                                }
                            }
                        }
                    }
                }
            }

            Item
            {
                id: forget
                width: 60
                height: passWordEditor.height
                anchors.left: passWordEditor.right
                anchors.leftMargin: 12
                anchors.verticalCenter: passWordEditor.verticalCenter
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
                    onClicked: Qt.openUrlExternally("https://aq.qq.com/cn2/index");

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
                anchors.top: passWordEditor.bottom
                anchors.topMargin: 12
                anchors.left: passWordEditor.left
                anchors.leftMargin: 22
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
                anchors.top: passWordEditor.bottom
                anchors.topMargin: 12
                anchors.left: remember.right
                anchors.leftMargin: 10
            }

            Item
            {
                id: loginIn
                width: 195
                height: 30
                anchors.bottom: clientInput.bottom
                anchors.bottomMargin: 14
                anchors.left: userNameEditor.left

                Rectangle
                {
                    id: back
                    anchors.fill: parent
                    radius: 4
                    color: "#09A3DC"

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
