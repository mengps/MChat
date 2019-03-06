import QtQuick 2.12

GlowCircularImage
{
    id: root
    radius: width / 2
    glowColor: "black"
    glowRadius: 16

    property bool mouseEnable: false

    signal clicked();
    signal entered();
    signal exited();

    MouseArea
    {
        id: imageMouseAre
        enabled: root.mouseEnable
        anchors.fill: parent
        hoverEnabled: true

        onEntered:
        {
            cursorShape = Qt.PointingHandCursor;
            root.entered();
        }

        onExited:
        {
            cursorShape = Qt.ArrowCursor;
            root.exited();
        }

        onClicked:
        {
            root.clicked();
        }
    }
}
