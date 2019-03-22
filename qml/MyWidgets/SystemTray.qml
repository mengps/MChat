import QtQuick 2.12
import an.utility 1.0
import an.chat 1.0

SystemTrayIcon
{
    id: root
    visible: true
    icon: "qrc:/image/winIcon.png"
    toolTip:
    {
        if (chatManager.loginStatus === Chat.LoginFinished)
        return "MChat: " + chatManager.userInfo.nickname + "(" + chatManager.username +
             ")\n声音: 开启" + "\n消息提醒: 开启" + "\n会话消息: 任务栏闪动";
        else return "MChat";
    }
    menu: menu2

    property MessageTipWindow messageTipWindow;

    onTrigger: chatManager.show();
    onMouseHovered:
    {
        if (flicker.running)
        {
            messageTipWindow.showWindow(root.x, root.y);
        }
    }
    onMouseExited:
    {
        if (flicker.running)
        {
            if (messageTipWindow.hovered === false)
                messageTipWindow.hideWindow();
        }
    }

    function createMessageTipWindow()
    {
        var component = Qt.createComponent("MessageTipWindow.qml");
        if (component.status === Component.Ready)
            var window = component.createObject(root);
        else print(component.errorString())
        messageTipWindow = window;
    }

    function flickerImage(sender_info)
    {
        flicker.icon = sender_info.headImage;
        flicker.restart();
    }

    function stopFlicker()
    {
        flicker.stop();
        root.icon = "qrc:/image/winIcon.png";
    }

    Connections
    {
        target: chatManager
        onLoginStatusChanged:
        {
            if (chatManager.loginStatus === Chat.LoginFinished)
                root.menu = menu1;
            else root.menu = menu2;
        }
    }

    Connections
    {
        target: messageTipWindow
        onStopFlicker: stopFlicker();
    }

    Connections
    {
        target: networkManager
        onHasNewText:
        {
           if (!chatManager.chatWindowIsOpenned(sender))
           {
                var sender_info = chatManager.createFriendInfo(sender);
                flickerImage(sender_info);
                messageTipWindow.appendMessage(sender_info);
            }
        }
        onHasNewShake:
        {
            var sender_info = chatManager.createFriendInfo(sender);
            stopFlicker();
            messageTipWindow.popbackMessage(sender_info)
        }
    }

    Timer
    {
        id: flicker
        running: false
        repeat: true
        interval: 500
        property string icon;

        onTriggered:
        {
            if (root.icon == "")
                root.icon = icon;
            else root.icon = "";
        }
    }

    MyMenu
    {
        id: menu1

        MyAction
        {
            text: "在线"
            icon: "qrc:/image/winIcon.png"
        }

        MyAction
        {
            text: "隐身"
            icon: "qrc:/image/winIcon.png"
        }

        MyAction
        {
            text: "忙碌"
            icon: "qrc:/image/winIcon.png"
        }

        MyAction
        {
            text: "离线"
            icon: "qrc:/image/winIcon.png"
        }

        MySeparator {}

        MyMenu
        {
            text: "设置          "
            MyAction
            {
                text: "关闭所有声音"
                icon: "qrc:/image/winIcon.png"
            }

            MyAction
            {
                text: "关闭头像闪动"
                icon: "qrc:/image/winIcon.png"
            }
        }

        MySeparator {}

        MyAction
        {
            text: "打开主界面"
            onTriggered: chatManager.show();
        }

        MyAction
        {
            text: "退出"
            onTriggered:
            {
                root.onExit();
                chatManager.quit();
            }
        }
    }

    MyMenu
    {
        id: menu2

        MyAction
        {
            text: "打开登录界面"
            icon: "qrc:/image/winIcon.png"
            onTriggered: chatManager.show();
        }

        MyAction
        {
            text: "退出"
            icon: "qrc:/image/winIcon.png"
            onTriggered:
            {
                if (messageTipWindow != null) messageTipWindow.close();
                chatManager.quit();
            }
        }
    }
}
