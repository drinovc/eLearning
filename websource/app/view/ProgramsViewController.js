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

	load: function(opts) {


		var me = this;


		opts = Ext.applyIf(opts || {}, {
			program: null
		});


		if(!App.personId){
			App.personId = -1;
			console.warn("Using mockup test person id");
		}

		var callback = function(){
			me.saveState(); // save ALL data that is after all initial data syncs to localstorage
		};

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

			me.updateDataStatusIndicator();

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
			data = me.getCurrentState(),
			syncIndicatorPrograms = Ext.getCmp('syncIndicatorPrograms'),
			localStorageData = Ext.decode(localStorage.getItem('mxp_elearning'));

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
		if(localStorageData.removed){
			newLocalStorageData.removed = localStorageData.removed;
		}


		// sets current state to localstorage and calls update with server
		localStorage.setItem('mxp_elearning', Ext.encode(newLocalStorageData));

		if(navigator.onLine){
			// sync all stores
			me.getStore('StorePrograms').sync();


			// after syncing everything - we can delete current programs' removed entries

			localStorageData = Ext.decode(localStorage.getItem('mxp_elearning'));
			if(localStorageData.removed){
				delete localStorageData.removed;
			}
			localStorage.setItem('mxp_elearning', Ext.encode(localStorageData));


			me.updateStatusIndicator(true, syncIndicatorPrograms);
			me.saveProgramsData();

		}else{
			me.updateStatusIndicator(false, syncIndicatorPrograms);
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
			store = me.getStore('StorePrograms'),
			syncIndicatorPrograms = Ext.getCmp('syncIndicatorPrograms'),
			syncStateCallback = function(){

				me.getView().setSelection(me.getSelection());
				Ext.getCmp('gridPrograms').getView().refresh();
				if(callback){ callback(); }
			};


		syncIndicatorPrograms.removeCls('fa-check fa-refresh fa-spin fa-exclamation-triangle warning success');
		syncIndicatorPrograms.addCls("fa-spin fa-refresh warning");
		syncIndicatorPrograms.tooltip.html = 'Syncing';


		var params = {userId: App.personId}; // Todo - this query by user is unsupported by 2018-08-08
		//initialDataSyncPrograms('StorePrograms', 'programInfo', params, syncStateCallback, 'id', me);
		initialDataSync('StorePrograms', 'programInfo', params, syncStateCallback, 'id', me);


		me.saveProgramsData();
	},

	unload: function() {
		// unload page

		// unload store data silently

		var me = this;
		me.getStore('StorePrograms').loadData([],false);
		me.getStore('StoreProgramCategories').loadData([],false);
		me.getStore('StoreProgramCertificates').loadData([],false);

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

	saveProgramsData: function() {
		var me = this,
			localStorageData = Ext.decode(localStorage.getItem('mxp_elearning')),
			programsStore = me.getStore('StorePrograms'),
			slidesController = me.getView().up('mainview').down('#editSlides').getController();

		var callback = function(){
			me.updateDataStatusIndicator();
		};

		for(var i = 0; i < programsStore.data.items.length; i++){
			var programId =programsStore.data.items[i].data.id;
			if(!localStorageData[programId]){
				// Maybe its not initialized yet when reloading in editSlides and going to trainingPrograms
				localStorageData[programId] = {};
			}
			if(localStorageData[programId].pageSetup && localStorageData[programId].pageSetup.programSynced === false){
				print("this program data is not synced");
				slidesController.programId = programId;
				slidesController.serverSync(callback);
			}
		}
		me.updateDataStatusIndicator();

	},

	updateStatusIndicator: function(synced, indicator) {
		var me = this;

		if(synced){
			indicator.removeCls('fa-check fa-refresh fa-spin fa-exclamation-triangle warning success');
			indicator.addCls("fa-check success");
			indicator.tooltip.html = 'Synced';
		}else{
			indicator.removeCls('fa-check fa-refresh fa-spin fa-exclamation-triangle warning success');
			indicator.addCls("fa-exclamation-triangle warning");
			indicator.tooltip.html = 'Not Synced';
		}






	},

	updateDataStatusIndicator: function() {
		// also update data status indicator


		// Count how many program data changes have been made - if any are made, update data status indicator to 'unsynced' and set tooltip text
		var me = this,
			programsStore = me.getStore('StorePrograms'),
			syncDataIndicator = Ext.getCmp('syncIndicatorProgramsData'),
			localStorageData = Ext.decode(localStorage.getItem('mxp_elearning')),
			unsyncedProgramsData = 0;
		for(var i = 0; i < programsStore.data.items.length; i++){
			var programId =programsStore.data.items[i].data.id;
			// this may not be initialized because of program duplicate
			if(!localStorageData[programId]){
				localStorageData[programId] = {};
			}
			if(localStorageData[programId].pageSetup &&  localStorageData[programId].pageSetup.programSynced === false){
				print("this program data is not synced");
				unsyncedProgramsData++;
			}
		}

		if(unsyncedProgramsData){
			me.updateStatusIndicator(false, syncDataIndicator);
			syncDataIndicator.tooltip.html = 'Not Synced ' + unsyncedProgramsData + ' Programs Data';
		}else{
			me.updateStatusIndicator(true, syncDataIndicator);
			syncDataIndicator.tooltip.html = 'Synced programs Data';
		}
	},

	onRowEditingCanceledit: function(editor, context, eOpts) {
		var me = this,
			refs = me.getReferences(),
			store = me.getStore('StorePrograms');

		// Canceling editing of a locally added, unsaved record: remove it
		if (context.record.phantom) {
			store.remove(context.record);
		}
		me.getView().setSelection(me.getSelection());
	},

	onRowEditingEdit: function(editor, context, eOpts) {
		context.record.phantom = true;
		context.record.data.lastChanged = new Date();
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
			prevProgram = store.getAt(prevProgramIdx),
			selection = me.getSelection(),
			slidesController = me.getView().up('mainview').down('#editSlides').getController();


		//  delete all slides, questions...
		slidesController.programId = selection.id;
		slidesController.personId = App.personId;
		slidesController.clean();

		//then delete program

		store.remove(selection);
		me.saveState();
		me.getView().setSelection(nextProgram || prevProgram || store.first()); // set new selection




	},

	duplicate: function(button, e) {
		var REPLICATE_ANSWERS = true, // we might not want to replicate answers
		me = this,
		store = me.getStore('StorePrograms'),
		selection = me.getView().getSelection()[0],
		slidesController = me.getView().up('mainview').down('#editSlides').getController();

		var duplicateProgram = me.getCurrentState()[selection.id].programInfo;
		//change its id
		Ext.toast("Duplicate not fully supported - some bugs with questions.");

		duplicateProgram.id = createGUID();
		duplicateProgram.name = duplicateProgram.name + " (duplicate)";

		store.add(duplicateProgram)[0].phantom = true;
		me.getView().setSelection(store.last());

		var ORG_programId = me.programId;

		store.sync({
			callback:function(){

				// todo iterate through its original programs slides, questions, answers and personProgram
				// programs view model doesn't have all the other needed stores, so i will have to access editSlides' stores somehow

				// ko mam duplicatan program id
				// nardim serverSync editSlides s tastarmu idjam,
				// potem poišem v localstorage ta tastar id
				// ga preimenujem v tanov id od programa
				// stisnem še enkrat serverSync in bo vse postal na tanov guid



				// save to localstorage this new program
				me.saveState();
				var serverSyncCallback2 = function(){
					// then save everything and set new selection to newly duplicated slide
					// save all changes that have been made to duplicated program

					me.saveState();

					// save everything for duplicated program
					slidesController.programId = duplicateProgram.id;
					slidesController.saveState();
					slidesController.clean(true);

				};


				var serverSyncCallback1 = function(){
					slidesController.saveState(true); // save everything to localstorage

					// copy localstorage data into new id
					var localStorageData = Ext.decode(localStorage.getItem('mxp_elearning'));
					localStorageData[duplicateProgram.id] = Ext.clone(localStorageData[selection.id]);

					var slides = localStorageData[duplicateProgram.id].slides,
						questions = localStorageData[duplicateProgram.id].questions,
						answers = localStorageData[duplicateProgram.id].answers,
						personProgram = localStorageData[duplicateProgram.id].personProgram,
						slidesNew = {},
						questionsNew = {},
						answersNew = {};

					// reparent everything

					for(var slideKey in slides){
						var slide = slides[slideKey];

						// memorize
						slideOldId = slide.id;
						// create new guid
						slide.id = createGUID();
						slide.programId = duplicateProgram.id;

						// iterate through all slides and check if anyone has set parent this slide
						for(var childSlideKey in slides){
							var childSlide = slides[childSlideKey];

							if(childSlide.parentId == slideOldId){
								// reparent
								childSlide.parentId = slide.id;
							}
						}


						if(!slide.content){
							continue;
						}

						var slideComps = Ext.decode(slide.content);
						var slideNewComponents = {components:{}};

						for(var compKey in slideComps.components){
							var comp = slideComps.components[compKey];
							comp.id = createGUID();

							// questions
							for(var questionKey in questions){
								var question = questions[questionKey];

								//if(slideOldId == questions.pageId){ // WITH THIS WORKED BUT ITS WRONG
								if(slideOldId == question.pageId){
									// first reparent
									question.pageId = slide.id;

									// memorize
									questionOldId = question.id;
									// use guid from component
									question.id = comp.id;

									if(REPLICATE_ANSWERS){
										for(var answerKey in answers){
											var answer = answers[answerKey];

											if(questionOldId == answer.questionId){
												// first reparent
												answer.questionId = question.id;

												// memorize
												answerOldId = answer.id;
												// create new guid
												answer.id = createGUID();
											}
											answersNew[answer.id] = answer;
										}
									}
									questionsNew[question.id] = question;
								}
							}
							slideNewComponents.components[comp.id] = comp;
						}
						slide.content = Ext.encode(slideNewComponents);
						slidesNew[slide.id] = slide;
					}
					localStorageData[duplicateProgram.id].slides = slidesNew;
					localStorageData[duplicateProgram.id].questions = questionsNew;
					localStorageData[duplicateProgram.id].answers = answersNew;

					// dont replicate person program

					// set data back to localstorage
					localStorage.setItem('mxp_elearning', Ext.encode(localStorageData));


					// call server sync to upload all data for this program id from localstorage to database

					slidesController.clean(true);

					slidesController.programId = duplicateProgram.id;
					slidesController.serverSync(serverSyncCallback2);
				};

				// first call save state to save everything from old program to localstorage
				slidesController.programId = selection.id;
				slidesController.serverSync(serverSyncCallback1);

			}
		});


	},

	editProgramData: function(button, e) {
		var me = this,
			view = me.getView(),
			selection = me.getSelection(),
			mainView = view.up('#mainView');

		me.saveState();
		me.unload();

		this.redirectTo('edit-pages/' + selection.id.slice(1, -1)); // passing id without surrounding curly brackets { }

	},

	createTooltip: function(component, eOpts) {
		// this function could be basic binding but if it is, defaultListenerScope becomes true and then store bindings dont work!!!!!!!!

		component.tooltip = Ext.create('Ext.tip.ToolTip', {
			target: component.id,
			html: 'Not Synced'
		});
	},

	createTooltipData: function(component, eOpts) {
		// this function could be basic binding but if it is, defaultListenerScope becomes true and then store bindings dont work!!!!!!!!

		component.tooltip = Ext.create('Ext.tip.ToolTip', {
			target: component.id,
			html: 'Synced Programs Data'
		});
	},

	close: function(owner, tool, event) {
		this.unload();
		this.redirectTo('home');
	},

	onGridProgramsActivate: function(component, eOpts) {
		var me = this;

		// if we reloaded page on training programs, we have to reload lookups and refresh grid
		var callback = function(){
			print("recieved callback grid programsActivate");
			me.getStore('StoreProgramCategories').setData(App.lookups.ProgramCategories);
			me.getStore('StoreProgramCertificates').setData(App.lookups.CoursesAndCertificates);
			Ext.getCmp('gridPrograms').getView().refresh();
		};
		loadLookups(callback);


		// Update the online status icon based on connectivity
		window.addEventListener('online',  me.connectionChange);
		window.addEventListener('offline', me.connectionChange);



		// create online / offline event listenere - when coming back online, we want to sync localstorage with database
		me.connectionChange = function() {
			if (navigator.onLine){
				var callback = function(){
					Ext.toast('Welcome back online! Content saved on server.');
					me.saveState();

				};


				me.serverSync(callback); // calls sync of everything (slides, questions, answers, pageConfig...) - it retrieves data and pushes latest data to server

			}else{
				Ext.toast('We went offline! Content is still saved locally. Reconnect to save content with server.');
			}
		};

		//this.load();

	},

	onStoreProgramsRemove: function(store, records, index, isMove, eOpts) {
		if(!navigator.onLine){
			var me = this;
			for(var i = 0; i < records.length; i++){
				var deletedRec = records[i];
				var recId = deletedRec.id;
				writeDeleted(recId, null, me, true, null);
			}
		}


	}

});
