#include <QJsonObject>
#include <QVariant>
#include <QDebug>
#include <QJsonArray>
#include "myjsonparse.h"
#include "iteminfo.h"
#include "friendmodel.h"

MyJsonParse::MyJsonParse(const QJsonDocument &doc)
{
    m_jsonDoc = doc;
}

MyJsonParse::~MyJsonParse()
{

}

void MyJsonParse::setJsonDocument(const QJsonDocument &json)
{
    if (!json.isNull())
        m_jsonDoc = json;
}

QJsonDocument MyJsonParse::jsonDocument() const
{
    return m_jsonDoc;
}

ItemInfo* MyJsonParse::userInfo()
{
    if (m_jsonDoc.isObject())
    {
        FriendInfo *info = new FriendInfo;
        QJsonObject object = m_jsonDoc.object();

        QJsonValue value = object.value("Username");
        if (value.isString())
            info->setUserName(value.toString());
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
            info->setHeadImage(value.toString());
        value = object.value("Signature");
        if (value.isString())
            info->setSignature(value.toString());
        value = object.value("Birthday");
        if (value.isString())
            info->setBirthday(value.toString());
        value = object.value("Level");
        if (value.isDouble())
            info->setLevel(value.toVariant().toInt());
        qDebug() << "用户数据载入成功";
        return info;
    }
    return nullptr;
}

void MyJsonParse::createFriend(FriendGroupList *friendGroupList, QMap<QString, ItemInfo *> *friendList)
{
    QList<FriendGroupModel *> groups;
    if (m_jsonDoc.isObject())
    {
        QJsonValue value = m_jsonDoc.object().value("FriendList");
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
                        FriendInfo *info = new FriendInfo(friendGroupList);
                        value = object.value("Username");
                        if (value.isString())
                            info->setUserName(value.toString());
                        value = object.value("Nickname");
                        if (value.isString())
                            info->setNickname(value.toString());
                        value = object.value("Gender");
                        if (value.isString())
                            info->setGender(value.toString());
                        value = object.value("HeadImage");
                        if (value.isString())
                            info->setHeadImage(value.toString());
                        value = object.value("Signature");
                        if (value.isString())
                            info->setSignature(value.toString());
                        value = object.value("Birthday");
                        if (value.isString())
                            info->setBirthday(value.toString());
                        value = object.value("Level");
                        if (value.isDouble())
                            info->setLevel(value.toVariant().toInt());
                        info->loadRecord();
                        friendList->insert(info->username(), info);
                        friends.append(info);
                    }
                }
                QString group = friendGroupObject.value("Group").toString();
                FriendGroupModel *friendGroupModel = new FriendGroupModel(group, friends.count(), friends, friendGroupList);
                groups.append(friendGroupModel);
            }
        }
    }
    friendGroupList->setData(groups);
}
