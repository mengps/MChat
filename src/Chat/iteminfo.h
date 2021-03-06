#ifndef ITEMINFO_H
#define ITEMINFO_H

#include "chatmanager.h"
#include "protocol.h"

#include <QObject>

class ChatMessage;
class ChatMessageList;
class DatabaseManager;
class NetworkManager;
class ItemInfo : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString nickname READ nickname WRITE setNickname NOTIFY nicknameChanged)
    Q_PROPERTY(QString headImage READ headImage WRITE setHeadImage NOTIFY headImageChanged)
    Q_PROPERTY(int unreadMessage READ unreadMessage WRITE setUnreadMessage NOTIFY unreadMessageChanged)
    Q_PROPERTY(ChatMessage* lastMessage READ lastMessage NOTIFY lastMessageChanged)
    Q_PROPERTY(ChatMessageList* chatRecord READ chatRecord CONSTANT)

public:
    ItemInfo(QObject *parent = nullptr);
    ~ItemInfo();

    QString username() const;
    void setUsername(const QString &arg);

    QString nickname() const;
    void setNickname(const QString &arg);

    QString headImage() const;
    void setHeadImage(const QString &arg);

    int unreadMessage() const;
    void setUnreadMessage(int arg);

    ChatMessage* lastMessage() const;
    ChatMessageList* chatRecord() const;

    Q_INVOKABLE void loadRecord();
    //在消息记录中添加一条消息
    Q_INVOKABLE void addTextMessage(const QString &sender, const QString &msg);
    //在消息记录中撤回一条消息
    Q_INVOKABLE void recallMessage(const QString &sender, const QString &msg);

signals:
    void usernameChanged();
    void nicknameChanged();
    void headImageChanged();
    void unreadMessageChanged();
    void lastMessageChanged();

protected:
    void addMessage(msg_t type, const QString &sender, const QString &msg);

private:
    QString m_username;     //id
    QString m_nickname;     //昵称
    QString m_headImage;    //头像
    int m_unreadMessage;    //未读消息数

    ChatMessageList *m_chatRecord;
    ChatManager* m_chatManager;
    DatabaseManager *m_databaseManager;
    NetworkManager *m_networkManager;
};

class FriendInfo : public ItemInfo
{
    Q_OBJECT

    Q_PROPERTY(int chatStatus READ chatStatus WRITE setChatStatus NOTIFY chatStatusChanged)
    Q_PROPERTY(QString background READ background WRITE setBackground NOTIFY backgroundChanged)
    Q_PROPERTY(QString signature READ signature WRITE setSignature NOTIFY signatureChanged)
    Q_PROPERTY(QString birthday READ birthday WRITE setBirthday NOTIFY birthdayChanged)
    Q_PROPERTY(QString gender READ gender WRITE setGender NOTIFY genderChanged)
    Q_PROPERTY(int level READ level WRITE setLevel NOTIFY levelChanged)
    Q_PROPERTY(int age READ age NOTIFY ageChanged)

public:
    FriendInfo(QObject *parent = nullptr);
    ~FriendInfo();

    int chatStatus() const;
    void setChatStatus(int status);

    QString background() const;
    void setBackground(const QString &arg);

    QString signature() const;
    void setSignature(const QString &arg);

    QString birthday() const;
    void setBirthday(const QString &arg);

    QString gender() const;
    void setGender(const QString &arg);

    int level() const;
    void setLevel(int arg);

    int age() const;

public slots:
    //在消息记录中添加一条窗口抖动消息
    void addShakeMessage(const QString &sender);

signals:
    void chatStatusChanged();
    void backgroundChanged();
    void signatureChanged();
    void birthdayChanged();
    void genderChanged();
    void levelChanged();
    void ageChanged();

private:
    int m_status;
    QString m_background;   //背景
    QString m_signature;    //签名
    QString m_birthday;     //生日
    QString m_gender;       //性别
    int m_level;            //等级
};

#endif // FRIENDINFO_H
