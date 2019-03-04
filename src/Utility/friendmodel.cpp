#include "friendmodel.h"
#include <QDebug>

FriendModel::FriendModel(QObject *parent)
    : QObject(parent),
      m_group(tr("未命名"))
{
    m_proxy = new QQmlListProperty<ItemInfo>(this, m_friends);
}

FriendModel::FriendModel(const QString &group,
                         int onlineNumber,
                         const QList<ItemInfo *> &data,
                         QObject *parent)
    : QObject(parent),
      m_group(group),
      m_onlineNumber(onlineNumber),
      m_friends(data)
{
    m_proxy = new QQmlListProperty<ItemInfo>(parent, m_friends);
}

FriendModel::~FriendModel()
{

}

QString FriendModel::group() const
{
    return m_group;
}

QQmlListProperty<ItemInfo> FriendModel::friends()
{
    return *m_proxy;
}

int FriendModel::onlineNumber() const
{
    return m_onlineNumber;
}

int FriendModel::totalNumber() const
{
    return m_friends.count();
}

void FriendModel::setOnlineNumber(int num)
{
    m_onlineNumber = num;
    emit onlineNumberChanged();
}

void FriendModel::setGroup(const QString &arg)
{
    if (arg != m_group)
    {
        m_group = arg;
        emit groupChanged();
    }
}

void FriendModel::setData(const QList<ItemInfo *> &data)
{
    m_friends = data;
    emit totalNumberChanged();
    emit friendsChanged();
}

void FriendModel::removeAt(int index)
{
    m_friends.removeAt(index);
    qDebug() << "removeAt:" << m_group << "index:" << index;
    emit totalNumberChanged();
    emit friendsChanged();
}


FriendGroup::FriendGroup(QObject *parent)
    : QObject(parent)
{
    m_proxy = new QQmlListProperty<FriendModel>(parent, m_friendGroups);
}

FriendGroup::FriendGroup(const QList<FriendModel *> &data, QObject *parent)
    : QObject(parent),
      m_friendGroups(data)
{
    m_proxy = new QQmlListProperty<FriendModel>(this, m_friendGroups);
}

FriendGroup::~FriendGroup()
{

}

void FriendGroup::setData(const QList<FriendModel *> &data)
{
    m_friendGroups = data;
}

QQmlListProperty<FriendModel> FriendGroup::friendGroups()
{
    return *m_proxy;
}
