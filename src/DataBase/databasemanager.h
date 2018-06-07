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

    Q_PROPERTY(QString recordPath READ recordPath WRITE setRecordPath NOTIFY recordPathChanged)

public:
    static DatabaseManager* instance();
    ~DatabaseManager();

    QString recordPath() const;

public slots:
    void setRecordPath(const QString &arg);

    bool openDatabase();
    void closeDatabase();
    bool insertData(const QString &username, ChatMessage *content);
    bool getData(const QString &username, int count, ChatMessageList *content_list);

signals:
    void recordPathChanged(const QString &arg);

private:
    DatabaseManager(QObject *parent = nullptr);

    bool tableExist(const QString &tableName);            //判断表是否存在
    int getTableSize(const QString &tableName);           //获取表大小
    QString getTableName(const QString &username);        //通过用户ID获取表名

private:
    QSqlDatabase m_database;
    QString m_recordPath;
};

#endif // DATABASEMANAGER_H
