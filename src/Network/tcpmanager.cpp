#include "chatmanager.h"
#include "chatmessage.h"
#include "tcpmanager.h"

#include <QCryptographicHash>
#include <QDataStream>
#include <QFile>
#include <QThread>
#include <QTimer>

TcpManager::TcpManager(QObject *parent)
    : QTcpSocket(parent)
{
    m_username = CLIENT_ID;
    m_sendDataBytes = 0;
    m_sendData = QByteArray();
    m_recvData = QByteArray();
    m_recvHeader = MessageHeader();
    m_hasMessageProcessing = false;
    m_curReceiver = QByteArray();
    m_curChatMessage = nullptr;
    m_heartbeat = new QTimer(this);
    m_heartbeat->setInterval(30000);
    m_messageTimeout = new QTimer(this);
    m_messageTimeout->setInterval(3000);

    connect(this, &TcpManager::abortConnection, this, [this]
    {
        abort();
    });
    connect(this, &TcpManager::requestNewConnection, this, &TcpManager::requestNewConnectionSlot);
    connect(this, &TcpManager::startHeartbeat, this, &TcpManager::startHeartbeatSlot);
    connect(this, &TcpManager::checkLoginInfo, this, &TcpManager::checkLoginInfoSlot);
    connect(this, &TcpManager::sendChatMessage, this, &TcpManager::sendChatMessageSlot);
    connect(this, &TcpManager::sendMessage, this, &TcpManager::sendMessageSlot);

    connect(this, &TcpManager::bytesWritten, this, &TcpManager::continueWrite);
    connect(this, &TcpManager::readyRead, this, [this]()
    {
        m_recvData += readAll();
        processRecvMessage();
    });
    connect(this, &TcpManager::stateChanged, this, &TcpManager::onStateChanged);
    connect(this, static_cast<void(QAbstractSocket::*)(QAbstractSocket::SocketError)>(&QAbstractSocket::error), this,
    [this](QAbstractSocket::SocketError socketError)
    {
        switch (socketError)
        {
        case QAbstractSocket::ConnectionRefusedError:
        case QAbstractSocket::SocketTimeoutError:
            qDebug() << "连接服务器超时。";
            emit loginError("\n连接服务器超时。");
            break;
        default:
            qDebug() << errorString();
            emit loginError(errorString());
            break;
        }
    });
    connect(m_heartbeat, &QTimer::timeout, this, [this]()
    {
        sendMessageSlot(MT_HEARTBEAT, MO_NULL, SERVER_ID, HEARTBEAT);
    });
    connect(m_messageTimeout, &QTimer::timeout, this, &TcpManager::messageTimeoutHandle);
}

TcpManager::~TcpManager()
{
}

void TcpManager::requestNewConnectionSlot()
{
    abort();
    connectToHost(server_ip, server_port, QAbstractSocket::ReadWrite);
    waitForConnected(10000);
}

void TcpManager::startHeartbeatSlot()
{
    if (!m_heartbeat->isActive())
        m_heartbeat->start();
}

void TcpManager::sendMessageSlot(msg_t type, msg_option_t option, const QByteArray &receiver, const QByteArray &data)
{
    QByteArray base64 = data.toBase64();
    QByteArray md5 = QCryptographicHash::hash(base64, QCryptographicHash::Md5);
    QString username = m_username;
    MessageHeader header = { MSG_FLAG, type, msg_size_t(base64.size()), option, username.toLatin1(), receiver, md5 };
    Message *message = new Message(header, base64);
    m_messageQueue.enqueue(message);

    processNextSendMessage();
}

void TcpManager::sendChatMessageSlot(msg_t type, const QByteArray &receiver, ChatMessage *chatMessage)
{
    m_chatMessageQueue.enqueue(chatMessage);
    sendMessageSlot(type, MO_UPLOAD, receiver, chatMessage->message().toLocal8Bit());
}

void TcpManager::checkLoginInfoSlot()
{
    requestNewConnectionSlot();
    QMutexLocker locker(&m_mutex);
    auto username  = ChatManager::instance()->username();
    auto password = ChatManager::instance()->password();
    locker.unlock();

    m_username = username;
    auto data = username + "%%" + password;
    sendMessageSlot(MT_CHECK, MO_NULL, SERVER_ID, data.toLocal8Bit());
}

void TcpManager::onStateChanged(QAbstractSocket::SocketState state)
{
    switch(state)
    {
    case QAbstractSocket::ConnectedState:
    {
        //已连接到服务器
        qDebug() << "已经连接到服务器。";
        break;
    }

    default:
        break;
    }
}

void TcpManager::processNextSendMessage()
{
    if (!m_hasMessageProcessing && !m_messageQueue.isEmpty())
    {
        QByteArray block;
        QDataStream out(&block, QIODevice::WriteOnly);
        out.setVersion(QDataStream::Qt_5_9);
        Message *message = m_messageQueue.dequeue();
        out << *message;
        m_sendData = block;
        m_sendDataBytes = block.size();
        if (MSG_IS_USER(get_type(*message)))        //本次处理的是用户消息
        {
            m_curReceiver = get_receiver(*message);
            m_curChatMessage = m_chatMessageQueue.dequeue();
        }
        m_hasMessageProcessing = true;
        m_messageTimeout->start();                  //启动超时定时器
        delete message;

        write(block);
        flush();
    }
}

