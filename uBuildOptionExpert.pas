unit uBuildOptionExpert;
interface
{$I BuildEvents.inc}
uses
  Windows, SysUtils, Graphics, Classes, Menus, ActnList, ToolsAPI, Dialogs,
  Forms, ComCtrls, Contnrs, ExtCtrls, uBuildMisc, Xml.XMLIntf, System.IniFiles;
type
  { This is an enumerater for the message types that we will display }
  TMessageType = (mtInfo, mtWarning, mtError, mtSuccess, mtDebug, mtCustom);
  { This is an enumerate for the types of messages that can be cleared. }
  TClearMessage = (cmBuildEvents, cmCompiler, cmSearch, cmTool, cmAll);
  { This is a set of messages that can be cleared. }
  TClearMessages = Set of TClearMessage;
  TBADIToolsAPIFunctions = record
     Class Procedure RegisterFormClassForTheming(Const AFormClass : TCustomFormClass;
        Const Component : TComponent = Nil); static;
  end;
  TBuildOptionExpert = class(TObject)
  private
    { Private declarations }
    FProjectMenu,
    FMenuOptions: TMenuItem;
    FActionOptions: TAction;
    FOptions: TBuildOptions;
    FBuildTimer: TTimer;
    FAutoSaveTimer: TTimer;
    procedure LogResults(AType: TMessageType; AText: String);
  protected
    { Protected declarations }
    {$IFDEF D7_UP}
    FBuildEventsGroup: IOTAMessageGroup;
    function BuildEventsGroup: IOTAMessageGroup;
    function GetSourceEditor: IOTASourceEditor;
    function GetEditorFileName: String;
    {$ENDIF}
    function GetModuleName: String;
    function GetProjectName: String;
    function AddAction(ACaption, AHint, AName : String; AExecuteEvent,
      AUpdateEvent : TNotifyEvent) : TAction;
    procedure RemoveAction(AAction: TAction; AToolbar: TToolbar);
    procedure RemoveActionFromToolbar(AAction: TAction);
    procedure DoOnPostBuildTimerEvent(Sender: TObject);
    procedure DoOnAutoSaveTimerEvent(Sender: TObject);
  public
    { Public declarations }
    FBuildSpan: TDateTime;
    FBuildSuccess: Boolean;
    constructor Create; virtual;
    destructor Destroy; override;
    class function Instance: TBuildOptionExpert;
    procedure AddMessage(AText: String; AForeColour: TColor;
      AStyle: TFontStyles; ABackColour: TColor = clWindow);
    procedure AddMessageTitle(AType: TMessageType; AText: String);
    procedure ClearMessages(AMsgType : TClearMessages);
    procedure ExecutePostBuildEvent(const Text: string);
    procedure ExecutePreBuildEvent;
    procedure LoadBuildOptions(const FileName: String);
    procedure LogLine(AType: TMessageType; AText : String); overload;
    procedure LogLine(AType: TMessageType; const AFormat: string;
      AParams: array of const); overload;
    procedure LogMessages(AType: TMessageType; AStrings : TStrings);
    procedure TriggerPostBuildEvent(ASuccess: Boolean);
    { Action Event Handlers }
    procedure MenuOptionsExecute(Sender : TObject);
    { Property declarations }
    property Options : TBuildOptions read FOptions;
    property ModuleName: String read GetModuleName;
    property ProjectName: String read GetProjectName;
    {$IFDEF D7_UP}
    function Modified: Boolean;
    property EditorFileName: String read GetEditorFileName;
    {$ENDIF}
  public
    FShowMsg: Boolean;
    FFontSize: Integer;
    FFontName: String;
    property ShowMessages : Boolean read FShowMsg write FShowMsg;
    property FontSize: Integer read FFontSize Write FFontSize;
    property FontName: String read FFontName Write FFontName;
  end;
  function BuildOptionExpert: TBuildOptionExpert;
implementation
uses Registry, System.IOUtils, JCLStrings, Controls, uBuildNotifier, uBuildEngine, uBuildMessages,
     uBuildOptionsForm, UBuildEventStat, DeploymentAPI;
const
  clAmber = TColor($004094FF);
  C_MESSAGE_TYPE_COLOUR : array [TMessageType] of TColor =
    (clBlue, clAmber, clRed, clGreen, clPurple, clBlack);
var
  FBuildOptionExpert: TBuildOptionExpert;
  CompNot: Integer;
{ TBuildOptionExpert }
function BuildOptionExpert: TBuildOptionExpert;
begin
  Result := TBuildOptionExpert.Instance;
