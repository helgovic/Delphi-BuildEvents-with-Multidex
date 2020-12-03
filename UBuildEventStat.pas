unit UBuildEventStat;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFBuildEvenStat = class(TForm)
    Label1: TLabel;
    Memo1: TMemo;
    PBuildEventStatHeader: TPanel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FBuildEvenStat: TFBuildEvenStat;

implementation

{$R *.dfm}

end.
