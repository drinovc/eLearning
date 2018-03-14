/*
 * File: app/view/FileUpload.js
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

Ext.define('eLearning.view.FileUpload', {
    extend: 'Ext.window.Window',
    alias: 'widget.fileupload',

    requires: [
        'eLearning.view.FileUploadViewModel',
        'eLearning.view.FileUploadViewController',
        'Ext.form.Panel',
        'Ext.form.field.File',
        'Ext.form.field.FileButton',
        'Ext.toolbar.Toolbar'
    ],

    controller: 'fileupload',
    viewModel: {
        type: 'fileupload'
    },
    modal: true,
    width: 500,
    title: 'File Upload',

    items: [
        {
            xtype: 'form',
            bodyPadding: 10,
            title: '',
            items: [
                {
                    xtype: 'textfield',
                    anchor: '1',
                    fieldLabel: 'Name',
                    name: 'name'
                },
                {
                    xtype: 'filefield',
                    anchor: '100%',
                    fieldLabel: 'File',
                    name: 'file',
                    emptyText: 'Select a file',
                    buttonConfig: {
                        xtype: 'filebutton',
                        iconCls: 'x-fa fa-paperclip',
                        text: ''
                    }
                }
            ]
        }
    ],
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
                    minWidth: 100,
                    text: 'Upload'
                },
                {
                    xtype: 'button',
                    handler: 'btnCancelHandler',
                    itemId: 'btnCancel',
                    minWidth: 100,
                    text: 'Cancel'
                }
            ]
        }
    ]

});