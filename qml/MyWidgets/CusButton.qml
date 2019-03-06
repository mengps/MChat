import QtQuick 2.12

Rectangle
{
    id: root
    color: hovered ? "#9AFFFFFF" : "transparent";

    property string buttonNormalImage: "";
    property string buttonPressedImage: "";
    property string buttonHoverImage: "";
    property bool hovered: false;

    signal pressed();
    signal released();
    signal clicked();
    signal exited();
    signal entered();

    Image
    {
        id: image
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        antialiasing: true
        mipmap: true
        source: root.buttonNormalImage

        MouseArea
        {
            anchors.fill: parent
            hoverEnabled: true

            onEntered:
            {
                root.entered();
                root.hovered = true;
                image.source = buttonHoverImage;
            }
            onPressed:
            {
                root.pressed();
                root.clicked();
                image.source = buttonPressedImage;
            }
            onReleased:
            {
                root.released();
                image.source = buttonNormalImage;
            }
            onExited:
            {
                root.exited();
                root.hovered = false;
                image.source = buttonNormalImage;
            }
        }
    }
}
