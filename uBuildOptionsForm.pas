unit uBuildOptionsForm;

{$I BuildEvents.Inc}

interface

uses
  Windows, Messages, SysUtils, {$IFDEF D6_UP}Variants, {$ENDIF} Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls, Buttons, ComCtrls, ExtCtrls,
  uBuildMisc, Spin, Vcl.Menus,
  ToolsAPI, AdvCombo, ColListb, Vcl.Grids, AdvObj, BaseGrid, AdvGrid, AdvCGrid,
  Vcl.CheckLst, AdvSmoothListBox, AdvSmoothComboBox, AdvGroupBox,
  AdvSmoothTabPager, JvExComCtrls, JvHotKey, AdvOfficeButtons, AdvSmoothButton,
  Vcl.WinXCtrls;

type

  TBuildOptionsForm = class(TForm)
    OpenDialog1: TOpenDialog;
    PUPreBuild: TPopupMenu;
    PreNewEvent: TMenuItem;
    PreEditEvent: TMenuItem;
    PreDeleteEvent: TMenuItem;
    PUPostBuild: TPopupMenu;
    PostNewEvent: TMenuItem;
    PostEditEvent: TMenuItem;
    PostDeleteEvent: TMenuItem;
    PUParams: TPopupMenu;
    AddParam1: TMenuItem;
    DeleteParameter1: TMenuItem;
    AdvGroupBox1: TAdvGroupBox;
    lblSize: TLabel;
    Label1: TLabel;
    CLBParams: TCheckListBox;
    SpinEditSize: TSpinEdit;
    CBPlatForms: TComboBox;
    CBConfig: TComboBox;
    cbFontNames: TComboBox;
    cbPostBuildEvents: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    TSMessages: TToggleSwitch;
    TSPostBuild: TToggleSwitch;
    TSPrebuild: TToggleSwitch;
    BSave: TPanel;
    btnCancel: TPanel;
    btnLoad: TPanel;
    btnOK: TPanel;
    ACGPostbuild: TStringGrid;
    ACGPreBuild: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure cbFontNamesDrawItem(AControl: TWinControl; AIndex: Integer;
      ARect: TRect; AState: TOwnerDrawState);
    procedure PreNewEventClick(Sender: TObject);
    procedure PreEditEventClick(Sender: TObject);
    procedure PreDeleteEventClick(Sender: TObject);
    procedure PostNewEventClick(Sender: TObject);
    procedure PostDeleteEventClick(Sender: TObject);
    procedure PostEditEventClick(Sender: TObject);
    procedure CBConfigDropDown(Sender: TObject);
    procedure CBPlatFormsDropDown(Sender: TObject);
    procedure AddParam1Click(Sender: TObject);
    procedure PUPreBuildPopup(Sender: TObject);
    procedure PUPostBuildPopup(Sender: TObject);
    procedure PUParamsPopup(Sender: TObject);
    procedure DeleteParameter1Click(Sender: TObject);
    procedure BSaveClick(Sender: TObject);
    procedure CBConfigChange(Sender: TObject);
    procedure CBPlatFormsChange(Sender: TObject);
    procedure TSPrebuildClick(Sender: TObject);
    procedure TSPostBuildClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure ACGPostbuildDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    function GetFontNameIndex(AName: String): Integer;
    function GetSelectedFontName: String;
    procedure LoadFontNames;
    procedure EnablePostBuild(AEnabled: Boolean);
    procedure EnablePreBuild(AEnabled: Boolean);
    procedure SetScreen;
    procedure SaveScreen;
    { Project Properties }
  public
    function Execute(AOptions : TBuildOptions) : Boolean;
  end;

var
   ProjOptions: TProjOptions;
   BuildOptionsForm: TBuildOptionsForm;

implementation

{$R *.dfm}

uses
  Registry,
  ShellAPI,
  uBuildCommandEditor,
  uBuildOptionExpert,
  uBuildEngine,
  UFParam;

procedure DeleteRow(Grid: TStringGrid; ARow: Integer);
var
  i: Integer;
begin
  for i := ARow to Grid.RowCount - 2 do
    Grid.Rows[i].Assign(Grid.Rows[i + 1]);
  Grid.RowCount := Grid.RowCount - 1;
