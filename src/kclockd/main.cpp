/*
 * Copyright 2020 Han Young <hanyoung@protonmail.com>
 * Copyright 2020 Devin Lin <espidev@gmail.com>
 * Copyright 2019 Nick Reitemeyer <nick.reitemeyer@web.de>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "alarmmodel.h"
#include "kclockdsettings.h"
#include "kclocksettingsadaptor.h"
#include "timermodel.h"

#include <KAboutData>
#include <KConfig>
#include <KLocalizedContext>
#include <KLocalizedString>

#include <QApplication>
#include <QCommandLineParser>

#include <KDBusService>

QCommandLineParser *createParser()
{
    QCommandLineParser *parser = new QCommandLineParser;
    parser->addOption(QCommandLineOption(QStringLiteral("no-powerdevil"), i18n("Don't use PowerDevil for alarms if it is available")));
    parser->addHelpOption();
    return parser;
};

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    KLocalizedString::setApplicationDomain("kclockd");
    KAboutData aboutData(QStringLiteral("kclockd"),
                         QStringLiteral("KClock daemon"),
                         QStringLiteral("1.0"),
                         QStringLiteral("KClock daemon"),
                         KAboutLicense::GPL,
                         i18n("© 2020-2021 KDE Community"));
    aboutData.addAuthor(i18n("Devin Lin"), QLatin1String(), QStringLiteral("devin@kde.org"));
    aboutData.addAuthor(i18n("Han Young"), QLatin1String(), QStringLiteral("hanyoung@protonmail.com"));
    KAboutData::setApplicationData(aboutData);

    // only allow one instance
    KDBusService service(KDBusService::Unique);

    // initialize models
    new KClockSettingsAdaptor(KClockSettings::self());
    QDBusConnection::sessionBus().registerObject(QStringLiteral("/Settings"), KClockSettings::self());

    // save config
    QObject::connect(KClockSettings::self(), &KClockSettings::timeFormatChanged, KClockSettings::self(), &KClockSettings::save);

    // start alarm polling
    AlarmModel::instance()->configureWakeups();
    TimerModel::instance();

    return app.exec();
}
