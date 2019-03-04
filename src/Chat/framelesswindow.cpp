#include "framelesswindow.h"
#include <QQuickItem>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

FramelessWindow::FramelessWindow(QQuickWindow *parent)
    : QQuickWindow(parent)
{
    m_minimumWidth = 0;
    m_minimumHeight = 0;
    m_maximumWidth = 9999;
    m_maximumHeight = 9999;
    m_mousePenetrate = false;
    m_topHint = false;
    m_taskbarHint = false;

    setFlags(flags() | Qt::Tool | Qt::FramelessWindowHint);
    setColor(Qt::transparent);

/*#if defined(Q_OS_WIN)
    HWND hwnd = reinterpret_cast<HWND>(winId());
    DWORD class_style = ::GetClassLong(hwnd, GCL_STYLE);
    class_style &= ~CS_DROPSHADOW;
    ::SetClassLong(hwnd, GCL_STYLE, class_style); // windows系统函数
#endif*/
}

FramelessWindow::~FramelessWindow()
{

}

QString FramelessWindow::windowIcon() const
{
    return m_windowIcon;
}

QPoint FramelessWindow::coord() const
{
    return QPoint(x(), y());
}

int FramelessWindow::width() const
{
    return m_width;
}

int FramelessWindow::height() const
{
    return m_height;
}

int FramelessWindow::actualWidth() const
{
    return QQuickWindow::width();
}

int FramelessWindow::actualHeight() const
{
    return QQuickWindow::height();
}

int FramelessWindow::minimumWidth() const
{
    return m_minimumWidth;
}

int FramelessWindow::minimumHeight() const
{
    return m_minimumHeight;
}

int FramelessWindow::maximumWidth() const
{
    return m_maximumWidth;
}

int FramelessWindow::maximumHeight() const
{
    return m_maximumHeight;
}

bool FramelessWindow::mousePenetrate() const
{
    return m_mousePenetrate;
}

bool FramelessWindow::topHint() const
{
    return m_topHint;
}

bool FramelessWindow::taskbarHint() const
{
    return m_taskbarHint;
}

void FramelessWindow::setWindowIcon(const QString &arg)
{
    if (m_windowIcon != arg)
    {
        setIcon(QIcon(arg));
        m_windowIcon = arg;
        emit windowIconChanged(arg);
    }
}

void FramelessWindow::setCoord(const QPoint &arg)
{
    if (coord() != arg)
    {
        setX(arg.x());
        setY(arg.y());
        emit coordChanged(arg);
    }
}

void FramelessWindow::setWidth(int arg)
{
    if (arg <= m_maximumWidth && arg >= m_minimumWidth)
    {
        m_width = arg;
        contentItem()->setWidth(arg);
        emit widthChanged(arg);
    }
}

void FramelessWindow::setHeight(int arg)
{
    if (arg <= m_maximumHeight && arg >= m_minimumHeight)
    {
        m_height = arg;
        contentItem()->setHeight(arg);
        emit heightChanged(arg);
    }
}

void FramelessWindow::setActualWidth(int arg)
{
    if (actualWidth() != arg)
    {
        QQuickWindow::setWidth(arg);
        emit actualWidthChanged(arg);
    }
}

void FramelessWindow::setActualHeight(int arg)
{
    if (actualHeight() != arg)
    {
        QQuickWindow::setHeight(arg);
        emit actualHeightChanged(arg);
    }
}

void FramelessWindow::setMinimumWidth(int arg)
{
    if (m_minimumWidth != arg)
    {
        m_minimumWidth = arg;
        emit minimumWidthChanged(arg);
    }
}

void FramelessWindow::setMinimumHeight(int arg)
{
    if (m_minimumHeight != arg)
    {
        m_minimumHeight = arg;
        emit minimumHeightChanged(arg);
    }
}

void FramelessWindow::setMaximumWidth(int arg)
{
    if (m_maximumWidth != arg)
    {
        m_maximumWidth = arg;
        emit maximumWidthChanged(arg);
    }
}

void FramelessWindow::setMaximumHeight(int arg)
{
    if (m_maximumHeight != arg)
    {
        m_maximumHeight = arg;
        emit maximumHeightChanged(arg);
    }
}

void FramelessWindow::setMousePenetrate(bool arg)
{
    if (m_mousePenetrate != arg)
    {
#if defined(Q_OS_WIN)
        HWND my_hwnd = (HWND)this->winId ();
        if(arg)
        {
            SetWindowLong(my_hwnd, GWL_EXSTYLE,
                         GetWindowLong(my_hwnd, GWL_EXSTYLE) | WS_EX_TRANSPARENT);
        }
        else
        {
            SetWindowLong(my_hwnd, GWL_EXSTYLE,
                         GetWindowLong(my_hwnd, GWL_EXSTYLE)&(~WS_EX_TRANSPARENT));
        }
#endif
        m_mousePenetrate = arg;
        emit mousePenetrateChanged();
    }
}

void FramelessWindow::setTopHint(bool arg)
{
    if (m_topHint != arg)
    {
        if (arg)
            setFlags(flags() | Qt::WindowStaysOnTopHint);
        else
            setFlags(flags() & ~Qt::WindowStaysOnTopHint);
        m_topHint = arg;
        emit topHintChanged();
    }
}

void FramelessWindow::setTaskbarHint(bool arg)
{
    if (m_taskbarHint != arg)
    {
        if(arg)
            setFlags(flags() & (~Qt::Tool) | Qt::Window);
        else
            setFlags(flags() | Qt::Tool);
        m_taskbarHint = arg;
        emit taskbarHintChanged();
    }
}

void FramelessWindow::close()
{
    emit closed();
    deleteLater();
}

bool FramelessWindow::event(QEvent *ev)
{
    if (ev->type() == QEvent::Enter)     //鼠标进入
    {
        emit entered();
    }
    else if (ev->type() == QEvent::Leave)    //鼠标离开
    {
        emit exited();
    }

    return QQuickWindow::event(ev);
}
