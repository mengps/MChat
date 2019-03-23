#include "chatapi.h"
#include "chatmanager.h"

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

QString Api::grayImage(const QString &src, const QString &name)
{
    QImage image(QQmlFile::urlToLocalFileOrQrc(src));
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
        QString dstPath = QDir::homePath() + "/MChat/Settings/" +
                ChatManager::instance()->username() + "/headImage/gray_" + name + info.fileName();
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