end;

{ TfrmOptions }
function EnumFontsProc(var LogFont: TLogFont; var TextMetric: TTextMetric;
  FontType: Integer; Data: Pointer): Integer; stdcall;
begin
  TStrings(Data).Add(LogFont.lfFaceName);
  Result := 1;
end;

procedure TBuildOptionsForm.LoadFontNames;
var
  DC: HDC;
  FontStrings: TStringList;
  i: integer;

begin

  FontStrings := TStringList.Create;

  DC := GetDC(0);
  EnumFonts(DC, nil, @EnumFontsProc, Pointer(FontStrings));
  ReleaseDC(0, DC);

  cbFontNames.Items.Clear;

  for i := 0 to FontStrings.Count - 1 do
     cbFontNames.Items.Add(FontStrings[i]);

   FontStrings.DisposeOf;

end;

function TBuildOptionsForm.GetFontNameIndex(AName: String): Integer;
begin
  Result := cbFontNames.Items.IndexOf(AName);
end;

function TBuildOptionsForm.GetSelectedFontName: String;
begin
  Result := Trim(cbFontNames.Text);
  if (Result = EmptyStr) then Result := C_DEFAULT_FONT_NAME;
end;

function TBuildOptionsForm.Execute(AOptions: TBuildOptions): Boolean;

var
  i: Integer;
  PlatForms: TArray<string>;
  CurrentProject: IOTAProject;
  Param: TParam;

begin

  Caption := Format('Build Events for %s', [ExtractFileName(GetCurrentProjectName)]);

  TSMessages.State := TToggleSwitchState(Ord(BuildOptionExpert.ShowMessages));

  cbFontNames.ItemIndex := GetFontNameIndex(BuildOptionExpert.FontName);
  SpinEditSize.Value := BuildOptionExpert.FontSize;

  CurrentProject := GetCurrentProject;
  PlatForms := CurrentProject.SupportedPlatforms;

  CBConfig.OnChange := nil;

  CBConfig.ItemIndex := CBConfig.Items.IndexOf(CurrentProject.CurrentConfiguration);

  CBPlatForms.OnChange := nil;

  CBPlatForms.Items.Clear;

  for i := 0 to Length(PlatForms) - 1 do
     CBPlatForms.Items.Add(PlatForms[i]);

  CBPlatForms.ItemIndex:= CBPlatForms.Items.IndexOf(CurrentProject.CurrentPlatform);

//  CBConfig.OnChange := CBConfigItemChanged;
//  CBPlatForms.OnChanged := CBPlatFormsItemChanged;

  CLBParams.Clear;

  for i := 0 to ProjOptions.FParams.Count - 1 do
     Begin
        CLBParams.AddItem(ProjOptions.FParams[i].Name, nil);
        CLBParams.Checked[i] := ProjOptions.FParams[i].OnOff;
     end;

  SetScreen;

  Result := (ShowModal = mrOK);

  if Result then
  begin

    BuildOptionExpert.FontSize := SpinEditSize.Value;
    BuildOptionExpert.FontName := GetSelectedFontName;
    BuildOptionExpert.ShowMessages := Bool(Ord(TSMessages.State));

     with TRegIniFile.Create(REG_KEY) do
     try
       WriteBool(REG_BUILD_OPTIONS, 'Show Messages', BuildOptionExpert.FShowMsg);
       WriteInteger(REG_BUILD_OPTIONS, 'Font Size', BuildOptionExpert.FFontSize);
       WriteString(REG_BUILD_OPTIONS, 'Font Name', BuildOptionExpert.FFontName);
     finally
       Free;
     end;

    ProjOptions.FParams.Clear;

    for i := 0 to CLBParams.Count - 1 do
       begin
          Param.Name := CLBParams.Items[i];
          Param.OnOff := CLBParams.Checked[i];
          ProjOptions.FParams.Add(Param);
       end;

    ProjOptions.Save;

    SaveScreen;

    AOptions.SaveAll;

    BuildOptionExpert.SetAutoSaveOptions;

  end;

end;

