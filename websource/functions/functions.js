function syntaxHighlight(json) {
	if (typeof json != 'string') {
		json = JSON.stringify(json, undefined, 2);
	}
	json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
	return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
		var cls = 'number';
		if (/^"/.test(match)) {
			if (/:$/.test(match)) {
				cls = 'key';
			} else {
				cls = 'string';
			}
		} else if (/true|false/.test(match)) {
			cls = 'boolean';
		} else if (/null/.test(match)) {
			cls = 'null';
		}
		return '<span class="' + cls + '">' + match + '</span>';
	});
}

function isNull(value, defaultValue) {
	if(value === undefined || value === null) {
		return defaultValue;
	}
	else {
		return value;
	}
}

function loremIpsum() {
	return 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
}

function createGUID() {
	var GUID = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx';

	GUID = GUID.replace(/[xy]/g, function(c) {
		var r = Math.random() * 16 | 0,
			v = c == 'x' ? r : (r & 0x3 | 0x8);
		return v.toString(16);
	});

	return '{' + GUID.toUpperCase() + '}';
}

function cleanTreeNodeData(data) {
	data = Ext.clone(data);

	try {
		delete data.allowDrag;
		delete data.allowDrop;
		//delete data.checked;
		delete data.children;
		delete data.cls;
		//delete data.depth;
		delete data.expandable;
		//delete data.expanded;
		delete data.glyph;
		delete data.href;
		delete data.hrefTarget;
		delete data.icon;
		delete data.iconCls;
		delete data.index;
		delete data.isFirst;
		delete data.isLast;
		//delete data.leaf;
		delete data.loaded;
		delete data.loading;
		//delete data.parentId;
		delete data.qshowDelay;
		delete data.qtip;
		delete data.qtitle;
		delete data.root;
		delete data.text;
		delete data.visible;

	}
	catch (e) {} 

	// delete content for selection components
	if(data && data.content){
		var content = Ext.decode(data.content);

		for (var key in content.components){
			var el = content.components[key];
			if(el.type == "Single selection" || el.type == "Multi selection" ||el.type == "selection"){
				delete el.options;
				delete el.html;
				delete el.id;
				delete el.cls;
				delete el.style;
				delete el.multi;


			}
		}
		data.content = Ext.encode(content);
	}



	return data;
}








function sumDict(obj) {
	var sum = 0;
	for( var el in obj ) {
		if( obj.hasOwnProperty( el ) ) {
			sum += parseFloat( obj[el] );
		}
	}
	return sum;
}

// making shortcut for console.log()
var print = console.log.bind(console);




/* Close fullscreen */
function closeFullscreen() {
	if (document.exitFullscreen) {
		document.exitFullscreen();
	} else if (document.mozCancelFullScreen) { /* Firefox */
		document.mozCancelFullScreen();
	} else if (document.webkitExitFullscreen) { /* Chrome, Safari and Opera */
		document.webkitExitFullscreen();
	} else if (document.msExitFullscreen) { /* IE/Edge */
		document.msExitFullscreen();
	}
}







function getAjax(url, params, name){

	/*
		Ext.Ajax.request({
		    url: 'feed.json',
		}).then(function(response) {
		    // use response
		}).always(function() {
		   // clean-up logic, regardless the outcome
		}).otherwise(function(reason){
		   // handle failure
		});
		*/

	return new Ext.Promise(function (resolve, reject) {
		Ext.Ajax.request({
			url: url,
			params: params,
			success: function (response) {
				var rObj = Ext.decode(response.responseText || '{}');

				if(rObj.success) {
					resolve({
						name: name,
						data: rObj.data,
					});
				}
				else {
					reject(rObj.reason || 'Success false');
				}
			},
			failure: function (response) {
				reject(response.status);
			}
		});
	});
}






function loadLookups(callback){

	Ext.Promise.all([
		getAjax('/Lookups/ProgramCategories', {}, 'ProgramCategories'),
		getAjax('/Lookups/ProgramPageCategories', {}, 'ProgramPageCategories'),
		getAjax('/Lookups/CoursesAndCertificates', {}, 'CoursesAndCertificates'),
		getAjax('/Lookups/ProgramStatuses', {}, 'ProgramStatuses')
	]).then(function(data) {
		Ext.each(data, function(data) {
			App.lookups[data.name] = data.data;
		});

		var i = 0,
			obj = null;

		// Getting ProgramPageCategories into dictionary where key is text ('Chapter', 'Page') and value is id (1, 2)
		App.ProgramPageCategoriesEnum = {};
		for(i = 0; i < App.lookups.ProgramPageCategories.length; i++){
			obj = App.lookups.ProgramPageCategories[i];
			App.ProgramPageCategoriesEnum[obj.text] = obj.id;
		}
		Object.freeze(App.ProgramPageCategoriesEnum); // freezing enum so it cannot be changed later

		// Getting ProgramStatuses into dictionary where key is text ('In Progress', 'Passed'...) and value is id (1, 2...)
		App.ProgramStatuses = {};
		for(i = 0; i < App.lookups.ProgramStatuses.length; i++){
			obj = App.lookups.ProgramStatuses[i];
			App.ProgramStatuses[obj.text] = obj.id;
		}
		Object.freeze(App.ProgramStatuses); // freezing enum so it cannot be changed later

		// Getting Programs and certificates into dictionary where key is text ('In Progress', 'Passed'...) and value is id (1, 2...)
		App.CoursesAndCertificates = {};
		for(i = 0; i < App.lookups.CoursesAndCertificates.length; i++){
			obj = App.lookups.CoursesAndCertificates[i];
			App.CoursesAndCertificates[obj.id] = obj.text;
		}
		Object.freeze(App.CoursesAndCertificates); // freezing enum so it cannot be changed later

		if(callback){ callback(); }
	}, function(err) {
		Ext.Msg.alert('Load Lookups Error', err);
	});
}