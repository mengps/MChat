#include "chatmessage.h"
#include "databasemanager.h"
#include "friendmodel.h"
#include "iteminfo.h"
#include "jsonparse.h"
#include "networkmanager.h"
#include "tcpmanager.h"

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

ItemInfo* NetworkManager::getUserInfo()
{
    return m_jsonParser->userInfo();
}

void NetworkManager::checkLoginInfo()
{
    m_tcpManager->checkLoginInfo();
}

void NetworkManager::createFriend(FriendGroup *FriendGroup, QMap<QString, ItemInfo *> *friendList)
{
    return m_jsonParser->createFriend(FriendGroup, friendList);
}

void NetworkManager::connectServer()
{
    m_tcpManager->requestNewConnection();
}

void NetworkManager::cancelLogin()
{
    m_tcpManager->abortConnection();
}

void NetworkManager::updateInfomation()
{
    FriendInfo *userInfo = qobject_cast<FriendInfo *>(ChatManager::instance()->userInfo());
    QByteArray data = m_jsonParser->infoToJson(userInfo);
    m_tcpManager->sendMessage(MT_USERINFO, MO_UPLOAD, SERVER_ID, data);
}

void NetworkManager::registerUser(const QString &json)
{
    m_tcpManager->requestNewConnection();
    m_tcpManager->sendMessage(MT_REGISTER, MO_UPLOAD, SERVER_ID, json.toUtf8());
}

void NetworkManager::requestUserInfo(const QString &username)
{
    m_tcpManager->sendMessage(MT_SEARCH, MO_DOWNLOAD, SERVER_ID, username.toLocal8Bit());
}

void NetworkManager::requestAddFriend(const QString &username)
{
    m_tcpManager->sendMessage(MT_ADDFRIEND, MO_UPLOAD, username.toLatin1(), ADDFRIEND);
}

void NetworkManager::acceptFriendRequest(const QString &username)
{
    m_tcpManager->sendMessage(MT_ADDFRIEND, MO_UPLOAD, username.toLatin1(), ADD_SUCCESS);
}

void NetworkManager::rejectFriendRequest(const QString &username)
{
    m_tcpManager->sendMessage(MT_ADDFRIEND, MO_UPLOAD, username.toLatin1(), ADD_FAILURE);
}

void NetworkManager::sendStateChange(Chat::ChatStatus status)
{
    m_tcpManager->sendMessage(MT_STATECHANGE, MO_UPLOAD, SERVER_ID, QByteArray::number(status));
}

void NetworkManager::sendChatMessage(msg_t type, const QString &receiver, ChatMessage *chatMessage)
{
    m_tcpManager->sendChatMessage(type, receiver.toLatin1(), chatMessage);
}

void NetworkManager::onLogined(bool ok)
{
    if (ok)
    {
        qDebug() << "验证通过";
        m_tcpManager->sendMessage(MT_USERINFO, MO_DOWNLOAD, SERVER_ID, USERINFO);
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

void NetworkManager::disposeNewMessage(const QString &sender, msg_t type, const QByteArray &data)
{
    FriendInfo *info = qobject_cast<FriendInfo *>(ChatManager::instance()->createFriendInfo(sender));
    switch (type)
    {
    case MT_STATECHANGE:
        info->setChatStatus(int(data.toInt()));
        break;

    case MT_SEARCH:
    {
        FriendInfo *newInfo = qobject_cast<FriendInfo *>(m_jsonParser->jsonToInfo(data));
        emit hasSearchResult(newInfo);
        break;
    }
    case MT_SHAKE:
        info->addShakeMessage(sender);
        emit hasNewShake(sender);
        break;

    case MT_TEXT:
        info->addTextMessage(sender, QString::fromLocal8Bit(data));
        emit hasNewText(sender, QString::fromLocal8Bit(data));
        break;

    case MT_ADDFRIEND:
    {
        QString addStr = QString::fromLocal8Bit(data);
        if (addStr == ADDFRIEND)
            emit hasFriendRequest(sender);
        else if (addStr == ADD_FAILURE)
        {

        }
        else
        {
            FriendInfo *newInfo = qobject_cast<FriendInfo *>(m_jsonParser->jsonToInfo(data));
            ChatManager::instance()->addFriendToGroup("我的好友", newInfo);
        }
        break;
    }
    case MT_REGISTER:
    {
        QString result = QString::fromLocal8Bit(data);
        if (result == REG_SUCCESS)
            emit hasRegister("注册成功~\n可以登陆了哟~");
        else emit hasRegister("注册失败\n原因：已经存在。");
        break;
    }

    default:
        break;
    }
}
