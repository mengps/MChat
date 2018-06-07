import QtQuick 2.7

Rectangle
{
    id: root
    width: tex.width + widthMargin * 2
    height: tex.height + heightMargin * 2
    radius: 4
    border.color: "#9ACFD6"
    color:
    {
        if (mouseEnable)
           return hovered ? hoverColor : Qt.lighter(hoverColor, 1.2);
        else return Qt.darker(hoverColor);
    }

    property alias text: tex.text;
    property alias mouseEnable: mouseArea.enabled;
    property alias fontSize: tex.font.pointSize
    property bool hovered: false;
    property int widthMargin: 10;
    property int heightMargin: 4;
    property color hoverColor: "gray";

    signal clicked();
    signal pressed();
    signal released();
    signal entered();
    signal exited();

    Text
    {
        id: tex
        font.family: "微软雅黑"
        x: widthMargin
        y: heightMargin
    }

    MouseArea
    {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onPressed:
        {
            root.pressed();
            tex.x += 1;
            tex.y += 1;
        }
        onReleased:
        {
            root.released();
            root.clicked();
            tex.x -= 1;
            tex.y -= 1;
        }
        onEntered: root.hovered = true;
        onExited: root.hovered = false;
    }
}
