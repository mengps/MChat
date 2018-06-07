#ifndef CHATMESSAGE_H
#define CHATMESSAGE_H
#include <QObject>
#include <QQmlListProperty>

class ChatMessage : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString senderID READ senderID WRITE setSenderID NOTIFY senderIDChanged)
    Q_PROPERTY(QString dateTime READ dateTime WRITE setDateTime NOTIFY dateTimeChanged)
    Q_PROPERTY(QString message READ message WRITE setMessage NOTIFY messageChanged)

public:
    ChatMessage(QObject *parent = nullptr);
    ~ChatMessage();

    QString senderID() const;
    QString dateTime() const;
    QString message() const;

public slots:
    void setSenderID(const QString &arg);
    void setDateTime(const QString &arg);
    void setMessage(const QString &arg);

signals:
    void senderIDChanged();
    void dateTimeChanged();
    void messageChanged();

private:
    QString m_senderID;       //存储该条消息的发送者id
    QString m_dateTime;       //存储该条消息的时间 格式为：yyyyMMdd hhmmss
    QString m_message;           //存储该条消息的数据
};

class ChatMessageList : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<ChatMessage> messageList READ messageList NOTIFY messageListChanged)

public:
    ChatMessageList(QObject *parent = nullptr);
    ChatMessageList(const QList<ChatMessage *> &data, QObject *parent = nullptr);
    ~ChatMessageList();

   QQmlListProperty<ChatMessage> messageList();

   Q_INVOKABLE int count() const;
   Q_INVOKABLE void append(ChatMessage *msg);
   Q_INVOKABLE ChatMessage* last();

public slots:
    void setData(const QList<ChatMessage *> &data);

signals:
    void messageListChanged();

private:
    QQmlListProperty<ChatMessage> *m_msgProxy;
    QList<ChatMessage *> m_msgList;
};

#endif // CHATMESSAGE_H
