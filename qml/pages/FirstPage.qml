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

        var callstr = dh0.GetData(idx,4)
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

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        pressDelay: 0
        anchors.fill: parent
        PageHeader {}

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }

        SilicaListView {
            id: listView
            spacing: 0
            model: dh0.NoOfEntries()
            anchors.fill: parent
            header: PageHeader {
                title: qsTr("Jolla Call log")
            }

            delegate: BackgroundItem {
                id: delegate
                /*Rectangle {
                    anchors.fill: parent
                    color: Theme.highlightColor
                    opacity: 0.1
                }*/

                Label {
                    id:firstlabel
                    x: Theme.paddingLarge
                    font.family: Theme.fontFamily
                    text:qsTr(dh0.GetData(index,0)+"\t" + dh0.GetData(index,2))
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    id: secondlabel
                    x: Theme.paddingLarge
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.bold: false
                    text: qsTr("   " +dh0.GetData(index,3)+"  "+dh0.GetData(index,5)+ "   ")
                    anchors.top: firstlabel.bottom
                    anchors.left:firstlabel.left
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                /*Label {
                    id: thirdlabel
                    x: Theme.paddingLarge
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.bold: true
                    text: qsTr("  "+dh0.GetQuery(index)+dh0.GetQueryStr(3)+"  ")
                    anchors.top: secondlabel.top
                    anchors.left:secondlabel.right
                    color: getCallColor()
                }*/
                Rectangle
                    {
                    id: rect
                    width: 25
                    height: 25
                    color: "white"
                    anchors.top: secondlabel.top
                    anchors.left:secondlabel.right
                    Image {
                        width: 20
                        height: 20
                        anchors.top: rect.top
                        anchors.left:rect.left
                        anchors.margins: 2
                        source: getCallIcon(index)
                    }
                }

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
            }

            VerticalScrollDecorator {}
        }


        /*
        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Jolla Detailed Call log")
            }
        }*/


    }
}


