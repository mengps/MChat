import QtQuick 2.7
import QtQuick.Controls 2.2
import an.chat 1.0
import "../MyWidgets"

Item
{
    id: root

    Component
    {
       id: subDelegate

       Rectangle
       {
           id: rec
           width: root.width
           height: 35
           clip: true
           color: hovered ?  "#bbb" : "#00ffffff"

           property bool hovered: false
           property var introduction: undefined;

           CircularImage
           {
               id: subImg
               width: parent.height - 5
               height: width
               mipmap: true
               anchors.left: parent.left
               anchors.leftMargin: 10
               anchors.verticalCenter: parent.verticalCenter
               source: headImage
           }

           Text
           {
               anchors.left: subImg.right
               anchors.leftMargin: 10
               anchors.verticalCenter: parent.verticalCenter
               font.family: "微软雅黑"
               font.pointSize: 10
               verticalAlignment: Text.AlignVCenter
               text: "<b>" + nickname + "</b>" + " 签名：" + "<font color=\"red\" size=\"2\">" + signature + "</font>"
           }

           MouseArea
           {
               anchors.fill: parent
               hoverEnabled: true
               onDoubleClicked:
               {
                   chatManager.addChatWindow(username);
               }
               onEntered:
               {
                   parent.hovered = true;
               }
               onPositionChanged:
               {
                   if (subImg.contains(Qt.point(mouse.x - 10, mouse.y)))
                   {
                       if (rec.introduction == undefined)
                           rec.introduction = mainInterface.createIntroduction(
                                       rec.ListView.view.introductionY - listView.contentY + rec.y + 130, modelData);
                       else rec.introduction.show();
                   }
                   else if (rec.introduction != undefined)
                       rec.introduction.fadeAway();
               }
               onExited:
               {
                   parent.hovered = false;
                   if (rec.introduction != undefined)
                       rec.introduction.fadeAway();
               }
           }
       }
    }

    Component
    {
        id: objDelegate

        Item
        { 
            id: item
            width: root.width
            height: rect.height
            state: clicked ? "expanded" : ""

            property bool clicked: false
            property bool hovered: false

            Rectangle
            {
                id: rect
                height: img.height
                width: parent.width
                color: parent.hovered ?  "#ccc" : "#00ffffff"

                Image
                {
                    id: img
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    source: item.clicked ? "qrc:/image/ContactImage/bottomArrow.png" : "qrc:/image/ContactImage/rightArrow.png"
                }

                Text
                {
                    anchors.left: img.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: img.verticalCenter
                    text: group + "<font color=\"black\" size=\"2\">" + "&nbsp;&nbsp;&nbsp;&nbsp;"
                          + onlineNumber + "/" + totalNumber +  "</font>"
                    font.family: "微软雅黑"
                    font.pointSize: 10
                }

                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.RightButton | Qt.LeftButton
                    onClicked:
                    {
                        item.clicked = !item.clicked;
                        item.ListView.view.currentIndex = index
                    }
                    onEntered: item.hovered = true;
                    onExited: item.hovered = false;
                }
            }

            ListView
            {
                id: subListView
                focus: true
                visible: false
                anchors.top: rect.bottom
                height: contentHeight
                model: friends
                delegate: subDelegate
                property real introductionY: item.y
            }

            transitions:
            [
                Transition
                {
                    reversible: true
                    NumberAnimation
                    {
                        properties: "height,visible"
                    }
                }
            ]

            states:
            [
                State
                {
                    name: "expanded"
                    PropertyChanges { target: item; height: subListView.height + rect.height }
                    PropertyChanges { target: subListView; visible: true }
                }
            ]
        }
    }

    ListView
    {
        id: listView
        focus: true
        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        spacing: 2
        delegate: objDelegate
        model: chatManager.friendGroupList.friendGroups
        ScrollBar.vertical: ScrollBar
        {
            width: 12
            policy: ScrollBar.AsNeeded
        }
    }
}
