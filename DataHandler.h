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
} Tcalldata;


class DataHandler : public QObject {
    Q_OBJECT
public:
    DataHandler(QObject *parent = 0);
    ~DataHandler();
public slots:
     int NoOfEntries();
     QString GetData (int nr,int tcdentry);
     int ReadCallData();
private:
     std::vector<Tcalldata> callsdb;
     QString GetContact(QString cont);
     QSqlDatabase db;
     QString querystr[6];
/*signals:
    void DHChanged();*/
};

#endif // DATAHANDLER_H