end;
class function TBuildOptionExpert.Instance: TBuildOptionExpert;
begin
  if FBuildOptionExpert = nil then
    FBuildOptionExpert := TBuildOptionExpert.Create;
  Result := FBuildOptionExpert;
end;
constructor TBuildOptionExpert.Create;
var
   NTAServices : INTAServices;
   Bmp: TBitmap;
   ImageIndex: integer;
   Intf: TCompileNotifier;
begin
  inherited Create;
  FShowMsg := True;
  FFontName := C_DEFAULT_FONT_NAME;
  FFontSize := C_DEFAULT_FONT_SIZE;
  with TRegIniFile.Create(REG_KEY) do
  try
    FShowMsg  := ReadBool(REG_BUILD_OPTIONS, 'Show Messages', FShowMsg);
    FFontSize := ReadInteger(REG_BUILD_OPTIONS, 'Font Size', FFontSize);
    FFontName := ReadString(REG_BUILD_OPTIONS, 'Font Name', FFontName);
  finally
    Free;
  end;
  ProjOptions := TProjOptions.Create;
  FOptions := TBuildOptions.Create();
  intf := TCompileNotifier.Create;
  CompNot := (BorlandIDEServices as IOTACompileServices).AddNotifier(Intf);
  { Main menu item }
   if Supports(BorlandIDEServices, INTAServices, NTAServices)
   then
      begin

         Bmp := TBitmap.Create;
//         Bmp.LoadFromFile('D:\Downloads\Delphi\Icons\Uniq\Settins.bmp');
         Bmp.LoadFromResourceName(HInstance, 'Settings');
         ImageIndex := NTAServices.AddMasked(Bmp, Bmp.TransparentColor,
                                  'Softmagical Settings icon');

         Bmp.DisposeOf;

         FProjectMenu := FindMenuItem('Project;QA Audits...');

         FActionOptions := TAction.Create(nil);
         FActionOptions.Category := 'Project';
         FActionOptions.Caption := 'Build Events';
         FActionOptions.Hint := 'Project Build Events';
         FActionOptions.Name := 'BuildEventsOptionAction';
         FActionOptions.Visible := True;
         FActionOptions.OnExecute := MenuOptionsExecute;
         FActionOptions.Enabled := True;
         FMenuOptions := TMenuItem.Create(nil);
         FMenuOptions.Name := 'BuildEventsOptions';
         FMenuOptions.Caption := 'Build Options';
         FMenuOptions.AutoHotkeys := maAutomatic;
         FMenuOptions.Action := FActionOptions;
         NTAServices.AddActionMenu(FProjectMenu.Name, FActionOptions, FMenuOptions, True);
         FActionOptions.ImageIndex := ImageIndex;
         FMenuOptions.ImageIndex := ImageIndex;
      end;
   BuildOptionsForm := TBuildOptionsForm.Create(nil);
   TBADIToolsAPIFunctions.RegisterFormClassForTheming(TBuildOptionsForm, BuildOptionsForm);
end;
destructor TBuildOptionExpert.Destroy;
var
  Service : INTAServices;
begin
  Service := (BorlandIDEServices as INTAServices);
  { Destroy the menu item }
  if (FProjectMenu = nil) then
  begin
    if (-1 <> Service.MainMenu.Items.IndexOf(FMenuOptions)) then
      Service.MainMenu.Items.Remove(FMenuOptions);
  end else
  begin
    if (-1 <> FProjectMenu.IndexOf(FMenuOptions)) then
      FProjectMenu.Remove(FMenuOptions);
  end;
  FMenuOptions.Free;
  FActionOptions.Free;
  (BorlandIDEServices as IOTACompileServices).RemoveNotifier(CompNot);
  if Assigned(FOptions)
  then
     FOptions.Free;
  BuildOptionsForm.Free;
//  ClearMessages([cmBuildEvents, cmAll]);
  inherited Destroy;
end;
function TBuildOptionExpert.AddAction(ACaption, AHint, AName: String;
  AExecuteEvent, AUpdateEvent: TNotifyEvent): TAction;
var
  Service : INTAServices;
begin
  Service := (BorlandIDEServices as INTAServices);
  Result := TAction.Create(Service.ActionList);
  with Result do
  begin
    ActionList := Service.ActionList;
    Category := 'Build';
    Caption := ACaption;
    Hint := AHint;
    Name := AName;
    Visible := True;
    OnExecute := AExecuteEvent;
    OnUpdate := AUpdateEvent;
  end;
