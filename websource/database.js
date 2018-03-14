var database = {
    db: null,
    init: function() {
        var request = indexedDB.open('mxpdb_elearning', 1);
        
        request.onerror = function(event) {
            alert('No IndexedDB support!');
            console.log('DB init onerror', event);
        };

        request.onupgradeneeded = function(event) {
            console.log('DB init onupgradeneeded', event);

            var db = event.target.result;
            var objectStore = db.createObjectStore('test', { keyPath: 'id' });   

            objectStore.createIndex('name', 'name', { unique: false });
            objectStore.createIndex('email', 'email', { unique: true });    
            objectStore.transaction.oncomplete = function(event) {
                var testObjectStore = db.transaction('test', 'readwrite').objectStore('test'); // readonly, readwrite, versionchange

                testObjectStore.add({ id: 1, name: 'James', email: 'james@demo.com' });
                testObjectStore.add({ id: 2, name: 'Mary', email: 'mary@demo.com' });
            };

        };
        
        request.onsuccess = function(event) {
            console.log('DB onsuccess', event);

            database.db = event.target.result;

            // global error handler
            database.db.onerror = function(event) {
                console.error('DB error: ' + event.target.error);
            };
        };

    },
    testAdd: function(obj) {
        var db = database.db;
        var transaction = db.transaction(['test'], 'readwrite');
        
        transaction.oncomplete = function(event) {
            console.log('oncomplete', event);
        };

        transaction.onerror = function(event) {
            console.log('onerror', event);
        };

        var objectStore = transaction.objectStore('test');
        
        var request = objectStore.add(obj);
            
        request.onsuccess = function(event) {
            console.log('onsuccess', event);
        };        
    }, 
    testRemove: function(id) {
        var db = database.db;
        var request = db.transaction(['test'], 'readwrite')
            .objectStore('test')
            .delete(id);
        
        request.onsuccess = function(event) {
            console.log('onsuccess', event);
        };
    },
    testRead: function(id) {
        database.db.transaction(['test']).objectStore('test').get(id).onsuccess = function(event) {
            console.log(event.target.result);
        };
    }
};

database.init();