object MacroEditor: TMacroEditor
  Left = 289
  Top = 233
  BorderStyle = bsDialog
  Caption = 'Macro Editor'
  ClientHeight = 120
  ClientWidth = 466
  Color = 3288877
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  DesignSize = (
    466
    120)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 20
    Width = 63
    Height = 13
    Caption = 'Macro Name:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 22
    Top = 46
    Width = 58
    Height = 13
    Caption = 'Macro Path:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object edMacroName: TEdit
    Left = 84
    Top = 16
    Width = 365
    Height = 21
    Color = 3288877
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnChange = edMacroNameChange
  end
  object edMacroPath: TEdit
    Left = 84
    Top = 44
    Width = 365
    Height = 21
    Color = 3288877
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnChange = edMacroNameChange
  end
  object ButtonOK: TPanel
    Left = 157
    Top = 76
    Width = 75
    Height = 25
    Anchors = [akBottom]
    Caption = 'OK'
    Color = clBlack
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 2
    TabStop = True
    OnClick = ButtonOKClick
  end
  object ButtonCancel: TPanel
    Left = 237
    Top = 76
    Width = 75
    Height = 25
    Anchors = [akBottom]
    Caption = 'Cancel'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 3
    TabStop = True
    OnClick = ButtonCancelClick
  end
end
