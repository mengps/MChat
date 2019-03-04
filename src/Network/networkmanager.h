#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include "tcpmanager.h"
#include <QObject>
#include <QPointer>

class JsonParse;
class ItemInfo;
class ChatMessage;
class FriendGroup;
class TcpManager;
class UdpManager;
class DatabaseManager;
class NetworkManager : public QObject
{
    Q_OBJECT

public:
    static NetworkManager* instance();
    ~NetworkManager();

    Q_INVOKABLE void cancelLogin();
    Q_INVOKABLE void sendChatMessage(msg_t type, ChatMessage *chatMessage, const QString &receiver);

signals:
    void loginError(const QString &error);
    void loginFinshed(bool ok);
    void hasNewShake(const QString &sender);
    void hasNewText(const QString &sender, const QString &message);

public slots:    
    ItemInfo* getUserInfo();
    void checkLoginInfo();
    void createFriend(FriendGroup *FriendGroup, QMap<QString, ItemInfo *> *friendList);
    void uploadUserInformation();

    void onLogined(bool ok);
    void onInfoGot(const QByteArray &infoJson);

private slots:
    void disposeNewMessage(const QString &sender, msg_t type, const QByteArray &data);

private:
    NetworkManager(QObject *parent = nullptr);

    QPointer<TcpManager> m_tcpManager;
    QPointer<UdpManager> m_udpManager;
    DatabaseManager *m_databaseManager;
    JsonParse *m_jsonParse;
};

#endif
