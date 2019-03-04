import QtQuick 2.7
import QtQuick.Controls 2.2

Item
{
    id: root
    width: 130

    property int index: 0;
    property int itemWidth: width;
    property int itemHeight: 30;
    property int dropWidth: width;
    property int dropHeight: 180;

    property alias model: listView.model;
    property alias interactive: listView.interactive;
    property alias clicked: currentBox.clicked;
    property alias comboBox: dropDownBox;

    signal comboBoxEdited();

    Keys.onPressed:
    {
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
        {
            currentBox.clicked = !currentBox.clicked;
            root.index = listView.currentIndex
            if (!clicked) focus = !clicked;
        }
    }

    Rectangle
    {
        id: currentBox
        width: parent.width
        height: root.itemHeight
        radius: 4
        border.width: (hovered || root.focus) ? 2 : 1
        border.color: (hovered || root.focus) ? "#1583DD" : "gray"
        property bool clicked: false
        property bool hovered: false

        Text
        {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            leftPadding: 10
            font.pointSize: 10
            font.family: "微软雅黑"
            text: model[index]
        }

        Image
        {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8
            source: currentBox.clicked ? "qrc:/image/WidgetsImage/topArrow.png" : "qrc:/image/WidgetsImage/bottomArrow.png";
        }

        MouseArea
        {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: parent.hovered = true;
            onExited: parent.hovered = false;
            onClicked:
            {
                currentBox.clicked = !currentBox.clicked;
                dropDownBox.focus = true;
            }
        }
    }

    Component
    {
        id: delegate

        Rectangle
        {
            id: rc
            width: root.width
            height: root.itemHeight
            color: (listView.currentIndex == index) ? "#1583DD" : "white"
            property bool hovered: false

            Text
            {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
                text: model.modelData
                font.pointSize: 10
                font.family: "微软雅黑"
            }

            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true

                onEntered:
                {
                    listView.currentIndex = index;
                    parent.hovered = true;
                }
                onExited: parent.hovered = false;
                onClicked:
                {
                    root.index = index;
                    currentBox.clicked = !currentBox.clicked;
                    root.comboBoxEdited();
                }
            }
        }
    }

    Rectangle
    {
        id: dropDownBox
        visible: currentBox.clicked
        clip: true
        width: root.dropWidth
        height: Math.min(root.dropHeight, listView.contentHeight)
        border.color: visible ? "#1583DD" : "transparent"
        anchors.left: parent.left
        anchors.top: currentBox.bottom
        Keys.onUpPressed: listView.decrementCurrentIndex()
        Keys.onDownPressed: listView.incrementCurrentIndex()
        onFocusChanged: if (!focus) currentBox.clicked = false;

        ListView
        {
            id: listView
            anchors.fill: parent
            delegate: delegate
            ScrollBar.vertical: ScrollBar
            {
                width: 10
                policy: ScrollBar.AsNeeded
            }
        }
    }
}
