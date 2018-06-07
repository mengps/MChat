#include <QDir>
#include "chatapi.h"

Api::Api(QObject *parent)
    :   QObject(parent)
{
}

bool Api::exists(const QString &arg)
{
    return QFile::exists(arg);
}

QString Api::baseName(const QString &arg)
{
    return QFileInfo(arg).baseName();
}

QPoint Api::cursorPosition()
{
    return QCursor::pos();
}
