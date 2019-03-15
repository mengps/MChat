#include "imagehelper.h"

#include <QFile>
#include <QFileInfo>
#include <QQmlFile>
#include <QQuickTextDocument>
#include <QDebug>

ImageHelper::ImageHelper(QObject *parent)
    : QObject(parent),
      m_maxWidth(120),
      m_maxHeight(120)
{

}

ImageHelper::~ImageHelper()
{
    cleanup();
}

void ImageHelper::insertImage(const QUrl &url)
{
    QImage image = QImage(QQmlFile::urlToLocalFileOrQrc(url));
    if (image.isNull())
    {
        qDebug() << "不支持的图像格式";
        return;
    }
    QString filename = url.toString();
    int width = qMin(m_maxWidth, image.width());
    int height = qMin(m_maxHeight, image.height());
    if (filename.left(3) == "qrc")  //
    {
        width = 25;
        height = 25;
    }
    QString suffix = QFileInfo(filename).suffix();
    if (suffix == "GIF" || suffix == "gif") //如果是gif，则单独处理
    {
        QString gif = toLocalFileName(filename);
        textCursor().insertHtml("<img src='" + url.toString() + "' width = " +
                                QString::number(width) + " height = " +
                                QString::number(height) + "/>");
        textDocument()->addResource(QTextDocument::ImageResource, url, image);
        if (m_urls.contains(url))
            return;
        else
        {
            QMovie *movie = new QMovie(gif);
            movie->setCacheMode(QMovie::CacheNone);
            connect(movie, &QMovie::finished, movie, &QMovie::start);   //循环播放
            connect(movie, &QMovie::frameChanged, this, [url, this](int)
            {
                QMovie *movie = qobject_cast<QMovie *>(sender());
                textDocument()->addResource(QTextDocument::ImageResource, url, movie->currentPixmap());
                emit needUpdate();
            });
            m_urls[url] = movie;
            movie->start();
        }
    }
    else
    {
        QTextImageFormat format;
        format.setName(filename);
        format.setWidth(width);
        format.setHeight(height);
        textCursor().insertImage(format, QTextFrameFormat::InFlow);
    }
}

void ImageHelper::processImage(const QString &text)
{
    QRegExp imgReg("<img src\\s*=\\s*['\"]([^'\"]*)['\"]");
    QString str = text;
    QStringList list;
    int pos = 0;
    while ((pos = imgReg.indexIn(str, pos)) != -1)
    {
        auto cap = imgReg.capturedTexts().at(0);
        if (cap.contains("qrc:/"))
        {
            cap = cap.mid(cap.indexOf("qrc:/"));
            cap = cap.left(cap.length() - 1);   //末尾有一个'/"
            if (!list.contains(cap))
                list << cap;
        }
        else if (cap.contains("file:/"))
        {
            cap = cap.mid(cap.indexOf("file:/"));
            cap = cap.left(cap.length() - 1);
            if (!list.contains(cap))
                list << cap;
        }
        pos += imgReg.matchedLength();
    }

    for (auto it : list)
    {
        QString suffix = QFileInfo(it).suffix();
        if (suffix == "GIF" || suffix == "gif")     //如果是gif，则单独处理
        {
            QUrl url = QUrl(it);
            if (m_urls.contains(url))
                return;
            else
            {
                QString gif = toLocalFileName(it);
                QMovie *movie = new QMovie(gif);
                movie->setCacheMode(QMovie::CacheNone);
                connect(movie, &QMovie::finished, movie, &QMovie::start);   //循环播放
                connect(movie, &QMovie::frameChanged, this, [url, this](int)
                {
                    QMovie *movie = qobject_cast<QMovie *>(sender());
                    textDocument()->addResource(QTextDocument::ImageResource, url, movie->currentPixmap());
                    emit needUpdate();
                });
                m_urls[url] = movie;
                movie->start();
            }
        }
    }
}

void ImageHelper::cleanup()
{
    for (auto it : m_urls)
        it->deleteLater();
    m_urls.clear();
}

QQuickTextDocument* ImageHelper::document() const
{
    return  m_document;
}

void ImageHelper::setDocument(QQuickTextDocument *document)
{
    if (document != m_document)
    {
        m_document = document;
        emit documentChanged();
    }
}

int ImageHelper::cursorPosition() const
{
    return m_cursorPosition;
}

void ImageHelper::setCursorPosition(int position)
{
    if (position != m_cursorPosition)
    {
        m_cursorPosition = position;
        emit cursorPositionChanged();
    }
}

int ImageHelper::selectionStart() const
{
    return m_selectionStart;
}

void ImageHelper::setSelectionStart(int position)
{
    if (position != m_selectionStart)
    {
        m_selectionStart = position;
        emit selectionStartChanged();
    }
}

int ImageHelper::selectionEnd() const
{
    return m_selectionEnd;
}

void ImageHelper::setSelectionEnd(int position)
{
    if (position != m_selectionEnd)
    {
        m_selectionEnd = position;
        emit selectionEndChanged();
    }
}

int ImageHelper::maxWidth() const
{
    return m_maxWidth;
}

void ImageHelper::setMaxWidth(int max)
{
    if (max != m_maxWidth)
    {
        m_maxWidth = max;
        emit maxWidthChanged();
    }
}

int ImageHelper::maxHeight() const
{
    return m_maxHeight;
}

void ImageHelper::setMaxHeight(int max)
{
    if (max != m_maxHeight)
    {
        m_maxHeight = max;
        emit maxHeightChanged();
    }
}

QTextDocument* ImageHelper::textDocument() const
{
    if (m_document)
        return m_document->textDocument();
    else return nullptr;
}

QTextCursor ImageHelper::textCursor() const
{
    QTextDocument *doc = textDocument();
    if (!doc)
        return QTextCursor();

    QTextCursor cursor = QTextCursor(doc);
    if (m_selectionStart != m_selectionEnd)
    {
        cursor.setPosition(m_selectionStart);
        cursor.setPosition(m_selectionEnd, QTextCursor::KeepAnchor);
    }
    else
    {
        cursor.setPosition(m_cursorPosition);
    }

    return cursor;
}

QString ImageHelper::toLocalFileName(QString name)
{
    if (name.left(4) == "file")
        name = name.mid(8);
    else if (name.left(3) == "qrc")
        name = name.mid(3);

    return name;
}
