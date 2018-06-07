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

public slots:    
    ItemInfo* createUserInfo();
    void checkLoginInfo(const QString &username, const QString &password);
    void createFriend(FriendGroupList *friendGroupList, QMap<QString, ItemInfo *> *friendList);
    void uploadUserInformation();

    void onLogined(bool ok);
    void cancelLogin();
    void sendMessage(MSG_TYPE type, ChatMessage *message, const QString &receiver);

private slots:
    void deposeNewMessage(const QString &senderID, MSG_TYPE type, const QVariant &data);

signals:
    void loginError(const QString &error);
    void loginFinshed(bool ok);
    void hasNewShake(const QString &senderID);
    void hasNewText(const QString &senderID, const QString &message);

private:
    NetworkManager(QObject *parent = nullptr);
    ~NetworkManager();

    QPointer<TcpManager> m_tcpManager;
    QPointer<UdpManager> m_udpManager;
    DatabaseManager *m_databaseManager;
    MyJsonParse *m_jsonParse;
};

#endif
