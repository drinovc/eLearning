function containsObject(obj, list, dataId) {
	for (var i = 0; i < list.length; i++) {
		if (list[i].data[dataId] == obj[dataId]) {
			return i;
		}
	}
	return -1;
}

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

		callback: function(){
			// check if localstorage exists
			
			var check;
			if(localStorageAttribute == 'programInfo'){
				check = localStorageData && Object.keys(localStorageData).length;
			}else{
				check = localStorageData && localStorageData[me.programId] && localStorageData[me.programId][localStorageAttribute];
			}
			if(check){
				// add missing or outdated data from localstorage to store
				
				if(localStorageAttribute != 'programInfo'){
					
					localStorageData = localStorageData[me.programId][localStorageAttribute];
				}
				for (var key in localStorageData){
					if(localStorageAttribute == 'programInfo'){
						
						if(!localStorageData[key][localStorageAttribute]){
							continue;
						}
					}
					
					var localStorageEntry = localStorageData[key];
					if(localStorageAttribute == 'programInfo'){
						localStorageEntry = localStorageEntry[localStorageAttribute];
					}
					
					
					var objectIndex = containsObject(localStorageEntry, initialDataStore.data.items, dataId); // get index of this item
					if(initialDataStore.data.length > 0 && objectIndex > -1) { // if returned index 0,1,2..
						// we found localstorage entry in store - update it
						if(new Date(localStorageEntry.lastChanged).getTime() > new Date(initialDataStore.data.items[objectIndex].data.lastChanged).getTime()){
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

				// iterate through records and remove them if they have been deleted offline 
				// first check if record hasnt been deleted in offline
				
				
				var check = false;
				if(localStorageAttribute == 'programInfo'){
					check = localStorageData.removed;
				}else{
					check = localStorageData.removed && localStorageData.removed[localStorageAttribute];
				}
				
				if(check){
					var removed = localStorageData.removed;
					
					if(localStorageAttribute != 'programInfo'){
						removed = removed[localStorageAttribute];
					}
					
					
					for(var i = 0; i < removed.length; i++){
						var rec = initialDataStore.findRecord(dataId, removed[i]);
						if(rec){
							//item was deleted offline, thats why we are deleting this record from the store
							if(initialDataStore.type == 'tree'){
								// we have to remove from parent node
								// remove this slide from tree store
								rec.parentNode.removeChild(rec);
							}else{
								initialDataStore.remove(rec); // remove this record loudly so it syncs
							}
						}
					}
				}
			}
			// dont save state here - it will overwrite all localstorage data that hasnt been synced yet with server
			if(callback){ callback(); }
		}
	});
}


function writeDeleted(record, localStorageAttribute, scope, isProgram, programId){
	var me = scope,
		localStorageData = Ext.decode(localStorage.getItem('mxp_elearning'));

	if(isProgram){
		if(!localStorageData.removed){
			localStorageData.removed = [];
		}
		localStorageData.removed.push(record);
	}else{
		if(!localStorageData[programId].removed){
			localStorageData[programId].removed = {};
		}
		if(!localStorageData[programId].removed[localStorageAttribute]){
			localStorageData[programId].removed[localStorageAttribute] = [];
		}
		localStorageData[programId].removed[localStorageAttribute].push(record);
	}
	// write back modified data
	localStorage.setItem('mxp_elearning', Ext.encode(localStorageData));
}
