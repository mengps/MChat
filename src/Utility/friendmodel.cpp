#include <QDebug>
#include "friendmodel.h"

FriendGroupModel::FriendGroupModel(QObject *parent)
    :   QObject(parent), m_group("未命名")
{
    m_proxy = new QQmlListProperty<ItemInfo>(this, m_friends);
}

FriendGroupModel::FriendGroupModel(const QString &group, int onlineNumber,
                                   const QList<ItemInfo *> &data, QObject *parent)
    :   QObject(parent), m_group(group), m_onlineNumber(onlineNumber), m_friends(data)
{
    m_proxy = new QQmlListProperty<ItemInfo>(parent, m_friends);
}

FriendGroupModel::~FriendGroupModel()
{

}

QString FriendGroupModel::group() const
{
    return m_group;
}

QQmlListProperty<ItemInfo> FriendGroupModel::friends()
{
    return *m_proxy;
}

int FriendGroupModel::onlineNumber() const
{
    return m_onlineNumber;
}

int FriendGroupModel::totalNumber() const
{
    return m_friends.count();
}

void FriendGroupModel::setOnlineNumber(int num)
{
    m_onlineNumber = num;
    emit onlineNumberChanged();
}

void FriendGroupModel::setGroup(const QString &arg)
{
    if (arg != m_group)
    {
        m_group = arg;
        emit groupChanged();
    }
}

void FriendGroupModel::setData(const QList<ItemInfo *> &data)
{
    m_friends = data;
    emit totalNumberChanged();
    emit friendsChanged();
}

void FriendGroupModel::removeAt(int index)
{
    m_friends.removeAt(index);
    qDebug() << "removeAt:" << m_group << "index:" << index;
    emit totalNumberChanged();
    emit friendsChanged();
}


FriendGroupList::FriendGroupList(QObject *parent)
    :   QObject(parent)
{
    m_proxy = new QQmlListProperty<FriendGroupModel>(parent, m_friendGroups);
}

FriendGroupList::FriendGroupList(const QList<FriendGroupModel *> &data, QObject *parent)
    :   QObject(parent), m_friendGroups(data)
{
    m_proxy = new QQmlListProperty<FriendGroupModel>(this, m_friendGroups);
}

FriendGroupList::~FriendGroupList()
{

}

void FriendGroupList::setData(const QList<FriendGroupModel *> &data)
{
    m_friendGroups = data;
}

QQmlListProperty<FriendGroupModel> FriendGroupList::friendGroups()
{
    return *m_proxy;
}
