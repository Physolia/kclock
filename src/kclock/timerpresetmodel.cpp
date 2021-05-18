// SPDX-FileCopyrightText: 2021 Swapnil Tripathi <swapnil06.st@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "timerpresetmodel.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

/* ~ TimerPreset ~ */
TimerPreset::TimerPreset(QObject *parent, const QString &presetName, int presetDuration)
    : QObject(parent)
    , m_presetName(presetName)
    , m_presetDuration(presetDuration)
{
}
TimerPreset::TimerPreset(const QJsonObject &obj)
    : m_presetName(obj["presetName"].toString())
    , m_presetDuration(obj["presetDuration"].toInt())
{
}

TimerPreset::~TimerPreset()
{
}

QJsonObject TimerPreset::toJson() const
{
    QJsonObject obj;
    obj["presetName"] = m_presetName;
    obj["presetDuration"] = m_presetDuration;
    return obj;
}

void TimerPreset::setPresetName(const QString &presetName)
{
    m_presetName = presetName;
    emit propertyChanged();
}

void TimerPreset::setDurationLength(int presetDuration)
{
    m_presetDuration = presetDuration;
    emit propertyChanged();
}

/* - TimerPresetModel - */

TimerPresetModel::TimerPresetModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_settings = new QSettings(parent);
    load();
}

TimerPresetModel::~TimerPresetModel()
{
    save();
    delete m_settings;

    qDeleteAll(m_presets);
}

void TimerPresetModel::load()
{
    QJsonDocument doc = QJsonDocument::fromJson(m_settings->value(QStringLiteral("presets")).toString().toUtf8());

    const auto array = doc.array();
    std::transform(array.begin(), array.end(), std::back_inserter(m_presets), [](const QJsonValue &pre) {
        return new TimerPreset(pre.toObject());
    });
}

void TimerPresetModel::save()
{
    QJsonArray arr;

    const auto presets = qAsConst(m_presets);
    std::transform(presets.begin(), presets.end(), std::back_inserter(arr), [](const TimerPreset *preset) {
        return QJsonValue(preset->toJson());
    });

    m_settings->setValue(QStringLiteral("presets"), QString(QJsonDocument(arr).toJson(QJsonDocument::Compact)));
}

QHash<int, QByteArray> TimerPresetModel::roleNames() const
{
    return {{Roles::TimerPresetRole, "preset"}};
}

QVariant TimerPresetModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_presets.count() || index.row() < 0)
        return {};

    auto *preset = m_presets.at(index.row());
    if (role == Roles::TimerPresetRole)
        return QVariant::fromValue(preset);

    return {};
}

int TimerPresetModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_presets.count();
}

void TimerPresetModel::insertPreset(QString presetName, int presetDuration)
{
    Q_EMIT beginInsertRows({}, 0, 0);
    m_presets.insert(0, new TimerPreset(this, presetName, presetDuration));
    Q_EMIT endInsertRows();

    save();
}

void TimerPresetModel::deletePreset(const int index)
{
    beginRemoveRows({}, index, index);
    m_presets.removeAt(index);
    endRemoveRows();

    save();
}
