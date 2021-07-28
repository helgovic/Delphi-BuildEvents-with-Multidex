unit uBuildMacroEditor;
interface
uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Buttons,
  ExtCtrls;
type
  TMacroEditor = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    edMacroName: TEdit;
    edMacroPath: TEdit;
    ButtonOK: TPanel;
    ButtonCancel: TPanel;
    procedure edMacroNameChange(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
function EditMacroItem(ACaption: String; var AName, APath: String): Boolean;
implementation
{$R *.dfm}
function EditMacroItem(ACaption: String; var AName, APath: String): Boolean;
begin
  with TMacroEditor.Create(Application) do
  begin
    try
      Caption := Format('%s Macro', [ACaption]);
      edMacroName.Text := AName;
      edMacroPath.Text := APath;
      Result := (ShowModal = mrOK);
      if Result then
      begin
        AName := edMacroName.Text;
        APath := edMacroPath.Text;
      end;
    finally
      Free;
    end;
  end;
end;
procedure TMacroEditor.ButtonCancelClick(Sender: TObject);
begin
   Self.ModalResult := mrCancel;
end;

procedure TMacroEditor.ButtonOKClick(Sender: TObject);
begin
   Self.ModalResult := mrOK;
end;

procedure TMacroEditor.edMacroNameChange(Sender: TObject);
begin
  ButtonOK.Enabled := (trim(edMacroName.Text) <> EmptyStr) and
                      (trim(edMacroPath.Text) <> EmptyStr);
end;
end.
