import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import an.window 1.0
import "../MyWidgets"

FramelessWindow
{
    id: root

    width: 320
    height: 600
    actualWidth: width + 24
    actualHeight: height + 24
    title: qsTr("个人资料")
    x: (Screen.desktopAvailableWidth - actualWidth) / 2
    y: (Screen.desktopAvailableHeight - actualHeight) / 2
    visible: true
    taskbarHint: true
    windowIcon: "qrc:/image/winIcon.png"

    property bool custom: false;
    property bool hasModify: false;
    property int index: customBackgroundComboBox.index;
    property alias gradient: content.gradient
    property var headImageWidget: undefined;
    property var saveInformation: undefined;
    property var backgroundImage: ["", "qrc:/image/Background/2.jpg",
                                   "qrc:/image/Background/3.jpg","qrc:/image/Background/4.jpg",
                                   "qrc:/image/Background/5.jpg", "qrc:/image/Background/6.jpg",
                                   "qrc:/image/Background/7.jpg", "qrc:/image/Background/8.jpg",
                                   "qrc:/image/Background/9.jpg", "qrc:/image/Background/10.jpg"];

    function save()
    {
        chatManager.userInfo.headImage = headImageEditor.source;
        chatManager.userInfo.nickname = nicknameEditor.text;
        chatManager.userInfo.gender = genderComboBox.model[genderComboBox.index];
        chatManager.userInfo.signature = signatureInput.text;
        networkManager.updateInfomation();
        root.close();
    }

    function creatSaveInformation()
    {
        var componet = Qt.createComponent("SaveInformation.qml");
        if (componet.status === Component.Ready)
            var obj = componet.createObject(root, { "x": 50 + root.x, "y": 240 + root.y });
        obj.save.connect(save);
        obj.closed.connect(close);
        return obj;
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
        glowColor: background.status == Image.Null ? "#C4E7F8" : "#66C4E7F8";
        radius: 6
        glowRadius: 5
        antialiasing: true
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
            text: qsTr("编辑资料")
            font.pointSize: 10
            font.family: "微软雅黑"
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.left: smallIcon.right
            anchors.leftMargin: 5
        }

        Row
        {
            width: 68
            height: 40
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.top: parent.top
            anchors.topMargin: 6

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
                    if (root.hasModify)
                    {
                        if (root.saveInformation == undefined)
                            root.saveInformation = root.creatSaveInformation();
                        else root.saveInformation.show();
                    }
                    else root.close();
                }
                Component.onCompleted:
                {
                    buttonNormalImage = "qrc:/image/ButtonImage/close_normal.png";
                    buttonPressedImage = "qrc:/image/ButtonImage/close_down.png";
                    buttonHoverImage = "qrc:/image/ButtonImage/close_hover.png";
                }
            }
        }

        Text
        {
            id: headImage
            anchors.verticalCenter: headImageEditor.verticalCenter
            anchors.left: nickname.left
            height: 30
            font.family: "微软雅黑"
            text: qsTr("头像：")
            verticalAlignment: Text.AlignVCenter
        }

        HeadStatus
        {
            id: headImageEditor
            width: 75
            height: 75
            anchors.top: parent.top
            anchors.topMargin: 45
            anchors.horizontalCenter: genderComboBox.horizontalCenter
            source: chatManager.userInfo.headImage

            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: cursorShape = Qt.PointingHandCursor;
                onExited: cursorShape = Qt.ArrowCursor;
                onClicked:
                {
                    if (root.headImageWidget == undefined)
                    {
                        var component = Qt.createComponent("ReplaceHeadImage.qml");
                        if (component.status === Component.Ready)
                            root.headImageWidget = component.createObject(root, { "gradient" : root.gradient });
                    }
                    else root.headImageWidget.show();
                }
            }
        }

        Text
        {
            id: myLevel
            anchors.top: headImageEditor.bottom
            anchors.topMargin: 15
            anchors.left: headImage.left
            height: 30
            font.family: "微软雅黑"
            text: qsTr("等级：")
            verticalAlignment: Text.AlignVCenter
        }

        MyLevel
        {
            level: chatManager.userInfo.level
            anchors.top: myLevel.top
            anchors.topMargin: 5
            anchors.left: myLevel.right
            anchors.leftMargin: 5
        }

        Row
        {
            id: nickname
            spacing: 5
            anchors.top: myLevel.bottom
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter

            Text
            {
                height: 30
                font.family: "微软雅黑"
                text: qsTr("昵称：")
                verticalAlignment: Text.AlignVCenter
            }

            TextField
            {
                id: nicknameEditor
                width: 130
                height: 30
                focus: true
                font.pointSize: 10
                font.family: "微软雅黑"
                selectByMouse: true
                selectedTextColor: "black"
                selectionColor: "#FDDD5C"
                hoverEnabled: true
                clip: true
                text: chatManager.userInfo.nickname
                placeholderText : qsTr("昵称")
                property int maxLength: 12;
                onLengthChanged:
                {
                    if (length > maxLength)
                    {
                        var curPosition = cursorPosition;
                        text = text.substring(0, maxLength);
                        cursorPosition = Math.min(curPosition, maxLength);
                    }
                }
                onTextEdited: root.hasModify = true;
                background : Rectangle
                {
                    radius: 4
                    border.width: (parent.hovered || parent.focus) ? 2 : 1
                    border.color: (parent.hovered || parent.focus) ? "#1583DD" : "transparent"
                }
                KeyNavigation.tab: genderComboBox
                KeyNavigation.down: genderComboBox

                Text
                {
                    visible: parent.focus
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 5
                    font.pointSize: 8
                    font.family: "微软雅黑"
                    text: parent.length + " / " + parent.maxLength
                    color: "red"
                }
            }
        }

        Text
        {
            id: gender
            anchors.top: nickname.bottom
            anchors.topMargin: 15
            anchors.left: nickname.left
            height: 30
            font.family: "微软雅黑"
            text: qsTr("性别：")
            verticalAlignment: Text.AlignVCenter
        }

        MyComboBox
        {
            id: genderComboBox
            z: 5
            anchors.left: gender.right
            anchors.leftMargin: 5
            anchors.top: gender.top
            index: chatManager.userInfo.gender === "男" ? 0 : 1;
            model: ["男", "女"]
            KeyNavigation.up: clicked ? comboBox : nicknameEditor;
            KeyNavigation.tab: clicked ? comboBox : yearField;
            KeyNavigation.down: clicked ? comboBox : yearField;
            onComboBoxEdited: root.hasModify = true;
        }

        Row
        {
            id: birthday
            anchors.top: gender.bottom
            anchors.topMargin: 15
            anchors.left: gender.left
            spacing: 5
            property var date: new Date(chatManager.userInfo.birthday.replace(/-/g, '/'));

            Text
            {
                height: 30
                font.family: "微软雅黑"
                text: qsTr("生日：")
                verticalAlignment: Text.AlignVCenter
            }

            TextField
            {
                id: yearField
                width: 54
                height: 30
                font.pointSize: 10
                font.family: "微软雅黑"
                validator: RegExpValidator
                {
                    regExp: new RegExp("[0-9]{4}");
                }
                selectByMouse: true
                selectedTextColor: "black"
                selectionColor: "#FDDD5C"
                hoverEnabled: true
                clip: true
                text: birthday.date.getFullYear();
                placeholderText : qsTr("年")
                background : Rectangle
                {
                    radius: 4
                    border.width: (parent.hovered || parent.focus) ? 2 : 1
                    border.color: (parent.hovered || parent.focus) ? "#1583DD" : "transparent"
                }
                KeyNavigation.up: genderComboBox
                KeyNavigation.tab: monthField
                KeyNavigation.down: monthField
                onTextEdited: root.hasModify = true;
            }

            TextField
            {
                id: monthField
                width: 35
                height: 30
                font.pointSize: 10
                font.family: "微软雅黑"
                validator: RegExpValidator
                {
                    regExp: new RegExp("[0-9]{2}");
                }
                selectByMouse: true
                selectedTextColor: "black"
                selectionColor: "#FDDD5C"
                hoverEnabled: true
                clip: true
                text:
                {
                    var mon = birthday.date.getMonth() + 1;
                    if (mon >= 10)
                        return mon;
                    else return '0' + mon;
                }
                placeholderText : qsTr("月")
                background : Rectangle
                {
                    radius: 4
                    border.width: (parent.hovered || parent.focus) ? 2 : 1
                    border.color: (parent.hovered || parent.focus) ? "#1583DD" : "transparent"
                }
                KeyNavigation.up: yearField
                KeyNavigation.tab: dayField
                KeyNavigation.down: dayField
                onTextEdited: root.hasModify = true;
            }

            TextField
            {
                id: dayField
                width: 35
                height: 30
                font.pointSize: 10
                font.family: "微软雅黑"
                validator: RegExpValidator
                {
                    regExp: new RegExp("[0-9]{2}");
                }
                selectByMouse: true
                selectedTextColor: "black"
                selectionColor: "#FDDD5C"
                hoverEnabled: true
                clip: true
                text:
                {
                    var day = birthday.date.getDate();
                    if (day >= 10)
                        return day;
                    else return '0' + day;
                }
                placeholderText : qsTr("日")
                background : Rectangle
                {
                    radius: 4
                    border.width: (parent.hovered || parent.focus) ? 2 : 1
                    border.color: (parent.hovered || parent.focus) ? "#1583DD" : "transparent"
                }
                KeyNavigation.up: monthField
                KeyNavigation.tab: customBackgroundComboBox
                KeyNavigation.down: customBackgroundComboBox
                onTextEdited: root.hasModify = true;
            }
        }

        Text
        {
            id: customBackground
            anchors.top: birthday.bottom
            anchors.topMargin: 15
            anchors.right: gender.right
            height: 30
            font.family: "微软雅黑"
            text: qsTr("自定义背景：")
            verticalAlignment: Text.AlignVCenter
        }

        MyComboBox
        {
            id: customBackgroundComboBox
            z: 3
            anchors.left: customBackground.right
            anchors.leftMargin: 5
            anchors.top: customBackground.top
            index: 0;
            model: ["无背景", "背景1", "背景2", "背景3", "背景4", "背景5", "背景6",
                    "背景7", "背景8", "背景9", "本地图片"]
            Component.onCompleted:
            {
                var x = root.backgroundImage.indexOf(chatManager.userInfo.background);
                if (x != -1)
                    index = x;
            }
            onIndexChanged:
            {
                chatManager.userInfo.background = root.backgroundImage[index];
            }
            onComboBoxEdited: root.hasModify = true;
            KeyNavigation.up: clicked ? comboBox : dayField;
            KeyNavigation.tab: clicked ? comboBox : signatureInput;
            KeyNavigation.down: clicked ? comboBox : signatureInput;
        }

        Text
        {
            id: signature
            anchors.top: customBackground.bottom
            anchors.topMargin: 15
            anchors.right: customBackground.right
            height: 30
            font.family: "微软雅黑"
            text: qsTr("个性签名：")
            verticalAlignment: Text.AlignVCenter
        }

        TextArea
        {
            id: signatureInput
            width: 150
            height: 88
            anchors.left: signature.right
            anchors.leftMargin: 5
            anchors.top: signature.top
            font.pointSize: 10
            font.family: "微软雅黑"
            selectByMouse: true
            hoverEnabled: true
            clip: true
            color: "black"
            text: chatManager.userInfo.signature
            placeholderText : qsTr("个性签名")
            selectedTextColor: "black"
            selectionColor: "#FDDD5C"
            wrapMode: TextEdit.WrapAnywhere
            background: Rectangle
            {
                radius: 4
                border.width: (parent.hovered || parent.focus) ? 2 : 1
                border.color: (parent.hovered || parent.focus) ? "#1583DD" : "transparent"
            }
            KeyNavigation.up: customBackgroundComboBox
            property int maxLength: 30;
            onLengthChanged:
            {
                if (length > maxLength)
                {
                    var curPosition = cursorPosition;
                    text = text.substring(0, maxLength);
                    cursorPosition = Math.min(curPosition, maxLength);
                }
            } 
            onEditingFinished: root.hasModify = true;

            Text
            {
                visible: parent.focus
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                font.pointSize: 8
                font.family: "微软雅黑"
                text: parent.length + " / " + parent.maxLength
                color: "red"
            }
        }

        MyButton
        {
            id: saveButton
            text: qsTr("保存")
            hoverColor: "#B0B0B0"
            mouseEnable: root.hasModify
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            anchors.right: exitButton.left
            anchors.rightMargin: 15
            onClicked: root.save();
        }

        MyButton
        {
            id: exitButton
            text: qsTr("退出")
            hoverColor: "#B0B0B0"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            anchors.right: parent.right
            anchors.rightMargin: 15
            onClicked:
            {
                if (root.hasModify)
                {
                    if (root.saveInformation == undefined)
                        root.saveInformation = root.creatSaveInformation();
                    else root.saveInformation.show();
                }
                else root.close();
            }
        }    
    }
}
