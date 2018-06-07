#ifndef CHATAPI_H
#define CHATAPI_H
#include <QObject>
#include <QCursor>

class Api : public QObject
{
    Q_OBJECT

public:
    Api(QObject *parent = nullptr);

    Q_INVOKABLE bool exists(const QString &arg);
    Q_INVOKABLE QString baseName(const QString &arg);

public slots:
    QPoint cursorPosition();
};


#endif // CHATAPI_H
