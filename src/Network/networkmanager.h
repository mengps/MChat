#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H
#include <QObject>
#include <QPointer>
#include "tcpmanager.h"

class MyJsonParse;
class ItemInfo;
class ChatMessage;
class FriendGroupList;
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
    Q_INVOKABLE void sendChatMessage(MSG_TYPE type, ChatMessage *chatMessage, const QString &receiver);

public slots:    
    ItemInfo* getUserInfo();
    void checkLoginInfo(const QString &username, const QString &password);
    void createFriend(FriendGroupList *friendGroupList, QMap<QString, ItemInfo *> *friendList);
    void uploadUserInformation();

    void onLogined(bool ok);
    void onInfoGot(const QByteArray &infoJson);

private slots:
    void disposeNewMessage(const QString &sender, MSG_TYPE type, const QVariant &data);

signals:
    void loginError(const QString &error);
    void loginFinshed(bool ok);
    void hasNewShake(const QString &sender);
    void hasNewText(const QString &sender, const QString &message);

private:
    NetworkManager(QObject *parent = nullptr);

    QPointer<TcpManager> m_tcpManager;
    QPointer<UdpManager> m_udpManager;
    DatabaseManager *m_databaseManager;
    MyJsonParse *m_jsonParse;
};

#endif
