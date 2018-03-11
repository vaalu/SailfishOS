import QtQuick 2.0
import Sailfish.Silica 1.0
import "../config.js" as DB

Page {
    id: page
    function addChannelToList(name, url, uid) {
        console.log("Channel: " + name);
        var contains = channelsListModel.contains(uid)
        if (!contains[0]) {
            channelsListModel.append({"name": name, "url": url, "uid":uid})
            /*
            for (var p = 0; p < 9; p++) {
                channelsListModel.append({"name": name, "url": url, "uid":uid})
            }
            */
        }
    }

    function addFeedData(feedListName, feedDetails) {
        feedListName.append({"detail":feedDetails});
    }



    Drawer {
        id: drawer

        anchors.fill: parent
        dock: page.isPortrait ? Dock.Top : Dock.Left

        SilicaFlickable {
            id: mainListView
            PullDownMenu {

                MenuItem {
                    text: qsTr("Refresh News")
                    onClicked: {
                        console.log("Page refresh got clicked.")
                        channelsListModel.clear()
                        DB.retrieveChannelsPg1();
                    }
                }
                MenuItem {
                    text: qsTr("Manage Channels")
                    onClicked: function() {
                        var editPage = pageStack.push(Qt.resolvedUrl("EditChannels.qml"))
                    }
                }
            }
            PushUpMenu {
                MenuItem {
                    text: qsTr("Back to top")
                    onClicked: {
                        //channelsListModel.scrollToTop()
                    }
                }
            }
            anchors {
                fill: parent
                leftMargin: page.isPortrait ? 0 : page.visibleSize
                topMargin: page.isPortrait ? page.visibleSize : 0
                rightMargin: page.isPortrait ? 0 : page.visibleSize
                bottomMargin: page.isPortrait ? page.visibleSize : 0
            }

            clip: page.isPortrait// && (page.expanded || page.expanded)

            contentHeight: column.height + Theme.paddingLarge

            VerticalScrollDecorator {flickable: mainListView}
            HorizontalScrollDecorator {flickable: mainListView}

            MouseArea {
                enabled: drawer.open
                anchors.fill: column
                onClicked: drawer.open = false
            }

            Column {
                id: column
                spacing: Theme.paddingLarge
                width: parent.width
                enabled: !drawer.opened

                PageHeader { title: "Jeani News Bites" }

                SectionHeader {
                    text: "Headlines"
                }

                ViewPlaceholder {
                    enabled: feedsListRep.count == 0
                    text: "No Channels Added"
                    hintText: "Pull down to add channel"
                }

                ExpandingSectionGroup {
                    currentIndex: 0

                    Repeater {
                        id: feedsListRep
                        Component.onCompleted: {
                            DB.retrieveChannelsPg1();
                        }

                        model: ListModel {
                            id: channelsListModel
                            function contains(uid) {
                                 for (var i=0; i<count; i++) {
                                     if (get(i).uid === uid)  {
                                         return [true, i];
                                     }
                                 }
                                 return [false, i];
                            }
                        }

                        ExpandingSection {
                            id: section

                            property int sectionIndex: model.index
                            title: model.name

                            content.sourceComponent: Column {
                                width: section.width

                                Repeater {
                                    id: newsRep
                                    model: ListModel {
                                        id: newsFeedDetail
                                        Component.onCompleted: {
                                            var feedData = DB.getRssNews(model.url)
                                            /*
                                            if (!(feedData) || feedData.length < 1) {
                                                page.addFeedData(newsFeedDetail, "News channels are not present \nPull down to add a channel");
                                            }
                                            */

                                            for (var p = 0; p < feedData.length; p++) {
                                                page.addFeedData(newsFeedDetail, feedData[p]);
                                                //console.log("Returned " + feedData[p]);
                                                console.log("Returned " + channelsListModel.hasChildren(this))
                                            };
                                        }
                                    }
                                    delegate: ListItem {
                                        x: Theme.paddingMedium
                                        Label {
                                            text: detail
                                        }
                                     }

                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
