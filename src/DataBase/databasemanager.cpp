#include <QDir>
#include <QDebug>
#include <QSqlError>
#include "chatmanager.h"
#include "chatmessage.h"
#include "databasemanager.h"

DatabaseManager* DatabaseManager::instance()
{
    static DatabaseManager databaseManager;
    return &databaseManager;
}

DatabaseManager::DatabaseManager(QObject *parent)
    :   QObject(parent)
{
    m_recordPath = QDir::homePath() + "/MChat/ChatRecord";
    m_database = QSqlDatabase::addDatabase("QSQLITE");
    m_database.setDatabaseName(m_recordPath + "/MSG" + ChatManager::instance()->username() + ".db");
    m_database.setUserName("MChat");
    m_database.setHostName("localhost");
    m_database.setPassword("123456");
}

DatabaseManager::~DatabaseManager()
{
    closeDatabase();
}

bool DatabaseManager::tableExist(const QString &tableName)
{
    if (!m_database.isOpen())
        openDatabase();

    QString query_create = "CREATE TABLE IF NOT EXISTS " + tableName +
                           "("
                           "  msg_index      int      NOT NULL PRIMARY KEY,"
                           "  msg_senderID   char(10) NOT NULL,"
                           "  msg_datetime   datetime NOT NULL,"
                           "  msg_content    text     NOT NULL"
                           ");";   //里面的分号可以不用
    QSqlQuery query;
    if (query.exec(query_create))
        return true;
    else
    {
        qDebug() <<  __func__ << query.lastError().text();
        return false;
    }
}

int DatabaseManager::getTableSize(const QString &tableName)
{
    openDatabase();
    QSqlQuery size(m_database);
    if (size.exec("SELECT COUNT(*) FROM " + tableName))
    {
        size.next();
        return size.value(0).toInt();
    }
    else
    {
        qDebug() << __func__ << size.lastError().text();
        return -1;
    }
    closeDatabase();
}

QString DatabaseManager::getTableName(const QString &username)
{
    return "Message" + username;
}

QString DatabaseManager::recordPath() const
{
    return m_recordPath;
}

void DatabaseManager::setRecordPath(const QString &arg)
{
    if (m_recordPath == arg)
    {
        m_recordPath = arg;
        if (!QFile::exists(m_recordPath))
        {
            QDir dir;
            dir.mkpath(m_recordPath);
        }

        emit recordPathChanged(arg);
    }
}

bool DatabaseManager::openDatabase()
{
    if (!QFile::exists(m_recordPath))
    {
        QDir dir;
        dir.mkpath(m_recordPath);
    }

    if (!m_database.isOpen())
    {
        if (m_database.open())
            return true;
        else
        {
            qDebug() << __func__ << m_database.lastError().text();
            return false;
        }
    }
    else return true;
}

void DatabaseManager::closeDatabase()
{
    if (m_database.isOpen())
        m_database.close();
}

bool DatabaseManager::insertData(const QString &username, ChatMessage *content)
{
    QString tableName = getTableName(username);
    if (tableExist(tableName))
    {
        QString query_insert = "INSERT INTO " + tableName + " VALUES(?, ?, ?, ?);";
        QSqlQuery query(m_database);
        int index = getTableSize(tableName) + 1; //当前消息的索引
        query.prepare(query_insert);
        query.addBindValue(index);
        query.addBindValue(content->senderID());
        query.addBindValue(content->dateTime());
        query.addBindValue(content->message());
        if (query.exec())
        {
            /*qDebug() << "消息" << content->message() << "插入成功"
                     << "senderID :" << content->senderID()
                     << "时间 :" << content->dateTime();*/
            closeDatabase();
            return true;
        }
        else
        {
            qDebug() << __func__ << query.lastError().text();
            closeDatabase();
            return false;
        }
    }

    return false;
}

bool DatabaseManager::getData(const QString &username, int count, ChatMessageList *content_list)
{
    QString tableName = getTableName(username);
    if (tableExist(tableName))
    {
        QSqlQuery query(m_database);
        int index = getTableSize(tableName); //得到最后一条消息的索引
        if (index <= count)                  //如果消息数量不够，就取出所有
            count = index;
        QString select = QString("SELECT msg_index, msg_senderID, msg_datetime, msg_content FROM " + tableName +
                                 " WHERE msg_index BETWEEN %1 AND %2").arg(index - count + 1).arg(index);
        if (query.exec(select))
        {
            while (query.next())
            {
                QString senderID = query.value(1).toString();
                QString datetime = query.value(2).toString();
                QString data = query.value(3).toString();

                ChatMessage *content = new ChatMessage(content_list);
                content->setSenderID(senderID);
                content->setDateTime(datetime);
                content->setMessage(data);
                content_list->append(content);
            }
            closeDatabase();
            return true;
        }
        else
        {
            qDebug() << __func__ << query.lastError().text();
            closeDatabase();
            return false;
        }
    }
}
