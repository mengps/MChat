#ifndef CHATMESSAGE_H
#define CHATMESSAGE_H

#include <QObject>
#include <QQmlListProperty>

namespace ChatMessageStatus
{
    Q_NAMESPACE

    enum Status
    {
        Sending,    //发送中
        Success,    //已发送
        Failure     //发送失败
    };

    Q_ENUMS(Status)
}

class ChatMessage : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString sender READ sender WRITE setSender NOTIFY senderChanged)
    Q_PROPERTY(QString dateTime READ dateTime WRITE setDateTime NOTIFY dateTimeChanged)
    Q_PROPERTY(QString message READ message WRITE setMessage NOTIFY messageChanged)
    Q_PROPERTY(ChatMessageStatus::Status state READ state WRITE setState NOTIFY stateChanged)

public:
    ChatMessage(QObject *parent = nullptr);
    ChatMessage(const ChatMessage &chatMessage, QObject *parent = nullptr);
    ~ChatMessage();

    QString sender() const;
    void setSender(const QString &arg);

    QString dateTime() const;
    void setDateTime(const QString &arg);

    QString message() const;
    void setMessage(const QString &arg);

    ChatMessageStatus::Status state() const;
    void setState(ChatMessageStatus::Status arg);

signals:
    void senderChanged();
    void dateTimeChanged();
    void messageChanged();
    void stateChanged();

private:
    QString m_sender;                           //存储该条消息的发送者id
    QString m_dateTime;                         //存储该条消息的时间 格式为：yyyyMMdd hhmmss
    QString m_message;                          //存储该条消息的数据
    ChatMessageStatus::Status m_state;          //存储本条消息的状态
};

class ChatMessageList : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<ChatMessage> messageList READ messageList NOTIFY messageListChanged)

public:
    ChatMessageList(QObject *parent = nullptr);
    ChatMessageList(const QList<ChatMessage *> &data, QObject *parent = nullptr);
    ~ChatMessageList();

   void setData(const QList<ChatMessage *> &data);
   QQmlListProperty<ChatMessage> messageList();

   Q_INVOKABLE int count() const;
   Q_INVOKABLE void append(const ChatMessage &msg);
   Q_INVOKABLE void append(ChatMessage *msg);
   Q_INVOKABLE ChatMessage* last();

signals:
    void messageListChanged();

private:
    QQmlListProperty<ChatMessage> *m_msgProxy;
    QList<ChatMessage *> m_msgList;
};

#endif // CHATMESSAGE_H
