import QtQuick 2.7

Rectangle
{
    id: root
    color: "#F3F3F3"
    radius: 8
    clip: true

    property var colorList: [ "#FFFFFF", "#CCCCCC", "#C0C0C0", "#999999", "#666666", "#333333", "#000000",
                              "#FFCCCC", "#FF6666", "#FF0000", "#CC0000", "#990000", "#660000", "#330000",
                              "#FFCC99", "#FF9966", "#FF9900", "#FF6600", "#CC6600", "#993300", "#663300",
                              "#FFFF99", "#FFFF66", "#FFCC66", "#FFCC33", "#CC9933", "#996633", "#663333",
                              "#FFFFCC", "#FFFF33", "#FFFF00", "#FFCC00", "#999900", "#666600", "#333300",
                              "#99FF99", "#66FF99", "#33FF33", "#33CC00", "#009900", "#006600", "#003300",
                              "#99FFFF", "#33FFFF", "#66CCCC", "#00CCCC", "#339999", "#336666", "#003333",
                              "#CCFFFF", "#66FFFF", "#33CCFF", "#3366FF", "#33FFFF", "#000099", "#000066",
                              "#CCCCFF", "#9999FF", "#6666CC", "#6633FF", "#6600CC", "#333399", "#330099",
                              "#FFCCFF", "#FF99FF", "#CC66CC", "#CC33CC", "#993399", "#663366", "#330033"
                            ];

    property color currentColor: "#000";
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
        target: root
        property: "height"
        duration: 300
    }
    Component
    {
        id: delegate

        Item
        {
            width: gridView.cellWidth
            height: gridView.cellHeight

            Rectangle
            {
                anchors.centerIn: parent
                width: hovered ? 18 : 14
                height: width
                radius: width / 2
                color: modelData
                border.color: hovered ? "black" : "transparent"
                property bool hovered: false

                MouseArea
                {
                    hoverEnabled: true
                    anchors.fill: parent
                    onEntered:
                    {
                        cursorShape = Qt.PointingHandCursor
                        parent.hovered = true;
                    }
                    onExited:
                    {
                        cursorShape = Qt.ArrowCursor;
                        parent.hovered = false;
                    }
                    onClicked: root.currentColor = modelData;
                }
            }
        }
    }

    GridView
    {
        id: gridView
        anchors.centerIn: parent
        width: 154
        height: 220
        cellHeight: 22
        cellWidth: 22
        model: colorList
        delegate: delegate
    }
}
