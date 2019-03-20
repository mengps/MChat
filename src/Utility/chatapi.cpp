#include "chatapi.h"

#include <QDir>
#include <QImage>
#include <QQmlFile>
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

QString Api::grayImage(const QString &src)
{
    QImage image(QQmlFile::urlToLocalFileOrQrc(src));
    qDebug() << src << image;
    if (!image.isNull())
    {
        int width = image.width();
        int height = image.height();
        QRgb color;
        int gray;
        for (int x = 0; x < width; x++)
        {
            for (int y = 0; y < height; y++)
            {
                color = image.pixel(x, y);
                gray = qGray(color);
                image.setPixel(x, y, qRgba(gray, gray, gray, qAlpha(color)));
            }
        }
        QFileInfo info(QQmlFile::urlToLocalFileOrQrc(src));
        QString dstPath = info.absolutePath() + "/gray_" + info.fileName();
        image.save(dstPath);

        return "file:///" + dstPath;
    }
    else return src;
}

QString Api::toPlainText(QQuickTextDocument *doc)
{
    return doc->textDocument()->toPlainText();
}

QPoint Api::cursorPosition()
{
    return QCursor::pos();
}
