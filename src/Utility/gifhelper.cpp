#include <QDir>
#include <QDebug>
#include <QCursor>
#include <QApplication>
#include <QDesktopWidget>
#include "gifhelper.h"

GifHelper::GifHelper(QObject *parent)
    :   QObject(parent)
{
    m_cachePath = QDir::homePath() + "/MChat/CacheGif/";
}

GifHelper::~GifHelper()
{
    cleanup();
}

QString GifHelper::cachePath() const
{
    return m_cachePath;
}

void GifHelper::addGif(QString gif)
{
    int speed = 100;
    if (gif.left(4) == "file")
    {
        gif = gif.mid(8);
        speed = 60;     //插入的图片速度为0.6倍
    }
    else if (gif.left(3) == "qrc")  gif = gif.mid(3);

    QMovie *movie = new QMovie(gif, "");
    movie->setCacheMode(QMovie::CacheAll);
    movie->setSpeed(speed);
    connect(movie, &QMovie::finished, movie, &QMovie::start);   //循环播放
    connect(movie, &QMovie::frameChanged, this, &GifHelper::disposeFrame);
    m_gifList.append(movie);
    movie->jumpToFrame(0);  //开始前先缓存第一帧
    movie->start();
}

void GifHelper::cleanup()
{
    for (auto it : m_gifList)
            delete it;
    m_gifList.clear();
}

void GifHelper::disposeFrame(int frameNumber)
{
    QMovie *movie = qobject_cast<QMovie *>(sender());
    QString baseName = QFileInfo(movie->fileName()).baseName();
    QImage image = movie->currentImage();
    QString src = m_cachePath + baseName + "/" +
                    QString::number(frameNumber) + ".png";
    if (!QFile::exists(src))    //如果缓存图像不存在就缓存
    {
        QDir dir;
        dir.mkpath(m_cachePath + baseName + "/");
        image.save(src);
    }
    QString newData = baseName + "/" + QString::number(frameNumber) + ".png";
    QString oldData;
    if (frameNumber == 0)
        oldData = baseName + "/" + QString::number(movie->frameCount() - 1) + ".png";
    else oldData = baseName + "/" + QString::number(frameNumber - 1) + ".png";

    emit updateGif(oldData, newData);
}

void GifHelper::setCachePath(const QString &path)
{
    if (path != m_cachePath)
    {
        m_cachePath = path;
        emit cachePathChanged(path);
    }
}