end;
{$IFDEF D7_UP}
function TBuildOptionExpert.GetEditorFileName: String;
var
  Serv: IOTAModuleServices;
begin
  Result := '';
  Serv := (BorlandIDEServices as IOTAModuleServices);
  if (Serv.CurrentModule <> nil) and
    (Serv.CurrentModule.CurrentEditor <> nil) then
  begin
    Result := Serv.CurrentModule.CurrentEditor.FileName;
  end;
end;
function TBuildOptionExpert.GetSourceEditor: IOTASourceEditor;
var
  Serv      : IOTAModuleServices;
  iCounter  : Integer;
begin
  Result := nil;
  if Supports(BorlandIDEServices, IOTAModuleServices, Serv) then
  begin
    iCounter := 0;
    while (iCounter < Serv.CurrentModule.ModuleFileCount) and (Result = nil) do
    begin
      if not Supports(Serv.CurrentModule.ModuleFileEditors[iCounter],
        IOTASourceEditor, Result) then
          Inc(iCounter);
    end;
  end;
end;
function TBuildOptionExpert.Modified: Boolean;
var
  Serv: IOTAModuleServices;
begin
  Result := False;
  Serv := (BorlandIDEServices as IOTAModuleServices);
  if Serv.CurrentModule <> nil then
    Result := Serv.CurrentModule.CurrentEditor.Modified;
end;
function TBuildOptionExpert.BuildEventsGroup: IOTAMessageGroup;
begin
  with (BorlandIDEServices as IOTAMessageServices) do
  begin
    { First we try to retrieve if we already have group }
    if (FBuildEventsGroup = nil) then
      FBuildEventsGroup := GetGroup('Build Events');
    { if not, we will add new group }
    if (FBuildEventsGroup = nil) then
      FBuildEventsGroup := AddMessageGroup('Build Events');
    if (FBuildEventsGroup = nil) then
      FBuildEventsGroup := GetMessageGroup(0);
  end;
  Result := FBuildEventsGroup;
end;
{$ENDIF}
function TBuildOptionExpert.GetModuleName: String;
begin
  Result := GetCurrentProjectFileName;
end;
function TBuildOptionExpert.GetProjectName: String;
begin
  Result := GetCurrentProjectName;
end;
procedure TBuildOptionExpert.LogLine(AType: TMessageType; AText: String);
begin
  if ShowMessages then
  begin
    AddMessage(Format('[%s] %s', [TimeToStr(Time), AText]),
      C_MESSAGE_TYPE_COLOUR[AType], []);
  end;
end;
procedure TBuildOptionExpert.AddMessageTitle(AType: TMessageType; AText: String);
begin
  if ShowMessages then
    AddMessage(AText, C_MESSAGE_TYPE_COLOUR[AType], []);
end;
procedure TBuildOptionExpert.LogLine(AType: TMessageType; const AFormat: String;
  AParams: array of const);
begin
  LogLine(AType, Format(AFormat, AParams));
end;
procedure TBuildOptionExpert.LogMessages(AType: TMessageType;
  AStrings: TStrings);
var
  I: Integer;
  mType: TMessageType;
begin
  if ShowMessages then
  begin
    for I := 0 to AStrings.Count - 1 do
    begin
      if ContainsString(AStrings[I],
        ['error', 'exception', 'failed', 'denied']) then
          mType := mtError
      else
      if ContainsString(AStrings[I], ['invalid']) then
        mType := mtWarning
      else
        mType := AType;
      LogLine(mType, AStrings[I]);
    end;
  end;
end;
procedure TBuildOptionExpert.MenuOptionsExecute(Sender: TObject);
begin
   Options.ShowDialog(ModuleName);
end;
procedure TBuildOptionExpert.RemoveAction(AAction: TAction; AToolbar: TToolbar);
var
  iCounter: Integer;
  btnTool : TToolButton;
begin
  for iCounter := AToolbar.ButtonCount - 1 downto 0 do
  begin
    btnTool := AToolbar.Buttons[iCounter];
    if btnTool.Action = AAction then
    begin
      AToolbar.Perform(CM_CONTROLCHANGE, WParam(btnTool), 0);
      btnTool.Free;
    end;
  end;
end;
procedure TBuildOptionExpert.RemoveActionFromToolbar(AAction: TAction);
var
  Services : INTAServices;
