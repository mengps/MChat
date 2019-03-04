#include "systemtrayicon.h"
#include <QApplication>
#include <QMenu>
#include <QAction>

/*#ifdef Q_OS_WIN
#include <windows.h>
#include <windowsx.h>
#define WM_TRAYNOTIFY WM_USER + 1
#endif*/

MyAction::MyAction(QObject *parent)
    : QAction(parent)
{
    setObjectName("MyAction");
}

MyAction::~MyAction()
{

}

QString MyAction::icon() const
{
    return m_icon;
}

void MyAction::setIcon(const QString &arg)
{
    if(m_icon != arg)
    {
        QString str = arg;
        if( str.mid (0, 3) == "qrc")
            str = str.mid (3, str.count() - 3);
        QAction::setIcon(QIcon(str));
        m_icon = arg;
        emit iconChanged(arg);
    }
}

MySeparator::MySeparator(QObject *parent)
    : QObject(parent)
{
    setObjectName("MySeparator");
}

MySeparator::~MySeparator()
{

}

MyMenu::MyMenu(QQuickItem *parent)
    : QQuickItem(parent)
{
    setObjectName("MyMenu");
    m_menu = new QMenu();
}

MyMenu::~MyMenu()
{

}

int MyMenu::width() const
{
    return m_menu->width();
}

int MyMenu::height() const
{
    return m_menu->height();
}

QString MyMenu::text() const
{
    return m_menu->title();
}

void MyMenu::clear()
{
    m_menu->clear();
}

void MyMenu::setWidth(int arg)
{
    if (m_menu->width() != arg)
    {
        m_menu->setFixedWidth(arg);
        emit widthChanged(arg);
    }
}

void MyMenu::setHeight(int arg)
{
    if (m_menu->height() != arg)
    {
        m_menu->setFixedHeight(arg);
        emit heightChanged(arg);
    }
}

void MyMenu::setText(const QString &arg)
{
    if (m_menu->title() != arg)
    {
        m_menu->setTitle(arg);
        emit textChanged(arg);
    }
}

void MyMenu::addAction(MyAction *action)
{
    m_menu->addAction(action);
}

void MyMenu::addSeparator()
{
    m_menu->addSeparator();
}

void MyMenu::addMenu(MyMenu *menu)
{
    m_menu->addMenu(menu->m_menu);
}

void MyMenu::componentComplete()        //在菜单完成构建后调用，将自定义Action,Menu,Separator加入
{
    QQuickItem::componentComplete();
    QObjectList list = children();
    for (auto it : list)
    {
        if (it->objectName() == "MyAction")
        {
            MyAction *action = qobject_cast<MyAction *>(it);
            m_menu->addAction(action);
        }
        else if (it->objectName() == "MySeparator")
        {
            m_menu->addSeparator();
        }
        else if (it->objectName() == "MyMenu")
        {
            MyMenu *menu = qobject_cast<MyMenu *>(it);
            m_menu->addMenu(menu->m_menu);
        }
    }
}

SystemTrayIcon::SystemTrayIcon(QQuickItem *parent)
    : QQuickItem(parent)
{
    m_systemTray = new QSystemTrayIcon(this);

    connect(m_systemTray, &QSystemTrayIcon::activated, this, &SystemTrayIcon::onActivated);
    connect(this, &SystemTrayIcon::visibleChanged, this, &SystemTrayIcon::onVisibleChanged);

    startTimer(200);
    setVisible(false);          //给visible一个初始值，否则会不显示
}

SystemTrayIcon::~SystemTrayIcon()
{
    delete m_menu;
}

int SystemTrayIcon::x() const
{
    return m_systemTray->geometry().x();
}

int SystemTrayIcon::y() const
{
    return m_systemTray->geometry().y();
}

QString SystemTrayIcon::icon() const
{
    return m_icon;
}

QString SystemTrayIcon::toolTip() const
{
    return m_systemTray->toolTip();
}

MyMenu *SystemTrayIcon::menu() const
{
    return m_menu;
}

void SystemTrayIcon::setIcon(const QString &arg)
{
    if(m_icon != arg)
    {
        QString str = arg;
        if( str.mid (0, 3) == "qrc")
            str = str.mid (3, str.count() - 3);
        m_systemTray->setIcon(QIcon(str));
        m_icon = arg;
        emit iconChanged(arg);
    }
}

void SystemTrayIcon::setToolTip(const QString &arg)
{
    if (m_toolTip != arg)
    {
        m_systemTray->setToolTip(arg);
        m_toolTip = arg;
        emit toolTipChanged(arg);
    }
}

void SystemTrayIcon::setMenu(MyMenu *arg)
{
    if (m_menu != arg)
    {
        m_menu = arg;
        m_systemTray->setContextMenu(m_menu->m_menu);
        emit menuChanged(arg);
    }
}

void SystemTrayIcon::onVisibleChanged()
{
    m_systemTray->setVisible(isVisible());
}

void SystemTrayIcon::onActivated(QSystemTrayIcon::ActivationReason reason)
{
    switch (reason)
    {
    case QSystemTrayIcon::DoubleClick:
    case QSystemTrayIcon::Trigger:
        emit trigger();

    default:
        break;
    }
}

void SystemTrayIcon::onExit()
{
    m_systemTray->hide();
    deleteLater();
}

void SystemTrayIcon::timerEvent(QTimerEvent *event)
{
    Q_UNUSED(event)
    QPoint pos = QCursor::pos();
    if (m_systemTray->geometry().contains(pos))
        emit mouseHovered();
    else emit mouseExited();
}