procedure TBuildOptionsForm.FormCreate(Sender: TObject);
begin

  LoadFontNames;

  ACGPostbuild.ColWidths[0] := 410;
  ACGPostbuild.ColWidths[1] := 74;
  ACGPostbuild.ColWidths[2] := 64;
  ACGPostbuild.Cells[0, 0] := 'Command';
  ACGPostbuild.Cells[1, 0] := 'Parameter';
  ACGPostbuild.Cells[2, 0] := 'On/Off';

  ACGPrebuild.ColWidths[0] := 410;
  ACGPrebuild.ColWidths[1] := 74;
  ACGPrebuild.ColWidths[2] := 64;
  ACGPrebuild.Cells[0, 0] := 'Command';
  ACGPrebuild.Cells[1, 0] := 'Parameter';
  ACGPrebuild.Cells[2, 0] := 'On/Off';

end;

procedure TBuildOptionsForm.SetScreen;

var
   PlatformConfigBuildOptions: TPlatformConfigBuildOptions;
   i: integer;

begin

   PlatformConfigBuildOptions := BuildOptionExpert.Options.GetPlatformConfigBuildOptions(CBPlatForms.Text + CBConfig.Text);

   ACGPreBuild.RowCount := 2;
   ACGPreBuild.Rows[1].Clear;

   for i := 0 to PlatformConfigBuildOptions.PreBuildEvents.Count - 1 do
      begin

         if i > 0
         then
            ACGPreBuild.RowCount := ACGPreBuild.RowCount + 1;

         ACGPreBuild.Cells[0, i + 1] := PlatformConfigBuildOptions.PreBuildEvents[i].Command;
         ACGPreBuild.Cells[1, i + 1] := PlatformConfigBuildOptions.PreBuildEvents[i].Param;

         if PlatformConfigBuildOptions.PreBuildEvents[i].OnOff
         then
            ACGPreBuild.Cells[2, i + 1] := 'On'
         else
            ACGPreBuild.Cells[2, i + 1] := 'Off';

      end;

   ACGPostBuild.RowCount := 2;
   ACGPostBuild.Rows[1].Clear;

   for i := 0 to PlatformConfigBuildOptions.PostBuildEvents.Count - 1 do
      begin

         if i > 0
         then
            ACGPostBuild.RowCount := ACGPostBuild.RowCount + 1;

         ACGPostBuild.Cells[0, i + 1] := PlatformConfigBuildOptions.PostBuildEvents[i].Command;
         ACGPostBuild.Cells[1, i + 1] := PlatformConfigBuildOptions.PostBuildEvents[i].Param;

         if PlatformConfigBuildOptions.PostBuildEvents[i].OnOff
         then
            ACGPostBuild.Cells[2, i + 1] := 'On'
         else
            ACGPostBuild.Cells[2, i + 1] := 'Off';

      end;

   cbPostBuildEvents.ItemIndex :=
     Integer(PlatformConfigBuildOptions.PostBuildOption);

   TSPrebuild.State := TToggleSwitchState(Ord(PlatformConfigBuildOptions.PreBuildEnabled));
   TSPostBuild.State := TToggleSwitchState(Ord(PlatformConfigBuildOptions.PostBuildEnabled));

end;

procedure TBuildOptionsForm.TSPostBuildClick(Sender: TObject);
begin
  EnablePostBuild(Bool(Ord(TSPostBuild.State)));
end;

procedure TBuildOptionsForm.TSPrebuildClick(Sender: TObject);
begin

  EnablePreBuild(Bool(Ord(TSPreBuild.State)));

end;

procedure TBuildOptionsForm.ACGPostbuildDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  S: string;
  grid: TStringGrid;
  drawrect: TRect;
  bgFill: TColor;