begin
  Services := (BorlandIDEServices as INTAServices);
  RemoveAction(AAction, Services.ToolBar[sCustomToolBar]);
  RemoveAction(AAction, Services.ToolBar[sDesktopToolBar]);
  RemoveAction(AAction, Services.ToolBar[sStandardToolBar]);
  RemoveAction(AAction, Services.ToolBar[sDebugToolBar]);
  RemoveAction(AAction, Services.ToolBar[sViewToolBar]);
//  RemoveAction(AAction, Services.ToolBar['InternetToolBar']);
end;
procedure TBuildOptionExpert.LogResults(AType: TMessageType; AText: String);
var
  slList: TStringList;
begin
  slList := TStringList.Create;
  try
    slList.Text := AText;
    LogMessages(AType, slList);
  finally
    slList.Free;
  end;
end;
procedure TBuildOptionExpert.TriggerPostBuildEvent(ASuccess: Boolean);
begin
  FBuildSuccess := ASuccess;
  FBuildTimer.Enabled := True;
end;
procedure TBuildOptionExpert.DoOnPostBuildTimerEvent(Sender: TObject);
begin
  FBuildTimer.Enabled := False;
  FBuildSpan := (Now - FBuildSpan);
  try
    case (Options.GetPlatformConfigBuildOptions(GetCurrentProject.CurrentPlatform + GetCurrentProject.CurrentConfiguration).PostBuildOption) of
      boSuccess:
        if (FBuildSuccess) then
          ExecutePostBuildEvent('Build Success');
      boFailed:
        if (not FBuildSuccess) then
          ExecutePostBuildEvent('Build Failed');
      boAlways:
        ExecutePostBuildEvent('After Build');
      boNone:
        LogLine(mtDebug, '%s Compiled in %s',
          [ProjectName, GetDoneTimeStr(FBuildSpan)]);
    end;
  finally
    FBuildSuccess := False;
  end;
end;
procedure TBuildOptionExpert.ExecutePostBuildEvent(const Text: String);
var
  Index, x: Integer;
  Command: string;
  slList: TStringList;
  PlatformConfigBuildOptions: TPlatformConfigBuildOptions;
  BuildResult: string;
  ProjFile: TextFile;
  ProjFileOut: TextFile;
  Line, LineOut: String;
  FileList: TArray<String>;
  ShortName: String;
  ProjectDeployment: IProjectDeployment;
  RCResult: TReconcileResult;
  TmpStr: String;
