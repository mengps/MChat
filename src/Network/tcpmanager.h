#ifndef TCPMANAGER_H
#define TCPMANAGER_H
#include <QTcpSocket>
#include "mymessagedef.h"

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
    void sendMessage(MSG_TYPE type, const QByteArray &receiver = QByteArray(), const QByteArray &message = QByteArray());
    void readData();

private slots:
    void checkLoginInfo(const QString &username, const QString &password);
    void onStateChanged(QAbstractSocket::SocketState state);
    void continueWrite(qint64 sentSize);

signals:
    void loginError(const QString &error);
    void logined(bool ok);
    void infoGot(const QByteArray &infoJson);
    void hasNewMessage(const QString &senderID, MSG_TYPE type, const QVariant &data);

private:
    QString m_username;
    QString m_password;

private:
    qint64 m_fileBytes;
    QByteArray m_data;
    QTimer *m_heartbeat;
};

#endif // TCPMANAGER_H
