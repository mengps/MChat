#ifndef ITEMINFO_H
#define ITEMINFO_H
#include <QObject>
#include "mymessagedef.h"

class ChatMessage;
class ChatMessageList;
class ChatManager;
class DatabaseManager;
class NetworkManager;
class ItemInfo : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString username READ username WRITE setUserName NOTIFY usernameChanged)
    Q_PROPERTY(QString nickname READ nickname WRITE setNickname NOTIFY nicknameChanged)
    Q_PROPERTY(QString headImage READ headImage WRITE setHeadImage NOTIFY headImageChanged)
    Q_PROPERTY(int unreadMessage READ unreadMessage WRITE setUnreadMessage NOTIFY unreadMessageChanged)
    Q_PROPERTY(ChatMessage* lastMessage READ lastMessage NOTIFY lastMessageChanged)
    Q_PROPERTY(ChatMessageList* messageList READ messageList CONSTANT)

public:
    ItemInfo(QObject *parent = nullptr);
    ~ItemInfo();

    QString username() const;
    QString nickname() const;
    QString headImage() const;
    int unreadMessage() const;
    ChatMessage* lastMessage() const;
    ChatMessageList* messageList() const;

public slots:
    void setUserName(const QString &arg);
    void setNickname(const QString &arg);
    void setHeadImage(const QString &arg);
    void setUnreadMessage(int arg);

    void loadRecord();

    //在消息记录中添加一条窗口抖动消息
    bool addShakeMessage(const QString &senderID);
    //在消息记录中添加一条消息
    bool addTextMessage(const QString &senderID, const QString &msg);
    //在消息记录中撤回一条消息
    void recallMessage(const QString &senderID, const QString &msg);

signals:
    void usernameChanged(const QString &arg);
    void nicknameChanged(const QString &arg);
    void headImageChanged(const QString &arg);
    void unreadMessageChanged(int arg);
    void lastMessageChanged();

private:
    bool addMessage(MSG_TYPE type, const QString &senderID, const QString &msg);

private:
    QString m_username;   //id
    QString m_nickname;   //昵称
    QString m_headImage;     //头像
    int m_unreadMessage;    //未读消息数

    ChatMessageList *m_messageList;
    ChatManager* m_chatManager;
    DatabaseManager *m_databaseManager;
    NetworkManager *m_networkManager;
};

class FriendInfo : public ItemInfo
{
    Q_OBJECT

    Q_PROPERTY(QString background READ background WRITE setBackground NOTIFY backgroundChanged)
    Q_PROPERTY(QString signature READ signature WRITE setSignature NOTIFY signatureChanged)
    Q_PROPERTY(QString birthday READ birthday WRITE setBirthday NOTIFY birthdayChanged)
    Q_PROPERTY(QString gender READ gender WRITE setGender NOTIFY genderChanged)
    Q_PROPERTY(int level READ level WRITE setLevel NOTIFY levelChanged)

public:
    FriendInfo(QObject *parent = nullptr);
    ~FriendInfo();

    QString background() const;
    QString signature() const;
    QString birthday() const;
    QString gender() const;
    int level() const;
    int age() const;

public slots:
    void setBackground(const QString &arg);
    void setSignature(const QString &arg);
    void setBirthday(const QString &arg);
    void setGender(const QString &arg);
    void setLevel(int arg);

signals:
    void backgroundChanged(const QString &arg);
    void signatureChanged(const QString &arg);
    void birthdayChanged(const QString &arg);
    void genderChanged(const QString &arg);
    void levelChanged(int arg);

private:
    QString m_background;   //背景
    QString m_signature;  //签名
    QString m_birthday; //生日
    QString m_gender;       //性别
    int m_level;            //等级
};

#endif // FRIENDINFO_H
