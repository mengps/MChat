#ifndef TCPMANAGER_H
#define TCPMANAGER_H
#include <QTcpSocket>
#include <QQueue>
#include "mymessagedef.h"

class ChatMessage;
class QTimer;
class TcpManager : public QTcpSocket
{
    Q_OBJECT

public:
    TcpManager(QObject *parent = nullptr);
    ~TcpManager();

public slots:
    void requestNewConnection();                                        //建立一个新的连接/重新连接
    void readyLogin(const QString &username, const QString &password);  //准备登录
    void startHeartbeat();
    void sendChatMessage(MSG_TYPE type, MSG_OPTION_TYPE option, const QByteArray &receiver, ChatMessage *chatMessage);//用于发送聊天消息的
    void sendMessage(MSG_TYPE type, MSG_OPTION_TYPE option = MO_NULL, const QByteArray &receiver = QByteArray(),
                         const QByteArray &data = QByteArray());

private slots:
    void readData();
    void checkLoginInfo(const QString &username, const QString &password);
    void onStateChanged(QAbstractSocket::SocketState state);
    void processNextMessage();
    void messageTimeoutHandle();        //消息超时处理
    void continueWrite(qint64 sentSize);

signals:
    void loginError(const QString &error);
    void logined(bool ok);
    void infoGot(const QByteArray &infoJson);
    void chatMessageSent(const QString &username, ChatMessage *chatMessage);
    void hasNewMessage(const QString &sender, MSG_TYPE type, const QVariant &data);

private:
    QString m_username;
    QString m_password;

private:
    qint64 m_fileBytes;
    QByteArray m_data;
    QTimer *m_heartbeat;
    QTimer *m_messageTimeout;

    QQueue<Message *> m_messageQueue;
    bool m_hasMessageProcessing;             //指示是否有消息在处理中

    QQueue<ChatMessage *> m_chatMessageQueue;   //专用于聊天消息
    QString m_curReceiver;
    ChatMessage *m_curChatMessage;
};

#endif // TCPMANAGER_H
