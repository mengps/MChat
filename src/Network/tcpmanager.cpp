#include <QTimer>
#include <QDataStream>
#include <QThread>
#include <QCryptographicHash>
#include <QFile>
#include "mymessagedef.h"
#include "tcpmanager.h"
#include "chatmessage.h"

TcpManager::TcpManager(QObject *parent)
    :   QTcpSocket(parent)
{
    m_fileBytes = 0;
    m_data = QByteArray();
    m_hasMessageProcessing = false;
    m_curReceiver = "";
    m_curChatMessage = nullptr;
    m_heartbeat = new QTimer(this);
    m_heartbeat->setInterval(30000);
    m_messageTimeout = new QTimer(this);
    m_messageTimeout->setInterval(3000);

    connect(this, &TcpManager::bytesWritten, this, &TcpManager::continueWrite);
    connect(this, &TcpManager::readyRead, this, &TcpManager::readData, Qt::DirectConnection);
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
            break;
        }
    });
    connect(m_heartbeat, &QTimer::timeout, this, [this]()
    {
        sendMessage(MT_HEARTBEAT);
    });
    connect(m_messageTimeout, &QTimer::timeout, this, &TcpManager::messageTimeoutHandle);
}

TcpManager::~TcpManager()
{
}

void TcpManager::requestNewConnection()
{
    abort();
    connectToHost("127.0.0.1", 43800, QAbstractSocket::ReadWrite);
}

void TcpManager::readyLogin(const QString &username, const QString &password)
{
    m_username = username;
    m_password = password;
}

void TcpManager::startHeartbeat()
{
    if (!m_heartbeat->isActive())
        m_heartbeat->start();
}

void TcpManager::sendMessage(MSG_TYPE type, MSG_OPTION_TYPE option, const QByteArray &receiver, const QByteArray &data)
{
    QByteArray base64 = data.toBase64();
    MSG_MD5_TYPE md5 = QCryptographicHash::hash(base64, QCryptographicHash::Md5);

    MessageHeader header = { MSG_FLAG, type, base64.size(), option, m_username.toLatin1(), receiver, md5 };
    Message *message = new Message(header, base64);
    m_messageQueue.enqueue(message);
    processNextMessage();
}

void TcpManager::sendChatMessage(MSG_TYPE type, MSG_OPTION_TYPE option, const QByteArray &receiver, ChatMessage *chatMessage)
{
    m_chatMessageQueue.enqueue(chatMessage);
    sendMessage(type, option, receiver, chatMessage->message().toLocal8Bit());
}

void TcpManager::checkLoginInfo(const QString &username, const QString &password)
{
    QString data = username + "%%" + password;
    sendMessage(MT_CHECK, MO_NULL, QByteArray(), data.toLocal8Bit());
}

void TcpManager::onStateChanged(QAbstractSocket::SocketState state)
{
    switch(state)
    {
    case QAbstractSocket::ConnectedState:
        checkLoginInfo(m_username, m_password);
        qDebug() << "已经连接到服务器。";
        break;

    default:
        break;
    }
}

void TcpManager::processNextMessage()
{
    if (!m_hasMessageProcessing && !m_messageQueue.isEmpty())
    {
        QByteArray block;
        QDataStream out(&block, QIODevice::WriteOnly);
        out.setVersion(QDataStream::Qt_5_9);
        Message *message = m_messageQueue.dequeue();
        out << *message;
        m_data = block;
        m_fileBytes = block.size();
        if (MSG_IS_USER(message->header.type))        //本次处理的是用户消息
        {
            m_curReceiver = QString(message->header.receiver);
            m_curChatMessage = m_chatMessageQueue.dequeue();
        }
        m_hasMessageProcessing = true;
        m_messageTimeout->start();                  //启动超时定时器
        delete message;

        write(block);
        flush();        //立即发送消息
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
        emit chatMessageSent(m_curReceiver, m_curChatMessage);
        m_curReceiver = "";
        m_curChatMessage = nullptr;
    }
    processNextMessage();
}

void TcpManager::continueWrite(qint64 sentSize)
{
    static int sentBytes = 0;
    sentBytes += sentSize;

    qDebug() << __func__ << sentBytes << m_fileBytes << m_data;
    if (sentBytes >= m_fileBytes)
    {
        m_fileBytes = 0;
        sentBytes = 0;
        m_data.clear();
        m_hasMessageProcessing = false;
        m_messageTimeout->stop();
        if (m_curChatMessage)
        {
            m_curChatMessage->setState(ChatMessageStatus::Success);
            emit chatMessageSent(m_curReceiver, m_curChatMessage);
            m_curReceiver = "";
            m_curChatMessage = nullptr;
        }
        processNextMessage();       //继续处理下一条待发送消息
    }
    else
    {
        write(m_data);
        QThread::msleep(10);    //重启线程后将立即发送数据
    }
}

void TcpManager::readData()
{
    static int gotSize = 0;

    qDebug() << bytesAvailable() << m_data.size();

    if (m_data.size() == 0)
    {
        QByteArray data = read(bytesAvailable());
        m_data.replace(gotSize, data.size(), data);
        gotSize += data.size();
        qDebug() << gotSize << m_data.size() << m_data;
    }

    if (gotSize >= m_data.size())     //接收完毕
    {
        qDebug() << gotSize << m_data.size() << "接收完毕";
        Message message;
        QDataStream in(&m_data, QIODevice::ReadOnly);
        in.setVersion(QDataStream::Qt_5_9);
        in >> message;
        QByteArray md5_t = QCryptographicHash::hash(message.data, QCryptographicHash::Md5);

        if (message.header.md5 == md5_t)   //正确的消息
        {
            QByteArray rawData = QByteArray::fromBase64(message.data);
            QString str = QString::fromLocal8Bit(rawData);
            qDebug() << "md5 一致，消息为：\"" + str + "\"，大小：" + QString::number(m_data.size());
            switch (message.header.type)
            {
            case MT_CHECK:
                emit logined(rawData == CHECK_SUCCESS ? true : false);
                break;

            case MT_USERINFO:
                emit infoGot(rawData);
                break;

            case MT_SHAKE:
                qDebug() << "收到一条窗口震动来自：" << QString(message.header.sender);
                emit hasNewMessage(message.header.sender, MT_SHAKE, QVariant());
                break;

            case MT_TEXT:
                qDebug() << "收到一条新消息来自：" << QString(message.header.sender) << "消息为：" + str;
                emit hasNewMessage(message.header.sender, MT_TEXT, QVariant(str));
                break;
            case MT_IMAGE:

                break;
            case MT_HEADIMAGE:

                break;
            case MT_UNKNOW:

                break;
            default:
                break;
            }
        }

        gotSize = 0;           //重新开始
        m_data.clear();
    }
}
