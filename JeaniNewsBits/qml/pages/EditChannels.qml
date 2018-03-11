import QtQuick 2.2
import Sailfish.Silica 1.0
import "../config.js" as DB

Page {
     id: editChannelsPage

     function addChannelToList(name, url, uid) {
         var contains = channelsList.contains(uid)
         if (!contains[0]) {
             channelsList.append({"name": name, "url": url, "uid":uid})
         }
     }

     SilicaListView {
         anchors.fill: parent
         id: listView
         property ListModel availableChannels: channelsList
         ViewPlaceholder {
             enabled: listView.count == 0
             text: "No Channels Added"
             hintText: "Pull down to add channel"
         }

         header: PageHeader {
             title: qsTr("Manage Channels")
         }

         model: ListModel {
             id: channelsList
             function contains(uid) {
                 for (var i=0; i<count; i++) {
                     if (get(i).uid === uid)  {
                         return [true, i];
                     }
                 }
                 return [false, i];
             }

             Component.onCompleted: {

                 //append({"name": "The Hindu (Chennai)", "uid" : "0", "url" : "http://www.thehindu.com/news/cities/Chennai/?service=rss"})
                 //append({"name": "The Hindu (Tamil Nadu)", "uid":"1","url" : "http://www.thehindu.com/news/states/tamil-nadu/?service=rss"})
                 DB.initialize()
                 DB.retrieveChannels()

             }


         }
         PullDownMenu {
             MenuItem {
                 text: qsTr("Add New")
                 onClicked: {
                     var addNewDialog = pageStack.push(Qt.resolvedUrl("AddChannelDialog.qml"))
                     addNewDialog.accepted.connect(
                         function() {
                             //console.log("Name entered: " + addNewDialog.name + " : " + addNewDialog.url)
                             //channelsList.append({name:addNewDialog.name, url: addNewDialog.url})
                             DB.addChannel(addNewDialog.name, addNewDialog.url);
                         }
                     )
                 }
             }
         }
         delegate: ListItem {
             id: delegate
             width: ListView.view.width
             ListView.onRemove: animateRemoval(delegate)
             Label {
                 x: Theme.horizontalPageMargin
                 id: label
                 text: model.name
                 anchors.verticalCenter: parent.verticalCenter
                 color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
             }
             onClicked: function(){
                 var updateDialog = pageStack.push(Qt.resolvedUrl("AddChannelDialog.qml"))
                 updateDialog.name=listView.model.get(index).name
                 updateDialog.url=listView.model.get(index).url
                 updateDialog.existingChannels=listView.model
                 updateDialog.onEntered()
                 console.log("Updating channel: " + updateDialog.name + " : " + updateDialog.url)

                 updateDialog.accepted.connect(
                     function() {
                         //console.log("Name entered: " + updateDialog.name + " : " + updateDialog.url)
                         //channelsList.append({name:addNewDialog.name, url: addNewDialog.url})
                         listView.model.get(index).name=updateDialog.name
                         listView.model.get(index).url=updateDialog.url

                     }
                 )
             }

             menu: ContextMenu {

                 MenuItem {
                     text: "Remove"
                     onClicked: {
                         remorseAction("Removing " + listView.model.get(index).name, function() { listView.model.remove(index) })
                         DB.removeChannel(listView.model.get(index).uid)
                     }
                 }
             }
         }
     }
}
