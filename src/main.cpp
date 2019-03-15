#include "chatapi.h"
#include "chatmanager.h"
#include "chatmessage.h"
#include "friendmodel.h"
#include "framelesswindow.h"
#include "imageHelper.h"
#include "iteminfo.h"
#include "magicpool.h"
#include "networkmanager.h"
#include "systemtrayicon.h"

#include <QApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>

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
    app.setQuitOnLastWindowClosed(false);

    QString styleSheet = " QMenu::item:selected{ background: #FF8040; color: #000; height: 30px; }" \
                         " QMenu{ padding: 6px 0px 6px 0px; }" \
                         " QMenu::item{ padding-left: 40px; padding-right: 20px; height: 28px; }" \
                         " QMenu::icon{ padding-left: 8px; }" \
                         " QMenu::separator{ height: 1px; margin: 6px 2px 6px 2px; background: #B2C0CD; }";
    app.setStyleSheet(styleSheet);

    qRegisterMetaType<msg_t>("msg_t");
    qRegisterMetaType<msg_flag_t>("msg_flag_t");
    qRegisterMetaType<msg_size_t>("msg_size_t");
    qRegisterMetaType<msg_option_t>("msg_option_t");
    qRegisterMetaType<ChatMessage>("ChatMessage");

    qmlRegisterType<FramelessWindow>("an.window", 1, 0, "FramelessWindow");
    qmlRegisterType<FriendInfo>("an.chat", 1, 0, "FriendInfo");
    qmlRegisterType<ItemInfo>("an.chat", 1, 0, "ItemInfo");
    qmlRegisterType<FriendGroup>("an.chat", 1, 0, "FriendGroup");
    qmlRegisterType<FriendModel>("an.chat", 1, 0, "FriendModel");
    qmlRegisterType<ChatMessage>("an.chat", 1, 0, "ChatMessage");
    qmlRegisterType<ChatMessageList>("an.chat", 1, 0, "ChatMessageList");
    qmlRegisterType<ImageHelper>("an.utility", 1, 0, "ImageHelper");
    qmlRegisterType<MyMenu>("an.utility", 1, 0, "MyMenu");
    qmlRegisterType<MyAction>("an.utility", 1, 0, "MyAction");
    qmlRegisterType<MySeparator>("an.utility", 1, 0, "MySeparator");
    qmlRegisterType<SystemTrayIcon>("an.utility", 1, 0, "SystemTrayIcon");
    qmlRegisterType<MagicPool>("an.utility", 1, 0, "MagicPool");
    qmlRegisterUncreatableMetaObject(Chat::staticMetaObject,
                                     "an.chat", 1, 0, "Chat", "不能创建Chat对象");
    qmlRegisterUncreatableMetaObject(ChatMessageStatus::staticMetaObject,
                                     "an.chat", 1, 0, "ChatMessageStatus", "不能创建ChatMessageStatus对象");
    qmlRegisterUncreatableMetaObject(NetworkMode::staticMetaObject,
                                     "an.network", 1, 0, "NetworkMode", "不能创建NetworkMode对象");

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
