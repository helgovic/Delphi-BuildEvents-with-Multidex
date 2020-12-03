object BuildCommandEditorDlg: TBuildCommandEditorDlg
  Left = 649
  Top = 402
  Caption = 'Macro Editor'
  ClientHeight = 677
  ClientWidth = 660
  Color = 3288877
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 15
  object PanelBase: TPanel
    Left = 0
    Top = 65
    Width = 660
    Height = 552
    Align = alClient
    BevelEdges = []
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 0
      Top = 236
      Width = 660
      Height = 6
      Cursor = crVSplit
      Align = alTop
      Color = clHotLight
      ParentColor = False
      ExplicitWidth = 650
    end
    object Editor: TMemo
      Left = 0
      Top = 0
      Width = 660
      Height = 236
      Align = alTop
      BevelEdges = []
      BevelOuter = bvNone
      BorderStyle = bsNone
      Color = 3288877
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object VLEMacros: TValueListEditor
      Left = 0
      Top = 242
      Width = 660
      Height = 310
      Align = alClient
      BorderStyle = bsNone
      Color = 3288877
      Ctl3D = True
      DrawingStyle = gdsGradient
      FixedColor = 3288877
      FixedCols = 1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      GradientEndColor = 3288877
      GradientStartColor = clGray
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goThumbTracking]
      ParentCtl3D = False
      ParentFont = False
      PopupMenu = pmMacro
      Strings.Strings = (
        '=')
      TabOrder = 1
      TitleCaptions.Strings = (
        'Macro'
        'Value')
      OnDblClick = VLEMacrosDblClick
      ColWidths = (
        192
        466)
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 660
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 16
      Top = 8
      Width = 54
      Height = 15
      Caption = 'Parameter'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object CBParam: TComboBox
      Left = 16
      Top = 29
      Width = 250
      Height = 23
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      Color = 3288877
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnDropDown = CBParamDropDown
      Items.Strings = (
        'Always'
        'On succes'
        'On failed'
        'Never')
    end
    object TSParm: TToggleSwitch
      Left = 292
      Top = 29
      Width = 154
      Height = 20
      Color = 3288877
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      FrameColor = clWhite
      ParentFont = False
      State = tssOn
      StateCaptions.CaptionOn = 'Parameter must be on'
      StateCaptions.CaptionOff = 'Parameter must be off'
      SwitchWidth = 40
      TabOrder = 1
      ThumbColor = clGreen
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 617
    Width = 660
    Height = 60
    Align = alBottom
    TabOrder = 2
    DesignSize = (
      660
      60)
    object ButtonCancel: TPanel
      Left = 551
      Top = 18
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Cancel'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 0
      TabStop = True
      OnClick = ButtonCancelClick
    end
    object ButtonInsert: TPanel
      Left = 393
      Top = 18
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Insert'
      Color = clBlack
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 1
      TabStop = True
      OnClick = ButtonInsertClick
    end
    object ButtonOK: TPanel
      Left = 472
      Top = 18
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 2
      TabStop = True
      OnClick = ButtonOKClick
    end
    object ButtonToggle: TPanel
      Left = 34
      Top = 18
      Width = 100
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = '<< Macros'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 3
      TabStop = True
      OnClick = ButtonToggleClick
    end
  end
  object pmMacro: TPopupMenu
    OnPopup = pmMacroPopup
    Left = 286
    Top = 316
    object mniAddMacro: TMenuItem
      Caption = 'Add'
      OnClick = mniAddMacroClick
    end
    object mniEditMacro: TMenuItem
      Caption = 'Edit'
      OnClick = mniEditMacroClick
    end
    object mniDeleteMacro: TMenuItem
      Caption = 'Delete'
      OnClick = mniDeleteMacroClick
    end
  end
end
