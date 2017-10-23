/*
 * File: app/view/SelectionEditor.js
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

Ext.define('eLearning.view.SelectionEditor', {
    extend: 'Ext.window.Window',
    alias: 'widget.selectioneditor',

    requires: [
        'eLearning.view.SelectionEditorViewModel',
        'eLearning.view.SelectionEditorViewController',
        'Ext.toolbar.Toolbar',
        'Ext.button.Button',
        'Ext.grid.Panel',
        'Ext.grid.column.RowNumberer',
        'Ext.form.field.Text',
        'Ext.view.Table',
        'Ext.grid.plugin.DragDrop',
        'Ext.util.Point',
        'Ext.grid.column.Check',
        'Ext.grid.plugin.CellEditing'
    ],

    controller: 'selectioneditor',
    viewModel: {
        type: 'selectioneditor'
    },
    modal: true,
    height: 600,
    itemId: 'selectioneditor',
    width: 1000,
    layout: 'fit',
    title: 'Selection editor',

    dockedItems: [
        {
            xtype: 'toolbar',
            dock: 'bottom',
            ui: 'footer',
            layout: {
                type: 'hbox',
                pack: 'center'
            },
            items: [
                {
                    xtype: 'button',
                    handler: 'btnSaveHandler',
                    itemId: 'btnSave',
                    text: 'Save'
                },
                {
                    xtype: 'button',
                    handler: 'btnCancelHandler',
                    itemId: 'btnCancel',
                    text: 'Cancel'
                }
            ]
        }
    ],
    items: [
        {
            xtype: 'gridpanel',
            reference: 'grid',
            itemId: 'grid',
            title: '',
            bind: {
                store: '{StoreAnswers}'
            },
            columns: [
                {
                    xtype: 'rownumberer'
                },
                {
                    xtype: 'gridcolumn',
                    flex: 1,
                    cellWrap: true,
                    dataIndex: 'text',
                    text: 'Answer text',
                    editor: {
                        xtype: 'textfield'
                    }
                },
                {
                    xtype: 'checkcolumn',
                    dataIndex: 'correct',
                    text: 'Correct'
                }
            ],
            viewConfig: {
                plugins: [
                    {
                        ptype: 'gridviewdragdrop'
                    }
                ]
            },
            plugins: [
                {
                    ptype: 'cellediting',
                    clicksToEdit: 1
                }
            ],
            dockedItems: [
                {
                    xtype: 'toolbar',
                    dock: 'top',
                    items: [
                        {
                            xtype: 'button',
                            handler: 'btnAddHandler',
                            itemId: 'btnAdd',
                            text: 'Add'
                        },
                        {
                            xtype: 'button',
                            handler: 'btnRemoveHandler',
                            itemId: 'btnRemove',
                            text: 'Remove'
                        }
                    ]
                }
            ]
        }
    ]

});