begin

  grid := Sender as TStringGrid;

   if gdFixed in State then
       bgFill := clBlack
     else
     if gdSelected in State then
       bgFill := clBlue
     else
       bgFill := clWhite;

  grid.Canvas.Brush.Color := bgFill;
  grid.canvas.Brush.Style := bsSolid;
  grid.canvas.fillrect(Rect);

  S := grid.Cells[ACol, ARow];
  If Length(S) > 0 Then
  Begin
    grid.canvas.Font.Color := clWhite;
    drawrect := Rect;
    drawrect.Inflate(-4 , 0);
    DrawText(grid.canvas.handle, Pchar(S), Length(S), drawrect,
      dt_calcrect or dt_wordbreak or dt_left);
    If (drawrect.bottom - drawrect.top) > grid.RowHeights[ARow] Then
      grid.RowHeights[ARow] := (drawrect.bottom - drawrect.top + 2)
      // changing the row height fires the event again!
    Else
    Begin
      drawrect.Right := Rect.Right;

      grid.canvas.fillrect(drawrect);
      DrawText(grid.canvas.handle, Pchar(S), Length(S), drawrect, dt_wordbreak or dt_left);
    End;
  End;

end;

procedure TBuildOptionsForm.AddParam1Click(Sender: TObject);

var
   i: Integer;
   ParmR: TParam;

begin

   if not Assigned(FAddParam)
   then
      FAddParam := TFAddParam.Create(Application);

   FAddParam.LEParam.Text := '';
   FAddParam.TSParmOffOn.State := tssOff;
   FAddParam.LEParam.Focused;

   if FAddParam.ShowModal = mrOK
   then
      begin

         ParmR.Name := FAddParam.LEParam.Text;
         ParmR.OnOff := Bool(Ord(FAddParam.TSParmOffOn.State));
         ProjOptions.FParams.Add(ParmR);

         i := CLBParams.Items.Add(FAddParam.LEParam.Text);
         CLBParams.Checked[i] := Bool(Ord(FAddParam.TSParmOffOn.State));

      end;

end;

procedure TBuildOptionsForm.BSaveClick(Sender: TObject);

var
   i: integer;
   Param: TParam;

begin

   BuildOptionExpert.FontSize := SpinEditSize.Value;
   BuildOptionExpert.FontName := GetSelectedFontName;
   BuildOptionExpert.ShowMessages := Bool(Ord(TSMessages.State));

   with TRegIniFile.Create(REG_KEY) do
      try
         WriteBool(REG_BUILD_OPTIONS, 'Show Messages', BuildOptionExpert.FShowMsg);
         WriteInteger(REG_BUILD_OPTIONS, 'Font Size', BuildOptionExpert.FFontSize);
         WriteString(REG_BUILD_OPTIONS, 'Font Name', BuildOptionExpert.FFontName);
      finally
         Free;
      end;

   ProjOptions.FParams.Clear;

   for i := 0 to CLBParams.Count - 1 do
      begin
         Param.Name := CLBParams.Items[i];
         Param.OnOff := CLBParams.Checked[i];
         ProjOptions.FParams.Add(Param);
      end;

   ProjOptions.Save;

   SaveScreen;

   BuildOptionExpert.Options.SaveAll;

end;

procedure TBuildOptionsForm.btnCancelClick(Sender: TObject);
begin
   BuildOptionsForm.ModalResult := mrCancel;
end;

procedure TBuildOptionsForm.btnLoadClick(Sender: TObject);
begin

  OpenDialog1.InitialDir := ExtractFilePath(GetCurrentProjectFileName);

  if (OpenDialog1.Execute)
  then
    if FileExists(OpenDialog1.FileName)
    then
       if AnsiLowerCase(ExtractFileExt(OpenDialog1.FileName)) = '.ini'
       then
          begin

             BuildOptionExpert.Options.CopyProjectEvents(OpenDialog1.FileName);

             CBPlatForms.ItemIndex := CBPlatForms.Items.IndexOf(GetCurrentProject.CurrentPlatform);

             CBConfig.ItemIndex := CBConfig.Items.IndexOf(GetCurrentProject.CurrentConfiguration);

          end;

end;

procedure TBuildOptionsForm.btnOKClick(Sender: TObject);
begin
   BuildOptionsForm.ModalResult := mrOK;
end;

procedure TBuildOptionsForm.SaveScreen;

var
   PlatformConfigBuildOptions: TPlatformConfigBuildOptions;
   i: integer;
   Event: TBuildCommand;

