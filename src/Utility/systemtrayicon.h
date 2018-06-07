#ifndef SYSTEMTRAYICON_H
#define SYSTEMTRAYICON_H

#include <QAction>
#include <QQuickItem>
#include <QSystemTrayIcon>

class MyAction : public QAction
{
    Q_OBJECT

    Q_PROPERTY(QString icon READ icon WRITE setIcon NOTIFY iconChanged)

public:
    MyAction(QObject *parent = nullptr);
    ~MyAction();

    QString icon() const;

public slots:
    void setIcon(const QString &arg);

signals:
    void iconChanged(const QString &arg);

private:
    QString m_icon;
};


class MySeparator : public QObject
{
public:
    MySeparator(QObject *parent = nullptr);
    ~MySeparator();
};

class SystemTray;
class MyMenu : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(int width READ width WRITE setWidth NOTIFY widthChanged)
    Q_PROPERTY(int height READ height WRITE setHeight NOTIFY heightChanged)
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)

public:
    MyMenu(QQuickItem *parent = nullptr);
    ~MyMenu();

    int width() const;
    int height() const;
    QString text() const;
    void clear();

public slots:
    void setWidth(int arg);
    void setHeight(int arg);
    void setText(const QString &arg);
    void addSeparator();
    void addAction(MyAction *action);
    void addMenu(MyMenu *menu);

protected:
    void componentComplete();

signals:
    void widthChanged(int arg);
    void heightChanged(int arg);
    void textChanged(const QString &arg);

private:
    friend class SystemTrayIcon;    //让SystemTray能够直接访问m_menu
    QMenu *m_menu;
};

class SystemTrayIcon : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(int x READ x CONSTANT)
    Q_PROPERTY(int y READ y CONSTANT)
    Q_PROPERTY(QString icon READ icon WRITE setIcon NOTIFY iconChanged)
    Q_PROPERTY(QString toolTip READ toolTip WRITE setToolTip NOTIFY toolTipChanged)
    Q_PROPERTY(MyMenu* menu READ menu WRITE setMenu NOTIFY menuChanged)

public:
    SystemTrayIcon(QQuickItem *parent = nullptr);
    ~SystemTrayIcon();

    int x() const;
    int y() const;
    QString icon() const;
    QString toolTip() const;
    MyMenu* menu() const;

public slots:
    void setIcon(const QString &arg);
    void setToolTip(const QString &arg);
    void setMenu(MyMenu *arg);
    void onVisibleChanged();
    void onActivated(QSystemTrayIcon::ActivationReason reason);
    void onExit();

signals:
    void trigger();
    void iconChanged(const QString &arg);
    void toolTipChanged(const QString &arg);
    void menuChanged(MyMenu *arg);
    void mouseHovered();
    void mouseExited();

protected:
    void timerEvent(QTimerEvent *event);

private:
    QSystemTrayIcon *m_systemTray;
    MyMenu *m_menu;
    QString m_toolTip;
    QString m_icon;
};

#endif // SYSTEMTRAYICON_H
