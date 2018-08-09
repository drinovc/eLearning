/*
 * File: app/view/ProgramsViewController.js
 *
 * This file was generated by Sencha Architect version 4.2.3.
 * http://www.sencha.com/products/architect/
 *
 * This file requires use of the Ext JS 6.5.x Classic library, under independent license.
 * License of Sencha Architect does not include license for Ext JS 6.5.x Classic. For more
 * details see http://www.sencha.com/license or contact license@sencha.com.
 *
 * This file will be auto-generated each and everytime you save your project.
 *
 * Do NOT hand edit this file.
 */

Ext.define('eLearning.view.ProgramsViewController', {
	extend: 'Ext.app.ViewController',
	alias: 'controller.programs',

	load: function() {
		var me = this;

		var callback = function(){
			me.saveState(); // save ALL data that is after all initial data syncs to localstorage
		};

		me.getStore('StoreProgramCategories').setData(App.lookups.ProgramCategories);

		if(navigator.onLine){
			// sync with server
			me.serverSync(callback); // calls sync of everything (slides, questions, answers, pageConfig...) - it retrieves data and pushes latest data to server
		}else{
			// store data from localstorage
			var store = me.getStore('StorePrograms');

			var localStorageData = Ext.decode(localStorage.getItem('mxp_elearning'));
			// init store
			var localStorageEntries = [];
			for (var key in localStorageData){
				localStorageEntries.push(localStorageData[key].programInfo);
			}
			store.setData(localStorageEntries);
		}



	},

	getCurrentState: function() {
		var me = this,
		    refs = me.getReferences(),
		    store = me.getStore('StorePrograms'),
		    data = Ext.clone(Ext.pluck(store.getRange(), 'data'));

		var programs = {};
		for (var i = 0; i < data.length; i++){
		    var entry = data[i];
		    programs[entry.id] = {programInfo: entry};
		}

		return programs;
	},

	saveState: function() {
		var me = this,
		    data = me.getCurrentState();

		var localStorageData = Ext.decode(localStorage.getItem('mxp_elearning'));
		// init store
		if(!localStorageData){
			localStorageData = {};
		}

		var newLocalStorageData = {};
		for (var key in data){
			// init program id
			if(!localStorageData[data[key].programInfo.id]){
				localStorageData[data[key].programInfo.id] = {};
			}// add program info to this program id
			localStorageData[data[key].programInfo.id].programInfo = data[key].programInfo;
			newLocalStorageData[key] = localStorageData[key]; // takes localstorage entries that their programs are avaliable in programs store
		}
		// sets current state to localstorage and calls update with server
		localStorage.setItem('mxp_elearning', Ext.encode(newLocalStorageData));

		if(navigator.onLine){
			// sync all stores
			me.getStore('StorePrograms').sync();
		}

		var editButton = Ext.getCmp('btnEdit');
		if(!me.getSelection()){
			editButton.disable();
			editButton.setText('Edit Slides (No Programs)');
		}
		else{
			editButton.enable();
			editButton.setText('Edit Slides');
		}
	},

	serverSync: function(callback) {
		// calls sync of everything - it retrieves data and pushes latest data to server
		// syncs all data with server - this is called on program load and on navigator onLine
		var me = this,
			TEST_PERSON_ID = 10000112,
			store = me.getStore('StorePrograms'),
			syncStateCallback = function(){
				store.sync();

				me.getView().setSelection(me.getSelection());

				if(callback){ callback(); }
			};

		var params = {userId: TEST_PERSON_ID}; // Todo - this query by user is unsupported by 2018-08-08
		initialDataSyncPrograms('StorePrograms', 'programInfo', params, syncStateCallback, 'id', me);

	},

	unload: function() {
		// unload page

		// unload store data silently

		var me = this;
		me.getStore('StorePrograms').loadData([],false);
		me.getStore('StoreProgramCategories').loadData([],false);

		// remove all listeners so they are not interfering with other views
		window.removeEventListener('online',  me.connectionChange);
		window.removeEventListener('offline',  me.connectionChange);

	},

	getSelection: function() {
		var me = this,
			store = me.getStore('StorePrograms'),
			selection =  me.getView().getSelection()[0] || store.first(); // backup is store first - this is usefull when initially loading data;

		return selection;


	},

	onRowEditingCanceledit: function(editor, context, eOpts) {
		var me = this,
			refs = me.getReferences(),
			store = me.getStore('StorePrograms');

		// Canceling editing of a locally added, unsaved record: remove it
		if (context.record.phantom) {
			store.remove(context.record);
		}
	},

	onRowEditingEdit: function(editor, context, eOpts) {
		this.saveState();
	},

	add: function(button, e) {
		var me = this,
			refs = me.getReferences(),
			store = me.getStore('StorePrograms'),
			editor = me.getView().getPlugin('rowEditing'),
			data = {
				id: createGUID(),
				name: 'New Training Program',
				categoryId: null,
				description: 'New Training Program Description',
				validFrom: new Date(),
				validTo: Ext.Date.add(new Date(), Ext.Date.YEAR, 1),
				completionTime: 60,
				maxAttemptsTrainingMode: 1,
				maxAttemptsScoreMode: 1,
				passScore: 75,
				active: true
			};

		var rec = store.add(data)[0];
		rec.phantom = true;
		editor.startEdit(rec);
	},

	remove: function(button, e) {
		var me = this,
			store = me.getStore('StorePrograms'),
			currentProgram = me.getSelection(),
			nextProgramIdx = store.indexOf(currentProgram) + 1,
			nextProgram = store.getAt(nextProgramIdx),
			prevProgramIdx = store.indexOf(currentProgram) - 1,
			prevProgram = store.getAt(prevProgramIdx);


		store.remove(me.getSelection());
		me.saveState();
		me.getView().setSelection(nextProgram || prevProgram || store.first()); // set new selection
	},

	duplicate: function(button, e) {
		console.warn("Duplicate unsupported - we have to copy current program, its slides, slides' questions, questions' answers and user program");

		return;

		var me = this,
			store = me.getStore('StorePrograms'),
			selection = me.getView.getSelection()[0];
		var duplicateProgram = Ext.clone(selection);
		//change its id
		duplicateProgram.id = createGUID(); // todo is this correct?
		store.add(duplicateProgram)[0].phantom = true;


		// todo iterate through its original programs slides, questions, answers and personProgram
		// programs view model doesn't have all the other needed stores, so i will have to access editSlides' stores somehow

		me.saveState();
		me.getView().setSelection(store.last()); // set new selection
	},

	bookmark: function(button, e) {
		console.warn("Bookmark unsupported - field in database needs to be added to support bookmarks");
	},

	editSlides: function(button, e) {
		var me = this,
			view = me.getView(),
			selection = me.getSelection(),
			mainView = view.up('#mainView');

		me.saveState();
		me.unload();
		var newActiveItem = mainView.setActiveItem('editSlides');
		newActiveItem.getController().load({ program: selection });
	},

	close: function(owner, tool, event) {
		this.unload();
		this.getView().up('#mainView').setActiveItem('homePage');
	},

	onGridProgramsActivate: function(component, eOpts) {
		var me = this;

		// create online / offline event listenere - when coming back online, we want to sync localstorage with database
		me.connectionChange = function() {
			if (navigator.onLine){
				var callback = function(){
					Ext.toast('Welcome back online! Content saved on server.');
				};


				me.serverSync(callback); // calls sync of everything (slides, questions, answers, pageConfig...) - it retrieves data and pushes latest data to server

			}else{
				Ext.toast('We went offline! Content is still saved locally. Reconnect to save content with server.');
			}
		};
		// Update the online status icon based on connectivity
		window.addEventListener('online',  me.connectionChange);
		window.addEventListener('offline', me.connectionChange);

		this.load();

	}

});
