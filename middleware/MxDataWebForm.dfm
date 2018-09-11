object FHttpRest: TFHttpRest
  Left = 0
  Top = 0
  Caption = 'MxData REST server'
  ClientHeight = 245
  ClientWidth = 506
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    506
    245)
  PixelsPerInch = 96
  TextHeight = 13
  object meLog: TMemo
    Left = 8
    Top = 8
    Width = 490
    Height = 209
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object chLog: TCheckBox
    Left = 8
    Top = 223
    Width = 153
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Display Log'
    Checked = True
    State = cbChecked
    TabOrder = 1
    OnClick = chLogClick
  end
  object chResponse: TCheckBox
    Left = 391
    Top = 223
    Width = 107
    Height = 17
    Anchors = [akRight, akBottom]
    Caption = 'Display Response'
    TabOrder = 2
    OnClick = chLogClick
  end
  object hsRest: TIdHTTPServer
    Bindings = <>
    DefaultPort = 88
    ListenQueue = 50
    KeepAlive = True
    OnCommandOther = hsRestCommandGet
    OnCommandGet = hsRestCommandGet
    Left = 32
    Top = 32
  end
  object ApplicationEvents1: TApplicationEvents
    OnException = ApplicationEvents1Exception
    Left = 328
    Top = 40
  end
end
