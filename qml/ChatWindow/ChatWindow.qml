import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import QtQuick.Dialogs 1.2
import QtQuick.Particles 2.0
import an.framelessWindow 1.0
import an.chat 1.0
import "../MyWidgets"

FramelessWindow
{
    id: chatWindow
    width: 560
    height: 540
    actualWidth: width + 60
    actualHeight: height + 60
    minimumHeight: 450
    minimumWidth: 280
    mousePenetrate: false
    topHint: false
    taskbarHint: true
    title: info.nickname
    x: (Screen.desktopAvailableWidth - actualWidth) / 2
    y: (Screen.desktopAvailableHeight - actualHeight) / 2
    visible: false

    property bool shaking: false;
    property bool quickSend: true;
    property int shakeCount: 0;
    property string username: "";
    property FriendInfo info: FriendInfo{}

    onUsernameChanged:
    {
        info = chatManager.createItemInfo(username);
        info.loadRecord();
        chatMessage.other = info;
    }

    function shakeWindow()
    {
        chatWindow.requestActivate();
        chatWindow.shaking = true;
        if (chatWindow.shakeCount == 8)
        {
            chatWindow.shakeCount = 0;
            chatWindow.shaking = false;
            return;
        }
        else
        {
            switch (chatWindow.shakeCount)
            {
            case 0:
            case 2:
            case 4:
            case 6:
                chatWindow.shakeCount++;
                shakeX.to = chatWindow.x + 10;    //右上
                shakeY.to = chatWindow.y - 10;
                shakeXY.restart();
                break;
            case 1:
            case 3:
            case 5:
            case 7:
                chatWindow.shakeCount++;
                shakeX.to = chatWindow.x - 10;    //还原
                shakeY.to = chatWindow.y + 10;
                shakeXY.restart();
                break;
            }
        }
    }

    function createSuperMenu(argX, argY)
    {
        var componet = Qt.createComponent("qrc:/qml/MyWidgets/SuperMenu.qml");
        if (componet.status === Component.Ready)
            var obj = componet.createObject(chatWindow, { "x" : argX, "y" : argY, "z" : 10 });
       return obj;
    }

    ParallelAnimation
    {
        id: shakeXY
        running: false
        alwaysRunToEnd: true

        NumberAnimation
        {
            id: shakeX
            property: "x"
            target: chatWindow
            duration: 50
        }

        NumberAnimation
        {
            id: shakeY
            property: "y"
            target: chatWindow
            duration: 50
        }
        onStopped: shakeWindow();
    }

    Image
    {
        id: background
        width: chatWindow.width
        height: chatWindow.height
        x: 30
        y: 30
        opacity: 0.95
        mipmap: true
        fillMode: Image.PreserveAspectCrop
        source: chatManager.userInfo.background;
    }

    Rectangle
    {
        id: content
        x: 30
        y: 30
        width: chatWindow.width
        height: chatWindow.height
        focus: true
        color: "#AAFFFFFF"

        Keys.onEscapePressed: chatWindow.close();

        ResizeMouseArea
        {
            anchors.fill: parent
            target: chatWindow
        }

        Row
        {
            id: controlButtons
            z: 10
            width: 68
            height: 40
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.top: parent.top
            anchors.topMargin: 6

            CusButton
            {
                id: minButton
                width: 34
                height: 24

                onClicked:
                {
                    chatWindow.showMinimized();
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
                    chatWindow.close();
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

        CircularImage
        {
            id: head
            width: 60
            height: 60
            mipmap: true
            source: info.headImage
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.left: parent.left
            anchors.leftMargin: 15
        }

        Text
        {
            id: contact
            anchors.left: head.right
            anchors.leftMargin: 10
            anchors.verticalCenter: head.verticalCenter
            font.pointSize: 22
            font.family: "微软雅黑"
            text: info.nickname
        }

        ChatRecord
        {
            id: chatMessage
            anchors.top: head.bottom
            anchors.topMargin: 20
            anchors.bottom: toolBar.top
            anchors.left: toolBar.left
            anchors.leftMargin: 8
            anchors.right: toolBar.right
            anchors.rightMargin: 8
        }

        Rectangle
        {
            id: previewRect
            z: 10
            radius: 10
            color: "#FFFFFF"
            border.color: "gray"
            visible: false
            width: 80
            height: 80

            AnimatedImage
            {
                id: gifPreview
                anchors.centerIn: parent
                width: 30
                height: 30
                mipmap: true
                onSourceChanged: playing = true;
                onPlayingChanged: playing = true;
            }

            Image
            {
                id: imagePreview
                anchors.centerIn: parent
                width: 30
                height: 30
                mipmap: true
            }
        }

        FacesManager
        {
            id: facesManager
            width: chatWindow.width - 160
            height: 0
            anchors.bottom: toolBar.top
            anchors.bottomMargin: 4
            anchors.horizontalCenter: toolBar.horizontalCenter

            onFocusChanged: if (!focus) hide();

            function show()
            {
                facesManagerAnimation.to = 220;
                facesManagerAnimation.restart();
            }

            function hide()
            {
                facesManagerAnimation.to = 0;
                facesManagerAnimation.restart();
            }

            NumberAnimation
            {
                id: facesManagerAnimation
                running: false
                target: facesManager
                property: "height"
                duration: 300
            }
        }

        ColorManager
        {
            id: colorManager
            anchors.bottom: toolBar.top
            anchors.bottomMargin: 4
            anchors.horizontalCenter: toolBar.horizontalCenter
            width: 174
            height: 0
            onFocusChanged: if (!focus) hide();

            function show()
            {
                colorManagerAnimation.to = 240;
                colorManagerAnimation.restart();
            }

            function hide()
            {
                colorManagerAnimation.to = 0;
                colorManagerAnimation.restart();
            }

            NumberAnimation
            {
                id: colorManagerAnimation
                running: false
                target: colorManager
                property: "height"
                duration: 300
            }
        }

        Rectangle
        {
            id: toolBar
            radius: 6
            color: "#58FFFFFF"
            width: parent.width
            height: 30
            x: 0
            y: parent.height - 150

            Row
            {
                width: 210
                height: parent.height
                spacing: 15
                anchors.centerIn: parent

                Rectangle
                {
                    id: fontBar
                    height: 26
                    width: 26
                    radius: 4
                    color: hovered ? Qt.darker(toolBar.color) : toolBar.color
                    border.color: "gray"
                    anchors.verticalCenter: parent.verticalCenter
                    property bool hovered: false

                    Image
                    {
                        width: 30
                        height: 30
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectCrop
                        source: "qrc:/image/WidgetsImage/font.png"
                    }

                    MyToolTip
                    {
                        text: "更换字体"
                        visible: fontBar.hovered
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: fontBar.hovered = true;
                        onExited: fontBar.hovered = false;
                        onClicked:
                        {
                            fontDialog.open();
                        }
                    }
                }

                Rectangle
                {
                    id: colorBar
                    height: 26
                    width: 26
                    radius: 4
                    color: hovered ? Qt.darker(toolBar.color) : toolBar.color
                    border.color: "gray"
                    anchors.verticalCenter: parent.verticalCenter
                    property bool hovered: false

                    Rectangle
                    {
                        width: 16
                        height: 16
                        radius: 8
                        anchors.centerIn: parent
                        color: sendMessage.color
                    }

                    MyToolTip
                    {
                        text: "更换颜色"
                        visible: colorBar.hovered
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: colorBar.hovered = true;
                        onExited: colorBar.hovered = false;
                        onClicked:
                        {
                            if (colorManager.focus)
                            {
                                colorManager.focus = false;
                            }
                            else
                            {
                                colorManager.show();
                                colorManager.focus = true;
                            }
                        }
                    }
                }

                Rectangle
                {
                    id: shakeBar
                    height: 26
                    width: 26
                    radius: 4
                    color: hovered ? Qt.darker(toolBar.color) : toolBar.color
                    border.color: "gray"
                    anchors.verticalCenter: parent.verticalCenter
                    property bool hovered: false;

                    MyToolTip
                    {
                        text: "窗口震动"
                        visible: shakeBar.hovered
                    }

                    Image
                    {
                        width: 30
                        height: 30
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectCrop
                        source: "qrc:/image/WidgetsImage/shake.png"
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: shakeBar.hovered = true;
                        onExited: shakeBar.hovered = false;
                        onClicked:
                        {
                            if (!chatWindow.shaking)
                                chatWindow.shakeWindow();
                            info.addShakeMessage(chatManager.username);
                        }
                    }
                }

                Rectangle
                {
                    id: facesBar
                    height: 26
                    width: 26
                    radius: 4
                    color: hovered ? Qt.darker(toolBar.color) : toolBar.color
                    border.color: "gray"
                    anchors.verticalCenter: parent.verticalCenter
                    property bool hovered: false;

                    MyToolTip
                    {
                        text: "表情"
                        visible: facesBar.hovered
                    }

                    Image
                    {
                        width: 30
                        height: 30
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectCrop
                        source: "qrc:/image/WidgetsImage/faces.png"
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: facesBar.hovered = true;
                        onExited: facesBar.hovered = false;
                        onClicked:
                        {
                            if (facesManager.focus)
                            {
                                facesManager.focus = false;
                            }
                            else
                            {
                                facesManager.show();
                                facesManager.focus = true;
                            }
                        }
                    }
                }

                Rectangle
                {
                    id: pictureBar
                    height: 26
                    width: 26
                    radius: 4
                    color: hovered ? Qt.darker(toolBar.color) : toolBar.color
                    border.color: "gray"
                    anchors.verticalCenter: parent.verticalCenter
                    property bool hovered: false

                    FileDialog
                    {
                        id: fileDialog
                        title: "插入图像"
                        folder: shortcuts.desktop
                        selectExisting: true
                        selectFolder: false
                        selectMultiple: false
                        modality: Qt.WindowModal
                        property string file: ""
                        nameFilters: ["图像文件 (*.jpg *.png *.jpeg *.bmp *.gif)"]
                        onAccepted:
                        {
                            file = fileUrl;
                            sendMessage.addImage(fileDialog.file)
                        }
                    }

                    Image
                    {
                        width: 30
                        height: 30
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectCrop
                        source: "qrc:/image/WidgetsImage/picture.png"
                    }

                    MyToolTip
                    {
                        text: "插入图片"
                        visible: pictureBar.hovered
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: pictureBar.hovered = true;
                        onExited: pictureBar.hovered = false;
                        onClicked:
                        {
                            fileDialog.open();
                        }
                    }
                }
            }
        }

        ParticleSystem
        {
            id: particleSystem
            running: false
            onEmptyChanged: if (empty) particleSystem.stop();
        }

        Emitter
        {
            id: particles
            system: particleSystem
            enabled: false
            lifeSpan: 1200
            lifeSpanVariation: 600
            maximumEmitted: 180
            velocity: AngleDirection
            {
                angleVariation: 360
                magnitude: 60
                magnitudeVariation:30
            }
        }

        ImageParticle
        {
            id: particleImage
            system: particleSystem
            source: "qrc:/image/ParticleImage/blueStar.png"
            colorVariation: 0.8
            alpha: 0.65
            alphaVariation: 0.35
            rotation: 30
            rotationVariation: 60
            rotationVelocity: 90
            rotationVelocityVariation: 30
            entryEffect: ImageParticle.Scale
        }

        Flickable
        {
            id: flick
            clip: true
            focus: true
            interactive: false
            anchors.top: toolBar.bottom
            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.bottom: close.top
            anchors.bottomMargin: 5
            contentWidth: sendMessage.contentWidth
            contentHeight: sendMessage.contentHeight

            Rectangle
            {
                anchors.fill: parent
                opacity: 0.6
                color: "#EFFFFF"
            }

            MyTextEdit
            {
                id: sendMessage
                font.family: "微软雅黑"
                opacity: 0.9
                focus: true
                width: chatWindow.width - 31
                height: Math.max(paintedHeight, flick.height)

                function qucikEnter()
                {
                    if (chatWindow.quickSend)
                        sendButton.clicked();
                    else sendMessage.insert(cursorPosition, "&#10");
                }

                Keys.onReturnPressed: qucikEnter();
                Keys.onEnterPressed: qucikEnter();
                Keys.onSpacePressed:
                {
                    if (cursorRectangle.x >= width)
                        sendMessage.insert(cursorPosition, "&#10");
                    else
                        sendMessage.insert(cursorPosition, "&nbsp");
                }
                onCursorPositionChanged:
                {
                    var relY = flick.y + cursorRectangle.y + cursorRectangle.height / 2 - flick.contentY;
                    if ((relY <= (flick.y + flick.height)) && (relY >= flick.y))
                    {
                        particleSystem.start();
                        particles.burst(420, flick.x + cursorRectangle.x, relY);
                    }
                }
            }

            ScrollBar.vertical: ScrollBar
            {
                width: 12
                policy: ScrollBar.AlwaysOn
            }
        }

        MyButton
        {
            id: sendButton
            text: "发送"
            widthMargin: 15
            hoverColor: "#CCC"
            anchors.right: close.left
            anchors.rightMargin: 15
            anchors.bottom: close.bottom

            MyToolTip
            {
                id: emptyTip
                text: "消息不能为空！"
                NumberAnimation on opacity
                {
                    id: emptyTipHide
                    running: false
                    from: 1
                    to: 0
                    duration: 1600
                }
            }

            onClicked:
            {
                if (sendMessage.length == 0)
                {
                    emptyTip.visible = true;
                    emptyTipHide.restart();
                }
                else
                {
                    chatMessage.appendMsg(chatManager.username, sendMessage.text);
                    sendMessage.cleanup();
                }
            }
        }

        MyButton
        {
            id: close
            text: "关闭"
            hoverColor: "#CCC"
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            onClicked: chatWindow.close();
        }
    }
}
