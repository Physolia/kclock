#ifndef TIMER_H
#define TIMER_H

#include <QObject>
#include <QUuid>

#include "timerinterface.h"
class Timer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int length READ length WRITE setLength NOTIFY propertyChanged)
    Q_PROPERTY(int elapsed READ elapsed NOTIFY propertyChanged)
    Q_PROPERTY(QString lengthPretty READ lengthPretty NOTIFY propertyChanged)
    Q_PROPERTY(QString elapsedPretty READ elapsedPretty NOTIFY propertyChanged)
    Q_PROPERTY(QString label READ label WRITE setLabel NOTIFY propertyChanged)
    Q_PROPERTY(bool running READ running NOTIFY propertyChanged)

public:
    Timer();
    explicit Timer(QString uuid);
    const QUuid &uuid()
    {
        return m_uuid;
    };
    Q_INVOKABLE void toggleRunning()
    {
        m_interface->toggleRunning();
    };
    Q_INVOKABLE void reset()
    {
        m_interface->reset();
    };

    QString lengthPretty() const
    {
        qint64 len = m_length, hours = len / 60 / 60, minutes = len / 60 - hours * 60, seconds = len - hours * 60 * 60 - minutes * 60;
        return QString::number(hours) + ":" + QString::number(minutes).rightJustified(2, '0') + ":" + QString::number(seconds).rightJustified(2, '0');
    }
    QString elapsedPretty() const
    {
        qint64 len = m_elapsed, hours = len / 60 / 60, minutes = len / 60 - hours * 60, seconds = len - hours * 60 * 60 - minutes * 60;
        return QString::number(hours) + ":" + QString::number(minutes).rightJustified(2, '0') + ":" + QString::number(seconds).rightJustified(2, '0');
    }
    int length() const
    {
        return m_length;
    }
    void setLength(int length)
    {
        m_interface->setLength(length);
    }
    const int &elapsed() const
    {
        return m_elapsed;
    }
    const QString &label() const
    {
        return m_label;
    }
    void setLabel(QString label)
    {
        m_interface->setLabel(label);
    }
    const bool &running() const
    {
        return m_running;
    }

signals:
    void propertyChanged();
private slots:
    void updateLength();
    void updateLabel();
    void updateRunning();

private:
    int m_length, m_elapsed; // seconds
    QString m_label;
    bool m_running;

    QUuid m_uuid;
    org::kde::kclock::Timer *m_interface;
};

#endif // TIMER_H
