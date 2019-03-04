#include "jsonparse.h"
#include "iteminfo.h"
#include "friendmodel.h"
#include <QJsonObject>
#include <QVariant>
#include <QJsonArray>
#include <QDir>
#include <QDebug>

JsonParse::JsonParse(const QJsonDocument &doc)
    : m_doc(doc)
{

}

JsonParse::~JsonParse()
{

}

void JsonParse::setJsonDocument(const QJsonDocument &doc)
{
    if (!doc.isNull())
        m_doc = doc;
}

QJsonDocument JsonParse::jsonDocument() const
{
    return m_doc;
}

ItemInfo* JsonParse::userInfo()
{
    if (m_doc.isObject())
    {
        FriendInfo *info = new FriendInfo;
        QJsonObject object = m_doc.object();

        QJsonValue value = object.value("Username");
        QString username;
        if (value.isString())
        {
            username = value.toString();
            info->setUsername(username);
        }
        value = object.value("Nickname");
        if (value.isString())
            info->setNickname(value.toString());
        value = object.value("Gender");
        if (value.isString())
            info->setGender(value.toString());
        value = object.value("Background");
        if (value.isString())
            info->setBackground(value.toString());
        value = object.value("HeadImage");
        if (value.isString())
        {
            QString image = value.toString();
            if (image.left(3) == "qrc")
                info->setHeadImage(image);
            else info->setHeadImage("file:///" + QDir::homePath() + "/MChat/Settings/" + username +
                                    "/headImage/" + image);
        }
        value = object.value("Signature");
        if (value.isString())
            info->setSignature(value.toString());
        value = object.value("Birthday");
        if (value.isString())
            info->setBirthday(value.toString());
        value = object.value("UnreadMessage");
        if (value.isDouble())
            info->setUnreadMessage(value.toInt());
        value = object.value("Level");
        if (value.isDouble())
            info->setLevel(value.toInt());
        return info;
    }
    return nullptr;
}

void JsonParse::createFriend(FriendGroup *friendGroup, QMap<QString, ItemInfo *> *friendList)
{
    QList<FriendModel *> groups;
    if (m_doc.isObject())
    {
        QJsonValue value = m_doc.object().value("FriendList");
        if (value.isArray())
        {
            QJsonArray friendGroupArray = value.toArray();       
            for (auto it : friendGroupArray)
            {
                QList<ItemInfo *> friends;
                QJsonObject friendGroupObject = it.toObject();
                value = friendGroupObject.value("Friend");
                if (value.isArray())
                {   
                    QJsonArray friendArray = value.toArray();  
                    for (auto iter : friendArray)
                    {
                        QJsonObject object = iter.toObject();
                        FriendInfo *info = new FriendInfo(friendGroup);
                        QString username;
                        value = object.value("Username");
                        if (value.isString())
                        {
                            username = value.toString();
                            info->setUsername(username);
                        }
                        value = object.value("Nickname");
                        if (value.isString())
                            info->setNickname(value.toString());
                        value = object.value("Gender");
                        if (value.isString())
                            info->setGender(value.toString());
                        value = object.value("HeadImage");
                        if (value.isString())
                        {
                            QString image = value.toString();
                            if (image.left(3) == "qrc")
                                info->setHeadImage(image);
                            else info->setHeadImage("file:///" + QDir::homePath() + "/MChat/Settings/" + username +
                                                    "/headImage/" + image);
                        }
                        value = object.value("Signature");
                        if (value.isString())
                            info->setSignature(value.toString());
                        value = object.value("Birthday");
                        if (value.isString())
                            info->setBirthday(value.toString());
                        value = object.value("UnreadMessage");
                        if (value.isDouble())
                            info->setUnreadMessage(value.toInt());
                        value = object.value("Level");
                        if (value.isDouble())
                            info->setLevel(value.toInt());
                        info->loadRecord();
                        friendList->insert(info->username(), info);
                        friends.append(info);
                    }
                }
                QString group = friendGroupObject.value("Group").toString();
                FriendModel *friendModel = new FriendModel(group, friends.count(), friends, friendGroup);
                groups.append(friendModel);
            }
        }
    }
    friendGroup->setData(groups);
}

bool JsonParse::updateInfo(ItemInfo *info)
{
    FriendInfo *userInfo = qobject_cast<FriendInfo *>(info);
    if (!m_doc.isNull())
    {
        if (m_doc.isObject())
        {
            QJsonObject object = m_doc.object();

            object.insert("Nickname", userInfo->nickname());
            object.insert("Gender", userInfo->gender());
            object.insert("Background", userInfo->background());
            object.insert("HeadImage", userInfo->headImage());
            object.insert("Signature", userInfo->signature());
            object.insert("Birthday", userInfo->birthday());
            m_doc = QJsonDocument(object);
        }
        qDebug() << "用户数据上传成功！";
        return true;
    }
    else
    {
        qDebug() << "用户数据上传失败！";
        return false;
    }
}
