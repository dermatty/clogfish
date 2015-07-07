#ifndef DATAHANDLER_H
#include <QObject>
#include <QtQuick>
#include <QtSql>
#include <QDebug>


#define DATAHANDLER_H

typedef struct {
    QString starttime;
    QString endtime;
    QString contactname;
    QString number;
    QString direction;
    QString duration;
    QString startdate;
    bool overlength;
    QString startday;
    QString startclock;
} Tcalldata;


class DataHandler : public QObject {
    Q_OBJECT
public:
    DataHandler(QObject *parent = 0);
    ~DataHandler();
public slots:
     int NoOfEntries();
     QString GetData (int nr,QString tcdentry);
     int ReadCallData();

private:

     int max(int a, int b);
     std::vector<Tcalldata> callsdb;
     QString GetContact(QString cont, bool overl0);
     QSqlDatabase db;
/*signals:
    void DHChanged();*/
};

#endif // DATAHANDLER_H
