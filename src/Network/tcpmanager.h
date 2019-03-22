#ifndef TCPMANAGER_H
#define TCPMANAGER_H

#include "protocol.h"

#include <QMutex>
#include <QQueue>
#include <QTcpSocket>

class ChatMessage;
class QTimer;
class TcpManager : public QTcpSocket
{
    Q_OBJECT

public:
    TcpManager(QObject *parent = nullptr);
    ~TcpManager();

signals:
    //退出连接
    void abortConnection();
    //校检结束后发出
    void checked(bool ok);
    //用户信息获取后发出
    void infoGot(const QByteArray &infoJson);
    //登陆错误时发出
    void loginError(const QString &error);
    //聊天消息发送后发出
    void chatMessageSent(const QString &username, ChatMessage *chatMessage);
    //有新消息时发出
    void hasNewMessage(const QString &sender, msg_t type, const QByteArray &data);
    //建立一个新的连接/重新连接
    void requestNewConnection();
    //开始心跳
    void startHeartbeat();
    //用于发送聊天消息的
    void sendChatMessage(const QByteArray &receiver, ChatMessage *chatMessage);
    void sendMessage(msg_t type, msg_option_t option, const QByteArray &receiver, const QByteArray &data);

private slots:
    void requestNewConnectionSlot();
    void startHeartbeatSlot();
    void sendChatMessageSlot(const QByteArray &receiver, ChatMessage *chatMessage);
    void sendMessageSlot(msg_t type, msg_option_t option, const QByteArray &receiver, const QByteArray &data);

    void continueWrite(qint64 sentSize);
    //消息超时处理
    void messageTimeoutHandle();
    void onStateChanged(QAbstractSocket::SocketState state);

private:
    void checkLoginInfo();
    void processNextSendMessage();
    void processRecvMessage();

private:
    QMutex m_mutex;
    QString m_username;
    QTimer *m_heartbeat;
    QTimer *m_messageTimeout;
    qint64 m_sendDataBytes;
    QByteArray m_sendData;
    QByteArray m_recvData;
    MessageHeader m_recvHeader;

    QQueue<Message *> m_messageQueue;           //所有消息都必须排队
    bool m_hasMessageProcessing;                //指示是否有消息在处理中

    QQueue<ChatMessage *> m_chatMessageQueue;   //专用于聊天消息的队列
    QByteArray m_curReceiver;
    ChatMessage *m_curChatMessage;
};

#endif // TCPMANAGER_H