begin
   PlatformConfigBuildOptions := Options.GetPlatformConfigBuildOptions(GetCurrentProject.CurrentPlatform + GetCurrentProject.CurrentConfiguration);
   if (Pos('Android', PlatformConfigBuildOptions.PlatformConfig) > 0) and
      (ProjOptions.GetParam('RunDex').OnOff)
   then
      begin
         AssignFile(ProjFile, GetCurrentProjectFileName);
         Reset(ProjFile);
         AssignFile(ProjFileOut, ExtractFilePath(GetCurrentProjectFileName) + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + 'New.dproj');
         ReWrite(ProjFileOut);

         FileList := TDirectory.GetFiles(ExtractFilePath(GetCurrentProjectFileName) + '\' + GetCurrentProject.CurrentPlatform + '\' + GetCurrentProject.CurrentConfiguration, '*.dex', TSearchOption.soTopDirectoryOnly);

         while not Eof(ProjFile) do
            begin

               Readln(ProjFile, Line);

               if (Pos('<DeployFile', Line) > 0) and
                  (Pos('Class="File"', Line) > 0) and
                  (Pos('classes', StrBefore('" Configuration=', StrAfter('LocalName="', Line))) > 0) and
                  (Pos('.dex', StrBefore('" Configuration=', StrAfter('LocalName="', Line))) > 0)
               then
                  while Pos('</DeployFile>', Line) = 0 do
                     Readln(ProjFile, Line)
               else
                  WriteLn(ProjFileOut, Line);

            end;

         CloseFile(ProjFile);
         CloseFile(ProjFileOut);

         AssignFile(ProjFileOut, ExtractFilePath(GetCurrentProjectFileName) + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + 'New.dproj');
         AssignFile(ProjFile, GetCurrentProjectFileName);

         Reset(ProjFileOut);
         Rewrite(ProjFile);

         while not Eof(ProjFileOut) do
            begin

               Readln(ProjFileOut, Line);

               WriteLn(ProjFile, Line);

               if Pos('<Deployment', Line) > 0
               then
                  begin

                     for x := 0 to High(FileList) do
                        begin
                           if ExtractFileName(FileList[x]) = 'classes.dex'
                           then
                              Continue;
                           ShortName := 'Android\Debug\' + ExtractFileName(FileList[x]);

                           LineOut := '                <DeployFile LocalName="' + ShortName + '" Configuration="Debug" Class="File">';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                    <Platform Name="Android">';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <RemoteDir>classes\</RemoteDir>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <RemoteName>' + ExtractFileName(ShortName) + '</RemoteName>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <Overwrite>true</Overwrite>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                    </Platform>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                </DeployFile>';
                           WriteLn(ProjFile, LineOut);

                           ShortName := 'Android\Release\' + ExtractFileName(FileList[x]);

                           LineOut := '                <DeployFile LocalName="' + ShortName + '" Configuration="Release" Class="File">';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                    <Platform Name="Android">';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <RemoteDir>classes\</RemoteDir>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <RemoteName>' + ExtractFileName(ShortName) + '</RemoteName>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <Overwrite>true</Overwrite>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                    </Platform>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                </DeployFile>';
                           WriteLn(ProjFile, LineOut);

                           ShortName := 'Android64\Debug\' + ExtractFileName(FileList[x]);

                           LineOut := '                <DeployFile LocalName="' + ShortName + '" Configuration="Debug" Class="File">';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                    <Platform Name="Android64">';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <RemoteDir>classes\</RemoteDir>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <RemoteName>' + ExtractFileName(ShortName) + '</RemoteName>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <Overwrite>true</Overwrite>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                    </Platform>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                </DeployFile>';
                           WriteLn(ProjFile, LineOut);

                           ShortName := 'Android64\Release\' + ExtractFileName(FileList[x]);

                           LineOut := '                <DeployFile LocalName="' + ShortName + '" Configuration="Release" Class="File">';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                    <Platform Name="Android64">';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <RemoteDir>classes\</RemoteDir>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <RemoteName>' + ExtractFileName(ShortName) + '</RemoteName>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                        <Overwrite>true</Overwrite>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                    </Platform>';
                           WriteLn(ProjFile, LineOut);
                           LineOut := '                </DeployFile>';
                           WriteLn(ProjFile, LineOut);

                        end;

                  end;

            end;

         CloseFile(ProjFile);
         CloseFile(ProjFileOut);

         DeleteFile(ExtractFilePath(GetCurrentProjectFileName) + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + 'New.dproj');

         with BorlandIDEServices as IOTAModuleServices do
            FindModule(GetCurrentProjectFileName).Refresh(True);

         if Supports(GetCurrentProject, IProjectDeployment, ProjectDeployment)
         then
            begin
               RCResult := ProjectDeployment.Reconcile();
               ProjectDeployment.SaveToMSBuild;
            end;
      end;

  if not PlatformConfigBuildOptions.PostBuildEnabled
  then
     Exit;

  if PlatformConfigBuildOptions.PostBuildEvents.Count = 0
  then
     Exit;

  slList := TStringList.Create;
  LogLine(mtDebug, '%s Compiled in %s',
    [ProjectName, GetDoneTimeStr(FBuildSpan)]);

   BuildEngine.RefreshMacros;

   if not Assigned(FBuildEvenStat)
   then
      FBuildEvenStat := TFBuildEvenStat.Create(Application);

   FBuildEvenStat.PBuildEventStatHeader.Caption := 'Running PostBuild Events';
   FBuildEvenStat.Memo1.Lines.Text := '';
   FBuildEvenStat.Visible := True;

  try
    for Index := 0 to PlatformConfigBuildOptions.PostBuildEvents.Count - 1 do
    begin
      slList.Clear;
      if PlatformConfigBuildOptions.PostBuildEvents[Index].Param <> ''
      then
         if ProjOptions.GetParam(PlatformConfigBuildOptions.PostBuildEvents[Index].Param).OnOff = PlatformConfigBuildOptions.PostBuildEvents[Index].OnOff
         then
            begin
               Command := Trim(PlatformConfigBuildOptions.PostBuildEvents[Index].Command);
               if Command = '' then Continue;
               if Pos('REM', UpperCase(Command)) = 1 then Continue;
               AddMessageTitle(mtCustom,
                 Format('Post-build %s: %s', [Text, Command]));
               try
                 BuildResult := BuildEngine.Command(Command, slList);
                 LogResults(mtSuccess, BuildResult);
                 if slList.Count > 0 then
                   LogMessages(mtInfo, slList);
                 // LogResults(mtInfo, BuildEngine.LastCmd);
               except
                 on E: Exception do
                 begin
                   LogLine(mtError, E.Message);
                   LogException(E, 'TBuildOptionExpert.ExecutePostBuildEvent');
                 end;
               end;
            end
         else
      else
         begin
            Command := Trim(PlatformConfigBuildOptions.PostBuildEvents[Index].Command);
            if Command = '' then Continue;
            if Pos('REM', UpperCase(Command)) = 1 then Continue;
            AddMessageTitle(mtCustom,
              Format('Post-build %s: %s', [Text, Command]));
            try
              LogResults(mtSuccess, BuildEngine.Command(Command, slList));
              if slList.Count > 0 then
                LogMessages(mtInfo, slList);
              // LogResults(mtInfo, BuildEngine.LastCmd);
            except
              on E: Exception do
              begin
                LogLine(mtError, E.Message);
                LogException(E, 'TBuildOptionExpert.ExecutePostBuildEvent');
              end;
            end;
         end;
    end;
  finally
    slList.Free;
  end;
  FBuildEvenStat.Visible := False;
   with TIniFile.Create(ChangeFileExt(GetCurrentProjectFileName, '.ini')) do
   try
      TmpStr := ReadString('ProjOptions', 'Params', '');
      TmpStr := StringReplace(TmpStr,'RunDex;True', 'RunDex;False', []);
      WriteString('ProjOptions', 'Params', TmpStr);
   finally
      Free;
   end;
end;
procedure TBuildOptionExpert.ExecutePreBuildEvent;
var
  Index, x, i: Integer;
  Command: string;
  PlatformConfigBuildOptions: TPlatformConfigBuildOptions;
  BDSDir: string;
  FileList: TArray<String>;
  FileLines: TStringList;
  Found: Boolean;
begin
  if (not FileExists(System.SysUtils.GetEnvironmentVariable('BDS') + '\bin\CodeGear.CommonMDDX.Targets')) and
     (not FileExists(System.SysUtils.GetEnvironmentVariable('BDS') + '\bin\CodeGear.CommonNMDX.Targets'))
  then
     begin
        ShowMessage('Target files not found. You have to run Targets.exe, located in the bin directory.');
        Exit;
     end;
  FOptions.LoadProjectEvents(ModuleName);
  PlatformConfigBuildOptions := Options.GetPlatformConfigBuildOptions(GetCurrentProject.CurrentPlatform + GetCurrentProject.CurrentConfiguration);
  FBuildSpan := Now;
  ClearMessages([cmBuildEvents]);
   if Pos('Android', PlatformConfigBuildOptions.PlatformConfig) > 0
   then
      begin

         BDSDir := System.SysUtils.GetEnvironmentVariable('BDS');

         if ProjOptions.GetParam('MultiDex').OnOff
         then
            begin

               if ProjOptions.GetParam('D8').OnOff
               then
                  begin

                     if FileExists(BDSDir + '\bin\CodeGear.CommonMDD8.Targets')
                     then
                        begin

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonNMD8.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonNMD8.Targets');

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonMDDX.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonMDDX.Targets');

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonNMDX.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonNMDX.Targets');

                           RenameFile(BDSDir + '\bin\CodeGear.CommonMDD8.Targets', BDSDir + '\bin\CodeGear.Common.Targets');

                        end;

                  end
               else
                  begin

                     if FileExists(BDSDir + '\bin\CodeGear.CommonMDDX.Targets')
                     then
                        begin

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonNMD8.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonNMD8.Targets');

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonMDD8.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonMDD8.Targets');

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonNMDX.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonNMDX.Targets');

                           RenameFile(BDSDir + '\bin\CodeGear.CommonMDDX.Targets', BDSDir + '\bin\CodeGear.Common.Targets');

                        end;

                  end;

            end
         else
            begin

               if ProjOptions.GetParam('D8').OnOff
               then
                  begin

                     if FileExists(BDSDir + '\bin\CodeGear.CommonNMD8.Targets')
                     then
                        begin

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonMDD8.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonMDD8.Targets');

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonMDDX.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonMDDX.Targets');

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonNMD8.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonNMD8.Targets');

                           RenameFile(BDSDir + '\bin\CodeGear.CommonNMD8.Targets', BDSDir + '\bin\CodeGear.Common.Targets');

                        end;

                  end
               else
                  begin

                     if FileExists(BDSDir + '\bin\CodeGear.CommonNMDX.Targets')
                     then
                        begin

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonNMD8.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonNMD8.Targets');

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonMDD8.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonMDD8.Targets');

                           if not (FileExists(BDSDir + '\bin\CodeGear.CommonMDDX.Targets'))
                           then
                              RenameFile(BDSDir + '\bin\CodeGear.Common.Targets', BDSDir + '\bin\CodeGear.CommonMDDX.Targets');

                           RenameFile(BDSDir + '\bin\CodeGear.CommonNMDX.Targets', BDSDir + '\bin\CodeGear.Common.Targets');

                        end;

                  end;

            end;

         if ProjOptions.GetParam('RunDex').OnOff
         then
            begin

               if DirectoryExists(ExtractFilePath(GetCurrentProjectFileName) + '\' + GetCurrentProject.CurrentPlatform + '\' + GetCurrentProject.CurrentConfiguration)
               then
                  begin

                     FileList := TDirectory.GetFiles(ExtractFilePath(GetCurrentProjectFileName) + '\' + GetCurrentProject.CurrentPlatform + '\' + GetCurrentProject.CurrentConfiguration, '*.dex', TSearchOption.soTopDirectoryOnly);

                     for x := 0 to High(FileList) do
                        if ExtractFileName(FileList[x]) <> 'classes.dex'
                        then
                           DeleteFile(FileList[x]);

                  end;

               if FileExists(BDSDir + '\bin\CodeGear.DelphiRD.Targets')
               then
                  begin
                     RenameFile(BDSDir + '\bin\CodeGear.Delphi.Targets', BDSDir + '\bin\CodeGear.DelphiDRD.Targets');
                     RenameFile(BDSDir + '\bin\CodeGear.DelphiRD.Targets', BDSDir + '\bin\CodeGear.Delphi.Targets');
                  end;

            end
         else
            begin

               if FileExists(BDSDir + '\bin\CodeGear.DelphiDRD.Targets')
               then
                  begin
                     RenameFile(BDSDir + '\bin\CodeGear.Delphi.Targets', BDSDir + '\bin\CodeGear.DelphiRD.Targets');
                     RenameFile(BDSDir + '\bin\CodeGear.DelphiDRD.Targets', BDSDir + '\bin\CodeGear.Delphi.Targets');
                  end;

            end;

      end;

  if not PlatformConfigBuildOptions.PreBuildEnabled
  then
     Exit;
  if PlatformConfigBuildOptions.PreBuildEvents.Count = 0
  then
     Exit;
  BuildEngine.RefreshMacros;
   if not Assigned(FBuildEvenStat)
   then
     FBuildEvenStat := TFBuildEvenStat.Create(Application);
   FBuildEvenStat.PBuildEventStatHeader.Caption := 'Running PreBuild Events';
   FBuildEvenStat.Memo1.Lines.Text := '';
  for Index := 0 to PlatformConfigBuildOptions.PreBuildEvents.Count - 1 do
  begin
    try
      if PlatformConfigBuildOptions.PreBuildEvents[Index].Param <> ''
      then
         if ProjOptions.GetParam(PlatformConfigBuildOptions.PreBuildEvents[Index].Param).OnOff = PlatformConfigBuildOptions.PreBuildEvents[Index].OnOff
         then
            begin
               Command := Trim(PlatformConfigBuildOptions.PreBuildEvents[Index].Command);
               if Command = '' then Continue;
               if Pos('REM', UpperCase(Command)) = 1 then Continue;
               AddMessageTitle(mtCustom,
                 Format('Pre-build: %s', [Command]));
               LogResults(mtSuccess, BuildEngine.Command(Command));
            end
         else
      else
         begin
            Command := Trim(PlatformConfigBuildOptions.PreBuildEvents[Index].Command);
            if Command = '' then Continue;
            if Pos('REM', UpperCase(Command)) = 1 then Continue;
            AddMessageTitle(mtCustom,
              Format('Pre-build: %s', [Command]));
            LogResults(mtSuccess, BuildEngine.Command(Command));
         end;
    except
      on E: Exception do
      begin
        LogLine(mtError, E.Message);
        LogException(E, 'TBuildOptionExpert.ExecutePreBuildEvent');
      end;
    end;
  end;
   FBuildEvenStat.Visible := False;
end;
procedure TBuildOptionExpert.LoadBuildOptions(const FileName: string);
begin
  LogText('In - TBuildOptionExpert.LoadBuildOptions (File: %s)', [FileName]);
  try
//    Options.SaveProjectEvents(True);
    Options.LoadProjectEvents(FileName);
    BuildEngine.RefreshMacros;
  except
    on E: Exception do
    begin
      LogLine(mtError, E.Message);
      LogException(E, 'TBuildOptionExpert.LoadBuildOptions');
    end;
  end;
  LogText('Out - TBuildOptionExpert.LoadBuildOptions (File: %s)', [FileName]);
end;
procedure TBuildOptionExpert.AddMessage(AText: String; AForeColour: TColor;
  AStyle: TFontStyles; ABackColour : TColor = clWindow);
var
{$IFNDEF D7_UP}
  I: Integer;
{$ENDIF}
  Mesg : TBuildEventMessage;
begin
  if (Trim(AText) = '') then Exit; // do not add empty / blank lines
  Application.ProcessMessages;
  try
    With (BorlandIDEServices As IOTAMessageServices) Do
    begin
      Mesg := TBuildEventMessage.Create(AText, FontName, AForeColour,
        AStyle, ABackColour);
      Mesg.FontSize := FontSize;
      AddCustomMessage(Mesg As IOTACustomMessage
        {$IFDEF D7_UP}, BuildEventsGroup{$ENDIF});
      {$IFDEF D7_UP}
        ShowMessageView(BuildEventsGroup);
      {$ELSE}
      for I := 0 to Screen.FormCount - 1 do
        if CompareText(Screen.Forms[I].ClassName, 'TMessageViewForm') = 0 then
           Screen.Forms[I].Visible := True;
      {$ENDIF}
    end;
  except
    On E: Exception do LogException(E, 'TBuildOptionExpert.AddMessage');
  end;
end;
procedure TBuildOptionExpert.ClearMessages(AMsgType: TClearMessages);
begin
  with (BorlandIDEServices As IOTAMessageServices) do
  begin
    if (cmCompiler In AMsgType) then ClearCompilerMessages;
    if (cmSearch in AMsgType) then ClearSearchMessages;
    if (cmTool in AMsgType) then ClearToolMessages;
    if (cmBuildEvents in AMsgType) then {$IFDEF D7_UP}
      ClearMessageGroup(BuildEventsGroup); {$ELSE} ClearToolMessages; {$ENDIF}
    if (cmAll in AMsgType) then ClearAllMessages;
  end;
end;
procedure TBuildOptionExpert.DoOnAutoSaveTimerEvent(Sender: TObject);
var
  activeProject: IOTAProject;
begin
  if Assigned(FAutoSaveTimer) then
  begin
    FAutoSaveTimer.Enabled := False;
    if (ProjOptions.AutoSaveProject) then
    begin
      activeProject := GetCurrentProject;
      if (activeProject <> nil) then
      begin
        try
          if activeProject.Save(False, True) then
            LogLine(mtInfo, '%s Saved', [ProjectName]);
        except
          On E: Exception do LogException(E,
            'TBuildOptionExpert.DoOnAutoSaveTimerEvent');
        end;
      end;
    end;
    FAutoSaveTimer.Enabled := True;
  end;
end;
{ TBADIToolsAPIFunctions }

class procedure TBADIToolsAPIFunctions.RegisterFormClassForTheming(
  const AFormClass: TCustomFormClass; const Component: TComponent);

   {$IFDEF Ver320}
   Var
     ITS : IOTAIDEThemingServices250;
   {$ENDIF Ver320}
   {$IFDEF Ver330}
   Var
     ITS : IOTAIDEThemingServices250;
   {$ENDIF Ver330}
   {$IFDEF Ver340}
   Var
     ITS : IOTAIDEThemingServices;
  {$ENDIF Ver340}

Begin

  {$IFDEF Ver340}
  If Supports(BorlandIDEServices, IOTAIDEThemingServices, ITS) Then
    If ITS.IDEThemingEnabled Then
      Begin
        ITS.RegisterFormClass(AFormClass);
        If Assigned(Component) Then
          ITS.ApplyTheme(Component);
      End;
  {$ENDIF Ver340}

  {$IFDEF Ver330}
  If Supports(BorlandIDEServices, IOTAIDEThemingServices250, ITS) Then
    If ITS.IDEThemingEnabled Then
      Begin
        ITS.RegisterFormClass(AFormClass);
        If Assigned(Component) Then
          ITS.ApplyTheme(Component);
      End;
  {$ENDIF Ver330}
  {$IFDEF Ver320}
  If Supports(BorlandIDEServices, IOTAIDEThemingServices250, ITS) Then
    If ITS.IDEThemingEnabled Then
      Begin
        ITS.RegisterFormClass(AFormClass);
        If Assigned(Component) Then
          ITS.ApplyTheme(Component);
      End;
  {$ENDIF Ver320}
End;

initialization
  FBuildOptionExpert := TBuildOptionExpert.Instance;
finalization
  FreeAndNil(FBuildOptionExpert);
end.
