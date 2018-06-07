#ifndef FRIENDMODEL_H
#define FRIENDMODEL_H
#include <QQmlListProperty>
#include "iteminfo.h"

class FriendGroupModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString group READ group WRITE setGroup NOTIFY groupChanged)
    Q_PROPERTY(QQmlListProperty<ItemInfo> friends READ friends NOTIFY friendsChanged)
    Q_PROPERTY(int onlineNumber READ onlineNumber WRITE setOnlineNumber NOTIFY onlineNumberChanged)
    Q_PROPERTY(int totalNumber READ totalNumber NOTIFY totalNumberChanged)

public:
    FriendGroupModel(QObject *parent = nullptr);
    FriendGroupModel(const QString &group, int onlineNumber, const QList<ItemInfo *> &other, QObject *parent = nullptr);
    ~FriendGroupModel();

    QString group() const;
    QQmlListProperty<ItemInfo> friends();
    int onlineNumber() const;
    int totalNumber() const;

public slots:
    void setGroup(const QString &arg);
    void setData(const QList<ItemInfo *> &data);
    void setOnlineNumber(int num);
    void removeAt(int index);

signals:
    void groupChanged();
    void friendsChanged();
    void onlineNumberChanged();
    void totalNumberChanged();

private:
    QString m_group;
    int m_onlineNumber;
    int m_totalNumber;
    QQmlListProperty<ItemInfo> *m_proxy;
    QList<ItemInfo *> m_friends;
};

class FriendGroupList : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<FriendGroupModel> friendGroups READ friendGroups NOTIFY friendGroupsChanged)

public:
    FriendGroupList(QObject *parent = nullptr);
    FriendGroupList(const QList<FriendGroupModel *> &data, QObject *parent = nullptr);
    ~FriendGroupList();

    QQmlListProperty<FriendGroupModel> friendGroups();

public slots:
    void setData(const QList<FriendGroupModel *> &data);

signals:
    void friendGroupsChanged();

private:
    QQmlListProperty<FriendGroupModel> *m_proxy;
    QList<FriendGroupModel *> m_friendGroups;
};

#endif // FRIENDMODEL_H
