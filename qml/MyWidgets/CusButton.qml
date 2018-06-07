import QtQuick 2.7

Item
{
    id: cusButton

    property string buttonNormalImage: ""
    property string buttonPressedImage: ""
    property string buttonHoverImage: ""
    property string buttonDisableImage: ""
    property bool buttonDisable: false

    signal clicked();
    signal exited();
    signal entered();

    Image
    {
        id: cusButtonImage
        anchors.fill: parent
        mipmap: true
        source: buttonNormalImage

        MouseArea
        {
            id: cusButtonMouseArea
            anchors.fill: parent
            hoverEnabled: true

            onEntered:
            {
                if (buttonDisable == false)
                {
                    cusButton.entered();
                    cusButtonImage.source = buttonHoverImage;
                }
            }
            onClicked:
            {
                if (buttonDisable == false)
                {
                    cusButton.clicked();
                    cusButtonImage.source = buttonPressedImage;
                }
            }
            onExited:
            {
                if (buttonDisable == false)
                {
                    cusButton.exited();
                    cusButtonImage.source = buttonNormalImage;
                }
            }
        }
    }
    onButtonDisableChanged :
    {
        buttonDisable === false ? (cusButtonImage.source = buttonNormalImage)
                                : (cusButtonImage.source = buttonDisableImage);
    }
}
