unit UFParam;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.WinXCtrls;

type
  TFAddParam = class(TForm)
    LEParam: TLabeledEdit;
    BParamOK: TPanel;
    BParamCancel: TPanel;
    TSParmOffOn: TToggleSwitch;
    procedure BParamOKClick(Sender: TObject);
    procedure BParamCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FAddParam: TFAddParam;

implementation

{$R *.dfm}

uses
   uBuildOptionsForm;

procedure TFAddParam.BParamCancelClick(Sender: TObject);
begin
   Self.ModalResult := mrCancel;
end;

procedure TFAddParam.BParamOKClick(Sender: TObject);

var
   i: Integer;

begin

   if LEParam.Text = ''
   then
      begin
         ShowMessage('Enter a Name');
         LEParam.Focused;
         Exit;
      end;

   for i := 0 to ProjOptions.FParams.Count - 1 do
      if ProjOptions.FParams[i].Name = LEParam.Text
      then
         begin
            ShowMessage('Param Already exists');
            LEParam.Focused;
            Exit;
         end;

   Self.ModalResult := mrOK;

end;

end.
