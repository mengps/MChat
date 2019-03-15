#include "chatmessage.h"
#include <QDebug>

ChatMessage::ChatMessage(QObject *parent)
    : QObject(parent)
{

}

ChatMessage::ChatMessage(const ChatMessage &chatMessage, QObject *parent)
    : QObject(parent)
    , m_sender(chatMessage.m_sender)
    , m_dateTime(chatMessage.m_dateTime)
    , m_message(chatMessage.m_message)
    , m_state(chatMessage.m_state)
{

}

ChatMessage::~ChatMessage()
{

}

QString ChatMessage::sender() const
{
    return m_sender;
}

void ChatMessage::setSender(const QString &arg)
{
    if (m_sender != arg)
    {
        m_sender = arg;
        senderChanged();
    }
}

QString ChatMessage::dateTime() const
{
    return m_dateTime;
}

void ChatMessage::setDateTime(const QString &arg)
{
    if (m_dateTime != arg)
    {
        m_dateTime = arg;
        dateTimeChanged();
    }
}

QString ChatMessage::message() const
{
    return m_message;
}

void ChatMessage::setMessage(const QString &arg)
{
    if (m_message != arg)
    {
        m_message = arg;
        messageChanged();
    }
}

ChatMessageStatus::Status ChatMessage::state() const
{
    return m_state;
}

void ChatMessage::setState(ChatMessageStatus::Status arg)
{
    if (m_state != arg)
    {
        m_state = arg;
        stateChanged();
    }
}


//ChatMessageList
ChatMessageList::ChatMessageList(QObject *parent)
    : QObject(parent)
{
    m_msgProxy = new QQmlListProperty<ChatMessage>(parent, m_msgList);
}

ChatMessageList::ChatMessageList(const QList<ChatMessage *> &data, QObject *parent)
    :   QObject(parent), m_msgList(data)
{
    m_msgProxy = new QQmlListProperty<ChatMessage>(parent, m_msgList);
}

ChatMessageList::~ChatMessageList()
{

}

QQmlListProperty<ChatMessage> ChatMessageList::messageList()
{
    return *m_msgProxy;
}

int ChatMessageList::count() const
{
    return m_msgList.count();
}

void ChatMessageList::append(const ChatMessage &msg)
{
    ChatMessage *chatMessage = new ChatMessage(msg, this);
    m_msgList.append(chatMessage);
    emit messageListChanged();
}

void ChatMessageList::append(ChatMessage *msg)
{
    m_msgList.append(msg);
    emit messageListChanged();
}

ChatMessage* ChatMessageList::last()
{
    if (!m_msgList.isEmpty())
        return m_msgList.last();

    return nullptr;
}

void ChatMessageList::setData(const QList<ChatMessage *> &data)
{
    m_msgList = data;
    emit messageListChanged();
}
