#include "DataHandler.h"

DataHandler::DataHandler (QObject *parent){
    db = QSqlDatabase::addDatabase( "QSQLITE" );
    for(int i=0;i<6;i++) querystr[i]="";
    ReadCallData();
 }

DataHandler::~DataHandler() {
    db.close();
}


int DataHandler::ReadCallData()
{
    Tcalldata tcd;
    QString dirstr;
    QDateTime s0,s1;

    db.setDatabaseName("/home/nemo/.local/share/commhistory/commhistory.db");
    if(!db.open())
        return -1;
    QSqlQuery query(db);
    query.exec("select startTime, endTime, remoteUid, direction,isMissedCall from Events where type=3 order by startTime desc");
    query.first();
    int i=0;
    if (query.isActive()) {

        while (query.next()) {
            int startTime = query.value(0).toInt();
            s0.setTime_t(startTime);
            tcd.starttime = s0.toString(Qt::SystemLocaleShortDate);
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
       callsdb[i].contactname=GetContact(callsdb[i].number);
   return 0;
}

QString DataHandler::GetData(int entry,int tcdentry) {


    if (entry>(int) callsdb.size()-1)
        return "";
    switch(tcdentry) {
        case 0: return callsdb[entry].starttime; break;
        case 1: return callsdb[entry].endtime; break;
        case 2: return callsdb[entry].contactname; break;
        case 3: return callsdb[entry].number; break;
        case 4: return callsdb[entry].direction; break;
        case 5: return callsdb[entry].duration; break;
    }
    return "";
}



int DataHandler::NoOfEntries() {

    return (int) callsdb.size();
}

QString DataHandler::GetContact(QString cont) {
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
        return "N/A";
    else
        return retstr;
}


