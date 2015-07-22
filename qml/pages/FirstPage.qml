/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import com.stu.lib 1.0

import "qrc:/"

Page {
    id: page

    DataHandler {
        id: dh0
    }

    function getCallIcon(idx)
    {

        var callstr = dh0.GetData(idx,"direction")
        if (callstr === "missed")
        {
            return "call-missed.png"
        }
        if (callstr === "incoming")
        {
            return "call-received.png"
        }
        if (callstr === "outgoing")
        {
            return "call-made.png"
        }
    }

    function getIconColor(callstr)
    {
        if (callstr === "missed")
        {
            return "red"
        }
        if (callstr === "incoming")
        {
            return "green"
        }
        return "lightgrey"

    }

    function translateStartDay(startday)
    {


        if (startday === "Today00000") { return qsTr("Today") }
        if (startday === "Yesterday0") { return qsTr("Yesterday") }
        return startday
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill:parent
        pressDelay: 0
        PageHeader {
            title: qsTr("Clogfish Call Log")
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Sync contacts and calls again")
                onClicked: dh0.ReadCallData()
            }

        }
        SilicaFlickable {
            pressDelay: 0
            anchors.top: parent.top
            anchors.topMargin: 140
            width: parent.width
            anchors.bottom: parent.bottom

            SilicaListView {
                id: listView
                spacing: 0
                model: dh0.NoOfEntries()
                anchors.fill: parent
                delegate: BackgroundItem {
                    id: delegate

                    Label {
                    id:labelcontact
                    x: Theme.paddingLarge
                    font.family: Theme.fontFamily
                    text:qsTr("  " + dh0.GetData(index,"contactname"))
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    anchors.left: parent.left
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }

                    Rectangle
                    {
                    id: labelrect
                    width: 23
                    height: 23
                    color: getIconColor(dh0.GetData(index,"direction"))
                    anchors.bottom: labelcontact.bottom
                    anchors.left:labelcontact.right
                    anchors.bottomMargin: 6
                    anchors.leftMargin: 5
                    radius: 5
                    Image {
                        width: 20
                        height: 20
                        anchors.top: labelrect.top
                        anchors.left:labelrect.left
                        anchors.margins: 2
                        source: getCallIcon(index)
                    }
                    }

                    Label {
                    id:labelstarttime
                    x: Theme.paddingLarge
                    font.family: Theme.fontFamily
                    text:qsTr(translateStartDay(dh0.GetData(index,"startday")) + "  " + dh0.GetData(index,"startclock"))
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: false
                    anchors.right: parent.right
                    anchors.bottom: labelcontact.bottom
                    anchors.rightMargin: 3
                    color: delegate.highlightedghted ? Theme.highlightColor : Theme.primaryColor
                    }

                    Label {
                    id: numberlabel
                    x: Theme.paddingLarge
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.bold: false
                    text: qsTr(dh0.GetData(index,"number"))
                    anchors.top: labelcontact.bottom
                    anchors.left:labelcontact.left
                    anchors.leftMargin: 8
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }

                    Label {
                    id: durationlabel
                    x: Theme.paddingLarge
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.bold: false
                    text: qsTr(dh0.GetData(index,"duration"))
                    anchors.top: labelstarttime.bottom
                    anchors.right: labelstarttime.right
                    anchors.rightMargin: 8
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }

                    onClicked: {
                    Qt.openUrlExternally("tel:"+dh0.GetData(index,"number"))
                    //pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                    }
                }

                VerticalScrollDecorator {}
            }
        }
    }
}

