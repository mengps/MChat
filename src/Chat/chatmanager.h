#ifndef CHATMANAGER_H
#define CHATMANAGER_H
#include <QObject>
#include <QPointer>
#include <QList>
#include <QQmlListProperty>
#include "iteminfo.h"

namespace Chat
{
    Q_NAMESPACE

    enum LoginStatus
    {
        NoLogin,
        Logging,
        LoginSuccess,
        LoginFinished,
        LoginFailure
    };
    enum ChatStatus
    {
        OnLine,     //在线
        Stealth,    //隐身
        Busy,       //忙碌
        OffLine     //离线
    };
    enum DockStatus
    {
        UnDock,
        LeftDock,
        RightDock,
        TopDock
    };

    Q_ENUMS(LoginStatus)
    Q_ENUMS(ChatStatus)
    Q_ENUMS(DockStatus)
}

class QJSEngine;
class QQmlApplicationEngine;
class ItemInfo;
class ChatMessage;
class SystemTrayIcon;
class FramelessWindow;
class FriendGroupList;
class NetworkManager;
class ChatManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Chat::LoginStatus loginStatus READ loginStatus WRITE setLoginStatus NOTIFY loginStatusChanged)
    Q_PROPERTY(Chat::ChatStatus chatStatus READ chatStatus WRITE setChatStatus NOTIFY chatStatusChanged)
    Q_PROPERTY(bool rememberPassword READ rememberPassword WRITE setRememberPassword NOTIFY rememberPasswordChanged)
    Q_PROPERTY(bool autoLogin READ autoLogin WRITE setAutoLogin NOTIFY autoLoginChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(ItemInfo* userInfo READ userInfo CONSTANT)
    Q_PROPERTY(FriendGroupList* friendGroupList READ friendGroupList CONSTANT)
    Q_PROPERTY(QQmlListProperty<ItemInfo> recentMessageID READ recentMessageID NOTIFY recentMessageIDChanged)

public:
    static ChatManager* instance();  //得到当前对象的唯一实例
    ~ChatManager();

    void initChatManager(QQmlApplicationEngine *qmlengine, QJSEngine *jsengine);
    bool loadLoginInterface();
    bool loadMainInterface();

    Chat::LoginStatus loginStatus() const;
    Chat::ChatStatus chatStatus() const;
    bool rememberPassword() const;
    bool autoLogin() const;
    QString username() const;
    QString password() const;
    ItemInfo* userInfo() const;
    FriendGroupList* friendGroupList() const;
    QQmlListProperty<ItemInfo> recentMessageID() const;

    Q_INVOKABLE QStringList getLoginHistory();                              //获取登录历史
    Q_INVOKABLE FramelessWindow* addChatWindow(const QString &username);    //增加一个聊天窗口
    Q_INVOKABLE void appendRecentMessageID(const QString &username);        //添加一个用户到最近消息列表
    Q_INVOKABLE FriendInfo* createItemInfo(const QString &username);        //创建/获取一个好友信息

    Q_INVOKABLE void closeAllOpenedWindow();                    //关闭所有打开的窗口
    Q_INVOKABLE void readSettings();                            //读取基本设置
    Q_INVOKABLE void writeSettings();                           //写入基本设置
    Q_INVOKABLE void show();                                    //任何时刻显示界面
    Q_INVOKABLE void quit();                                    //任何时刻正确退出程序

public slots:
    void setLoginStatus(Chat::LoginStatus arg);
    void setChatStatus(Chat::ChatStatus arg);
    void setRememberPassword(bool arg);
    void setAutoLogin(bool arg);
    void setUsername(const QString &arg);
    void setPassword(const QString &arg);

private slots:
    void onLoginFinshed(bool ok);
    void deleteChatWindow();

signals:
    void loginStatusChanged(Chat::LoginStatus arg);
    void chatStatusChanged(Chat::ChatStatus arg);
    void rememberPasswordChanged(bool arg);
    void autoLoginChanged(bool arg);
    void usernameChanged(const QString &arg);
    void passwordChanged(const QString &arg);
    void recentMessageIDChanged();

private:
    ChatManager(QObject *parent = nullptr);

    QPointer<FramelessWindow> m_loginInterface, m_mainInterface;    //登录界面和主界面
    QPointer<QQmlApplicationEngine> m_qmlEngine;
    QPointer<QJSEngine> m_jsEngine;                         //
    Chat::LoginStatus m_loginStatus;                        //当前登录状态
    Chat::ChatStatus m_chatStatus;                          //当前聊天的状态
    QString m_username;                                     //当前登录的用户id
    QString m_password;                                     //当前登录的用户密码
    bool m_rememberPassword;
    bool m_autoLogin;
    NetworkManager *m_networkManager;
    SystemTrayIcon *m_systemTray;                           //全局系统托盘
    ItemInfo *m_userInfo;                                   //当前登录的用户信息
    FriendGroupList *m_friendGroupList;                     //保存好友model
    QQmlListProperty<ItemInfo> *m_rencentMessageIDProxy;
    QList<ItemInfo *> m_recentMessageID;                    //保存最近消息的id
    QMap<QString, ItemInfo *> m_friendList;                 //保存好友列表
    QMap<QString, FramelessWindow *> m_chatList;            //保存当前会话窗口列表
};

#endif // CHATMANAGER_H
