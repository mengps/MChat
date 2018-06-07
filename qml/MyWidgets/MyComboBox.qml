import QtQuick 2.7

Item
{
    id: root
    width: 130

    property alias model: listView.model;
    property alias clicked: currentBox.clicked
    property alias comboBox: dropDownBox
    property int index: 0;

    signal comboBoxEdited();

    Keys.onPressed:
    {
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
        {
            dropDownBox.visible = !dropDownBox.visible;
            currentBox.clicked = !currentBox.clicked;
            root.index = listView.currentIndex
            if (!clicked) focus = !clicked;
        }
    }

    Rectangle
    {
        id: currentBox
        width: parent.width
        height: 30
        radius: 4
        border.width: 2
        border.color: hovered || root.focus ? "#1583DD" : "transparent"
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
            anchors.rightMargin: 10
            source: parent.clicked ? "qrc:/image/WidgetsImage/topArrow.png" : "qrc:/image/WidgetsImage/bottomArrow.png";
        }

        MouseArea
        {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: parent.hovered = true;
            onExited: parent.hovered = false;
            onClicked:
            {
                root.focus = true;
                dropDownBox.visible = !dropDownBox.visible;
                parent.clicked = !parent.clicked;
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
            height: 30
            radius: 4
            color: (listView.currentIndex == index) ? "#1583DD" : "#D1D1D1"
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
                    dropDownBox.visible = !dropDownBox.visible;
                    currentBox.clicked = !currentBox.clicked;
                    root.comboBoxEdited();
                }
            }
        }
    }

    Item
    {
        id: dropDownBox
        visible: false
        width: parent.width
        height: listView.contentHeight
        anchors.left: parent.left
        anchors.top: currentBox.bottom
        Keys.onUpPressed: listView.decrementCurrentIndex()
        Keys.onDownPressed: listView.incrementCurrentIndex()

        ListView
        {
            id: listView
            interactive : false
            anchors.fill: parent
            delegate: delegate
        }
    }
}
