/*
 * Utilities for loading and saving
 */
.pragma library
.import QtQuick.LocalStorage 2.0 as LS

var db_initialized = false;

/** Save an object
 *
 * @param {object}  obj object to store
 */
function store(obj) {
    save(obj);
}
/** Load an object
 *
 * @param {url} loc         path to storage location (cache)
 */
function restore(loc) {
    return load();
}
function reset() { resetDdefault() }

/* 
 * **** INTERNAL FUNCTIONS ****
 */


function getDb() {
    var db = LS.LocalStorage.openDatabaseSync("Trollbridge Storage", "0.1", "Persistent Storage", 20000);
    if (!db_initialized) {
        db_initialized = true;
        initDb(db);
    }
    return db;
}
function initDb(db) {
    console.debug("Init DB");
    try {
        db.transaction(function(tx) {
            //tx.executeSql('CREATE TABLE IF NOT EXISTS SavedContent( id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name TEXT, post TEXT)');
            tx.executeSql('CREATE TABLE IF NOT EXISTS Thumbnails(path TEXT, url TEXT)');
        })
    } catch (err) {
        console.warn("Error creating or adding table in database: " + err);
    }
}
function clearDb(db) {
    try {
        db.transaction(function(tx) {
            tx.executeSql('DROP TABLE Thumbnails');
        })
    } catch (err) {
        console.warn("Error creating table in database: " + err);
    }
}
function dropDb(db) {
    try {
        db.transaction(function(tx) {
            tx.executeSql('DROP DATABASE');
        })
    } catch (err) {
        console.warn("Error creating table in database: " + err);
    }}

function hasThumb(path){
   var ret = getThumb(path)
   return ret.length;
}
function getThumb(path){
    console.debug("Load from DB");
    var db = getDb();
    var ret = "";
    try {
        db.readTransaction(function(tx) {
            var rs = tx.executeSql('SELECT url FROM Thumbnails WHERE path like %2', path);
            return rs.rows;
        })
    } catch (err) {
        console.warn("Error executing transaction: " + err);
        return "";
    }
    return ret;
}

function putThumb(data){
    console.debug("Saving to DB");
    var db = getDb();
    try {
        db.transaction( function(tx) {
            tx.executeSql('INSERT INTO Thumbnails VALUES(?)', [ data.path, data.url ]);
        })
    } catch (err) {
        console.warn("Error executing transaction: " + err);
    }
}

// vim: expandtab ts=4 st=4 sw=4 filetype=javascript
