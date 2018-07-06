#include <QApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include "iteminfo.h"
#include "chatmanager.h"
#include "chatmessage.h"
#include "framelesswindow.h"
#include "networkmanager.h"
#include "friendmodel.h"
#include "gifhelper.h"
#include "chatapi.h"
#include "systemtrayicon.h"

int main(int argc, char *argv[])
{
#ifdef Q_OS_ANDROID
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
    QApplication app(argc, argv);

    app.setApplicationName("MChat");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("MPS");
    app.setApplicationDisplayName("MChat 聊天");
    app.setQuitOnLastWindowClosed(true);

    QString styleSheet = " QMenu::item:selected { background: #FF8040; color: #000; height: 30px; }" \
                         " QMenu{ padding: 6px 0px 6px 0px; }" \
                         " QMenu::item{ padding-left: 40px; padding-right: 20px; height: 28px; }" \
                         " QMenu::icon{ padding-left: 8px; }" \
                         " QMenu::separator{ height: 1px; margin: 6px 2px 6px 2px; background: #B2C0CD; }";
    app.setStyleSheet(styleSheet);

    qmlRegisterType<FramelessWindow>("an.framelessWindow", 1, 0, "FramelessWindow");
    qmlRegisterType<FriendInfo>("an.chat", 1, 0, "FriendInfo");
    qmlRegisterType<ItemInfo>("an.chat", 1, 0, "ItemInfo");
    qmlRegisterType<FriendGroupList>("an.chat", 1, 0, "FriendGroupList");
    qmlRegisterType<FriendGroupModel>("an.chat", 1, 0, "FriendGroupModel");
    qmlRegisterType<ChatMessage>("an.chat", 1, 0, "ChatMessage");
    qmlRegisterType<ChatMessageList>("an.chat", 1, 0, "ChatMessageList");
    qmlRegisterType<GifHelper>("an.utility", 1, 0, "GifHelper");
    qmlRegisterType<MyMenu>("an.utility", 1, 0, "MyMenu");
    qmlRegisterType<MyAction>("an.utility", 1, 0, "MyAction");
    qmlRegisterType<MySeparator>("an.utility", 1, 0, "MySeparator");
    qmlRegisterType<SystemTrayIcon>("an.utility", 1, 0, "SystemTrayIcon");
    qmlRegisterUncreatableMetaObject(Chat::staticMetaObject, "an.chat", 1, 0, "Chat", "不能创建Chat对象");

    ChatManager *chatManager = ChatManager::instance();
    QQmlApplicationEngine qmlEngine;
    chatManager->initChatManager(&qmlEngine);
    qmlEngine.rootContext()->setContextProperty("Api", new Api);
    qmlEngine.rootContext()->setContextProperty("chatManager", chatManager);
    NetworkManager *networkManager = NetworkManager::instance();
    qmlEngine.rootContext()->setContextProperty("networkManager", networkManager);

    chatManager->loadLoginInterface();

    return app.exec();
}
