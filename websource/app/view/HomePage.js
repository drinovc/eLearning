/*
 * File: app/view/HomePage.js
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

Ext.define('eLearning.view.HomePage', {
	extend: 'Ext.container.Container',
	alias: 'widget.homepage',

	requires: [
		'eLearning.view.HomePageViewModel',
		'Ext.button.Button',
		'Ext.container.Container',
		'Ext.form.Label'
	],

	viewModel: {
		type: 'homepage'
	},
	itemId: 'homePage',
	defaults: {
		width: 200,
		height: 50,
		margin: 5
	},

	layout: {
		type: 'vbox',
		align: 'center',
		pack: 'center'
	},
	items: [
		{
			xtype: 'button',
			handler: function(button, e) {
				this.up('#mainView').setActiveItem('gridPrograms');
			},
			text: 'Training Programs'
		},
		{
			xtype: 'button',
			handler: function(button, e) {

			},
			text: 'Help'
		},
		{
			xtype: 'container',
			height: 200,
			defaults: {
				flex: 1
			},
			layout: {
				type: 'vbox',
				align: 'stretch'
			},
			items: [
				{
					xtype: 'label',
					flex: 0,
					height: 20,
					text: 'DEV / DEBUG / TEST'
				},
				{
					xtype: 'button',
					handler: function(button, e) {
						var TEMP_ID = "{BA8780A3-9D57-40D5-8623-7033A31323D8}";

						var mainView = this.up('#mainView');
						var newActiveItem = mainView.setActiveItem('editSlides');

						var localStorageData = Ext.decode(localStorage.getItem('mxp_elearning'));

						if(!localStorageData){
							localStorageData = {};
						}
						if(!localStorageData[TEMP_ID]){
							localStorageData[TEMP_ID] = {};
						}
						for (var key in localStorageData[TEMP_ID]) {
							if(!localStorageData[TEMP_ID][key]){
								localStorageData[TEMP_ID][key]={};
							}
						}
						localStorage.setItem('mxp_elearning', Ext.encode(localStorageData));

						newActiveItem.getController().load({ program :{
							data:{
								"active":true,
								"categoryId":30231143,
								"certificateFileName":"",
								"changed":"Y",
								"completionTime":60,
								"created":"2018-07-23T12:04:00",
								"createdAtId":5,
								"createdById":0,
								"description":"New Training Program Description",
								"id":TEMP_ID,
								"lastChangeLogId":191175066,
								"lastChanges":"2018-07-23T12:04:00",
								"maxAttemptsScoreMode":1000,
								"maxAttemptsTrainingMode":1000,
								"name":"First program",
								"passScore":2,
								"programId":50000026,
								"validFrom":"2018-07-23T00:00:00",
								"validTo":"2019-07-23T00:00:00"
							},
							id :TEMP_ID
						} }); // with programId
					},
					text: 'Edit Pages'
				},
				{
					xtype: 'button',
					handler: function(button, e) {
						Ext.toast('This is a toast message');
					},
					text: 'Test'
				}
			]
		}
	]

});