#include "chatmessage.h"
#include "chatmanager.h"
#include "databasemanager.h"
#include "iteminfo.h"
#include "networkmanager.h"

#include <QDateTime>
#include <QDebug>

ItemInfo::ItemInfo(QObject *parent)
    : QObject(parent)
    , m_username("")
    , m_nickname("")
    , m_headImage("")
    , m_unreadMessage(0)
{
    m_chatRecord = new ChatMessageList(this);
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
    return m_chatRecord->last();
}

ChatMessageList* ItemInfo::chatRecord() const
{
    return m_chatRecord;
}

void ItemInfo::setNickname(const QString &arg)
{
    if (arg != m_nickname)
    {
        m_nickname = arg;
        emit nicknameChanged();
    }
}

void ItemInfo::setUsername(const QString &arg)
{
    if (m_username != arg)
    {
        m_username = arg;
        emit usernameChanged();
    }
}

void ItemInfo::loadRecord()
{
    if (m_chatRecord->count() == 0)
        m_databaseManager->getChatMessage(m_username, 40, m_chatRecord);
}

void ItemInfo::addTextMessage(const QString &sender, const QString &msg)
{
    addMessage(MT_TEXT, sender, msg);
}

void ItemInfo::addMessage(msg_t type, const QString &sender, const QString &msg)
{
    ChatMessage *message = new ChatMessage(this);
    QString datetime = QDateTime::currentDateTime().toString("yyyyMMdd hhmmss");
    message->setSender(sender);
    message->setDateTime(datetime);
    message->setMessage(msg);
    message->setState(ChatMessageStatus::Sending);
    m_chatRecord->append(message);                                      //加入到消息列表
    if (sender == m_chatManager->username())
        m_networkManager->sendChatMessage(m_username, message);   //如果为自己发送的，就发送
    else
    {
        message->setState(ChatMessageStatus::Success);
        if (!m_chatManager->chatWindowIsOpenned(sender))
            setUnreadMessage(unreadMessage() + 1);                      //如果为好友发送的，并且窗口未打开，未读数+1
    }
    m_chatManager->appendRecentMessageID(m_username);                   //加入到最近消息列表
    emit lastMessageChanged();
}

void ItemInfo::recallMessage(const QString &sender, const QString &msg)
{
    Q_UNUSED(sender);
    Q_UNUSED(msg);
}

void ItemInfo::setHeadImage(const QString &arg)
{
    if (m_headImage != arg)
    {
        m_headImage = arg;
        emit headImageChanged();
    }
}

void ItemInfo::setUnreadMessage(int arg)
{
    if (m_unreadMessage != arg)
    {
        m_unreadMessage = arg;
        emit unreadMessageChanged();
    }
}


FriendInfo::FriendInfo(QObject *parent)
    : ItemInfo(parent)
    , m_status(Chat::Offline)
    , m_background("qrc:/image/Background/7.jpg")
    , m_signature("")
    , m_birthday("")
    , m_gender("")
    , m_level(0)
{

}

FriendInfo::~FriendInfo()
{

}

int FriendInfo::chatStatus() const
{
    return m_status;
}

void FriendInfo::setChatStatus(int status)
{
    if (status != m_status)
    {
        m_status = status;
        emit chatStatusChanged();
    }
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
        emit backgroundChanged();
    }
}

void FriendInfo::setSignature(const QString &arg)
{
    if (m_signature != arg)
    {
        m_signature = arg;
        emit signatureChanged();
    }
}

void FriendInfo::setBirthday(const QString &arg)
{
    if(m_birthday != arg)
    {
        m_birthday = arg;
        emit birthdayChanged();
    }
}

void FriendInfo::setGender(const QString &arg)
{
    if (m_gender != arg)
    {
        m_gender = arg;
        emit genderChanged();
    }
}

void FriendInfo::setLevel(int arg)
{
    if (m_level != arg)
    {
        m_level = arg;
        emit levelChanged();
    }
}

int FriendInfo::age() const
{
    QDate birth = QDate::fromString(m_birthday, "yyyy-mm-dd");
    int age = QDate::currentDate().year() - birth.year();
    return age > 0 ? age : 0;
}

void FriendInfo::addShakeMessage(const QString &sender)
{
    addMessage(MT_SHAKE, sender, QString("窗口抖动~~"));
}
