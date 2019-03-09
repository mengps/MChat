import QtQuick 2.12
import QtGraphicalEffects 1.0
import Qt.labs.platform 1.0
import QtQuick.Controls 1.4
import QtQuick.Window 2.12
import an.window 1.0
import "../MyWidgets"

FramelessWindow
{
    id: root

    width: 300
    height: 410
    actualWidth: width + 14
    actualHeight: height + 14
    x: (Screen.desktopAvailableWidth - actualWidth) / 2
    y: (Screen.desktopAvailableHeight - actualHeight) / 2
    visible: true
    taskbarHint: true

    GlowRectangle
    {
        id: backContent
        anchors.centerIn: parent
        width: root.width
        height: root.height
        color: "#666"
        glowColor: color
        radius: 6
        glowRadius: 5
        antialiasing: true
        opacity: 0.85

        MoveMouseArea
        {
            anchors.fill: parent
            target: root
        }

        Row
        {
            id: controlButtons
            z: 10
            width: 68
            height: 30
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.top: parent.top
            anchors.topMargin: 6

            CusButton
            {
                id: minButton
                width: 32
                height: 32

                onClicked: root.showMinimized();
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

                onClicked: root.close();
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
            id: content
            anchors.top: controlButtons.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: width
            clip: true

            Item
            {
                id: source
                width: 300
                height: 300

                Image
                {
                    id: headImage
                    width: 300
                    height: 300
                    antialiasing: true
                    fillMode: Image.PreserveAspectCrop
                    source: chatManager.userInfo.headImage
                    property real magnification: scaleToImage.value

                    onMagnificationChanged:
                    {
                        width = 300 * magnification;
                        height = 300 * magnification;
                    }
                    onSourceChanged:
                    {
                        x = 0;
                        y = 0;
                        scaleToImage.oldValue = 1.0;
                        scaleToImage.value = 1.0;
                    }
                }
            }

            Image
            {
                id: mask
                anchors.fill: parent
                source: "qrc:/image/WidgetsImage/replaceMask.png"
            }

            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                property int headImageStartX: 0;
                property int headImageStartY: 0;
                property int mouseStartX: 0;
                property int mouseStartY: 0;
                property int offsetX: 0;
                property int offsetY: 0;

                onWheel:
                {
                    var degrees = wheel.angleDelta.y / 120;

                    if (degrees > 0)
                    {
                        for (var i = 0; i < degrees; i++)
                            if (headImage.magnification < 2.0) scaleToImage.value += 0.05;
                    }
                    else if (degrees < 0)
                    {
                        for (var j = degrees; j < 0; j++)
                            if (headImage.magnification > 1.0) scaleToImage.value -= 0.05;
                    }
                }
                onEntered: cursorShape = Qt.OpenHandCursor;
                onExited: cursorShape = Qt.ArrowCursor;
                onPressed:
                {
                    headImageStartX = headImage.x;
                    headImageStartY = headImage.y;
                    mouseStartX = mouse.x;
                    mouseStartY = mouse.y;
                    cursorShape = Qt.ClosedHandCursor;
                }
                onPositionChanged:
                {
                    if (pressed)
                    {
                        offsetX = mouse.x - mouseStartX;
                        offsetY = mouse.y - mouseStartY;
                        if (offsetX >= 0)
                        {
                            if ((headImageStartX + offsetX) > 0)
                                headImage.x = 0;
                            else headImage.x = headImageStartX + offsetX;
                        }
                        else
                        {
                            if ((headImageStartX + offsetX) < (content.width - headImage.width))
                                headImage.x = content.width - headImage.width;
                            else headImage.x = headImageStartX + offsetX;
                        }

                        if (offsetY >= 0)
                        {
                            if ((headImageStartY + offsetY) > 0)
                                headImage.y = 0;
                            else headImage.y = headImageStartY + offsetY;
                        }
                        else
                        {
                            if ((headImageStartY + offsetY) < (content.height - headImage.height))
                                headImage.y = content.height - headImage.height;
                            else headImage.y = headImageStartY + offsetY;
                        }
                    }
                }
                onReleased: cursorShape = Qt.OpenHandCursor;
            }
        }

        CusButton
        {
            id: minusButton
            width: 20
            height: 20
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: content.bottom
            anchors.topMargin: 6
            buttonNormalImage: "qrc:/image/ButtonImage/minus_normal.png"
            buttonHoverImage: "qrc:/image/ButtonImage/minus_hover.png"
            buttonPressedImage: "qrc:/image/ButtonImage/minus_hover.png"
            onClicked: scaleToImage.value -= 0.04;
        }

        CusButton
        {
            id: addButton
            width: 20
            height: 20
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.top: content.bottom
            anchors.topMargin: 6
            buttonNormalImage: "qrc:/image/ButtonImage/add_normal.png"
            buttonHoverImage: "qrc:/image/ButtonImage/add_hover.png"
            buttonPressedImage: "qrc:/image/ButtonImage/add_hover.png"
            onClicked: scaleToImage.value += 0.04;
        }

        Slider
        {
            id: scaleToImage
            anchors.verticalCenter: minusButton.verticalCenter
            anchors.left: minusButton.right
            anchors.leftMargin: 5
            anchors.right: addButton.left
            anchors.rightMargin: 5
            maximumValue : 2.0
            minimumValue : 1.0
            stepSize: 0.01
            property real oldValue: 1.0
            onValueChanged:
            {
                headImage.x -= (value - oldValue) * 150;
                headImage.y -= (value - oldValue) * 150;
                oldValue = value;
                headImage.magnification = value;
            }
        }

        MyButton
        {
            id: openLocalImage
            text: qsTr("本地图片")
            hoverColor: "#B0B0B0"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            anchors.right: saveButton.left
            anchors.rightMargin: 15
            onClicked: fileDialog.open();
            FileDialog
            {
                id: fileDialog
                folder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
                nameFilters: [ "图像类型 (*.jpg *.png *.bmp)", "所有文件 (*)" ]
                title: qsTr("打开本地图片")
                onAccepted:
                {
                    console.log("You chose result: " + file);
                    headImage.source = file;
                }
            }
        }

        MyButton
        {
            id: saveButton
            text: qsTr("保存")
            hoverColor: "#B0B0B0"
            anchors.bottom: openLocalImage.bottom
            anchors.right: exitButton.left
            anchors.rightMargin: 15
            onClicked:
            {
                source.grabToImage(function (result)
                {
                    chatManager.userInfo.headImage = result.url;
                    root.close();
                });
            }
        }

        MyButton
        {
            id: exitButton
            text: qsTr("退出")
            hoverColor: "#B0B0B0"
            anchors.bottom: saveButton.bottom
            anchors.right: parent.right
            anchors.rightMargin: 15
            onClicked: root.close();
        }
    }
}
