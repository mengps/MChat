#ifndef CHATMANAGER_H
#define CHATMANAGER_H

#include "iteminfo.h"
#include "Utility/friendmodel.h"
#include <QObject>
#include <QPointer>
#include <QList>
#include <QQmlListProperty>

namespace Chat
{
    Q_NAMESPACE

    //登录状态
    enum LoginStatus
    {
        NoLogin,        //未登录
        Logging,        //登录中
        LoginSuccess,   //登录成功
        LoginFinished,  //登录结束
        LoginFailure    //登录失败
    };
    //聊天状态
    enum ChatStatus
    {
        Online = 0,     //在线
        Stealth,        //隐身
        Busy,           //忙碌
        OffLine         //离线
    };
    //停靠状态
    enum DockStatus
    {
        UnDock,     //未停靠
        LeftDock,   //左停靠
        RightDock,  //右停靠
        TopDock     //上停靠
    };

    Q_ENUMS(LoginStatus)
    Q_ENUMS(ChatStatus)
    Q_ENUMS(DockStatus)
}

class QQmlApplicationEngine;
class ChatMessage;
class SystemTrayIcon;
class FramelessWindow;
class FriendGroup;
class NetworkManager;
class ChatManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Chat::LoginStatus loginStatus READ loginStatus WRITE setLoginStatus NOTIFY loginStatusChanged)
    Q_PROPERTY(Chat::ChatStatus chatStatus READ chatStatus WRITE setChatStatus NOTIFY chatStatusChanged)
    Q_PROPERTY(bool rememberPassword READ rememberPassword WRITE setRememberPassword NOTIFY rememberPasswordChanged)
    Q_PROPERTY(bool autoLogin READ autoLogin WRITE setAutoLogin NOTIFY autoLoginChanged)
    Q_PROPERTY(QString headImage READ headImage WRITE setHeadImage NOTIFY headImageChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(ItemInfo* userInfo READ userInfo CONSTANT)
    Q_PROPERTY(QQmlListProperty<FriendModel> friendGroups READ friendGroups CONSTANT)
    Q_PROPERTY(QQmlListProperty<ItemInfo> recentMessageID READ recentMessageID NOTIFY recentMessageIDChanged)

public:
    static ChatManager* instance();  //得到当前对象的唯一实例
    ~ChatManager();

    void initChatManager(QQmlApplicationEngine *qmlengine);
    bool loadLoginInterface();
    bool loadMainInterface();

    Chat::LoginStatus loginStatus() const;
    Chat::ChatStatus chatStatus() const;
    bool rememberPassword() const;
    bool autoLogin() const;
    QString headImage() const;
    QString username() const;
    QString password() const;
    ItemInfo* userInfo() const;
    QQmlListProperty<FriendModel> friendGroups() const;
    QQmlListProperty<ItemInfo> recentMessageID() const;

    Q_INVOKABLE QStringList getLoginHistory();                              //获取登录历史
    Q_INVOKABLE FramelessWindow* addChatWindow(const QString &username);    //增加一个聊天窗口
    Q_INVOKABLE bool chatWindowIsOpenned(const QString &username);          //判断聊天窗口事是否已经打开
    Q_INVOKABLE void appendRecentMessageID(const QString &username);        //添加一个用户到最近消息列表
    Q_INVOKABLE FriendInfo* createFriendInfo(const QString &username);      //创建/获取一个好友信息

    Q_INVOKABLE void closeAllOpenedChat();                      //关闭所有打开的窗口
    Q_INVOKABLE void readSettings();                            //读取基本设置
    Q_INVOKABLE void writeSettings();                           //写入基本设置
    Q_INVOKABLE void show();                                    //显示主界面
    Q_INVOKABLE void quit();                                    //退出程序

signals:
    //登录状态改变时发出
    void loginStatusChanged(Chat::LoginStatus arg);
    //用户状态改变时发出
    void chatStatusChanged(Chat::ChatStatus arg);
    //记住密码改变时发出
    void rememberPasswordChanged(bool arg);
    void autoLoginChanged(bool arg);
    void headImageChanged(const QString &arg);
    void usernameChanged(const QString &arg);
    void passwordChanged(const QString &arg);
    void recentMessageIDChanged();

public slots:
    void setLoginStatus(Chat::LoginStatus arg);
    void setChatStatus(Chat::ChatStatus arg);
    void setRememberPassword(bool arg);
    void setAutoLogin(bool arg);
    void setHeadImage(const QString &arg);
    void setUsername(const QString &arg);
    void setPassword(const QString &arg);

private slots:
    void onLoginFinshed(bool ok);
    void deleteChatWindow();

private:
    ChatManager(QObject *parent = nullptr);

    QPointer<FramelessWindow> m_loginInterface, m_mainInterface;    //登录界面和主界面
    QPointer<QQmlApplicationEngine> m_qmlEngine;            //当前的qml引擎
    Chat::LoginStatus m_loginStatus;                        //当前登录状态
    Chat::ChatStatus m_chatStatus;                          //当前聊天的状态
    QString m_username;                                     //当前用户id
    QString m_password;                                     //当前用户密码
    QString m_headImage;                                    //当前用户的头像
    bool m_rememberPassword;                                //是否记住密码
    bool m_autoLogin;                                       //是否自动登录
    NetworkManager *m_networkManager;
    SystemTrayIcon *m_systemTray;                           //全局系统托盘
    ItemInfo *m_userInfo;                                   //当前登录的用户信息
    FriendGroup *m_friendGroup;                             //保存好友分组
    QQmlListProperty<ItemInfo> *m_rencentMessageIDProxy;
    QList<ItemInfo *> m_recentMessageID;                    //保存最近消息的id
    QMap<QString, ItemInfo *> m_friendList;                 //保存好友列表
    QMap<QString, FramelessWindow *> m_chatList;            //保存当前会话窗口列表
};

#endif // CHATMANAGER_H
