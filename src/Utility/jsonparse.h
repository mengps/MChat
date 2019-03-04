#ifndef JSONPARSE_H
#define JSONPARSE_H
#include <QJsonDocument>

class ItemInfo;
class FriendGroup;
class JsonParse
{
public :
    JsonParse(const QJsonDocument &doc);
    ~JsonParse();

    void setJsonDocument(const QJsonDocument &doc);
    QJsonDocument jsonDocument() const;

public:
    ItemInfo* userInfo();
    void createFriend(FriendGroup *friendGroup, QMap<QString, ItemInfo *> *friendList);
    bool updateInfo(ItemInfo *info);

private:
    QJsonDocument m_doc;
};

#endif //JSONPARSE_H
