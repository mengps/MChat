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
    //是否穿透鼠标
    Q_PROPERTY(bool mousePenetrate READ mousePenetrate WRITE setMousePenetrate NOTIFY mousePenetrateChanged)
    //是否显示在最前
    Q_PROPERTY(bool topHint READ topHint WRITE setTopHint NOTIFY topHintChanged)
    Q_PROPERTY(bool taskbarHint READ taskbarHint WRITE setTaskbarHint NOTIFY taskbarHintChanged)

public:
    FramelessWindow(QQuickWindow *parent = nullptr);
    ~FramelessWindow();

    QString windowIcon() const;
    void setWindowIcon(const QString &arg);

    QPoint coord() const;
    void setCoord(const QPoint &arg);

    int width() const;
    void setWidth(int arg);

    int height() const;
    void setHeight(int arg);

    int actualWidth() const;
    void setActualWidth(int arg);

    int actualHeight() const;
    void setActualHeight(int arg);

    int minimumWidth() const;
    void setMinimumWidth(int arg);

    int minimumHeight() const;
    void setMinimumHeight(int arg);

    int maximumWidth() const;
    void setMaximumWidth(int arg);

    int maximumHeight() const;
    void setMaximumHeight(int arg);

    bool mousePenetrate() const;
    void setMousePenetrate(bool arg);

    bool topHint() const;
    void setTopHint(bool arg);

    bool taskbarHint() const;
    void setTaskbarHint(bool arg);

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

public slots:
    void close();

protected:
    bool event(QEvent *ev);

private:
    QString m_windowIcon;
    int m_width;
    int m_height;
    int m_minimumWidth;
    int m_minimumHeight;
    int m_maximumWidth;
    int m_maximumHeight;
    bool m_mousePenetrate;
    bool m_topHint;
    bool m_taskbarHint;
};

#endif // FRAMELESSWINDOW_H
