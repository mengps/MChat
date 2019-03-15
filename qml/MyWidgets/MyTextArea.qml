import QtQuick 2.12
import QtQuick.Controls 2.12
import an.utility 1.0

TextArea
{
    id: editor
    antialiasing: true
    textFormat: Text.RichText
    selectionColor: "#3399FF"
    selectByMouse: true
    selectByKeyboard: true
    wrapMode: TextEdit.Wrap

    function insertImage(src)
    {
        imageHelper.insertImage(src);
    }

    function cleanup()
    {
        editor.remove(0, length)
        imageHelper.cleanup();
    }

    Component.onCompleted: imageHelper.processImage(text);

    ImageHelper
    {
        id: imageHelper
        document: editor.textDocument
        cursorPosition: editor.cursorPosition
        selectionStart: editor.selectionStart
        selectionEnd: editor.selectionEnd

        onNeedUpdate:
        {
            let alpha = editor.color.a;
            editor.color.a = alpha - 0.01;
            editor.color.a = alpha;
        }
    }

    MouseArea
    {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.RightButton
        onClicked:
        {
            menu.x = mouse.x + 10;
            menu.y = mouse.y + 10;
            menu.open();
            mouse.accepted = true;
        }
    }

    Menu
    {
        id: menu
        focus: false
        background: GlowRectangle
        {
            radius: 4
            implicitWidth: 140
            implicitHeight: 110
            color: "#F9FCFE"
            glowColor: color
        }
        enter: Transition
        {
            NumberAnimation
            {
                alwaysRunToEnd: true
                property: "opacity"
                easing.type: Easing.Linear
                from: 0
                to: 1
                duration: 400
                onStopped: editor.focus = true;
            }
        }

        FocusScope
        {
            id: focusScope
            focus: false

            MenuItem
            {
                id: cut
                focus: false
                height: 30
                anchors.top: parent.top
                anchors.topMargin: 2
                background: Rectangle
                {
                    width: menu.width
                    height: 30
                    radius: 2
                    border.color: "#DDD"
                    color:
                    {
                        if (editor.readOnly) return "#F9FCFE"
                        else return hovered ? "#9EF2FA" : "#F9FCFE"
                    }
                    property bool hovered: false

                    Text
                    {
                        anchors.centerIn: parent
                        font.family: "微软雅黑"
                        color: editor.readOnly ? "#EEE" : "black"
                        text: qsTr("剪切 (Ctrl + X)")
                    }

                    MouseArea
                    {
                        hoverEnabled: true
                        anchors.fill: parent
                        onEntered: parent.hovered = true;
                        onExited:  parent.hovered = false;
                        onClicked:
                        {
                            menu.close();
                            editor.cut();
                        }
                    }
                }
            }

            MenuItem
            {
                id: copy
                focus: false
                height: 30
                anchors.top: cut.bottom
                anchors.topMargin: 5
                background: Rectangle
                {
                    width: menu.width
                    height: 30
                    radius: 2
                    border.color: "#DDD"
                    color: copy.hovered ? "#9EF2FA" : "#F9FCFE"
                    property bool hovered: false

                    Text
                    {
                        anchors.centerIn: parent
                        font.family: "微软雅黑"
                        text: qsTr("复制 (Ctrl + C)")
                    }

                    MouseArea
                    {
                        hoverEnabled: true
                        anchors.fill: parent
                        onEntered: parent.hovered = true;
                        onExited:  parent.hovered = false;
                        onClicked:
                        {
                            menu.close();
                            editor.copy();
                        }
                    }
                }
            }

            MenuItem
            {
                id: paste
                focus: false
                height: 30
                anchors.top: copy.bottom
                anchors.topMargin: 5
                background: Rectangle
                {
                    width: menu.width
                    height: 30
                    radius: 2
                    border.color: "#DDD"
                    color:
                    {
                        if (editor.readOnly) return "#F9FCFE"
                        else return hovered ? "#9EF2FA" : "#F9FCFE"
                    }
                    property bool hovered: false

                    Text
                    {
                        anchors.centerIn: parent
                        font.family: "微软雅黑"
                        color: editor.readOnly ? "#EEE" : "black"
                        text: qsTr("粘贴 (Ctrl + V)")
                    }

                    MouseArea
                    {
                        hoverEnabled: true
                        anchors.fill: parent
                        onEntered: parent.hovered = true;
                        onExited:  parent.hovered = false;
                        onClicked:
                        {
                            menu.close();
                            editor.paste();
                        }
                    }
                }
            }
        }
    }
}
