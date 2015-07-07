#include "DataHandler.h"

DataHandler::DataHandler (QObject *parent){
    db = QSqlDatabase::addDatabase( "QSQLITE" );
    ReadCallData();
 }

DataHandler::~DataHandler() {
    db.close();
}


int DataHandler::ReadCallData()
{
    Tcalldata tcd;
    QString dirstr;
    QString datestr0;
    QString timestr0;
    QDateTime s0,s1,s00;
    QDate dat0, dat1;

    db.setDatabaseName("/home/nemo/.local/share/commhistory/commhistory.db");
    if(!db.open())
        return -1;
    QSqlQuery query(db);
    query.exec("select startTime, endTime, remoteUid, direction,isMissedCall from Events where type=3 order by startTime desc;");
    //query.exec("SELECT datetime(startTime, 'unixepoch', 'localtime') as StartTime, datetime(endTime, 'unixepoch', 'localtime') as EndTime, remoteUid as Number, direction FROM Events WHERE type=3 and datetime(startTime, 'unixepoch', 'localtime') >= datetime('now','-30 day') ORDER BY startTime desc;");
    //query.first();
    int i=0;
    s00 = QDateTime::currentDateTime();
    dat0 = s00.date();
    callsdb.clear();

    if (query.isActive()) {
        callsdb.clear();
        while (query.next()) {
            int startTime = query.value(0).toInt();
            s0.setTime_t(startTime);
            dat1 = s0.date();
            tcd.overlength = false;
            if (dat0 == dat1)
                datestr0 = "Today00000";
            else if ((s00.date().day() -1 == s0.date().day()) && (s00.date().month() == s0.date().month()) && (s00.date().year() == s0.date().year()))
                datestr0 = "Yesterday0";
            else if (s00.date().weekNumber() == s0.date().weekNumber())
                datestr0 = s0.date().longDayName(s0.date().dayOfWeek());
            else {
                datestr0 = s0.date().longDayName(s0.date().dayOfWeek());
                datestr0 = datestr0.left(3) + " " + s0.date().toString("dd MMM");
                if (s00.date().year() != s0.date().year()) {
                    datestr0 = datestr0 + " " + s0.date().toString("yyyy");
                    tcd.overlength = true;
                }
            }
            timestr0 = QString::number(s0.time().hour()) + ":" + QString("%1").arg(s0.time().minute(),2,'g',-1,'0');
            //datestr0 = dat0.toString(Qt::SystemLocaleShortDate);
            qDebug() << timestr0;

            tcd.starttime = datestr0 + " " + timestr0;//s0.toString(Qt::SystemLocaleShortDate);
            tcd.startday = datestr0;
            tcd.startclock = timestr0;
            int endTime = query.value(1).toInt();
            s1.setTime_t(endTime);
            tcd.endtime = s1.toString(Qt::SystemLocaleShortDate);
            tcd.number=query.value(2).toString();
            tcd.contactname="";//GetContact(tcd.number);
            int direction = query.value(3).toInt();
            int isMissed = query.value(4).toInt();
            switch(direction) {
                case 1: dirstr = (isMissed == 1) ? "missed" : "incoming"; break;
                case 2: dirstr = "outgoing"; break;
                default: dirstr = "";
            }
            tcd.direction = dirstr;
            int msdiff = s0.secsTo(s1);
            int msmin = msdiff/60;
            int mssec = msdiff - msmin*60;
            tcd.duration = (msmin>0) ?  QString::number(msmin) + "m" + QString::number(mssec)+"s" : QString::number(mssec)+"s";
            callsdb.push_back(tcd);


        }
    }
   db.close();
   for (i=0;i<(int) callsdb.size();i++)
       callsdb[i].contactname=GetContact(callsdb[i].number,callsdb[i].overlength);
   return 0;
}

QString DataHandler::GetData(int entry,QString tcdentry) {

    if (entry>(int) callsdb.size()-1)
        return "";
    if (tcdentry == "starttime") return callsdb[entry].starttime;
    if (tcdentry == "endtime") return callsdb[entry].endtime;
    if (tcdentry == "contactname") return callsdb[entry].contactname;
    if (tcdentry == "number") return callsdb[entry].number;
    if (tcdentry == "direction") return callsdb[entry].direction;
    if (tcdentry == "duration") return callsdb[entry].duration;
    if (tcdentry == "startday") return callsdb[entry].startday;
    if (tcdentry == "startclock") return callsdb[entry].startclock;
    return "";
}



int DataHandler::NoOfEntries() {

    return (int) callsdb.size();
}

int DataHandler::max (int a, int b) {
    return ((a>b) ? a : b);
}

QString DataHandler::GetContact(QString cont, bool overl0) {
    db.setDatabaseName("/home/nemo/.local/share/system/Contacts/qtcontacts-sqlite/contacts.db");
    if(!db.open())
        return "N/A";
    QSqlQuery query(db);
    query.exec("select c.displayLabel from Contacts c join PhoneNumbers pn on pn.contactId=c.contactId where pn.phoneNumber='"+cont+"'");
    query.first();
    QString retstr = query.value(0).toString();
    // if not found, try some things:
    // 1: if e.g. "+43" --> make "0043"
    if (retstr=="" && cont[0]=='+') {
        QString cont0 = "00" + cont.mid(1,cont.length()-1);
        qDebug() << "Change Nr.:" + cont0;
        query.exec("select c.displayLabel from Contacts c join PhoneNumbers pn on pn.contactId=c.contactId where pn.phoneNumber='"+cont0+"'");
        query.first();
        retstr = query.value(0).toString();
    }
    // 2: if e.g. +43 3612 ... -> 0 3612
    if (retstr=="" && cont[0]=='+') {
            QString cont0 = "0" + cont.mid(3,cont.length()-2);
            qDebug() << "Change Nr.:" + cont0;
            query.exec("select c.displayLabel from Contacts c join PhoneNumbers pn on pn.contactId=c.contactId where pn.phoneNumber='"+cont0+"'");
            query.first();
            retstr = query.value(0).toString();
        }
    db.close();
    if (retstr=="")
        return cont;
    else
        return retstr.left(max(retstr.length(),(overl0) ? 16 : 22));
}


