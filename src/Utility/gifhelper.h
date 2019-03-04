#ifndef GIFHELPER_H
#define GIFHELPER_H

#include <QMovie>

class GifHelper : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString cachePath READ cachePath WRITE setCachePath NOTIFY cachePathChanged)

public:
    GifHelper(QObject *parent = nullptr);
    ~GifHelper();

    QString cachePath() const;

    Q_INVOKABLE void addGif(QString gif);
    Q_INVOKABLE void cleanup();

signals:
    void cachePathChanged(const QString &path);
    void updateGif(const QString &oldData, const QString &newData);

public slots:
    void setCachePath(const QString &path);

private slots:
    void disposeFrame(int frameNumber);

private:
    QList<QMovie *> m_gifList;
    QString m_cachePath;
    QString m_gifText;
};

#endif // GIFHELPER_H
