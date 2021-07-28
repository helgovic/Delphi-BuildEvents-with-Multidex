unit uBuildCommandEditor;
interface
{$I BuildEvents.inc}
uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Buttons,
  ExtCtrls, Grids, ComCtrls, uBuildMisc, Menus, Vcl.ValEdit,
  Vcl.WinXCtrls;
type
  TBuildCommandEditorDlg = class(TForm)
    PanelBase: TPanel;
    Editor: TMemo;
    Splitter1: TSplitter;
    pmMacro: TPopupMenu;
    mniAddMacro: TMenuItem;
    mniDeleteMacro: TMenuItem;
    mniEditMacro: TMenuItem;
    VLEMacros: TValueListEditor;
    Panel1: TPanel;
    CBParam: TComboBox;
    Label1: TLabel;
    TSParm: TToggleSwitch;
    Panel2: TPanel;
    ButtonCancel: TPanel;
    ButtonInsert: TPanel;
    ButtonOK: TPanel;
    ButtonToggle: TPanel;
    procedure ButtonInsertClick(Sender: TObject);
    procedure ButtonToggleClick(Sender: TObject);
    procedure mniAddMacroClick(Sender: TObject);
    procedure mniEditMacroClick(Sender: TObject);
    procedure mniDeleteMacroClick(Sender: TObject);
    procedure pmMacroPopup(Sender: TObject);
    procedure VLEMacrosDblClick(Sender: TObject);
    procedure CBParamDropDown(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
  protected
    procedure UpdateUI;
  public
    procedure ToggleMacroDisplay;
    procedure PopulateDefaultMacros;
  end;
  function ShowBuildCommandEditor(const Caption, CommandStr: string; New: Boolean): string;
implementation
{$R *.dfm}
uses
  uBuildEngine,
  uBuildMacroEditor,
  ToolsAPI, uBuildOptionsForm;
function ShowBuildCommandEditor(const Caption, CommandStr: string; New: Boolean): string;
var
  Dialog: TBuildCommandEditorDlg;
begin
  Dialog := TBuildCommandEditorDlg.Create(Application);
  try
   Dialog.PopulateDefaultMacros;
   Dialog.Editor.Text := CommandStr;
   Dialog.Caption := Caption + '-build Event Command Line';
   if Caption = 'Pre'
   then
      begin
         if not New
         then
            Dialog.CBParam.Text := BuildOptionsForm.ACGPreBuild.Cells[BuildOptionsForm.ACGPreBuild.Row, 1]
         else
            Dialog.CBParam.Text := '';
         if BuildOptionsForm.ACGPreBuild.Cells[BuildOptionsForm.ACGPreBuild.Row, 2] = 'On'
         then
            Dialog.TSParm.State := tssOn
         else
            Dialog.TSParm.State := tssOff;
      end
   else
      begin
         if not New
         then
            Dialog.CBParam.Text := BuildOptionsForm.ACGPostBuild.Cells[BuildOptionsForm.ACGPostBuild.Row, 1]
         else
            Dialog.CBParam.Text := '';
         if BuildOptionsForm.ACGPostBuild.Cells[BuildOptionsForm.ACGPostBuild.Row, 2] = 'On'
         then
            Dialog.TSParm.State := tssOn
         else
            Dialog.TSParm.State := tssOff;
      end;
   if Dialog.ShowModal = mrOk
   then
      begin
         if Caption = 'Pre'
         then
            begin
               BuildOptionsForm.ACGPreBuild.Cells[BuildOptionsForm.ACGPreBuild.Row, 1] := Dialog.CBParam.Text;
               if Dialog.TSParm.State = tssOff
               then
                  BuildOptionsForm.ACGPreBuild.Cells[BuildOptionsForm.ACGPreBuild.Row, 2] := 'Off'
               else
                  BuildOptionsForm.ACGPreBuild.Cells[BuildOptionsForm.ACGPreBuild.Row, 2] := 'On';
            end
         else
            begin
               BuildOptionsForm.ACGPostBuild.Cells[BuildOptionsForm.ACGPostBuild.Row, 1] := Dialog.CBParam.Text;
               if Dialog.TSParm.State = tssOff
               then
                  BuildOptionsForm.ACGPostBuild.Cells[BuildOptionsForm.ACGPostBuild.Row, 2] := 'Off'
               else
                  BuildOptionsForm.ACGPostBuild.Cells[BuildOptionsForm.ACGPostBuild.Row, 2] := 'On';
            end;
         Result := Dialog.Editor.Text;
      end
   else
     Result := CommandStr;
  finally
    Dialog.Free;
  end;
end;
procedure TBuildCommandEditorDlg.ButtonCancelClick(Sender: TObject);
begin
   Self.ModalResult := mrCancel;
end;

procedure TBuildCommandEditorDlg.ButtonInsertClick(Sender: TObject);
begin
  if (VLEMacros.Row < 0)
  then
     Exit;
  Editor.SelText := '$(' + VLEMacros.Cells[0, VLEMacros.Row] + ')';
end;
procedure TBuildCommandEditorDlg.ToggleMacroDisplay;
begin
  if (VLEMacros.Visible) then
  begin
    Splitter1.Visible := False;
    VLEMacros.Visible := False;
    Height := 406;
    ButtonToggle.Caption := 'Macros >>';
  end else
  begin
    Splitter1.Visible := True;
    VLEMacros.Visible := True;
    Height := 706;
    ButtonToggle.Caption := '<< Macros';
  end;
end;
procedure TBuildCommandEditorDlg.ButtonOKClick(Sender: TObject);
begin
   Self.ModalResult := mrOk;
end;

procedure TBuildCommandEditorDlg.ButtonToggleClick(Sender: TObject);
begin
  ToggleMacroDisplay();
end;
procedure TBuildCommandEditorDlg.CBParamDropDown(Sender: TObject);

var
   i: Integer;

begin

   CBParam.Items.Clear;

   if Pos('Android', BuildOptionsForm.CBPlatForms.Text) > 0
   then
      i := 0
   else
      i := 2;

   CBParam.Items.Add('');

   for i := i to BuildOptionsForm.CLBParams.Items.Count - 1 do
      CBParam.Items.Add(BuildOptionsForm.CLBParams.Items[i]);

end;

procedure TBuildCommandEditorDlg.PopulateDefaultMacros;
var
  Index: Integer;
begin
try
    if Assigned(BuildEngine) then
    begin
      BuildEngine.RefreshMacros;
      for Index := 0 to BuildEngine.MacroList.Count - 1 do
        VLEMacros.InsertRow(BuildEngine.MacroList.Names[Index], BuildEngine.MacroList.ValueFromIndex[Index], True);
    end;
    UpdateUI;
  except
    ButtonInsert.Visible := False;
  end;
end;
procedure TBuildCommandEditorDlg.UpdateUI;
begin
  ButtonInsert.Enabled := VLEMacros.RowCount > 0;
  mniEditMacro.Enabled := VLEMacros.Row >= 0;
  mniDeleteMacro.Enabled := VLEMacros.Row >= 0;
end;
procedure TBuildCommandEditorDlg.VLEMacrosDblClick(Sender: TObject);
begin

  if (VLEMacros.Row < 0)
  then
     Exit;
  Editor.SelText := '$(' + VLEMacros.Cells[0, VLEMacros.Row] + ')';
end;

procedure TBuildCommandEditorDlg.mniAddMacroClick(Sender: TObject);
var
  sName, sPath: String;
begin
  if (EditMacroItem('Add', sName, sPath)) then
  begin
    VLEMacros.InsertRow(sName, sPath, True);
    BuildEngine.AddMacro(sName, sPath);
  end;
end;
procedure TBuildCommandEditorDlg.mniEditMacroClick(Sender: TObject);
var
  sOldName, sName, sPath: String;
begin
  if (VLEMacros.Row < 0)
  then
     Exit;
  sName := VLEMacros.Cells[0, VLEMacros.Row];
  sOldName:= sName;
  sPath := VLEMacros.Cells[1, VLEMacros.Row];
  if (EditMacroItem('Edit', sName, sPath)) then
  begin
     VLEMacros.Cells[0, VLEMacros.Row] := sName;
     VLEMacros.Cells[1, VLEMacros.Row] := sPath;
     BuildEngine.EditMacro(sOldName, sName, sPath);
  end;
end;
procedure TBuildCommandEditorDlg.mniDeleteMacroClick(Sender: TObject);
var
  sName: String;
begin
  if (VLEMacros.Row < 0)
  then
     Exit;
  sName := VLEMacros.Cells[0, VLEMacros.Row];
  VLEMacros.DeleteRow(VLEMacros.Row);
  BuildEngine.DeleteMacro(sName);
end;
procedure TBuildCommandEditorDlg.pmMacroPopup(Sender: TObject);
begin
  UpdateUI;
end;
end.