begin

   PlatformConfigBuildOptions := BuildOptionExpert.Options.GetPlatformConfigBuildOptions(CBPlatForms.Text + CBConfig.Text);

   PlatformConfigBuildOptions.PreBuildEvents.Clear;

   for i := 1 to ACGPreBuild.RowCount - 1 do
      begin

         if ACGPreBuild.Cells[0, i] = ''
         then
            Break;

         Event.Command := ACGPreBuild.Cells[0, i];
         Event.Param := ACGPreBuild.Cells[1, i];

         if ACGPreBuild.Cells[2, i] = 'On'
         then
            Event.OnOff := True
         else
            Event.OnOff := False;

         PlatformConfigBuildOptions.PreBuildEvents.Add(Event);

      end;

   PlatformConfigBuildOptions.PostBuildEvents.Clear;

   for i := 1 to ACGPostBuild.RowCount - 1 do
      begin

         if ACGPostBuild.Cells[0, i] = ''
         then
            Break;

         Event.Command := ACGPostBuild.Cells[0, i];
         Event.Param := ACGPostBuild.Cells[1, i];

         if ACGPostBuild.Cells[2, i] = 'On'
         then
            Event.OnOff := True
         else
            Event.OnOff := False;

         PlatformConfigBuildOptions.PostBuildEvents.Add(Event);

      end;

   PlatformConfigBuildOptions.PostBuildOption := TPostBuildOption(cbPostBuildEvents.ItemIndex);
   ProjOptions.FileName := ExtractFilePath(GetCurrentProjectFileName);
   PlatformConfigBuildOptions.PreBuildEnabled := Bool(Ord(TSPreBuild.State));
   PlatformConfigBuildOptions.PostBuildEnabled := Bool(Ord(TSPostBuild.State));

end;

procedure TBuildOptionsForm.CBConfigChange(Sender: TObject);
begin
  SetScreen;
end;

procedure TBuildOptionsForm.CBConfigDropDown(Sender: TObject);
begin
   SaveScreen;
end;

