import QtQuick 2.12
import QtQuick.Controls 2.12
import "../MyWidgets"
import "../FlatWidgets"

Item
{
    id: root
    visible: false
    clip: true
    width: loginInterface.width
    height: 0
    anchors.centerIn: parent

    function show()
    {
        root.visible = true;
        showAnimation.restart();
    }

    Connections
    {
        target: networkManager
        onHasRegister:
        {
            registerButton.showEmptyTip(result);
        }
    }

    NumberAnimation
    {
        id: showAnimation
        target: root
        to: loginInterface.height
        running: false
        property: "height"
        duration: 400
    }

    NumberAnimation
    {
        id: hideAnimation
        target: root
        to: 0
        running: false
        property: "height"
        duration: 300
        onStopped: root.visible = false;
    }

    MoveMouseArea
    {
        anchors.fill: parent
        target: loginInterface
    }

    Rectangle
    {
        anchors.fill: parent
        radius: 8
        color: "#C4E7F8"

        Column
        {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 24
            anchors.bottom: buttons.top
            anchors.bottomMargin: 10
            spacing: 10
            width: 180
            height: parent.height * 0.8

            Item
            {
                width: parent.width
                height: 32

                Text
                {
                    id: usernameText
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 10
                    font.family: "微软雅黑"
                    text: qsTr("帐号：")
                }

                FlatInput
                {
                    id: usernameField
                    width: 130
                    height: 30
                    anchors.left: usernameText.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: 10
                    font.family: "微软雅黑"
                    selectByMouse: true
                    hoverEnabled: true
                    clip: true
                    placeholderText : qsTr("帐号(必填)")
                    validator: RegExpValidator
                    {
                        regExp: new RegExp("[a-zA-z0-9]*");
                    }
                }
            }

            Item
            {
                width: parent.width
                height: 32

                Text
                {
                    id: passwordText
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 10
                    font.family: "微软雅黑"
                    text: qsTr("密码：")
                }

                FlatInput
                {
                    id: passwordField
                    width: 130
                    height: 30
                    anchors.left: passwordText.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: 10
                    font.family: "微软雅黑"
                    selectByMouse: true
                    hoverEnabled: true
                    clip: true
                    placeholderText : qsTr("密码(必填)")
                    validator: RegExpValidator
                    {
                        regExp: new RegExp("[a-zA-z0-9]*");
                    }
                }
            }

            Item
            {
                width: parent.width
                height: 32

                Text
                {
                    id: nicknameText
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 10
                    font.family: "微软雅黑"
                    text: qsTr("昵称：")
                }

                FlatInput
                {
                    id: nicknameField
                    width: 130
                    height: 30
                    anchors.left: nicknameText.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: 10
                    font.family: "微软雅黑"
                    selectByMouse: true
                    hoverEnabled: true
                    clip: true
                    placeholderText : qsTr("昵称(必填)")
                }
            }

            Item
            {
                z: 5
                width: parent.width
                height: 32

                Text
                {
                    id: genderText
                    height: parent.height
                    font.family: "微软雅黑"
                    font.pointSize: 10
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr("性别：")
                }

                MyComboBox
                {
                    id: genderComboBox
                    anchors.top: genderText.top
                    anchors.left: genderText.right
                    anchors.leftMargin: 5
                    index: 0
                    model: ["男", "女"]
                }
            }

            Item
            {
                width: parent.width
                height: 32

                Text
                {
                    id: birthdayText
                    height: parent.height
                    font.family: "微软雅黑"
                    font.pointSize: 10
                    text: qsTr("生日：")
                    verticalAlignment: Text.AlignVCenter
                }

                FlatInput
                {
                    id: yearField
                    width: 54
                    height: parent.height
                    anchors.left: birthdayText.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: 10
                    font.family: "微软雅黑"
                    validator: RegExpValidator
                    {
                        regExp: new RegExp("[0-9]{4}");
                    }
                    selectByMouse: true
                    selectionColor: "#FDDD5C"
                    hoverEnabled: true
                    clip: true
                    placeholderText : qsTr("年")
                }

                FlatInput
                {
                    id: monthField
                    width: 35
                    height: parent.height
                    anchors.left: yearField.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: 10
                    font.family: "微软雅黑"
                    validator: RegExpValidator
                    {
                        regExp: new RegExp("[0-9]{2}");
                    }
                    selectByMouse: true
                    selectionColor: "#FDDD5C"
                    hoverEnabled: true
                    clip: true
                    placeholderText : qsTr("月")
                }

                FlatInput
                {
                    id: dayField
                    width: 35
                    height: parent.height
                    anchors.left: monthField.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: 10
                    font.family: "微软雅黑"
                    validator: RegExpValidator
                    {
                        regExp: new RegExp("[0-9]{2}");
                    }
                    selectByMouse: true
                    selectionColor: "#FDDD5C"
                    hoverEnabled: true
                    clip: true
                    placeholderText : qsTr("日")
                }
            }

            Item
            {
                width: parent.width
                height: 88

                Text
                {
                    id: signatureText
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height
                    font.family: "微软雅黑"
                    font.pointSize: 10
                    text: qsTr("签名：")
                    verticalAlignment: Text.AlignVCenter
                }

                TextArea
                {
                    id: signatureInput
                    width: 150
                    height: 88
                    anchors.left: signatureText.right
                    anchors.leftMargin: 5
                    anchors.top: parent.top
                    font.pointSize: 10
                    font.family: "微软雅黑"
                    selectByMouse: true
                    hoverEnabled: true
                    clip: true
                    color: "black"
                    placeholderText : qsTr("签名")
                    selectedTextColor: "black"
                    selectionColor: "#FDDD5C"
                    wrapMode: TextEdit.WrapAnywhere
                    background: Rectangle
                    {
                        radius: 4
                        border.width: (parent.hovered || parent.focus) ? 2 : 1
                        border.color: (parent.hovered || parent.focus) ? "#1583DD" : "gray"
                    }
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
        }

        Row
        {
            id: buttons
            spacing: 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter

            MyButton
            {
                id: registerButton
                hoverColor: "#D0D0D0"
                text: qsTr("  注册  ")
                property date currentDate: new Date();

                function showEmptyTip(arg)
                {
                    emptyTip.text = arg;
                    emptyTip.visible = true;
                    emptyTipHide.restart();
                }

                onClicked:
                {
                    if (usernameField.text.length == 0)
                    {
                        showEmptyTip("帐号不能为空！");
                    }
                    else if (usernameField.text.length < 8)
                    {
                        showEmptyTip("帐号至少为8位！");
                    }
                    else if (passwordField.text.length == 0)
                    {
                        showEmptyTip("密码不能为空！");
                    }
                    else if (passwordField.text.length < 10)
                    {
                        showEmptyTip("密码至少为10位！");
                    }
                    else if (nicknameField.text.length == 0)
                    {
                        showEmptyTip("昵称不能为空！");
                    }
                    else
                    {
                        var date;
                        if (yearField.text.length < 4 ||
                            monthField.text.length < 2 ||
                            dayField.text.length < 2)
                        {
                            date = currentDate.toLocaleDateString(Qt.locale(), "yyyy-MM-dd");
                        }
                        else date = yearField.text + "-" + monthField.text + "-"  + dayField.text;

                        var row = {
                            Username   : usernameField.text,
                            Password   : passwordField.text,
                            Nickname   : nicknameField.text,
                            HeadImage  : "qrc:/image/winIcon.png",
                            Background : "qrc:/image/Background/7.jpg",
                            Gender     : genderComboBox.model[genderComboBox.index],
                            Birthday   : date,
                            Signature  : signatureInput.text,
                            Level      : 1
                        };
                        var str = JSON.stringify(row);
                        networkManager.registerUser(str);
                    }
                }

                MyToolTip
                {
                    id: emptyTip
                    NumberAnimation on opacity
                    {
                        id: emptyTipHide
                        running: false
                        from: 1
                        to: 0
                        duration: 1600
                    }
                }
            }

            MyButton
            {
                id: cancelButton
                hoverColor: "#D0D0D0"
                text: qsTr("  取消  ")
                onClicked:
                {
                    hideAnimation.restart();
                }
            }
        }
    }
}
