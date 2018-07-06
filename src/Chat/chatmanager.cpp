#include <QDir>
#include <QSettings>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QApplication>
#include "chatmanager.h"
#include "iteminfo.h"
#include "framelesswindow.h"
#include "databasemanager.h"
#include "networkmanager.h"
#include "friendmodel.h"
#include "systemtrayicon.h"

ChatManager* ChatManager::instance()
{
    static ChatManager m_instance;
    return &m_instance;
}

ChatManager::ChatManager(QObject *parent)
    :   QObject(parent),
        m_username("843261040"),
        m_password("00000000000"),
        m_rememberPassword(false),
        m_autoLogin(false)
{
    m_networkManager = NetworkManager::instance();
    m_rencentMessageIDProxy = new QQmlListProperty<ItemInfo>(this, m_recentMessageID);

    connect(m_networkManager, &NetworkManager::loginFinshed, this, &ChatManager::onLoginFinshed);
    //connect updateUserInfo UserInfoChanged()
}

ChatManager::~ChatManager()
{

}

void ChatManager::initChatManager(QQmlApplicationEngine *qmlengine)
{
    m_qmlEngine = qmlengine;
    //readSettings();
}

bool ChatManager::loadLoginInterface()
{
    if (m_loginInterface.isNull())
    {
        QQmlComponent component(m_qmlEngine, QUrl("qrc:/qml/main.qml"));
        QObject *object = component.create();
        m_loginInterface = qobject_cast<FramelessWindow *>(object);
        if (m_loginInterface.isNull())
        {
            qDebug() << "载入登录界面失败";
            return false;
        }

        QQmlComponent component1(m_qmlEngine, QUrl("qrc:/qml/MyWidgets/SystemTray.qml"));    //给应用一个全局的托盘
        QObject *object1 = component1.create();
        m_systemTray = qobject_cast<SystemTrayIcon *>(object1);
        m_qmlEngine->rootContext()->setContextProperty("systemTray", m_systemTray);
    }

    return true;
}

bool ChatManager::loadMainInterface()
{
    if (m_mainInterface.isNull())
    {
        QQmlComponent component(m_qmlEngine, QUrl("qrc:/qml/MainInterface/MainInterface.qml"));
        QObject *object = component.create();
        m_mainInterface = qobject_cast<FramelessWindow *>(object);
        if (m_mainInterface.isNull())
        {
            qDebug() << "载入主界面失败";
            return false;
        }
        else
        {
            readSettings();
            QMetaObject::invokeMethod(m_mainInterface, "display");
        }
    }
    return true;
}

Chat::LoginStatus ChatManager::loginStatus() const
{
    return m_loginStatus;
}

Chat::ChatStatus ChatManager::chatStatus() const
{
    return m_chatStatus;
}

bool ChatManager::rememberPassword() const
{
    return m_rememberPassword;
}

bool ChatManager::autoLogin() const
{
    return m_autoLogin;
}

QString ChatManager::username() const
{
    return m_username;
}

QString ChatManager::password() const
{
    return m_password;
}

ItemInfo* ChatManager::userInfo() const
{
    return m_userInfo;
}

FriendGroupList* ChatManager::friendGroupList() const
{
    return m_friendGroupList;
}

QQmlListProperty<ItemInfo> ChatManager::recentMessageID() const
{
    return *m_rencentMessageIDProxy;
}

void ChatManager::setLoginStatus(Chat::LoginStatus arg)
{
    m_loginStatus = arg;
    emit loginStatusChanged(arg);
    if (arg == Chat::Logging)  //开始登录
    {
        qDebug() << "登录中";
        m_networkManager->checkLoginInfo(m_username, m_password);
    }
    else if (arg == Chat::LoginSuccess)    //登录成功载入主界面
    {
        qDebug() << "登录成功";
        QMetaObject::invokeMethod(m_loginInterface, "quit");
    }
    else if (arg == Chat::LoginFinished)
    {
        qDebug() << "登录完成";
        loadMainInterface();
        QMetaObject::invokeMethod(m_systemTray, "createMessageTipWindow");
    }
    else if (arg == Chat::LoginFailure)    //登录失败
    {
        qDebug() << "登录失败";
        m_loginStatus = Chat::NoLogin;
    }
    else return;
}

void ChatManager::setChatStatus(Chat::ChatStatus arg)
{
    if (arg != m_chatStatus)
    {
        m_chatStatus = arg;
        // postChatStatus(arg);
        emit chatStatusChanged(arg);
    }
}

void ChatManager::setRememberPassword(bool arg)
{
    if (m_rememberPassword != arg)
    {
        m_rememberPassword = arg;
        emit rememberPasswordChanged(arg);
    }
}

void ChatManager::setAutoLogin(bool arg)
{
    if (m_autoLogin != arg)
    {
        m_autoLogin = arg;
        emit autoLoginChanged(arg);
    }
}

void ChatManager::setUsername(const QString &arg)
{
    if (m_username != arg)
    {
        m_username = arg;
        emit usernameChanged(arg);
    }
}

void ChatManager::setPassword(const QString &arg)
{
    if (m_password != arg)
    {
        m_password = arg;
        emit passwordChanged(arg);
    }
}

void ChatManager::onLoginFinshed(bool ok)
{
    if (ok)    //帐号密码验证
    {
        m_userInfo = m_networkManager->createUserInfo();
        m_friendGroupList = new FriendGroupList(this);
        m_networkManager->createFriend(m_friendGroupList, &m_friendList);
        setLoginStatus(Chat::LoginSuccess);
    }
    else setLoginStatus(Chat::LoginFailure);
}

