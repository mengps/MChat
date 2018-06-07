import QtQuick 2.7
import QtQuick.Controls 2.2

Rectangle
{
    id: root
    color: "#F3F3F3"
    radius: 8
    clip: true
    property var faces: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11",
                          "12", "13", "14", "21", "23", "25", "26", "27", "29", "32",
                          "33", "34", "36", "37", "38", "39", "42", "45", "46", "47",
                          "50", "51", "53", "54", "55", "56", "57", "58", "59", "62",
                          "63", "64", "71", "72", "73", "74", "75", "76", "77", "78",
                          "79", "80", "81", "82", "83", "84", "85", "86", "87", "88",
                          "91", "93", "95", "96", "97", "98", "99", "100", "101", "102",
                          "103", "104", "105", "106", "107", "108", "109", "110", "111", "112",
                          "113", "114", "115", "116", "117", "118", "119", "120", "121", "122",
                          "123", "124", "125", "126", "127", "128", "129", "130", "131", "132",
                          "133", "134", "dfp", "dfr", "dhp", "K歌", "棒棒糖", "爆筋", "鞭炮", "彩球",
                          "钞票", "车厢", "打伞", "灯笼", "灯泡", "多云", "发财", "飞机", "风车",
                          "高铁右车头", "高铁左车头", "购物", "喝彩", "喝奶", "开车", "闹钟", "祈祷",
                          "青蛙", "沙发", "手枪", "帅", "双喜", "下面", "下雨", "香蕉", "熊猫", "药",
                          "邮件", "纸巾", "钻戒"];
    GridView
    {
        id: grid
        anchors.centerIn: parent
        width: parent.width - 30
        height: parent.height - 30
        cellWidth: 40
        cellHeight: 40
        model: faces
        delegate: delegate
        ScrollBar.vertical: ScrollBar
        {
            width: 12
            policy: ScrollBar.AlwaysOn
        }
    }

    Component
    {
        id: delegate

        Rectangle
        {
            id: back
            width: grid.cellWidth
            height: grid.cellHeight
            color: hovered ? "gray" : "#F3F3F3";
            property bool hovered: false

            Image
            {
                width: 30
                height: 30
                anchors.centerIn: parent
                source: "qrc:/image/FacesImage/" + modelData + ".png"
                mipmap: true

                MouseArea
                {
                    hoverEnabled: true
                    anchors.fill: parent
                    onEntered:
                    {
                        back.hovered = true;
                        var file = ":/FacesImage/" + modelData;
                        if (Api.exists(file + ".gif"))
                        {
                            gifPreview.visible = true;
                            imagePreview.visible = false;
                            gifPreview.source = "qrc" + file + ".gif";
                        }
                        else
                        {
                            gifPreview.visible = false;
                            imagePreview.visible = true;
                            imagePreview.source = "qrc" + file + ".png";
                        }
                        previewRect.x = root.x + back.x;
                        previewRect.y = root.y + (back.y - grid.contentY) - 75;
                        previewRect.visible = true;
                    }
                    onExited:
                    {
                        back.hovered = false;
                        previewRect.visible = false;
                    }
                    onClicked:
                    {
                        var file = ":/FacesImage/" + modelData;
                        if (Api.exists(file + ".gif"))
                            file = "qrc" + file + ".gif";
                        else file = "qrc" + file + ".png";
                        sendMessage.addImage(file, 25, 25);
                    }
                }
            }
        }
    }
}
