#include "chatmanager.h"
#include "chatmessage.h"
#include "databasemanager.h"
#include "friendmodel.h"
#include "iteminfo.h"
#include "jsonparse.h"
#include "networkmanager.h"

#include <QDateTime>
#include <QFile>
#include <QJsonObject>
#include <QJsonDocument>
#include <QThread>
#include <QDebug>

NetworkManager* NetworkManager::instance()
{
    static NetworkManager networkManager;
    return &networkManager;
}

NetworkManager::NetworkManager(QObject *parent)
    : QObject(parent)
{
    QThread *thread = new QThread;
    m_tcpManager = new TcpManager;
    connect(thread, &QThread::finished, thread, &QThread::deleteLater);
    connect(m_tcpManager, &TcpManager::checked, this, &NetworkManager::onLogined);
    connect(m_tcpManager, &TcpManager::infoGot, this, &NetworkManager::onInfoGot);
    connect(m_tcpManager, &TcpManager::loginError, this, &NetworkManager::loginError);
    connect(m_tcpManager, &TcpManager::chatMessageSent, this, [this](const QString &username, ChatMessage *chatMessage)
    {
        m_databaseManager->insertChatMessage(username, chatMessage);      //消息发送完成加入到本地数据库
    });
    connect(m_tcpManager, &TcpManager::hasNewMessage, this, &NetworkManager::disposeNewMessage);
    m_tcpManager->moveToThread(thread);
    thread->start();
}

NetworkManager::~NetworkManager()
{
    if (m_jsonParser)
        delete m_jsonParser;
}

void NetworkManager::setMode(NetworkMode::Mode mode)
{
    if (mode != m_mode)
    {
        m_mode = mode;
        emit modeChanged();
    }
}

void NetworkManager::checkLoginInfo()
{
    m_tcpManager->requestNewConnection();
}

ItemInfo *NetworkManager::getUserInfo()
{
    return m_jsonParser->userInfo();
}

void NetworkManager::createFriend(FriendGroup *FriendGroup, QMap<QString, ItemInfo *> *friendList)
{
    return m_jsonParser->createFriend(FriendGroup, friendList);
}

void NetworkManager::uploadUserInformation()
{
    FriendInfo *userInfo = qobject_cast<FriendInfo *>(ChatManager::instance()->userInfo());
    m_jsonParser->updateInfo(userInfo);
}

void NetworkManager::onLogined(bool ok)
{
    if (ok)
    {
        qDebug() << "验证通过";
        m_tcpManager->sendMessage(MT_USERINFO, MO_DOWNLOAD,
                                  ChatManager::instance()->username().toLatin1(), USERINFO);
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
        m_jsonParser = new JsonParser(myInfo);              //创建json解析器
        m_tcpManager->startHeartbeat();                     //开始心跳检测
        m_databaseManager = DatabaseManager::instance();
        m_databaseManager->initDatabase();                  //初始化本地数据库
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
    m_tcpManager->abortConnection();
}

void NetworkManager::sendChatMessage(msg_t type, ChatMessage *chatMessage, const QString &receiver)
{
    m_tcpManager->sendChatMessage(type, MO_UPLOAD, receiver.toLatin1(), chatMessage);
}

void NetworkManager::disposeNewMessage(const QString &sender, msg_t type, const QByteArray &data)
{
    FriendInfo *info = ChatManager::instance()->createFriendInfo(sender);
    switch (type)
    {
    case MT_SHAKE:
        info->addShakeMessage(sender);
        emit hasNewShake(sender);
        break;

    case MT_TEXT:
        info->addTextMessage(sender, QString::fromLocal8Bit(data));
        emit hasNewText(sender, QString::fromLocal8Bit(data));
        break;

    default:
        break;
    }
}