QStringList ChatManager::getLoginHistory()
{
    QDir dir(QDir::homePath() + "/MChat/Settings");
    QFileInfoList list = dir.entryInfoList();
    QStringList historyList;

    for (auto it : list)
    {
        if (it.isDir() && it.fileName() != "." && it.fileName() != "..")
            historyList.append(it.fileName());
    }

    return historyList;
}

FramelessWindow* ChatManager::addChatWindow(const QString &username)
{
    auto info = createFriendInfo(username);
    info->setUnreadMessage(0);      //清空未读消息
    if (m_chatList.contains(username))
    {
        m_chatList[username]->requestActivate();
        m_chatList[username]->show();
        return m_chatList[username];
    }
    else
    {
        QQmlComponent component(m_qmlEngine, QUrl("qrc:/qml/ChatWindow/ChatWindow.qml"));
        QObject *object = component.create();
        FramelessWindow *window = qobject_cast<FramelessWindow *>(object);
        window->setProperty("username", username);
        connect(window, &FramelessWindow::closed, this, &ChatManager::deleteChatWindow);
        m_chatList.insert(username, window);
        window->requestActivate();
        window->show();
        return window;
    }
}

void ChatManager::appendRecentMessageID(const QString &username)
{
    ItemInfo *info = static_cast<ItemInfo *>(createFriendInfo(username));
    if (!m_recentMessageID.contains(info))
    {
        m_recentMessageID.append(info);
        emit recentMessageIDChanged();
    }
}

void ChatManager::closeAllOpenedWindow()
{
    foreach (FramelessWindow *window, m_chatList)
    {
       if (window) window->close();
    }
}

void ChatManager::deleteChatWindow()
{
    FramelessWindow *chatWindow = qobject_cast<FramelessWindow *>(sender());
    m_chatList.remove(m_chatList.key(chatWindow));
    chatWindow = nullptr;
}

FriendInfo* ChatManager::createFriendInfo(const QString &username)
{
    if (m_friendList.contains(username))
        return qobject_cast<FriendInfo *>(m_friendList[username]);
    else
    {
        FriendInfo *info = new FriendInfo(this);
        info->setUsername(username);
        //set *****
        m_friendList[username] = static_cast<ItemInfo *>(info);
        return info;
    }
}

void ChatManager::readSettings()
{
    QSettings settings(QDir::homePath() + "/MChat/Settings/" + m_username + "/configura.ini", QSettings::IniFormat);

    if (m_loginStatus != Chat::LoginFinished)
    {
        settings.beginGroup("LoginSettings");
        setChatStatus((Chat::ChatStatus)settings.value("ChatStatus").toInt());
        setRememberPassword(settings.value("RememberPassword").toBool());
        setAutoLogin(settings.value("AutoLogin").toBool());
        settings.endGroup();

        settings.beginGroup("AccountInfo");
        setUsername(settings.value("Username").toString());
        if (m_rememberPassword)
            setPassword(QString::fromLatin1(QByteArray::fromBase64(settings.value("Password").toByteArray())));
        settings.endGroup();
    }
    else
    {
        settings.beginGroup("MainSettings");
        m_mainInterface->setCoord(settings.value("Coord", m_mainInterface->coord()).toPoint());
        m_mainInterface->setWidth(settings.value("Width", m_mainInterface->width()).toInt());
        m_mainInterface->setHeight(settings.value("Height", m_mainInterface->height()).toInt());//默认大小即为当前大小
        m_mainInterface->setProperty("isDock", (Chat::DockStatus)settings.value("IsDock", false).toBool());
        m_mainInterface->setProperty("dockState", (Chat::DockStatus)settings.value("DockState", 0).toInt());
        settings.endGroup();
    }
}

void ChatManager::writeSettings()
{

    QString path = QDir::homePath() + "/MChat/Settings/" + m_username;
    QSettings settings(path + "/configura.ini", QSettings::IniFormat);

    if (!QFile::exists(path))   //为每一个帐号创建一个文件夹
    {
        QDir dir;
        dir.mkpath(path);
    }

    settings.beginGroup("LoginSettings");
    settings.setValue("ChatStatus", m_chatStatus);
    settings.setValue("RememberPassword", m_rememberPassword);
    settings.setValue("AutoLogin", m_autoLogin);
    settings.endGroup();

    if (m_loginStatus == Chat::LoginFinished)
    {
        settings.beginGroup("AccountInfo");
        settings.setValue("Username", m_username);
        if (m_rememberPassword)
            settings.setValue("Password", m_password.toLatin1().toBase64());
        settings.endGroup();

        settings.beginGroup("MainSettings");
        settings.setValue("HeadImage", m_userInfo->headImage());
        settings.setValue("Coord", m_mainInterface->coord());
        settings.setValue("Width", m_mainInterface->width());
        settings.setValue("Height", m_mainInterface->height());
        settings.setValue("IsDock", m_mainInterface->property("isDock"));
        settings.setValue("DockState", m_mainInterface->property("dockState"));
        settings.endGroup();
    }
}

void ChatManager::show()
{
    if (m_loginInterface)
    {
        m_loginInterface->requestActivate();
        m_loginInterface->show();
    }
    else if (m_mainInterface)
    {
        m_mainInterface->requestActivate();
        m_mainInterface->entered();
        m_mainInterface->show();
    }
}

void ChatManager::quit()
{
    writeSettings();
    if (!m_loginInterface.isNull())
        QMetaObject::invokeMethod(m_loginInterface, "quit");
    if (!m_mainInterface.isNull())
    {
        QMetaObject::invokeMethod(m_mainInterface, "quit");  
        closeAllOpenedWindow();
    }
    m_systemTray->onExit();
}
