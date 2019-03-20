#ifndef CHATAPI_H
#define CHATAPI_H

#include <QCursor>
#include <QObject>

class QQuickTextDocument;
class Api : public QObject
{
    Q_OBJECT

public:
    Api(QObject *parent = nullptr);

    Q_INVOKABLE bool exists(const QString &arg);
    Q_INVOKABLE QString baseName(const QString &arg);
    Q_INVOKABLE QString grayImage(const QString &src);
    Q_INVOKABLE QString toPlainText(QQuickTextDocument *doc);

public slots:
    QPoint cursorPosition();
};


#endif // CHATAPI_H
