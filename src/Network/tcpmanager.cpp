#include <QTimer>
#include <QDataStream>
#include <QThread>
#include <QCryptographicHash>
#include <QFile>
#include "mymessagedef.h"
#include "tcpmanager.h"

TcpManager::TcpManager(QObject *parent)
    :   QTcpSocket(parent)
{
    m_fileBytes = 0;
    m_data = QByteArray();
    m_heartbeat = new QTimer(this);
    m_heartbeat->setInterval(30000);

    connect(this, &TcpManager::bytesWritten, this, &TcpManager::continueWrite);
    connect(this, &TcpManager::readyRead, this, &TcpManager::readData);
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
}

TcpManager::~TcpManager()
{

}

void TcpManager::requestNewConnection()
{
    abort();
    connectToHost("10.103.0.13", 43800, QAbstractSocket::ReadWrite);
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

void TcpManager::sendMessage(MSG_TYPE type, const MSG_ID_TYPE &receiver, const QByteArray &message)
{
    QByteArray block;
    QDataStream out(&block, QIODevice::WriteOnly);
    out.setVersion(QDataStream::Qt_5_9);

    MSG_FLAG_TYPE flag = MSG_FLAG;
    MSG_ID_TYPE senderID = m_username.toLatin1();
    MSG_MD5_TYPE md5 = QCryptographicHash::hash(QByteArray(), QCryptographicHash::Md5);

    if (type == MT_TEXT || type == MT_CHECK)
    {    
        m_data =  message.toBase64();
        md5 = QCryptographicHash::hash(m_data, QCryptographicHash::Md5);
        m_fileBytes = m_data.size() + sizeof(flag) + sizeof(type) + sizeof(MSG_SIZE_TYPE) +
                sizeof(MSG_ID_TYPE) + senderID.size() + sizeof(MSG_ID_TYPE) + receiver.size() +
                sizeof(QByteArray) + md5.size();
    }

    out << flag << type << m_data.size() << senderID << receiver << md5;

    qDebug() << write(block) << m_fileBytes << m_data.size();
    QThread::msleep(10);
}

void TcpManager::checkLoginInfo(const QString &username, const QString &password)
{
    QString data = username + "%%" + password;
    sendMessage(MT_CHECK, QByteArray(), data.toLocal8Bit());
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

void TcpManager::continueWrite(qint64 sentSize)
{
    static int sentBytes = 0;
    sentBytes += sentSize;

    if (sentBytes >= m_fileBytes)
    {
        m_fileBytes = 0;
        sentBytes = 0;
        m_data.clear();
        return;
    }

    write(m_data);
    QThread::msleep(10);    //重启线程后将立即发送数据
}

void TcpManager::readData()
{
    static int got_size = 0;
    static MSG_TYPE type = MT_UNKNOW;
    static MSG_ID_TYPE senderID = MSG_ID_TYPE();
    static MSG_ID_TYPE receiver = MSG_ID_TYPE();
    static MSG_MD5_TYPE md5;

    if (m_data.size() == 0)  //必定为消息头
    {
        QDataStream in(this);
        in.setVersion(QDataStream::Qt_5_9);

        MSG_FLAG_TYPE flag;
        in >> flag;
        if (flag != MSG_FLAG)
        {
            readAll();
            return;
        }

        MSG_SIZE_TYPE size;
        in >> type >> size >> senderID >> receiver >> md5;
        m_data.resize(size);     
    }
    else                                //合并数据
    {
        QByteArray data = read(bytesAvailable());
        m_data.replace(got_size, data.size(), data);
        got_size += data.size();
    }

    if (got_size == m_data.size())     //接收完毕
    {
        QByteArray md5_t = QCryptographicHash::hash(m_data, QCryptographicHash::Md5);
        if (md5 == md5_t)   //正确的消息
        {
            QByteArray base64data = QByteArray::fromBase64(m_data);
            QString str = QString::fromLocal8Bit(base64data);
            qDebug() << "md5 一致，消息为：\"" + str + "\"，大小：" + QString::number(m_data.size());
            switch (type)
            {
            case MT_CHECK:
                emit logined((bool)str.toInt());
                break;

            case MT_SHAKE:
                qDebug() << "收到一条窗口震动来自：" << QString(senderID);
                emit hasNewMessage(senderID, MT_SHAKE, QVariant());
                break;

            case MT_TEXT:
                qDebug() << "收到一条新消息来自：" << QString(senderID) << "消息为：" + str;
                emit hasNewMessage(senderID, MT_TEXT, QVariant(str));
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

        got_size = 0;           //重新开始
        type = MT_UNKNOW;
        senderID.clear();
        receiver.clear();
        m_data.clear();
        md5.clear();
    }
}
