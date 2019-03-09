import QtQuick 2.12
import QtQuick.Controls 2.12
import an.utility 1.0

TextEdit
{
    id: editor
    selectionColor: "#3399FF"
    textFormat: TextEdit.RichText   //使用富文本
    selectByMouse: true
    selectByKeyboard: true
    wrapMode: TextEdit.Wrap
    property alias cachePath: gifHelper.cachePath

    function addImage(src, w, h)
    {
        var index1 = src.lastIndexOf(".");
        var index2 = src.length;
        var suffix = src.substring(index1 + 1, index2);  //后缀名
        if (suffix === "gif" || suffix === "GIF")   //如果为动图
        {
            gifHelper.addGif(src)
            var baseName = Api.baseName(src);
            editor.insert(editor.cursorPosition, "<img src=\"file:///" +
                          gifHelper.cachePath + baseName + "/0" + ".png" +
                          "\" height=" + w + " width=" + h + ">");  //插入第一帧的图片
        }
        else  editor.insert(editor.cursorPosition,
                            "<img src=\"" + src + "\" height=" + w + " width=" + h + ">")
    }

    function cleanup()
    {
        editor.remove(0, length)
        gifHelper.cleanup();
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
                onStopped:
                {
                    editor.activeFocus = true;
                    editor.focus = true;
                }
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

    GifHelper
    {
        id: gifHelper

        onUpdateGif:
        {
            var pos = editor.cursorPosition;
            var selstart = editor.selectionStart;
            var selend = editor.selectionEnd;
            editor.text = editor.text.replace(oldData, newData);
            editor.cursorPosition = pos;
            editor.select(selstart, selend);
        }
    }  
}
