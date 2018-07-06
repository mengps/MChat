#include "chatmessage.h"
#include <QDebug>

ChatMessage::ChatMessage(QObject *parent)
    :   QObject(parent)
{

}

ChatMessage::~ChatMessage()
{

}

void ChatMessage::setSenderID(const QString &arg)
{
    if (m_senderID != arg)
    {
        m_senderID = arg;
        senderIDChanged();
    }
}

void ChatMessage::setDateTime(const QString &arg)
{
    if (m_dateTime != arg)
    {
        m_dateTime = arg;
        dateTimeChanged();
    }
}

void ChatMessage::setMessage(const QString &arg)
{
    if (m_message != arg)
    {
        m_message = arg;
        messageChanged();
    }
}

QString ChatMessage::senderID() const
{
    return m_senderID;
}

QString ChatMessage::dateTime() const
{
    return m_dateTime;
}

QString ChatMessage::message() const
{
    return m_message;
}


//ChatMessageList
ChatMessageList::ChatMessageList(QObject *parent)
    :   QObject(parent)
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

void ChatMessageList::append(ChatMessage *msg)
{
    m_msgList.append(msg);
    emit messageListChanged();
}

ChatMessage* ChatMessageList::last()
{
    if (!m_msgList.isEmpty())
        return m_msgList.last();
}

void ChatMessageList::setData(const QList<ChatMessage *> &data)
{
    m_msgList = data;
    emit messageListChanged();
}
