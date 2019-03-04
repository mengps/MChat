#ifndef FRIENDMODEL_H
#define FRIENDMODEL_H

#include "iteminfo.h"
#include <QQmlListProperty>

class FriendModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString group READ group WRITE setGroup NOTIFY groupChanged)
    Q_PROPERTY(QQmlListProperty<ItemInfo> friends READ friends NOTIFY friendsChanged)
    Q_PROPERTY(int onlineNumber READ onlineNumber WRITE setOnlineNumber NOTIFY onlineNumberChanged)
    Q_PROPERTY(int totalNumber READ totalNumber NOTIFY totalNumberChanged)

public:
    FriendModel(QObject *parent = nullptr);
    FriendModel(const QString &group, int onlineNumber, const QList<ItemInfo *> &other, QObject *parent = nullptr);
    ~FriendModel();

    QString group() const;
    QQmlListProperty<ItemInfo> friends();
    int onlineNumber() const;
    int totalNumber() const;

signals:
    void groupChanged();
    void friendsChanged();
    void onlineNumberChanged();
    void totalNumberChanged();

public slots:
    void setGroup(const QString &arg);
    void setData(const QList<ItemInfo *> &data);
    void setOnlineNumber(int num);
    void removeAt(int index);

private:
    QString m_group;
    int m_onlineNumber;
    QQmlListProperty<ItemInfo> *m_proxy;
    QList<ItemInfo *> m_friends;
};

class FriendGroup : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<FriendModel> friendGroups READ friendGroups NOTIFY friendGroupsChanged)

public:
    FriendGroup(QObject *parent = nullptr);
    FriendGroup(const QList<FriendModel *> &data, QObject *parent = nullptr);
    ~FriendGroup();

    QQmlListProperty<FriendModel> friendGroups();

signals:
    void friendGroupsChanged();

public slots:
    void setData(const QList<FriendModel *> &data);

private:
    QQmlListProperty<FriendModel> *m_proxy;
    QList<FriendModel *> m_friendGroups;
};

#endif // FRIENDMODEL_H
