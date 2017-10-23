// Extend Ext.pluck to search down using '.' operator
Ext.pluck2 = function(array, propertyName) {
    var ret = [],
        i, ln, item,
        propertyArray = propertyName.split('.');
    
    for (i = 0, ln = array.length; i < ln; i++) {
        item = array[i];
        
        for (p = 0; p < propertyArray.length; p++) {
            item = item[propertyArray[p]];
        }
        ret.push(item);
    }
    
    return ret;
};
