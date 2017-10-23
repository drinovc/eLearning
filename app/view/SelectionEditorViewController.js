/*
 * File: app/view/SelectionEditorViewController.js
 *
 * This file was generated by Sencha Architect version 4.2.2.
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

Ext.define('eLearning.view.SelectionEditorViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.selectioneditor',

    show: function(opts) {
        opts = Ext.applyIf(opts, {
            callback: function(value) { console.log('Please specify a callback!', value); },
            scope: this
        });

        var me = this,
            refs = me.getReferences(),
            view = me.getView();

        me._opts = opts;

        view.show();
    },

    btnSaveHandler: function(button, e) {
        var me = this,
            refs = me.getReferences(),
            opts = me._opts,
            answers = refs.grid.store.data.items,
            reason = opts.callback.call(opts.scope, Ext.pluck(answers, 'data'));

        if(reason) {
            Ext.Msg.alert('Note', reason);
        }
        else {
            me.getView().close();
        }
    },

    btnCancelHandler: function(button, e) {
        var me = this;

        me.getView().close();
    },

    btnAddHandler: function(button, e) {
        var me = this,
            refs = me.getReferences(),
            sequence = Ext.Array.max(Ext.pluck2(refs.grid.store.data.items, 'data.sequence')) || 0;

        sequence++;

        refs.grid.store.add({
            sequence: sequence,
            text: 'New Answer ' + sequence
        });
    },

    btnRemoveHandler: function(button, e) {
        var me = this,
            refs = me.getReferences(),
            rec = refs.grid.getSelection()[0];

        refs.grid.store.remove(rec);
    }

});
