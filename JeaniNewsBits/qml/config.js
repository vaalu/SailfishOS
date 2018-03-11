.import QtQuick.LocalStorage 2.0 as LS
function getDatabase() {
    return LS.LocalStorage.openDatabaseSync("JeaniNewsBits", "1.0", "StorageDatabase", 100000);
}
// We want a unique id for channels
function getUniqueId()
{
     var dateObject = new Date();
     var uniqueId =
          dateObject.getFullYear() + '' +
          dateObject.getMonth() + '' +
          dateObject.getDate() + '' +
          dateObject.getTime();

     return uniqueId;
};

var SQL_STATEMENTS = {
  'CREATE_CHANNEL': 'CREATE TABLE IF NOT EXISTS CHANNELS_INFO(CHANNEL_ID LONGVARCHAR UNIQUE, CHANNEL_NAME TEXT, CHANNEL_URL TEXT)',
  'INSERT_CHANNEL': 'INSERT INTO CHANNELS_INFO VALUES(?,?,?);',
  'REMOVE_CHANNEL': 'DELETE FROM CHANNELS_INFO WHERE CHANNEL_ID=?;',
  'RETRIEVE_CHANNELS':'SELECT DISTINCT CHANNEL_ID, CHANNEL_NAME, CHANNEL_URL FROM CHANNELS_INFO;'
};

function initialize() {
    var db = getDatabase();
    console.log('Initializing the DB for channel feeds');
    db.transaction(
                function(tx) {
                    tx.executeSql(SQL_STATEMENTS.CREATE_CHANNEL);
                });
};

function addChannel(name, url) {
    var db = getDatabase();
    var uid = getUniqueId();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql(SQL_STATEMENTS.INSERT_CHANNEL, [uid, name, url]);
        if (rs.rowsAffected > 0) {
            res = "OK";
            //console.log ("Saved to database");
        } else {
            res = "Error";
            //console.log ("Error saving to database");
        }
        return res;
    });
    editChannelsPage.addChannelToList(name, url, uid);
};

function removeChannel(channel_id) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql(SQL_STATEMENTS.REMOVE_CHANNEL, [channel_id]);
        if (rs.rowsAffected > 0) {
            res = "OK";
            //console.log ("Removed from database");
        } else {
            res = "Error";
            //console.log ("Error removing from database");
        }
        return res;
    });
};

function retrieveChannels() {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql(SQL_STATEMENTS.RETRIEVE_CHANNELS);
        for (var i = 0; i < rs.rows.length; i++) {
            //console.log('Available feed: ' + rs.rows.item(i).CHANNEL_NAME);
            editChannelsPage.addChannelToList(rs.rows.item(i).CHANNEL_NAME, rs.rows.item(i).CHANNEL_URL, rs.rows.item(i).CHANNEL_ID);
        };
    });
};
function retrieveChannelsPg1() {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql(SQL_STATEMENTS.RETRIEVE_CHANNELS);
        for (var i = 0; i < rs.rows.length; i++) {
            //console.log('Available feed: ' + rs.rows.item(i).CHANNEL_NAME);
            page.addChannelToList(rs.rows.item(i).CHANNEL_NAME, rs.rows.item(i).CHANNEL_URL, rs.rows.item(i).CHANNEL_ID);
        };
    });
};
function getRssNews(feedUrl) {
    var feedDataArray = [];
    var xhttp = new XMLHttpRequest();

    if (feedUrl) {
        xhttp.onreadystatechange = function(resp) {
            console.log("Response from server: " +status+" : "+ JSON.stringify(resp))
            //feedDataArray = this.responseText();
            /*
            if (this.readystate === 4 || this.status === 200) {
            }
            */
        }
        xhttp.open("GET", feedUrl, true);
        xhttp.send();
        console.log("Feed Data from RSS URL:"+feedUrl+":"+feedDataArray);
        return ["Data 1", "Data 2"];
    } else {
        return ["Unavailable"];
    }
};

