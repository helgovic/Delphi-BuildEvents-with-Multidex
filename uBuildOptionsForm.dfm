object BuildOptionsForm: TBuildOptionsForm
  Left = 527
  Top = 274
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Build Events'
  ClientHeight = 580
  ClientWidth = 575
  Color = 3288877
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    575
    580)
  PixelsPerInch = 96
  TextHeight = 13
  object AdvGroupBox1: TAdvGroupBox
    Left = 0
    Top = 0
    Width = 575
    Height = 517
    BorderColor = clBlue
    Align = alTop
    Caption = 'Pre / Post -Build Events'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object lblSize: TLabel
      Left = 381
      Top = 477
      Width = 33
      Height = 16
      Caption = 'Si&ze :'
      FocusControl = SpinEditSize
    end
    object Label1: TLabel
      Left = 5
      Top = 28
      Width = 66
      Height = 16
      Caption = 'Parameters'
      FocusControl = SpinEditSize
    end
    object Label2: TLabel
      Left = 3
      Top = 135
      Width = 48
      Height = 16
      Caption = 'Platform'
      FocusControl = SpinEditSize
    end
    object Label3: TLabel
      Left = 286
      Top = 135
      Width = 76
      Height = 16
      Caption = 'Configuration'
      FocusControl = SpinEditSize
    end
    object Label4: TLabel
      Left = 3
      Top = 476
      Width = 116
      Height = 16
      Caption = 'Build Messages Font'
      FocusControl = SpinEditSize
    end
    object Label5: TLabel
      Left = 3
      Top = 450
      Width = 118
      Height = 16
      Caption = 'Run Postbuild Events'
      FocusControl = SpinEditSize
    end
    object CLBParams: TCheckListBox
      Left = 3
      Top = 50
      Width = 553
      Height = 75
      Color = 3288877
      PopupMenu = PUParams
      TabOrder = 4
    end
    object SpinEditSize: TSpinEdit
      Left = 420
      Top = 477
      Width = 50
      Height = 26
      Hint = 'Font Size'
      Color = 3288877
      MaxLength = 2
      MaxValue = 20
      MinValue = 8
      TabOrder = 5
      Value = 10
    end
    object CBPlatForms: TComboBox
      Left = 5
      Top = 156
      Width = 275
      Height = 24
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      Color = 3288877
      TabOrder = 2
      OnChange = CBPlatFormsChange
      OnDropDown = CBPlatFormsDropDown
      OnSelect = CBPlatFormsSelect
    end
    object CBConfig: TComboBox
      Left = 286
      Top = 156
      Width = 275
      Height = 24
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      Color = 3288877
      TabOrder = 0
      OnChange = CBConfigChange
      OnDropDown = CBConfigDropDown
      OnSelect = CBConfigSelect
      Items.Strings = (
        'Debug'
        'Release')
    end
    object cbFontNames: TComboBox
      Left = 125
      Top = 474
      Width = 250
      Height = 24
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      Color = 3288877
      TabOrder = 1
    end
    object cbPostBuildEvents: TComboBox
      Left = 125
      Top = 446
      Width = 250
      Height = 24
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      Color = 3288877
      TabOrder = 3
      Items.Strings = (
        'Always'
        'On succes'
        'On failed'
        'Never')
    end
    object TSPostBuild: TToggleSwitch
      Left = 5
      Top = 316
      Width = 175
      Height = 20
      Color = 3288877
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      FrameColor = clWhite
      ParentFont = False
      StateCaptions.CaptionOn = 'Run post build events'
      StateCaptions.CaptionOff = 'Don'#39't run post build events'
      SwitchWidth = 40
      TabOrder = 7
      ThumbColor = clGreen
      OnClick = TSPostBuildClick
    end
    object TSPrebuild: TToggleSwitch
      Left = 5
      Top = 188
      Width = 167
      Height = 20
      Color = 3288877
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      FrameColor = clWhite
      ParentFont = False
      StateCaptions.CaptionOn = 'Run prebuild events'
      StateCaptions.CaptionOff = 'Don'#39't run prebuild events'
      SwitchWidth = 40
      TabOrder = 8
      ThumbColor = clGreen
      OnClick = TSPrebuildClick
    end
    object ACGPostbuild: TStringGrid
      Left = 5
      Top = 338
      Width = 559
      Height = 95
      BevelInner = bvNone
      BevelOuter = bvNone
      Color = 3288877
      ColCount = 3
      Ctl3D = True
      DefaultRowHeight = 22
      DefaultDrawing = False
      DrawingStyle = gdsClassic
      FixedColor = clBlack
      FixedCols = 0
      RowCount = 2
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      GradientEndColor = clBlack
      GradientStartColor = clGray
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
      ParentCtl3D = False
      ParentFont = False
      PopupMenu = PUPostBuild
      ScrollBars = ssVertical
      TabOrder = 6
      OnDrawCell = ACGPostbuildDrawCell
    end
    object ACGPreBuild: TStringGrid
      Left = 3
      Top = 214
      Width = 559
      Height = 95
      BevelInner = bvNone
      BevelOuter = bvNone
      Color = 3288877
      ColCount = 3
      Ctl3D = True
      DefaultRowHeight = 22
      DefaultDrawing = False
      DrawingStyle = gdsClassic
      FixedColor = clBlack
      FixedCols = 0
      RowCount = 2
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      GradientEndColor = clBlack
      GradientStartColor = clGray
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
      ParentCtl3D = False
      ParentFont = False
      PopupMenu = PUPreBuild
      ScrollBars = ssVertical
      TabOrder = 9
      OnDrawCell = ACGPostbuildDrawCell
    end
  end
  object TSMessages: TToggleSwitch
    Left = 381
    Top = 422
    Width = 174
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
    StateCaptions.CaptionOn = 'Show build messages'
    StateCaptions.CaptionOff = 'Don'#39't show build messages'
    SwitchWidth = 40
    TabOrder = 1
    ThumbColor = clGreen
  end
  object BSave: TButton
    Left = 136
    Top = 539
    Width = 75
    Height = 25
    Anchors = [akTop]
    Caption = 'Save'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    TabStop = False
    OnClick = BSaveClick
  end
  object btnCancel: TButton
    Left = 363
    Top = 539
    Width = 75
    Height = 25
    Anchors = [akTop]
    Caption = '&Cancel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 2
    ParentFont = False
    TabOrder = 3
    TabStop = False
  end
  object btnLoad: TButton
    Left = 212
    Top = 539
    Width = 75
    Height = 25
    Anchors = [akTop]
    Caption = '&Load'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    TabStop = False
    OnClick = btnLoadClick
  end
  object btnOK: TButton
    Left = 288
    Top = 539
    Width = 75
    Height = 25
    Anchors = [akTop]
    Caption = 'O&K'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 5
    TabStop = False
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.ini'
    Filter = 'Configuration files|*.ini|Text Files|*.txt|All Files|*.*'
    Left = 292
    Top = 200
  end
  object PUPreBuild: TPopupMenu
    OnPopup = PUPreBuildPopup
    Left = 372
    Top = 208
    object PreNewEvent: TMenuItem
      Caption = 'New Event'
      OnClick = PreNewEventClick
    end
    object PreEditEvent: TMenuItem
      Caption = 'Edit Event'
      OnClick = PreEditEventClick
    end
    object PreDeleteEvent: TMenuItem
      Caption = 'Delete Event'
      OnClick = PreDeleteEventClick
    end
  end
  object PUPostBuild: TPopupMenu
    OnPopup = PUPostBuildPopup
    Left = 440
    Top = 206
    object PostNewEvent: TMenuItem
      Caption = 'New Event'
      OnClick = PostNewEventClick
    end
    object PostEditEvent: TMenuItem
      Caption = 'Edit Event'
      OnClick = PostEditEventClick
    end
    object PostDeleteEvent: TMenuItem
      Caption = 'Delete Event'
      OnClick = PostDeleteEventClick
    end
  end
  object PUParams: TPopupMenu
    OnPopup = PUParamsPopup
    Left = 292
    Top = 314
    object AddParam1: TMenuItem
      Caption = 'Add Parameter'
      OnClick = AddParam1Click
    end
    object DeleteParameter1: TMenuItem
      Caption = 'Delete Parameter'
      OnClick = DeleteParameter1Click
    end
  end
end
