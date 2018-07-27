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
    try {
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
    catch (e) {} 

    console.log("printing filtered data", data);
    
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