void TcpManager::messageTimeoutHandle()
{
    m_messageTimeout->stop();
    m_hasMessageProcessing = false;
    if (m_curChatMessage)
    {
        if (m_curChatMessage->state() == ChatMessageStatus::Sending)
            m_curChatMessage->setState(ChatMessageStatus::Failure);
        emit chatMessageSent(QString(m_curReceiver), m_curChatMessage);
        m_curReceiver = QByteArray();
        m_curChatMessage = nullptr;
    }
    processNextSendMessage();
}

void TcpManager::continueWrite(qint64 sentSize)
{
    static int sentBytes = 0;
    sentBytes += sentSize;

    if (sentBytes >= m_sendDataBytes)
    {
        m_sendDataBytes = 0;
        sentBytes = 0;
        m_sendData.clear();
        m_hasMessageProcessing = false;
        m_messageTimeout->stop();
        if (m_curChatMessage)
        {
            m_curChatMessage->setState(ChatMessageStatus::Success);
            emit chatMessageSent(QString(m_curReceiver), m_curChatMessage);
            m_curReceiver = QByteArray();
            m_curChatMessage = nullptr;
        }
        processNextSendMessage();       //继续处理下一条待发送消息
    }
}

void TcpManager::processRecvMessage()
{
    //尝试读取一个完整的消息头
    if (m_recvHeader.isEmpty() && m_recvData.size() > 0)
    {
        MessageHeader header;
        QDataStream in(&m_recvData, QIODevice::ReadOnly);
        in.setVersion(QDataStream::Qt_5_9);
        in >> header;
        qDebug() << header;

        if (header.isEmpty()) return;

        m_recvHeader = header;
        m_recvData.remove(0, header.getSize() + 4); //QByteArray 4 字节大小

        //如果成功读取了一个完整的消息头，但flag不一致(即：不是我的消息)
        if (get_flag(m_recvHeader) != MSG_FLAG)
        {
            m_recvHeader = MessageHeader();
            return;
        }
    }

    //如果数据大小不足一条消息
    int size = int(get_size(m_recvHeader));
    if (m_recvData.size() < size)
        return;

    auto rawData = m_recvData.left(size);
    m_recvData = m_recvData.mid(size);

    auto md5 = QCryptographicHash::hash(rawData, QCryptographicHash::Md5);
    auto data = QByteArray::fromBase64(rawData);
    if (md5 != get_md5(m_recvHeader)) return;

    qDebug() << "md5 一致，消息为：" << data;
    qDebug() << "大小为：" << size;

    if (get_option(m_recvHeader) == MO_NULL)    //来自服务器的都为NULL
    {
        QString username = m_username;
        switch (get_type(m_recvHeader))
        {
        case MT_CHECK:
            if (get_sender(m_recvHeader) == SERVER_ID && get_receiver(m_recvHeader) == username)
                emit checked(data == CHECK_SUCCESS ? true : false);
            break;

        case MT_USERINFO:
            qDebug() << "获取到用户信息";
            if (get_sender(m_recvHeader) == SERVER_ID && get_receiver(m_recvHeader) == username)
                emit infoGot(data);
            break;

        case MT_STATECHANGE:
            qDebug() << "收到一条状态变化来自："
                     << QString(get_sender(m_recvHeader));
            emit hasNewMessage(QString(get_sender(m_recvHeader)), MT_STATECHANGE, data);
            break;

        case MT_SEARCH:
            qDebug() << "收到一条搜索结果来自："
                     << QString(get_sender(m_recvHeader));
            if (get_sender(m_recvHeader) == SERVER_ID && get_receiver(m_recvHeader) == username)
                emit hasNewMessage(QString(get_sender(m_recvHeader)), MT_SEARCH, data);
            break;

        case MT_SHAKE:
            qDebug() << "收到一条窗口震动来自："
                     << QString(get_sender(m_recvHeader));
            if (get_receiver(m_recvHeader) == username)
                emit hasNewMessage(QString(get_sender(m_recvHeader)), MT_SHAKE, QByteArray());
            break;

        case MT_TEXT:
            qDebug() << "收到一条新消息来自："
                     << QString(get_sender(m_recvHeader))
                     << "消息为：" + QString::fromLocal8Bit(data);
            if (get_receiver(m_recvHeader) == username)
                emit hasNewMessage(QString(get_sender(m_recvHeader)), MT_TEXT, data);
            break;

        case MT_IMAGE:
            qDebug() << "收到一副图片来自："
                     << QString(get_sender(m_recvHeader))
                     << "消息为：" + QString::fromLocal8Bit(data);
            if (get_receiver(m_recvHeader) == username)
                emit hasNewMessage(QString(get_sender(m_recvHeader)), MT_IMAGE, data);
            break;

        case MT_ADDFRIEND:
            qDebug() << "收到好友请求来自："
                     << QString(get_sender(m_recvHeader))
                     << "消息为：" + QString::fromLocal8Bit(data);
            if (get_receiver(m_recvHeader) == username)
                emit hasNewMessage(QString(get_sender(m_recvHeader)), MT_ADDFRIEND, data);
            break;

        case MT_REGISTER:
            emit hasNewMessage(QString(get_sender(m_recvHeader)), MT_REGISTER, data);
            break;

        case MT_UNKNOW:
            qDebug() << "收到一条未知消息来自："
                     << QString(get_sender(m_recvHeader))
                     << "消息为：" + QString::fromLocal8Bit(data);
            if (get_receiver(m_recvHeader) == username)
                emit hasNewMessage(QString(get_sender(m_recvHeader)), MT_TEXT, data);
            break;

        default:
            break;
        }
    }
    //处理结束，清空消息头
    m_recvHeader = MessageHeader();
}
