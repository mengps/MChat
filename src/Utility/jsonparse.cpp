#include "friendmodel.h"
#include "iteminfo.h"
#include "jsonparse.h"

#include <QDir>
#include <QJsonObject>
#include <QJsonArray>
#include <QVariant>
#include <QDebug>

JsonParser::JsonParser(const QJsonDocument &doc)
    : m_doc(doc)
{

}

JsonParser::~JsonParser()
{

}

void JsonParser::setJsonDocument(const QJsonDocument &doc)
{
    if (!doc.isNull())
        m_doc = doc;
}

QJsonDocument JsonParser::jsonDocument() const
{
    return m_doc;
}

ItemInfo* JsonParser::userInfo()
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
        value = object.value("Level");
        if (value.isDouble())
            info->setLevel(value.toInt());
        return info;
    }
    return nullptr;
}

void JsonParser::createFriend(FriendGroup *friendGroup, QMap<QString, ItemInfo *> *friendList)
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

QByteArray JsonParser::infoToJson(ItemInfo *info)
{
    FriendInfo *userInfo = qobject_cast<FriendInfo *>(info);
    if (m_doc.isObject())
    {
        QJsonObject object;
        object.insert("Username", userInfo->username());
        object.insert("Nickname", userInfo->nickname());
        object.insert("Gender", userInfo->gender());
        object.insert("Background", userInfo->background());
        object.insert("Password", ChatManager::instance()->password());
        QString headImage = userInfo->headImage();
        if (headImage.left(6) == "file:/")
        {
            headImage = QFileInfo(headImage).fileName();
        }
        object.insert("HeadImage", headImage);
        object.insert("Signature", userInfo->signature());
        object.insert("Birthday", userInfo->birthday());
        object.insert("Level", userInfo->level());
        QJsonDocument doc = QJsonDocument(object);
        qDebug() << __func__ << "成功!";
        return doc.toJson();
    }
    else
    {
        qDebug() << __func__ << "失败!";
        return QByteArray();
    }
}