procedure TBuildOptionsForm.cbFontNamesDrawItem(AControl: TWinControl;
  AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
begin
  with (AControl as TComboBox).Canvas do
  begin
    FillRect(ARect);
    Font.Name := cbFontNames.Items[AIndex];
    TextOut(ARect.Left, ARect.Top, cbFontNames.Items[AIndex]);
  end;
end;

procedure TBuildOptionsForm.CBPlatFormsChange(Sender: TObject);
begin
  SetScreen;
end;

procedure TBuildOptionsForm.CBPlatFormsDropDown(Sender: TObject);
begin
   SaveScreen;
end;

procedure TBuildOptionsForm.DeleteParameter1Click(Sender: TObject);

var
   i, x: Integer;

begin

   SaveScreen;

   for i := 0 to BuildOptionExpert.Options.FPlatformConfigBuildOptions.Count - 1 do
      begin

         for x := 0 to BuildOptionExpert.Options.FPlatformConfigBuildOptions[i].PreBuildEvents.Count - 1 do
            if BuildOptionExpert.Options.FPlatformConfigBuildOptions[i].PreBuildEvents[x].Param = CLBParams.Items[CLBParams.ItemIndex]
            then
               begin
                  ShowMessage(CLBParams.Items[CLBParams.ItemIndex] + ' is used in PlatformConfiguration ' + BuildOptionExpert.Options.FPlatformConfigBuildOptions[i].PlatformConfig + ' PreBuildEvents');
                  Exit;
               end;

         for x := 0 to BuildOptionExpert.Options.FPlatformConfigBuildOptions[i].PostBuildEvents.Count - 1 do
            if BuildOptionExpert.Options.FPlatformConfigBuildOptions[i].PostBuildEvents[x].Param = CLBParams.Items[CLBParams.ItemIndex]
            then
               begin
                  ShowMessage(CLBParams.Items[CLBParams.ItemIndex] + ' is used in PlatformConfiguration ' + BuildOptionExpert.Options.FPlatformConfigBuildOptions[i].PlatformConfig + ' PostBuildEvents');
                  Exit;
               end;

      end;

   if MessageDlg('Delete ' + CLBParams.Items[CLBParams.ItemIndex] + ' parameter?', mtConfirmation, [mbYes, mbNo], 0) = mrYes
   then
      CLBParams.Items.Delete(CLBParams.ItemIndex);

end;

procedure TBuildOptionsForm.EnablePostBuild(AEnabled: Boolean);
begin
  ACGPostBuild.Enabled := AEnabled;
  cbPostBuildEvents.Enabled := AEnabled;
end;

procedure TBuildOptionsForm.EnablePreBuild(AEnabled: Boolean);
begin
  ACGPreBuild.Enabled := AEnabled;
end;

procedure TBuildOptionsForm.PreDeleteEventClick(Sender: TObject);
begin

   if ACGPreBuild.Row > 0
   then
      DeleteRow(ACGPreBuild, ACGPreBuild.Row);

end;

procedure TBuildOptionsForm.PreEditEventClick(Sender: TObject);
begin

   if ACGPreBuild.Row > 0
   then
      begin
         ACGPreBuild.Cells[0, ACGPreBuild.Row] := ShowBuildCommandEditor('Pre', ACGPreBuild.Cells[0, ACGPreBuild.Row], False);
      end;

end;

procedure TBuildOptionsForm.PostNewEventClick(Sender: TObject);

var
   TmpStr: string;

begin

   TmpStr := ShowBuildCommandEditor('Post', '', True);

   if TmpStr <> ''
   then
      begin

         if ACGPostBuild.Cells[0, ACGPostBuild.RowCount - 1] <> ''
         then
            ACGPostBuild.RowCount := ACGPostBuild.RowCount + 1;

         ACGPostBuild.Cells[0, ACGPostBuild.RowCount - 1] := TmpStr;
//         ACGPostBuild.AutoSizeRow(ACGPostBuild.RowCount - 1);

         ACGPostBuild.Cells[2, ACGPostBuild.RowCount - 1] := 'Off';

      end;

end;

procedure TBuildOptionsForm.PostDeleteEventClick(Sender: TObject);
begin

   if ACGPostBuild.Row > 0
   then
      DeleteRow(ACGPostBuild, ACGPostBuild.Row);

end;

procedure TBuildOptionsForm.PostEditEventClick(Sender: TObject);
begin

   if ACGPostBuild.Row > 0
   then
      begin
         ACGPostBuild.Cells[0, ACGPostBuild.Row] := ShowBuildCommandEditor('Post', ACGPostBuild.Cells[0, ACGPostBuild.Row], False);
      end;

end;

procedure TBuildOptionsForm.PreNewEventClick(Sender: TObject);

var
   TmpStr: string;

begin

   TmpStr := ShowBuildCommandEditor('Pre', '', True);

   if TmpStr <> ''
   then
      begin

         if ACGPreBuild.Cells[0, ACGPreBuild.RowCount - 1] <> ''
         then
            ACGPreBuild.RowCount := ACGPreBuild.RowCount + 1;

         ACGPreBuild.Cells[0, ACGPreBuild.RowCount - 1] := TmpStr;
         ACGPreBuild.Cells[2, ACGPreBuild.RowCount - 1] := 'Off';

      end;

end;

procedure TBuildOptionsForm.PUParamsPopup(Sender: TObject);
begin

   if CLBParams.ItemIndex < 2
   then
      DeleteParameter1.Enabled := False
   else
      DeleteParameter1.Enabled := True;

end;

procedure TBuildOptionsForm.PUPostBuildPopup(Sender: TObject);
begin

   if (ACGPostBuild.Row < 1) or
      (ACGPostBuild.Cells[0, ACGPostBuild.Row] = '')
   then
      begin
         PostEditEvent.Enabled := False;
         PostDeleteEvent.Enabled := False;
      end
   else
      begin
         PostEditEvent.Enabled := True;
         PostDeleteEvent.Enabled := True;
      end;

end;

procedure TBuildOptionsForm.PUPreBuildPopup(Sender: TObject);
begin

   if (ACGPreBuild.Row < 1) or
      (ACGPreBuild.Cells[0, ACGPreBuild.Row] = '')
   then
      begin
         PreEditEvent.Enabled := False;
         PreDeleteEvent.Enabled := False;
      end
   else
      begin
         PreEditEvent.Enabled := True;
         PreDeleteEvent.Enabled := True;
      end;

end;

end.
