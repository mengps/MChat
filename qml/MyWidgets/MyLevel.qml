import QtQuick 2.7

Item
{
    //levelImage: 25 x 25
    id: root

    property int level: 0

    Row
    {
        Repeater
        {
            id: level5
            model: (root.level & 384) >> 8;
            delegate: Image
            {
                width: 20
                height: 20
                mipmap: true
                fillMode: Image.PreserveAspectFit
                source: "qrc:/image/LevelImage/level5.png"
            }
        }

        Repeater
        {
            id: level4
            model: (root.level & 192) >> 6;
            delegate: Image
            {
                width: 20
                height: 20
                mipmap: true
                fillMode: Image.PreserveAspectFit
                source: "qrc:/image/LevelImage/level4.png"
            }
        }

        Repeater
        {
            id: level3
            model: (root.level & 48) >> 4;
            delegate: Image
            {
                width: 20
                height: 20
                mipmap: true
                fillMode: Image.PreserveAspectFit
                source: "qrc:/image/LevelImage/level3.png"
            }
        }

        Repeater
        {
            id: level2
            model: (root.level & 12) >> 2;
            delegate: Image
            {
                width: 20
                height: 20
                mipmap: true
                fillMode: Image.PreserveAspectFit
                source: "qrc:/image/LevelImage/level2.png"
            }
        }

        Repeater
        {
            id: level1
            model: root.level & 3;
            delegate: Image
            {
                width: 20
                height: 20
                mipmap: true
                fillMode: Image.PreserveAspectFit
                source: "qrc:/image/LevelImage/level1.png"
            }
        }
    }
}
