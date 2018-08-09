
function containsObject(obj, list, dataId) {
	for (var i = 0; i < list.length; i++) {
		if (list[i].data[dataId] == obj[dataId]) {
			return i;
		}
	}
	return -1;
}

// TODO - join these two functions below


function initialDataSync(storeName, localStorageAttribute, LoadParams, callback, dataId, scope){

	if (!navigator.onLine){
		//You are offline - cannot sync with server
		if(callback){
			callback();
		}
		return;
	}

	var me = scope,
		localStorageData = Ext.decode(localStorage.getItem('mxp_elearning')),

		initialDataStore = me.getStore(storeName);

	initialDataStore.load({
		params: LoadParams,

		callback: function(records, operation, success){
			if(initialDataStore.data.length === 0){
				// no return data, check if there are any locally saved localStorageAttribute

				if(localStorageData && localStorageData[me.programId] && localStorageData[me.programId][localStorageAttribute]){
					//we have locally saved localStorageAttribute, syncing with server
					// data for this programId exists - reassign it
					localStorageData = localStorageData[me.programId];
					for (var key in localStorageData[localStorageAttribute]){
						var localStorageEntry = localStorageData[localStorageAttribute][key];

						if(initialDataStore.type == 'tree'){ // if tree store
							// we must append this to root node not add
							initialDataStore.getRootNode().appendChild(localStorageEntry);
							initialDataStore.findRecord(dataId, localStorageEntry[dataId]).phantom = true;
						}
						else{
							var rec = initialDataStore.add(localStorageEntry)[0];
							rec.phantom = true;
						}
					}
				}
				if(callback){ callback();}
				return;
			}

			// if no localstorage
			if(!localStorageData || !localStorageData[me.programId] || !localStorageData[me.programId][localStorageAttribute]){
				// no data yet in localstorage - just return and save state will take care of storing in localstorage
				if(callback){ callback(); }
				return;
			}
			

			// add missing or outdated data from localstorage to store
			for (var key in localStorageData[localStorageAttribute]){
				var localStorageEntry = localStorageData[localStorageAttribute][key];
				var objectIndex = containsObject(localStorageEntry, initialDataStore.data.items, dataId); // get index of this item
				if(objectIndex > -1) { // if returned index 0,1,2..
					// we found localstorage entry in store - update it
					if(localStorageEntry.lastChanged > initialDataStore.data.items[objectIndex].data.lastChanged){
						// update entry in
						var rec = initialDataStore.findRecord(dataId, localStorageEntry[dataId]);
						rec.data = localStorageEntry;
						rec.phantom = true;
					}
				}else{
					// entry was found in localstorage but is not in store

					if(initialDataStore.type == 'tree'){ // if tree store
						// for tree store, we add data to it by appending it to root node
						initialDataStore.getRootNode().appendChild(localStorageEntry);
						initialDataStore.findRecord(dataId, localStorageEntry[dataId]).phantom = true;
					}
					else{
						// for all other stores - that are json stores we can add entry normally
						var rec = initialDataStore.add(localStorageEntry)[0];
						rec.phantom = true;
					}
				}
			}
			// dont save state here - it will overwrite all localstorage data that hasnt been synced yet with server

			if(callback){ callback(); }
		}
	});
}



function initialDataSyncPrograms(storeName, localStorageAttribute, LoadParams, callback, dataId, scope){

	if (!navigator.onLine){
		//You are offline - cannot sync with server
		if(callback){
			callback();
		}
		return;
	}

	var me = scope,
		localStorageData = Ext.decode(localStorage.getItem('mxp_elearning')),

		initialDataStore = me.getStore(storeName);

	initialDataStore.load({
		params: LoadParams,

		callback: function(records, operation, success){
			if(initialDataStore.data.length === 0){
				// no return data, check if there are any locally saved localStorageAttribute
				if(localStorageData && Object.keys(localStorageData).length){ // if any programs exist
					//we have locally saved programs, syncing with server
					// data for this programId exists - reassign it
					for (var key in localStorageData){
						if(!localStorageData[key][localStorageAttribute]){
							localStorageData[key][localStorageAttribute] = {};
						}
						var localStorageEntry = localStorageData[key][localStorageAttribute];
						
						if(initialDataStore.type == 'tree'){ // if tree store
							// we must append this to root node not add
							initialDataStore.getRootNode().appendChild(localStorageEntry);
							initialDataStore.findRecord(dataId, localStorageEntry[dataId]).phantom = true;
						}
						else{
							var rec = initialDataStore.add(localStorageEntry)[0];
							rec.phantom = true;
						}
					}
				}
				if(callback){ callback();}
				return;
			}

			if(!localStorageData || !Object.keys(localStorageData).length){
				// no data yet in localstorage
				if(callback){ callback(); }
				return;
			}

			// add missing or outdated data from localstorage to store
			for (var key in localStorageData){
				if(!localStorageData[key][localStorageAttribute]){
					//localStorageData[key][localStorageAttribute] = {};
					continue;
				}
				
				var localStorageEntry = localStorageData[key][localStorageAttribute];
			
				
				
				
				var objectIndex = containsObject(localStorageEntry, initialDataStore.data.items, dataId); // get index of this item
				if(objectIndex > -1) { // if returned index 0,1,2..
					// we found localstorage entry in store - update it

					if(localStorageEntry.lastChanged > initialDataStore.data.items[objectIndex].data.lastChanged){
						// update entry in
						var rec = initialDataStore.findRecord(dataId, localStorageEntry[dataId]);
						rec.data = localStorageEntry;
						rec.phantom = true;
					}
				}else{
					// entry was found in localstorage but is not in store

					if(initialDataStore.type == 'tree'){ // if tree store
						// for tree store, we add data to it by appending it to root node
						initialDataStore.getRootNode().appendChild(localStorageEntry);
						initialDataStore.findRecord(dataId, localStorageEntry[dataId]).phantom = true;
					}
					else{
						// for all other stores - that are json stores we can add entry normally
						
						var rec = initialDataStore.add(localStorageEntry)[0];
						rec.phantom = true;
					}
				}
			}
			// dont save state here - it will overwrite all localstorage data that hasnt been synced yet with server
			if(callback){ callback(); }
		}
	});
}



