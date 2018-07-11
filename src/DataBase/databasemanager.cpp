#include <QDir>
#include <QDebug>
#include <QSqlError>
#include <QThread>
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
    QThread *thread = new QThread;
    connect(thread, &QThread::finished, thread, &QThread::deleteLater);
    connect(this, &DatabaseManager::initDatabase, this, &DatabaseManager::initDatabaseSlot);
    connect(this, &DatabaseManager::openDatabase, this, &DatabaseManager::openDatabaseSlot);
    connect(this, &DatabaseManager::closeDatabase, this, &DatabaseManager::closeDatabaseSlot);
    connect(this, &DatabaseManager::getChatMessage, this, &DatabaseManager::getChatMessageSlot);
    connect(this, &DatabaseManager::insertChatMessage, this, &DatabaseManager::insertChatMessageSlot);
    moveToThread(thread);
    thread->start();
}

void DatabaseManager::initDatabaseSlot()
{
    m_database = QSqlDatabase::addDatabase("QSQLITE");
    m_database.setDatabaseName(QDir::homePath() + "/MChat/ChatRecord" + "/MSG" + ChatManager::instance()->username() + ".db");
    m_database.setUserName("MChat");
    m_database.setHostName("localhost");
    m_database.setPassword("123456");
}

DatabaseManager::~DatabaseManager()
{
    closeDatabaseSlot();
}

bool DatabaseManager::tableExist(const QString &tableName)
{
    if (!m_database.isOpen())
        openDatabaseSlot();

    QString query_create = "CREATE TABLE IF NOT EXISTS " + tableName +
                           "("
                           "  msg_index          int         NOT NULL PRIMARY KEY,"
                           "  msg_sender         varchar(10) NOT NULL,"
                           "  msg_datetime       datetime    NOT NULL,"
                           "  msg_chatMessage    text        NOT NULL, "
                           "  msg_state          int         NOT NULL"
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
        closeDatabaseSlot();
        return -1;
    }
}

QString DatabaseManager::getTableName(const QString &username)
{
    return "Message" + username;
}

void DatabaseManager::openDatabaseSlot()
{
    QString recordPath = QDir::homePath() + "/MChat/ChatRecord";
    if (!QFile::exists(recordPath))
    {
        QDir dir;
        dir.mkpath(recordPath);
    }

    if (!m_database.isOpen())
    {
        if (m_database.open())
            return;
        else
        {
            qDebug() << __func__ << m_database.lastError().text();
        }
    }
}

void DatabaseManager::closeDatabaseSlot()
{
    if (m_database.isOpen())
        m_database.close();
}

void DatabaseManager::insertChatMessageSlot(const QString &username, ChatMessage *chatMessage)
{
    QString tableName = getTableName(username);
    if (tableExist(tableName))
    {
        QString query_insert = "INSERT INTO " + tableName + " VALUES(?, ?, ?, ?, ?);";
        QSqlQuery query(m_database);
        int index = getTableSize(tableName) + 1; //当前消息的索引
        query.prepare(query_insert);
        query.addBindValue(index);
        query.addBindValue(chatMessage->sender());
        query.addBindValue(chatMessage->dateTime());
        query.addBindValue(chatMessage->message());
        query.addBindValue((int)chatMessage->state());
        if (query.exec())
        {
            /*qDebug() << "消息" << chatMessage->message() << "插入成功"
                     << "sender :" << chatMessage->sender()
                     << "时间 :" << chatMessage->dateTime();*/
            closeDatabaseSlot();
        }
        else
        {
            qDebug() << __func__ << query.lastError().text();
            closeDatabaseSlot();
        }
    }
}

void DatabaseManager::getChatMessageSlot(const QString &username, int count, ChatMessageList *chatMessageList)
{
    QString tableName = getTableName(username);
    if (tableExist(tableName))
    {
        QSqlQuery query(m_database);
        int index = getTableSize(tableName); //得到最后一条消息的索引
        if (index <= count)                  //如果消息数量不够，就取出所有
            count = index;
        QString select = QString("SELECT msg_index, msg_sender, msg_datetime, msg_chatMessage, msg_state FROM " + tableName +
                                 " WHERE msg_index BETWEEN %1 AND %2").arg(index - count + 1).arg(index);
        if (query.exec(select))
        {
            while (query.next())
            {
                QString sender = query.value(1).toString();
                QString datetime = query.value(2).toString();
                QString data = query.value(3).toString();
                ChatMessageStatus::Status state = (ChatMessageStatus::Status)query.value(4).toInt();

                ChatMessage chatMessage;
                chatMessage.setSender(sender);
                chatMessage.setDateTime(datetime);
                chatMessage.setMessage(data);
                chatMessage.setState(state);
                QMetaObject::invokeMethod(chatMessageList, "append", Q_ARG(ChatMessage, chatMessage));  //跨线程使用这个
            }
            closeDatabaseSlot();
        }
        else
        {
            qDebug() << __func__ << query.lastError().text();
            closeDatabaseSlot();
        }
    }
}
