#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include "tcpmanager.h"
#include <QObject>
#include <QPointer>

namespace NetworkMode
{
    Q_NAMESPACE

    enum Mode
    {
        Internet = 0,   //互联网
        LocalInternet   //局域网
    };

    Q_ENUMS(Mode)
}

class ChatMessage;
class DatabaseManager;
class FriendGroup;
class ItemInfo;
class JsonParser;
class TcpManager;
class UdpManager;
class NetworkManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(NetworkMode::Mode mode READ mode WRITE setMode NOTIFY modeChanged)

public:
    static NetworkManager* instance();
    ~NetworkManager();

    NetworkMode::Mode mode() const { return m_mode; }
    void setMode(NetworkMode::Mode mode);

    Q_INVOKABLE void cancelLogin();
    Q_INVOKABLE void sendChatMessage(msg_t type, ChatMessage *chatMessage, const QString &receiver);

signals:
    void modeChanged();
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
    JsonParser *m_jsonParser;
    NetworkMode::Mode m_mode = NetworkMode::Internet;   //默认局域网
};

#endif
