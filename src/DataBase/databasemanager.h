#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QObject>

class ChatMessage;
class ChatMessageList;
class DatabaseManager : public QObject
{
    Q_OBJECT

public:
    static DatabaseManager* instance();
    ~DatabaseManager();

private slots:
    void initDatabaseSlot();
    void openDatabaseSlot();
    void closeDatabaseSlot();
    void insertChatMessageSlot(const QString &username, ChatMessage *chatMessage);
    void getChatMessageSlot(const QString &username, int count, ChatMessageList *chatMessageList);

signals:    //所有的操作使用信号进行
    void initDatabase();
    void openDatabase();
    void closeDatabase();
    void insertChatMessage(const QString &username, ChatMessage *chatMessage);
    void getChatMessage(const QString &username, int count, ChatMessageList *chatMessageList);

private:
    DatabaseManager(QObject *parent = nullptr);

    bool tableExist(const QString &tableName);            //判断表是否存在
    int getTableSize(const QString &tableName);           //获取表大小
    QString getTableName(const QString &username);        //通过用户ID获取表名

private:
    QSqlDatabase m_database;
};

#endif // DATABASEMANAGER_H
