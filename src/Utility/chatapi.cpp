#include "chatapi.h"
#include <QDir>
#include <QQuickTextDocument>

Api::Api(QObject *parent)
    : QObject(parent)
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

QString Api::toPlainText(QQuickTextDocument *doc)
{
    return doc->textDocument()->toPlainText();
}

QPoint Api::cursorPosition()
{
    return QCursor::pos();
}
