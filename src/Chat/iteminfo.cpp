#include <QDebug>
#include <QDateTime>
#include "iteminfo.h"
#include "chatmessage.h"
#include "chatmanager.h"
#include "databasemanager.h"
#include "networkmanager.h"

ItemInfo::ItemInfo(QObject *parent)
    :   QObject(parent),
        m_username(""),
        m_nickname(""),
        m_headImage("qrc:/image/winIcon.png"),
        m_unreadMessage(0)
{
    m_messageList = new ChatMessageList(this);
    m_chatManager = ChatManager::instance();
    m_databaseManager = DatabaseManager::instance();
    m_networkManager = NetworkManager::instance();
}

ItemInfo::~ItemInfo()
{

}

QString ItemInfo::username() const
{
    return m_username;
}

QString ItemInfo::nickname() const
{
    return m_nickname;
}

QString ItemInfo::headImage() const
{
    return m_headImage;
}

int ItemInfo::unreadMessage() const
{
    return m_unreadMessage;
}

ChatMessage* ItemInfo::lastMessage() const
{
    return m_messageList->last();
}

ChatMessageList* ItemInfo::messageList() const
{
    return m_messageList;
}

void ItemInfo::setNickname(const QString &arg)
{
    if (arg != m_nickname)
    {
        m_nickname = arg;
        emit nicknameChanged(arg);
    }
}

void ItemInfo::setUsername(const QString &arg)
{
    if (m_username != arg)
    {
        m_username = arg;
        emit usernameChanged(arg);
    }
}

void ItemInfo::loadRecord()
{
    if (m_databaseManager->openDatabase())
    {
        if (m_messageList->count() == 0)
            m_databaseManager->getData(m_username, 100, m_messageList);
    }
}

bool ItemInfo::addShakeMessage(const QString &senderID)
{
    return addMessage(MT_SHAKE, senderID, QString("窗口抖动~~"));
}

bool ItemInfo::addTextMessage(const QString &senderID, const QString &msg)
{
    return addMessage(MT_TEXT, senderID, msg);
}

bool ItemInfo::addMessage(MSG_TYPE type, const QString &senderID, const QString &msg)
{
    if (m_databaseManager->openDatabase())
    {
        ChatMessage *message = new ChatMessage(this);
        QString datetime = QDateTime::currentDateTime().toString("yyyyMMdd hhmmss");
        message->setSenderID(senderID);
        message->setDateTime(datetime);
        message->setMessage(msg);
        m_messageList->append(message);                         //加入到消息队列
        m_databaseManager->insertData(m_username, message);     //加入到本地数据库
        m_chatManager->appendRecentMessageID(m_username);       //加入到最近消息列表
        if (senderID == m_chatManager->username())
            m_networkManager->sendMessage(type, message, m_username);   //如果为自己发送的，就发送
        else
        {
            //if (m_chatManager->)
            setUnreadMessage(unreadMessage() + 1);             //如果为好友发送的，未读数+1
        }
        emit lastMessageChanged();
        return true;
    }
    else
    {
        qDebug() << "数据库无法打开，消息发送失败。";
        return false;
    }
}

void ItemInfo::recallMessage(const QString &senderID, const QString &msg)
{

}

void ItemInfo::setHeadImage(const QString &arg)
{
    if (m_headImage != arg)
    {
        m_headImage = arg;
        emit headImageChanged(arg);
    }
}

void ItemInfo::setUnreadMessage(int arg)
{
    if (m_unreadMessage != arg)
    {
        m_unreadMessage = arg;
        emit unreadMessageChanged(arg);
    }
}


FriendInfo::FriendInfo(QObject *parent)
    :   ItemInfo(parent)
{
    m_signature = "";
    m_birthday = "";
    m_gender = "";
    m_level = 0;
    m_background = "qrc:/image/Background/7.jpg";
}

FriendInfo::~FriendInfo()
{

}

QString FriendInfo::background() const
{
    return m_background;
}

QString FriendInfo::signature() const
{
    return m_signature;
}

QString FriendInfo::birthday() const
{
    return m_birthday;
}

QString FriendInfo::gender() const
{
    return m_gender;
}

int FriendInfo::level() const
{
    return m_level;
}

void FriendInfo::setBackground(const QString &arg)
{
    if (m_background != arg)
    {
        m_background = arg;
        emit backgroundChanged(arg);
    }
}

void FriendInfo::setSignature(const QString &arg)
{
    if (m_signature != arg)
    {
        m_signature = arg;
        emit signatureChanged(arg);
    }
}

void FriendInfo::setBirthday(const QString &arg)
{
    if(m_birthday != arg)
    {
        m_birthday = arg;
        emit birthdayChanged(arg);
    }
}

void FriendInfo::setGender(const QString &arg)
{
    if (m_gender != arg)
    {
        m_gender = arg;
        emit genderChanged(arg);
    }
}

void FriendInfo::setLevel(int arg)
{
    if (m_level != arg)
    {
        m_level = arg;
        emit levelChanged(arg);
    }
}
