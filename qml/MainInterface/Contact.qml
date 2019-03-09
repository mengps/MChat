import QtQuick 2.12
import QtQuick.Controls 2.12
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
           id: subRect
           width: root.width
           height: 40
           clip: true
           color: hovered ?  "#ACBBBBBB" : "transparent"

           property bool hovered: false
           property var introduction: undefined;

           CircularImage
           {
               id: subImage
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
               id: subSignature
               anchors.left: subImage.right
               anchors.leftMargin: 10
               anchors.verticalCenter: parent.verticalCenter
               font.family: "微软雅黑"
               font.pointSize: 10
               verticalAlignment: Text.AlignVCenter
               text: "<b>" + nickname + "</b>" + " 签名：" + "<font color=\"red\" size=\"2\">" + signature + "</font>"
           }

           MyToolTip
           {
               id: signatureTip
               visible: false
               text: signature
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
                   if (subImage.contains(Qt.point(mouse.x - 10, mouse.y)))
                   {
                       signatureTip.visible = false;
                       if (subRect.introduction == undefined)
                           subRect.introduction = mainInterface.createIntroduction(
                                       subRect.ListView.view.introductionY - listView.contentY + subRect.y + 130, modelData);
                       else subRect.introduction.show();
                   }
                   else if (subRect.introduction != undefined)
                       subRect.introduction.fadeAway();
                   else if (subSignature.contains(Qt.point(mouse.x - 10 + subImage.width, mouse.y)))
                       signatureTip.visible = true;
               }
               onExited:
               {
                   parent.hovered = false;
                   signatureTip.visible = false;
                   if (subRect.introduction != undefined)
                       subRect.introduction.fadeAway();
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
                height: image.height + 8
                width: parent.width
                color: parent.hovered ?  "#ACBBBBBB" : "transparent"

                Image
                {
                    id: image
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    source: item.clicked ? "qrc:/image/WidgetsImage/bottomArrow.png" : "qrc:/image/WidgetsImage/rightArrow.png"
                }

                Text
                {
                    anchors.left: image.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
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
        model: chatManager.friendGroups
        ScrollBar.vertical: ScrollBar
        {
            width: 12
            policy: ScrollBar.AsNeeded
        }
    }
}
