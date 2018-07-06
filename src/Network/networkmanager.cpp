#include <QDebug>
#include <QFile>
#include <QDateTime>
#include <QJsonObject>
#include <QJsonDocument>
#include "chatmanager.h"
#include "networkmanager.h"
#include "iteminfo.h"
#include "chatmessage.h"
#include "databasemanager.h"
#include "myjsonparse.h"
#include "friendmodel.h"

NetworkManager* NetworkManager::instance()
{
    static NetworkManager networkManager;
    return &networkManager;
}

NetworkManager::NetworkManager(QObject *parent)
    :   QObject(parent)
{
    m_tcpManager = new TcpManager(this);

    connect(m_tcpManager, &TcpManager::logined, this, &NetworkManager::onLogined);
    connect(m_tcpManager, &TcpManager::infoGot, this, &NetworkManager::onInfoGot);
    connect(m_tcpManager, &TcpManager::loginError, this, &NetworkManager::loginError);
    connect(m_tcpManager, &TcpManager::hasNewMessage, this, &NetworkManager::deposeNewMessage);
}

NetworkManager::~NetworkManager()
{
    if (m_jsonParse)
        delete m_jsonParse;
}

void NetworkManager::checkLoginInfo(const QString &username, const QString &password)
{
    m_tcpManager->readyLogin(username, password);
    m_tcpManager->requestNewConnection();
}

ItemInfo *NetworkManager::createUserInfo()
{
    return m_jsonParse->userInfo();
}

void NetworkManager::createFriend(FriendGroupList *friendGroupList, QMap<QString, ItemInfo *> *friendList)
{
    return m_jsonParse->createFriend(friendGroupList, friendList);
}

void NetworkManager::uploadUserInformation()
{
    FriendInfo *userInfo = qobject_cast<FriendInfo *>(ChatManager::instance()->userInfo());
    m_jsonParse->updateInfo(userInfo);
}

void NetworkManager::onLogined(bool ok)
{
    if (ok)
    {
        qDebug() << "验证通过";
        m_tcpManager->sendMessage(MT_USERINFO, ChatManager::instance()->username().toLatin1(), QByteArray("1"));
    }
    else
    {
        qDebug() << "验证不通过";
        emit loginError("密码不正确\n" \
                        "你输入的帐号或密码不正确，你要找回密码吗？\n" \
                        "如果你的密码丢失或遗忘，可以点击找回密码。");
    }
}

void NetworkManager::onInfoGot(const QByteArray &infoJson)
{
    QJsonParseError error;
    QJsonDocument myInfo = QJsonDocument::fromJson(infoJson, &error);
    if (!myInfo.isNull() && (error.error == QJsonParseError::NoError))
    {
        m_jsonParse = new MyJsonParse(myInfo);
        m_tcpManager->startHeartbeat();     //开始心跳检测
        m_databaseManager = DatabaseManager::instance();	//初始化本地数据库
        emit loginFinshed(true);
    }
    else
    {
        qDebug() << "数据初始化不成功：" << error.errorString();
        emit loginFinshed(false);
    }
}

void NetworkManager::cancelLogin()
{
    m_tcpManager->abort();
}

void NetworkManager::sendMessage(MSG_TYPE type, ChatMessage *message, const QString &receiver)
{
    m_tcpManager->sendMessage(type, receiver.toLatin1(), message->message().toLocal8Bit());
}

void NetworkManager::deposeNewMessage(const QString &senderID, MSG_TYPE type, const QVariant &data)
{
    FriendInfo *info = ChatManager::instance()->createFriendInfo(senderID);
    switch (type)
    {
    case MT_SHAKE:
        info->addShakeMessage(senderID);
        emit hasNewShake(senderID);
        break;

    case MT_TEXT:
        info->addTextMessage(senderID, data.toString());
        emit hasNewText(senderID, data.toString());
        break;

    default:
        break;
    }
}
