#ifndef FRAMELESSWINDOW_H
#define FRAMELESSWINDOW_H

#include <QQuickWindow>

class FramelessWindow : public QQuickWindow
{
    Q_OBJECT

    Q_PROPERTY(QString windowIcon READ windowIcon WRITE setWindowIcon NOTIFY windowIconChanged)
    Q_PROPERTY(QPoint coord READ coord WRITE setCoord NOTIFY coordChanged)
    Q_PROPERTY(int width READ width WRITE setWidth NOTIFY widthChanged)
    Q_PROPERTY(int height READ height WRITE setHeight NOTIFY heightChanged)
    Q_PROPERTY(int actualWidth READ actualWidth WRITE setActualWidth NOTIFY actualWidthChanged)
    Q_PROPERTY(int actualHeight READ actualHeight WRITE setActualHeight NOTIFY actualHeightChanged)
    Q_PROPERTY(int minimumWidth READ minimumWidth WRITE setMinimumWidth NOTIFY minimumWidthChanged)
    Q_PROPERTY(int minimumHeight READ minimumHeight WRITE setMinimumHeight NOTIFY minimumHeightChanged)
    Q_PROPERTY(int maximumWidth READ maximumWidth WRITE setMaximumWidth NOTIFY maximumWidthChanged)
    Q_PROPERTY(int maximumHeight READ maximumHeight WRITE setMaximumHeight NOTIFY maximumHeightChanged)
    Q_PROPERTY(bool mousePenetrate READ mousePenetrate WRITE setMousePenetrate NOTIFY mousePenetrateChanged)
    //是否穿透鼠标
    Q_PROPERTY(bool topHint READ topHint WRITE setTopHint NOTIFY topHintChanged)    //是否显示在最前
    Q_PROPERTY(bool taskbarHint READ taskbarHint WRITE setTaskbarHint NOTIFY taskbarHintChanged)

public:
    FramelessWindow(QQuickWindow *parent = nullptr);
    ~FramelessWindow();

    QString windowIcon() const;
    QPoint coord() const;
    int width() const;
    int height() const;
    int actualWidth() const;
    int actualHeight() const;
    int minimumWidth() const;
    int minimumHeight() const;
    int maximumWidth() const;
    int maximumHeight() const;
    bool mousePenetrate() const;
    bool topHint() const;
    bool taskbarHint() const;

public slots:
    void setWindowIcon(const QString &arg);
    void setCoord(const QPoint &arg);
    void setWidth(int arg);
    void setHeight(int arg);
    void setActualWidth(int arg);
    void setActualHeight(int arg);
    void setMinimumWidth(int arg);
    void setMinimumHeight(int arg);
    void setMaximumWidth(int arg);
    void setMaximumHeight(int arg);
    void setMousePenetrate(bool arg);
    void setTopHint(bool arg);
    void setTaskbarHint(bool arg);
    void close();

signals:
    void windowIconChanged(const QString &arg);
    void coordChanged(const QPoint &arg);
    void widthChanged(int arg);
    void heightChanged(int arg);
    void actualWidthChanged(int arg);
    void actualHeightChanged(int arg);
    void minimumWidthChanged(int arg);
    void minimumHeightChanged(int arg);
    void maximumWidthChanged(int arg);
    void maximumHeightChanged(int arg);
    void mousePenetrateChanged();
    void topHintChanged();
    void taskbarHintChanged();
    void entered();
    void exited();
    void closed();

protected:
    bool event(QEvent *ev);

private:
    int m_width;
    int m_height;
    QString m_windowIcon;
    int m_minimumWidth;
    int m_minimumHeight;
    int m_maximumWidth;
    int m_maximumHeight;
    bool m_mousePenetrate;
    bool m_topHint;
    bool m_taskbarHint;
};

#endif // FRAMELESSWINDOW_H
