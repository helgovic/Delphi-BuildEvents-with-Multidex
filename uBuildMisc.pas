unit uBuildMisc;

interface

{$I BuildEvents.inc}

uses
  Classes,
  SysUtils,
  Windows,
  Forms,
  ShellAPI,
  Dialogs,
  StdCtrls,
  Buttons,
  ExtCtrls,
  Graphics,
  Controls,
  Menus,
  ToolsAPI,
  ActnList,
  System.Actions,
  System.Generics.Collections,
  JCLStrings;

const
  REG_KEY = '\Software\SoftMagical\Experts';
  REG_BUILD_OPTIONS = 'BuildOptions';

type

{ TAutoCloseMessage }

  TAutoCloseMessage = class
  private
    FForm: TForm;
    FInterval: Integer;
    FLabel: TLabel;
    FLabelTime: TLabel;
    FResult: Word;
    FTimer: TTimer;
    FTimeOut: Boolean;
    procedure DoOnDialogShow(Sender: TObject);
    procedure DoOnDialogClose(Sender: TObject; var Action: TCloseAction);
    procedure SetDefaultButton(AButtons: TMsgDlgButtons);
  protected
    procedure DoOnTimerTick(Sender: TObject);
    procedure FreeResources;
    procedure InitLabel(ASeconds: Integer);
    procedure InitTimer(ASeconds: Integer);
  public
    constructor Create(const AMessage: string; AType: TMsgDlgType;
      AButtons: TMsgDlgButtons; AHelpContext: Longint; ADefResult: Word;
      ASeconds: Integer = 10);
    destructor Destroy; override;

    function ResultStr(AIndex: Integer): string;
    function Execute: Word;
  end;

  TWaitOption = (woNoWait, woUntilStart, woUntilFinish);
  TPostBuildOption = (boAlways, boSuccess, boFailed, boNone);
  EatsWindowsError = class(Exception);

  TParam = record
    Name: string;
    OnOff: Boolean;
  end;

  TProjOptions = class(TObject)
  private
    FAutoSaveProject: Boolean;
    FAutoSaveInterval: Integer;
    FFileName: String;
    procedure SetFileName(const Value: string);
    function GetFileName: String;
  public
    FParams: TList<TParam>;
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Load(SourceFile: String);
    procedure Save;
    function GetParam(Name: String): TParam;
    property AutoSaveProject : Boolean read FAutoSaveProject write FAutoSaveProject;
    property AutoSaveInterval: Integer read FAutoSaveInterval
      write FAutoSaveInterval;
    property FileName: String read GetFileName
      write SetFileName;
  end;

{ TBuildOptions }

  TBuildCommand = record
    Command: string;
    Param: string;
    OnOff: Boolean;
  end;

  TPlatformConfigBuildOptions = class(TObject)
  private
    FPlatformConfig: string;
    FPreBuildEvents: TList<TBuildCommand>;
    FPostBuildEvents: TList<TBuildCommand>;
    FPostBuildOption: TPostBuildOption;
    FPreBuildEnabled: Boolean;
    FPostBuildEnabled: Boolean;
  public
    constructor Create; virtual;
    property PreBuildEvents : TList<TBuildCommand> read FPreBuildEvents
      write FPreBuildEvents;
    property PostBuildEvents : TList<TBuildCommand> read FPostBuildEvents
      write FPostBuildEvents;
    property PostBuildOption: TPostBuildOption read FPostBuildOption
      write FPostBuildOption;
    property PreBuildEnabled: Boolean read FPreBuildEnabled
      write FPreBuildEnabled;
    property PostBuildEnabled: Boolean read FPostBuildEnabled
      write FPostBuildEnabled;
    property PlatformConfig: string read FPlatformConfig
      write FPlatformConfig;
  end;

  TBuildOptions = class(TObject)
  private
    function ConvertBuildEventStringToIniFormat(
      Commands: TList<TBuildCommand>): string;
    procedure ConvertIniFormatStringToBuildEvent(const Text: String;
      var Commands: TList<TBuildCommand>);
  public
    FPlatformConfigBuildOptions: TList<TPlatformConfigBuildOptions>;
    constructor Create; virtual;
    destructor Destroy; override;
    procedure LoadProjectEvents(const NewFileName: string);
    procedure SaveProjectEvents(const FileCheck: Boolean = False);
    procedure CopyProjectEvents(const ASourceFile: string);
    procedure SaveAll;
    procedure ClearEvents;
    procedure Reset;
    function ShowDialog(AFileName: String): Boolean;
    function GetPlatformConfigBuildOptions(APlatformConfig: string): TPlatformConfigBuildOptions;
  end;

function PosBack(psSearch, psSource : String):  Integer;
function PosFrom(psSearch, psSource : String; piStartPos : Integer) : Integer;
function GetLastWindowsError : String;
function RunProgram(psCmdLine : String;
  AWaitUntil : TWaitOption) : TProcessInformation;
function WildcardCompare(psWildCard, psCompare : String;
  pbCaseSens : Boolean = false) : Boolean;
function GetBuildMacroList: TStringList;
function StringContains(ASource: String; AStringArray: array of string;
  AIgnoreCase: Boolean = True): Boolean;
function ContainsString(ASource: String; AStringArray: array of string;
  AIgnoreCase: Boolean = True): Boolean;
function IfThen(ACondition: Boolean; ATrueValue, AFalseValue: Variant): Variant;
{$IFNDEF D6_UP}
function BoolToStr(ABoolean: Boolean; AUseBoolStrs: Boolean = False): string;
{$ENDIF}
function GetConfirmation(AMessage: String): Boolean; overload;
function GetConfirmation(const AFormat: string;
  AParams: array of const): Boolean; overload;
procedure SafeFreeAndNil(var AObject: TControl);
procedure ShowError(AMessage: String); overload;
procedure ShowError(const AFormat: string; AParams: array of const); overload;
procedure ShowInformation(ACaption, AMessage: String); overload;
procedure ShowInformation(AMessage: String); overload;
procedure ShowInformation(const AFormat: string; AParams: array of const); overload;
procedure ShowWarning(AMessage: String); overload;
procedure ShowWarning(const AFormat: string; AParams: array of const); overload;

procedure LogText(AText: String); overload;
procedure LogText(const AFormat: String; AParams: array of const); overload;
procedure LogException(AException: Exception; AMethod: String = '');

function GetDoneTimeStr(ATime: Double): String;
function GetDoneNowTimeStr(AStartTime: Double): String;

function ValidatePath(const Path: string): string;
function ValidateDir(const Dir: string): string;

{ Registry Methods }
procedure AddCustomMacro(AName, AValue: String);
procedure EditCustomMacro(AName, ANewName, AValue: String);
procedure DeleteCustomMacro(AName: String);
function GetCustomMacros: TStringList;

{ Open Tools Methods }
function GetProjectPath: string;
function ExecuteIDEAction(const ActionName: string): Boolean;
function FindIDEAction(const ActionName: string): TContainedAction;
function FindEditorContextPopupMenu: TPopupMenu;
function GetCurrentProject: IOTAProject;
function GetCurrentProjectFileName: string;
function GetCurrentProjectName: String;
function GetEnvVar(const AVarName: string): String;
function GetIDEMainMenu: TMainMenu;
function GetIDEMenuItem(AName: String): TMenuItem;
function GetProject: IOTAProject;
function GetProjectGroup: IOTAProjectGroup;
function GetProjectGroupFileName: string;
function GetProjectOption(const Name: string): string;
function GetActiveProjectOptions(
  AProject: IOTAProject = nil): IOTAProjectOptions;
function GetProjectOptionsNames(AOptions: IOTAOptions;
  AList: TStrings; AIncludeType: Boolean = False): Boolean;
function QuerySvcs(const Instance: IUnknown;
  const Intf: TGUID; out Inst): Boolean;

function FindMenuItem(MenuCaptions: String): TMenuItem;

const
  C_DEFAULT_FONT_NAME = 'Tahoma';
  C_DEFAULT_FONT_SIZE = 8;
  C_5_MINUTES         = 60000 * 5;

implementation

uses
  {$IFDEF D6_UP} Variants, {$ENDIF}
  IniFiles,
  uBuildOptionsForm,
  Registry,
  PlatformAPI;

const
  REG_MACROS = 'Macros';
  MAX_BUFFER_SIZE = 255;
  MULTI_CHAR = ['*'];
  SINGLE_CHAR = ['?'];
  WILD_CARDS = MULTI_CHAR + SINGLE_CHAR;

{$IFNDEF D6_UP}
function BoolToStr(ABoolean: Boolean; AUseBoolStrs: Boolean = False): string;
const
  cSimpleBoolStrs: array [boolean] of String = ('No', 'Yes');
  cTrueFalseStr: array[Boolean] of String = ('False', 'True');
begin
  if AUseBoolStrs then
    Result := cTrueFalseStr[ABoolean]
  else
    Result := cSimpleBoolStrs[ABoolean];
end;
{$ENDIF}

function GetProjectPath: string;
begin
  Result := ValidatePath(ExtractFilePath(GetCurrentProjectFileName));
end;

procedure LogText(AText: String);
begin
  {$IFDEF DEBUG_ON}
  if (AText = EmptyStr) then Exit;
  OutputDebugString(PAnsiChar(FormatDateTime('[hh:nn:ss.zzz] ', Time) + AText));
  {$ENDIF}
end;

procedure LogText(const AFormat: String; AParams: array of const);
begin
  LogText(Format(AFormat, AParams));
end;

procedure LogException(AException: Exception; AMethod: String = '');
begin
  LogText('Exception: %s, occured in %s method', [AException.Message, AMethod]);
end;

function QuerySvcs(const Instance: IUnknown; const Intf: TGUID;
  out Inst): Boolean;
begin
  Result := (Instance <> nil) and Supports(Instance, Intf, Inst);
end;

function GetEnvVar(const AVarName: string): string;
{$IFNDEF D6_UP}
var
  nSize: DWORD;
{$ENDIF}
begin
{$IFDEF D6_UP}
  Result := GetEnvironmentVariable(AVarName);
{$ELSE}
  nSize := GetEnvironmentVariable(PChar(AVarName), @Result[1], 0);
  SetLength(Result, nSize);
  GetEnvironmentVariable(PChar(AVarName), @Result[1], nSize);
{$ENDIF}
  Result := Trim(Result);
end;

function GetProjectGroup: IOTAProjectGroup;

var
   IModuleServices: IOTAModuleServices;
   IModule: IOTAModule;
   i: Integer;

begin

   IModuleServices := BorlandIDEServices as IOTAModuleServices;

   Result := nil;

   for i := 0 to IModuleServices.ModuleCount - 1 do
      begin

         IModule := IModuleServices.Modules[i];

         if IModule.QueryInterface(IOTAProjectGroup, Result) = S_OK
         then
            Break;

      end;

end;

function GetActiveProjectOptions(AProject: IOTAProject = nil): IOTAProjectOptions;
begin
  Result := nil;
  if Assigned(AProject) then
  begin
    Result := AProject.ProjectOptions;
    Exit;
  end else
  begin
    AProject := GetCurrentProject;
    if Assigned(AProject) then
      Result := AProject.ProjectOptions;
  end;
end;

function GetProjectOptionsNames(AOptions: IOTAOptions; AList: TStrings;
  AIncludeType: Boolean = False): Boolean;
var
  Names: TOTAOptionNameArray;
  I: Integer;
begin
  Result := False;
  AList.Clear;
  Names := nil;
  if not Assigned(AOptions) then
    AOptions := GetActiveProjectOptions(nil);

  if not Assigned(AOptions) then Exit;

  Names := AOptions.GetOptionNames;
  try
    for I := Low(Names) to High(Names) do
      {if AIncludeType then  AList.Add(Names[i].Name + ': ' +
        GetEnumName(TypeInfo(TTypeKind), Ord(Names[i].Kind)))
      else}
        AList.Add(Names[i].Name + '=' +
          VarToStr(AOptions.Values[Names[I].Name]));
  finally
    Names := nil;
    Result := AList.Count > 0;
  end;
end;

function GetProjectGroupFileName: string;
var
  IModuleServices: IOTAModuleServices;
  IModule: IOTAModule;
  IProjectGroup: IOTAProjectGroup;
  i: Integer;
begin
  Result := '';
  IModuleServices := BorlandIDEServices as IOTAModuleServices;
  if IModuleServices = nil then Exit;

  IProjectGroup := nil;
  for i := 0 to IModuleServices.ModuleCount - 1 do
  begin
    IModule := IModuleServices.Modules[i];
    if IModule.QueryInterface(IOTAProjectGroup, IProjectGroup) = S_OK then
      Break;
  end;
  // Delphi 5 does not return the file path when querying IOTAProjectGroup
  // directly
  if IProjectGroup <> nil then
    Result := IModule.FileName;
end;

function GetCurrentProject: IOTAProject;

var
   Project: IOTAProject;
   ProjectGroup: IOTAProjectGroup;

begin

   Result := nil;

   ProjectGroup := GetProjectGroup;

   if Assigned(ProjectGroup)
   then
      begin

         Project := ProjectGroup.ActiveProject;

         if Assigned(Project)
         then
            Result := Project;

      end;

end;

function GetProject: IOTAProject;
var
  ModuleServices: IOTAModuleServices;
  Module: IOTAModule;
  i: Integer;
begin
  Result := nil;
  QuerySvcs(BorlandIDEServices, IOTAModuleServices, ModuleServices);
  if ModuleServices <> nil then
    for i := 0 to ModuleServices.ModuleCount - 1 do
    begin
      Module := ModuleServices.Modules[i];
      if Supports(Module, IOTAProject, Result) then
        Break;
    end;

end;

function GetCurrentProjectFileName: string;
var
  IProject: IOTAProject;
begin
  Result := '';

  IProject := GetCurrentProject;
  if Assigned(IProject) then
  begin
    Result := IProject.FileName;
  end;
end;

function FindMenuItem(MenuCaptions: String): TMenuItem;

var
   Captions: TStringList;
   NTAServices: INTAServices;
   y, i: integer;
   MenuItems: TMenuItem;
   Caption: String;
   Found: Boolean;

begin

   Result := nil;

   if Supports(BorlandIDEServices, INTAServices, NTAServices)
   then
      begin

         Captions := TStringList.Create;
         Captions.Delimiter := ';';
         Captions.StrictDelimiter := True;
         Captions.DelimitedText := MenuCaptions;

         MenuItems := NTAServices.MainMenu.Items;

         for y := 0 to Captions.Count - 1 do
            begin

               Found := False;

               for i := 0 to MenuItems.Count - 1 do
                  begin

                     Caption := StringReplace(MenuItems.Items[i].Caption, '&', '', []);

                     if Uppercase(Caption) = Uppercase(Captions[y])
                     then
                        begin
                           MenuItems := MenuItems.Items[i];
                           Found := True;
                           Break;
                        end;

                  end;

               if not Found
               then
                  begin
                     Captions.DisposeOf;
                     Exit;
                  end;

            end;

         Result := MenuItems;
         Captions.DisposeOf;

      end;

end;

function FindEditorContextPopupMenu: TPopupMenu;
var
  EditorServices: IOTAEditorServices;
begin
  Result := nil;

  EditorServices := BorlandIDEServices as IOTAEditorServices;
  if not Assigned(EditorServices) then Exit;
  if not Assigned(EditorServices.TopView) then Exit;
  if not Assigned(EditorServices.TopView.GetEditWindow) then Exit;
  if not Assigned(EditorServices.TopView.GetEditWindow.Form) then Exit;
  Result := (EditorServices.TopView.GetEditWindow.Form.FindComponent(
    'EditorLocalMenu') as TPopupMenu);
end;

function FindIDEAction(const ActionName: string): TContainedAction;
var
  Svcs: INTAServices;
  ActionList: TCustomActionList;
  i: Integer;
begin
  Result := nil;
  if ActionName = '' then Exit;

  QuerySvcs(BorlandIDEServices, INTAServices, Svcs);
  ActionList := Svcs.ActionList;
  for i := 0 to ActionList.ActionCount - 1 do
    if SameText(ActionList.Actions[i].Name, ActionName) then
    begin
      Result := ActionList.Actions[i];
      Exit;
    end;
end;

function ExecuteIDEAction(const ActionName: string): Boolean;
var
  Action: TContainedAction;
begin
  Action := FindIDEAction(ActionName);
  if Assigned(Action) then
    Result := Action.Execute
  else
    Result := False;
end;

function GetIDEMainMenu: TMainMenu;
var
  Svcs40: INTAServices40;
begin
  QuerySvcs(BorlandIDEServices, INTAServices40, Svcs40);
  Result := Svcs40.MainMenu;
end;

// Usage: GetIDEMenuItem('Tools')
function GetIDEMenuItem(AName: String): TMenuItem;
var
  MainMenu: TMainMenu;
  i: Integer;
begin
  Result := nil;
  MainMenu := GetIDEMainMenu;
  if MainMenu <> nil then
  begin
    for i := 0 to MainMenu.Items.Count - 1 do
      if AnsiCompareText(AName, MainMenu.Items[i].Name) = 0 then
      begin
        Result := MainMenu.Items[i];
        Exit;
      end
  end;
end;

function GetCurrentProjectName: String;

var
   Project: IOTAProject;
   ProjectGroup: IOTAProjectGroup;

begin

   Result := '';

   ProjectGroup := GetProjectGroup;

   if Assigned(ProjectGroup)
   then
      begin

         Project := ProjectGroup.ActiveProject;

         if Assigned(Project)
         then
            Result := Project.FileName;

      end;

end;

procedure SafeFreeAndNil(var AObject: TControl);
begin
  try
    if Assigned(Pointer(AObject)) then
      FreeAndNil(AObject);
  except end;
end;

function ValidatePath(const Path: string): string;
begin
  Result := Trim(Path);

  {$IFDEF D6_UP}
    Result := ExcludeTrailingPathDelimiter(Result);
    Result := IncludeTrailingPathDelimiter(Result);
  {$ELSE}
    Result := ExcludeTrailingBackslash(Result);
    Result := IncludeTrailingBackslash(Result);
  {$ENDIF}

  Result := StringReplace(Result, '\\', '\', [rfReplaceAll]);
end;

function ValidateDir(const Dir: string): string;
begin
  Result := ValidatePath(Dir);
  Result :=
    {$IFDEF D6_UP}
      ExcludeTrailingPathDelimiter(Result);
    {$ELSE}
      ExcludeTrailingBackslash(Result);
    {$ENDIF}
end;

function GetProjectOption(const Name: string): string;
var
  IProject: IOTAProject;
  IProjectOptions: IOTAProjectOptions;

begin
  Result := '';

  IProject := GetCurrentProject;
  if not Assigned(IProject) then Exit;

  IProjectOptions := IProject.ProjectOptions;
  if not Assigned(IProjectOptions) then Exit;

  Result := VarToStr(IProjectOptions.Values[Name]);
end;

function GetProjectFileName: string;
var
  IProject: IOTAProject;
begin
  IProject := GetCurrentProject;
  if Assigned(IProject) then
    Result := IProject.FileName
  else
    Result := '';
end;

function GetBuildMacroList: TStringList;
var
  Value: string;
  PlatformSDKServices: IOTAPlatformSDKServices;
  AndroidSDK: IOTAPlatformSDKAndroid;
  ProjFile: TextFile;
  Line: String;
  slList: TStringList;
  i: Integer;
  BDSVar: String;
  PG: string;

begin

   Result := GetCustomMacros;

   Value := ValidateDir(GetEnvVar('BDS'));

   if Value = ''
   then
      begin

         Value := ValidateDir(ExtractFileDir(ParamStr(0)));

         if LowerCase(Copy(Value, Length(Value) - 3, 4)) = '\bin'
         then
            Delete(Value, Length(Value) - 3, 4);

      end;

   BDSVar := Value;

   Result.AddPair('BDS', Value);

   Result.AddPair('DEFINES', GetProjectOption('Defines'));
   Result.AddPair('CONFIG', GetCurrentProject.CurrentConfiguration);

   PlatformSDKServices := (BorlandIDEServices as IOTAPlatformSDKServices);
   AndroidSDK := PlatformSDKServices.GetDefaultForPlatform(cAndroid32ArmPlatform) as IOTAPlatformSDKAndroid;

   Result.AddPair('PLATFORM', GetCurrentProject.CurrentPlatform);

   if ProjOptions.FParams[0].OnOff
   then
      Value := 'MultiDex'
   else
      Value := 'NoMultiDex';

   Result.AddPair('MultiDex', Value);

   Result.AddPair('SDKAaptPath', AndroidSDK.SDKAaptPath);
   Result.AddPair('SDKAndroidPath', AndroidSDK.SDKAndroidPath);
   Result.AddPair('JDKPath', AndroidSDK.JDKPath);
   Result.AddPair('JavaDxPath', ExtractFileDir(AndroidSDK.SDKAaptPath) + '\dx.bat');
   Result.AddPair('SDKApiLevelPath', AndroidSDK.SDKApiLevel);

   Result.AddPair('Path', GetEnvVar('Path'));

   Value := GetCurrentProjectFileName;
   Result.AddPair('PROJECTDIR', ValidateDir(ExtractFileDir(Value)));
   Result.AddPair('PROJECTEXT', ExtractFileExt(Value));
   Result.AddPair('PROJECTFILENAME', ExtractFileName(Value));
   Result.AddPair('PROJECTNAME', Copy(ExtractFileName(Value), 1,
      Length(ExtractFileName(Value)) - Length(ExtractFileExt(Value))));
   Result.AddPair('PROJECTPATH', Value);

   Result.AddPair('SystemRoot', GetEnvVar('SystemRoot'));

   Value := ValidateDir(GetEnvVar('TEMP'));

   if Value = ''
   then
      Value := ValidateDir(GetEnvVar('TMP'));

   Result.AddPair('TEMPDIR', Value);

   Result.AddPair('UNITOUTPUTDIR', GetProjectOption('UnitOutputDir'));
   Result.AddPair('WINDIR', GetEnvVar('WINDIR'));

   slList := TStringList.Create;
   slList.Delimiter := ';';
   slList.StrictDelimiter := True;
   Value := '';

   AssignFile(ProjFile, GetCurrentProjectFileName);
   Reset(ProjFile);

   while not Eof(ProjFile) do
      begin

         Readln(ProjFile, Line);

         if Pos('<PropertyGroup Condition="''$(Base_Android)''!=''''">', Line) > 0
         then
            PG := 'Android';

         if Pos('<PropertyGroup Condition="''$(Base_Android64)''!=''''">', Line) > 0
         then
            PG := 'Android64';

         if (Pos('<EnabledSysJars>', Line) > 0) and
            (PG = GetCurrentProject.CurrentPlatform)
         then
            begin

               Line := StrAfter('<EnabledSysJars>', StrBefore('</EnabledSysJars>', Line));

               if ProjOptions.FParams[0].OnOff
               then
                  Line := StringReplace(Line, '.dex.', '.', [rfReplaceAll]);

               slList.DelimitedText := Line;

               for i := 0 to slList.Count - 1 do
                  if i = 0
                  then
                     Value := '!q!' + BDSVar + '\lib\' + GetCurrentProject.CurrentPlatform + '\' + GetCurrentProject.CurrentConfiguration + '\' + slList[i] + '!q!'
                  else
                     Value := Value + ' !q!' + BDSVar + '\lib\' + GetCurrentProject.CurrentPlatform + '\' + GetCurrentProject.CurrentConfiguration + '\' + slList[i] + '!q!'

            end;

         if Pos('<JavaReference', Line) > 0
         then
            begin

               Line := StrAfter('Include="', StrBefore('">', Line));

               if not ProjOptions.FParams[0].OnOff
               then
                  Line := StringReplace(Line, '.jar', '-dexed.jar', [rfReplaceAll]);

               if Pos(':', Line) = 0
               then
                  Line := ExtractFileDir(GetCurrentProjectFileName) + '\' + Line;

                if Value = ''
                then
                   Value := '!q!' + Line + '!q!'
                else
                   Value := Value + ' !q!' + Line + '!q!';

            end;

      end;

   CloseFile(ProjFile);

   Result.AddPair('Jars', Value);

   slList.DisposeOf;

end;

function IfThen(ACondition: Boolean; ATrueValue, AFalseValue: Variant): Variant;
begin
  if ACondition then
    Result := ATrueValue
  else
    Result := AFalseValue;
end;

procedure AddCustomMacro(AName, AValue: String);
begin
  with TRegIniFile.Create(REG_KEY) do
  try
    WriteString(REG_MACROS, AName, AValue);
  finally
    Free;
  end;
end;

procedure EditCustomMacro(AName, ANewName, AValue: String);
begin
  with TRegIniFile.Create(REG_KEY) do
  try
    DeleteKey(REG_MACROS, AName);
    WriteString(REG_MACROS, ANewName, AValue);
  finally
    Free;
  end;
end;

procedure DeleteCustomMacro(AName: String);
begin
  with TRegIniFile.Create(REG_KEY) do
  try
    DeleteKey(REG_MACROS, AName);
  finally
    Free;
  end;
end;

function GetCustomMacros: TStringList;
begin

  Result := TStringList.Create;

//  with TRegIniFile.Create(REG_KEY) do
//  try
//    { Custom Macros }
//    ReadSectionValues(REG_MACROS, Result);
//  finally
//    Free;
//  end;
end;

function StringContains(ASource: String; AStringArray: array of string;
  AIgnoreCase: Boolean = True): Boolean;
var
  Loop: Integer;
begin
  Result := False;
  for Loop := Low(AStringArray) to High(AStringArray) do
  begin
    Result := IfThen(AIgnoreCase,
      (0 = CompareText(ASource, AStringArray[Loop])),
      (ASource = AStringArray[Loop]));
    if Result then Break;
  end;
end;

function ContainsString(ASource: String; AStringArray: array of string;
  AIgnoreCase: Boolean = True): Boolean;
var
  Loop: Integer;
begin
  Result := False;
  if AIgnoreCase then
  begin
    ASource := LowerCase(ASource);
    for Loop := Low(AStringArray) to High(AStringArray) do
      AStringArray[Loop] := LowerCase(AStringArray[Loop]);
  end;

  for Loop := Low(AStringArray) to High(AStringArray) do
  begin
    Result := (Pos(AStringArray[Loop], ASource) > 0);
    if Result then Break;
  end;
end;

function GetDoneTimeStr(ATime: Double): String;
begin
  if (ATime * 24 * 60 > 1) then
    Result := FormatDateTime('hh:nn:ss', ATime) //'done' time is more than 1 min
  else
    Result := Format('%f ms.', [ATime * 24 * 60 * 60 * 60]);
end;

function GetDoneNowTimeStr(AStartTime: Double): String;
begin
  Result := GetDoneTimeStr(Now - AStartTime);
end;

function PosBack(psSearch, psSource:  String):  Integer;
var
  blnFound  :  Boolean;
begin
  Result := Length(psSource) - Length(psSearch) + 1;
  blnFound := false;
  while (Result > 0) and (not blnFound) do
    begin
      if psSearch = Copy(psSource, Result, Length(psSearch)) then
        blnFound := true
      else
        Result := Result - Length(psSearch);
    end;
  if Result < 0 then
    Result := 0;
end;

function PosFrom(psSearch, psSource:  String; piStartPos: Integer): Integer;
begin
  Dec(piStartPos);
  if piStartPos < 0 then
    piStartPos := 0;
  Delete(psSource, 1, piStartPos);
  Result := Pos(psSearch, psSource);
  if Result > 0 then
    Result := piStartPos + Result;
end;

function GetLastWindowsError : String;
var
  dwrdError          :  DWord;
  pchrBuffer         :  PChar;
begin
  dwrdError := GetLastError;
  GetMem(pchrBuffer, MAX_BUFFER_SIZE);
  try
    FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, dwrdError, 0, pchrBuffer,
      MAX_BUFFER_SIZE, nil);
    Result := String(pchrBuffer);
  finally
    FreeMem(pchrBuffer, MAX_BUFFER_SIZE);
  end;
end;

function RunProgram(psCmdLine: String;
  AWaitUntil: TWaitOption): TProcessInformation;
var
  sErrorMsg,
  sCmdLine       :  String;
  StartInfo      :  TStartupInfo;
  iExitCode      :  Cardinal;
begin
  sCmdLine := psCmdLine + #0;

  with StartInfo do
  begin
    lpReserved := nil;
    lpDesktop := nil;
    lpTitle := nil;
    dwFlags := 0;
    cbReserved2 := 0;
    lpReserved2 := nil;
  end;

  StartInfo.cb := SizeOf(StartInfo);

  if CreateProcess(nil, PChar(sCmdLine), nil, nil, true, 0, nil, nil,
    StartInfo, Result) then
  begin
    if AWaitUntil in [woUntilStart, woUntilFinish] then
      WaitForInputIdle(Result.hProcess, INFINITE);

    if (AWaitUntil = woUntilFinish) then
      repeat
        Application.ProcessMessages;
        GetExitCodeProcess(Result.hProcess, iExitCode);
      until iExitCode <> STILL_ACTIVE;
  end else
  begin
    sErrorMsg := GetLastWindowsError;
    raise EatsWindowsError.Create(sErrorMsg);
  end;
end;   { RunProgram }

function WildcardCompare(psWildCard, psCompare : String;
  pbCaseSens : Boolean) : Boolean;
var
  strlstWild : TStringList;
  intPos,
  intStart,
  intCounter : Integer;
  strWork    : String;
  blnAtStart : Boolean;
begin
  { If it's not case sensitive, convert both strings to all uppercase. }
  if not pbCaseSens then
  begin
    psWildCard := UpperCase(psWildCard);
    psCompare := UpperCase(psCompare);
  end;

  { If either string is empty, return false immediately. }
  if (psWildCard = '') or (psCompare = '') then
  begin
    Result := false;
    Exit;
  end;

  strlstWild := TStringList.Create;
  try
    { ----------------------------------------------------------------------- }
    { First, we split the wildcard string up into sections - text vs wild
      cards with a line in a string list for each.

      So, the wildcard "abc*def?ghi" would be broken up into a string list
      like this:
             abc
             *
             def
             ?
             ghi

      }
    intStart := 1;
    for intCounter := 1 to Length(psWildCard) do
    begin
      {$IFDEF UNICODE}
      if CharInSet(psWildCard[intCounter], WILD_CARDS) then
      {$ELSE}
      if psWildCard[intCounter] in WILD_CARDS then
      {$ENDIF}
       begin
         if intStart < intCounter then
         begin
           strWork := Copy(psWildCard, intStart, intCounter - intStart);
           strlstWild.Add(strWork);
         end;
         strlstWild.Add(psWildCard[intCounter]);
         intStart := intCounter + 1;
       end;
    end;
    { If there's still some characters left over after the last wildcard has been found,
      add them to the end of the string list. This is for wildcard strings like "*bob". }
    if intStart <= Length(psWildCard) then
    begin
      strWork := Copy(psWildCard, intStart, Length(psWildCard));
      strlstWild.Add(strWork);
    end;

    Result := true;
    blnAtStart := true;
    intStart := 1;
    intCounter := 0;
    while (intCounter < strlstWild.Count) and Result do
    begin
      strWork := strlstWild[intCounter];
      {$IFDEF UNICODE}
      if (Length(strWork) = 1) and (CharInSet(strWork[1], WILD_CARDS)) then
      {$ELSE}
      if (Length(strWork) = 1) and (strWork[1] in WILD_CARDS) then
      {$ENDIF}
      begin
        {$IFDEF UNICODE}
        if CharInSet(strWork[1], MULTI_CHAR) then
        {$ELSE}
        if strWork[1] in MULTI_CHAR then
        {$ENDIF}
           { A multi-character wildcard (eg "*") }
           blnAtStart := false
        else
        begin
          { A single-character wildcard (eg "?") }
          blnAtStart := true;
          if intStart > Length(psCompare) then
            Result := false;
          Inc(intStart);
        end;
      end else
      begin
        if blnAtStart then
        begin
          { Text after a "?" }
          if Copy(psCompare, intStart, Length(strWork)) = strWork then
            intStart := intStart + Length(strWork)
          else
            Result := false;
        end else
        begin
          { Text after a "*" }
          if intCounter = strlstWild.Count - 1 then
            intPos := PosBack(strWork, psCompare)
          else
            intPos := PosFrom(strWork, psCompare, intStart);
          if intPos > 0 then
            intStart := intPos + Length(strWork)
          else
            Result := false;
         end;

        blnAtStart := true;
      end;
      Inc(intCounter);
    end;
    if Result and (blnAtStart) and (intStart <= Length(psCompare)) then
      Result := false;
  finally
    strlstWild.Free;
  end;
end;

function MessageDlgEx(const AMessage: string; AType: TMsgDlgType;
  AButtons: TMsgDlgButtons; AHelpContext: Longint; ADefResult: Word;
  ASeconds: Integer = 10): Word;
begin
  with TAutoCloseMessage.Create(AMessage, AType, AButtons, AHelpContext,
    ADefResult, ASeconds) do
  try
    Result := Execute;
  finally
    Free;
  end;
end;

procedure ShowError(AMessage: String);
begin
  MessageDlgEx(AMessage, mtError, [mbOk], 0, IDOK);
end;

procedure ShowError(const AFormat: string; AParams: array of const);
begin
  ShowError(Format(AFormat, AParams));
end;

procedure ShowWarning(AMessage: String);
begin
  MessageDlgEx(AMessage, mtWarning, [mbOK], 0, IDOK);
end;

procedure ShowWarning(const AFormat: string; AParams: array of const);
begin
  ShowError(Format(AFormat, AParams));
end;

procedure ShowInformation(ACaption, AMessage: String);
begin
  MessageBox(0, PChar(AMessage), PChar(ACaption),
    MB_OK or MB_ICONEXCLAMATION);
end;

procedure ShowInformation(AMessage: String);
begin
  MessageDlgEx(AMessage, mtInformation, [mbOK], 0, IDOK);
end;

procedure ShowInformation(const AFormat: string; AParams: array of const);
begin
  ShowInformation(Format(AFormat, AParams));
end;

function GetConfirmation(AMessage: String): Boolean;
begin
  Result :=
    MessageDlgEx(AMessage, mtConfirmation, [mbYes, mbNo], 0, IDNO) = IDYES;
end;

function GetConfirmation(const AFormat: string;
  AParams: array of const): Boolean;
begin
  Result := GetConfirmation(Format(AFormat, AParams));
end;

{ TAutoCloseMessage }

constructor TAutoCloseMessage.Create(const AMessage: string; AType: TMsgDlgType;
  AButtons: TMsgDlgButtons; AHelpContext: Longint; ADefResult: Word;
  ASeconds: Integer = 10);
begin
  inherited Create;
  FForm := CreateMessageDialog(AMessage, AType, AButtons);
  FForm.HelpContext := AHelpContext;
  FForm.OnShow := DoOnDialogShow;
  FForm.OnClose := DoOnDialogClose;
  FResult := ADefResult;
  FInterval := ASeconds;
  FTimeOut := False;
  SetDefaultButton(AButtons);
  if (ASeconds > 0) then
  begin
    InitLabel(ASeconds);
    InitTimer(ASeconds);
  end;
end;

destructor TAutoCloseMessage.Destroy;
begin
  FreeResources;
  inherited;
end;

procedure TAutoCloseMessage.DoOnTimerTick(Sender: TObject);
begin
  Dec(FInterval);
  FLabelTime.Caption := Format('%.2d', [FInterval]);
  FLabelTime.Refresh;

  if (FInterval <= 0) then
  begin
    (Sender as TTimer).Enabled := False;
    FTimeOut := True;
    FForm.ModalResult := FResult;
    FForm.Close;
  end;
end;

procedure TAutoCloseMessage.InitLabel(ASeconds: Integer);
begin
  FLabel:= TLabel.Create(FForm);
  FLabel.Parent := FForm;
  FLabel.Caption := 'This window will automatically close in 00 sec';
  FLabel.Font.Size := C_DEFAULT_FONT_SIZE;
  FLabel.Font.Color := clNavy;
  FLabel.Font.Style := [fsItalic];
  FLabel.Left := 6;
  FLabel.Top := FForm.ClientHeight - 16;

  FLabelTime:= TLabel.Create(FForm);
  FLabelTime.Parent := FForm;
  FLabelTime.Caption := Format('%.2d', [FInterval]);
  FLabelTime.Font.Size := C_DEFAULT_FONT_SIZE;
  FLabelTime.Font.Style := [fsItalic];
  FLabelTime.Left := FLabel.Left + FLabel.Width - 29;
  FLabelTime.Top := FLabel.Top;

  if (FForm.Width < 260) then FForm.Width := 260;
  FLabel.Visible := True;
  FLabelTime.Visible := True;
end;

procedure TAutoCloseMessage.InitTimer(ASeconds: Integer);
begin
  FTimer := TTimer.Create(FForm);
  FTimer.Interval := 1000;
  FTimer.OnTimer := DoOnTimerTick;
  FTimer.Enabled := True;
end;

function TAutoCloseMessage.ResultStr(AIndex: Integer): String;
const
  CReturnStr: array[0..10] of string = ('mrNone', 'mrOk', 'mrCancel', 'mrAbort',
    'mrRetry', 'mrIgnore', 'mrYes', 'mrNo', 'mrAll', 'mrNoToAll', 'mrYesToAll');
begin
  if (AIndex in [Low(CReturnStr).. High(CReturnStr)]) then
    Result := CReturnStr[AIndex]
  else
    Result := 'Unknown';
end;

procedure TAutoCloseMessage.SetDefaultButton(AButtons: TMsgDlgButtons);
var
  I: Integer;
begin
  if Assigned(FForm) then
  begin
    if (FResult = mrNone) then
    begin
      if (AButtons = mbOkCancel) then FResult := mrCancel;
    	 if (AButtons = mbYesNoCancel) then FResult := mrNo;
      if (AButtons = mbAbortRetryIgnore) then FResult := mrIgnore;
    end;

    for I := 0 to FForm.ComponentCount -1 do
    begin
      if (FForm.Components[I] is TButton) then
      begin
        //with FForm.Components[I] as TButton do ShowMessageFmt(
        //  '%s - %d - Default: %s', [Caption, ModalResult, ResultStr(FResult)]);

        if (TButton(FForm.Components[I]).ModalResult = FResult) then
        begin
          FForm.ActiveControl := TButton(FForm.Components[I]);
          Exit;
        end;
      end;
    end;
  end;
end;

procedure TAutoCloseMessage.DoOnDialogShow(Sender: TObject);
begin
  if Assigned(FForm) then
    AnimateWindow(FForm.Handle, 200, AW_CENTER or AW_ACTIVATE);
end;

procedure TAutoCloseMessage.DoOnDialogClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if Assigned(FForm) then
    AnimateWindow(FForm.Handle, 200, AW_CENTER or AW_HIDE);
end;

procedure TAutoCloseMessage.FreeResources;
begin

  if Assigned(FTimer)
  then
     begin
        FTimer.DisposeOf;
        FTimer := nil;
     end;

  if Assigned(FLabelTime)
  then
     begin
        FLabelTime.DisposeOf;
        FLabelTime := nil;
     end;

  if Assigned(FLabel)
  then
     begin
        FLabel.DisposeOf;
        FLabel := nil;
     end;

  if Assigned(FForm)
  then
     begin
        FForm.DisposeOf;
        FForm := nil;
     end;

//  SafeFreeAndNil(FTimer);
//  SafeFreeAndNil(FLabelTime);
//  SafeFreeAndNil(FLabel);
//  SafeFreeAndNil(FForm);
end;

function TAutoCloseMessage.Execute: Word;
begin
 if Assigned(FForm) then
 begin
   FForm.ShowModal;
   if (FTimeOut) then
     Result := FResult
   else
     Result := FForm.ModalResult;
 end else
   Result := FResult;
end;

{ TBuildOptions }

constructor TBuildOptions.Create;
begin
  inherited Create;
  FPlatformConfigBuildOptions := TList<TPlatformConfigBuildOptions>.Create;
end;

destructor TBuildOptions.Destroy;

var
   i: Integer;

begin

  for i := 0 to FPlatformConfigBuildOptions.Count - 1 do
     begin
        FPlatformConfigBuildOptions[i].FPreBuildEvents.DisposeOf;
        FPlatformConfigBuildOptions[i].FPostBuildEvents.DisposeOf;
        FPlatformConfigBuildOptions.Delete(i);
     end;

  FPlatformConfigBuildOptions.DisposeOf;

  inherited;

end;

function TBuildOptions.GetPlatformConfigBuildOptions(
  APlatformConfig: string): TPlatformConfigBuildOptions;

var
   i: Integer;

begin

   for i := 0 to FPlatformConfigBuildOptions.Count - 1 do
      if FPlatformConfigBuildOptions[i].PlatformConfig = APlatformConfig
      then
         begin

            Result := FPlatformConfigBuildOptions[i];
            Exit;

         end;

   Result := TPlatformConfigBuildOptions.Create;
   FPlatformConfigBuildOptions.Add(Result);

end;

procedure TProjOptions.Load(SourceFile: String);

var
   Params: TStringList;
   i: Integer;
   ParmR: TParam;

begin

   with TIniFile.Create(SourceFile) do
   try

      FAutoSaveProject := ReadBool('ProjOptions', 'AutoSave', False);
      FAutoSaveInterval := ReadInteger('ProjOptions', 'Interval', C_5_MINUTES);

      Params := TStringList.Create;
      Params.Delimiter := '¤';
      Params.StrictDelimiter := True;
      Params.DelimitedText := ReadString('ProjOptions', 'Params', 'MultiDex;False¤RunDex;True');

      FParams.Clear;

      for i := 0 to Params.Count - 1 do
         begin
            ParmR.Name := StrBefore(';', Params[i]);
            ParmR.OnOff := StrToBool(StrAfter(';', Params[i]));
            FParams.Add(ParmR);
         end;

      Params.DisposeOf;

   finally
      Free;
   end;

end;

procedure TProjOptions.Save;

var
   i: integer;
   TmpStr: String;

begin

   with TIniFile.Create(FileName) do
   try

      WriteBool('ProjOptions', 'AutoSave', FAutoSaveProject);
      WriteInteger('ProjOptions', 'Interval', FAutoSaveInterval);

      TmpStr := '';

      for i := 0 to FParams.Count - 1 do
         if TmpStr = ''
         then
            TmpStr := FParams[i].Name + ';' + BoolToStr(FParams[i].OnOff, True)
         else
            TmpStr := TmpStr + '¤' + FParams[i].Name + ';' + BoolToStr(FParams[i].OnOff, True);

      WriteString('ProjOptions', 'Params', TmpStr);

   finally
      Free;
   end;

end;

function TBuildOptions.ConvertBuildEventStringToIniFormat(
  Commands: TList<TBuildCommand>): string;

var
   Index: Integer;
   TmpStr: String;

begin

   Result := '';

   for Index := 0 to Commands.Count - 1 do
      begin

         TmpStr := Trim(Commands[Index].Command) + '¤' + Commands[Index].Param + '¤' + BoolToStr(Commands[Index].OnOff, True);

         if Result = ''
         then
            Result := TmpStr
         else
            Result := Result + '|' + TmpStr;

      end;

end;

procedure TBuildOptions.ConvertIniFormatStringToBuildEvent(const Text: string;
  var Commands: TList<TBuildCommand>);

var
   i: Integer;
   Event: TBuildCommand;
   InpStrings: TStringList;
   CommandStr: TStringList;

begin

   Commands.Clear;

   InpStrings := TStringList.create;
   InpStrings.Delimiter := '|';
   InpStrings.StrictDelimiter := True;
   InpStrings.DelimitedText := Text;

   CommandStr := TStringList.create;
   CommandStr.Delimiter := '¤';
   CommandStr.StrictDelimiter := True;

   for i := 0 to InpStrings.Count - 1 do
      begin

         CommandStr.DelimitedText := InpStrings[i];

         Event.Command := CommandStr[0];
         Event.Param := CommandStr[1];
         Event.OnOff := StrToBool(CommandStr[2]);

         Commands.Add(Event);

      end;

   InpStrings.DisposeOf;
   CommandStr.DisposeOf;

end;

procedure TBuildOptions.CopyProjectEvents(const ASourceFile: string);

var
   i: Integer;
   PlatForms: TArray<string>;
   CurrentProject: IOTAProject;
   PlatformConfigBuildOptions: TPlatformConfigBuildOptions;
   TmpPreBuildEvents : TList<TBuildCommand>;
   TmpPostBuildEvents : TList<TBuildCommand>;

begin

  LogText('TBuildOptions.CopyProjectEvents(ASourceFile: %s)', [ASourceFile]);

  ClearEvents;
  ProjOptions.Load(ASourceFile);

  CurrentProject := GetCurrentProject;
  PlatForms := CurrentProject.SupportedPlatforms;

  TmpPreBuildEvents := TList<TBuildCommand>.Create;
  TmpPostBuildEvents := TList<TBuildCommand>.Create;

   with TIniFile.Create(ASourceFile) do
   begin

      try

       for i := 0 to Length(PlatForms) - 1 do
          begin

             PlatformConfigBuildOptions := TPlatformConfigBuildOptions.Create;
             PlatformConfigBuildOptions.FPlatformConfig := PlatForms[i] + 'Debug';
             ConvertIniFormatStringToBuildEvent(Trim(ReadString(
                PlatForms[i] + 'Debug', 'PreBuild', '')), TmpPreBuildEvents);
             ConvertIniFormatStringToBuildEvent(Trim(ReadString(
                PlatForms[i] + 'Debug', 'PostBuild', '')), TmpPostBuildEvents);

             PlatformConfigBuildOptions.PreBuildEnabled := ReadBool(PlatForms[i] + 'Debug', 'PreBuildEnabled', False);
             PlatformConfigBuildOptions.PostBuildEnabled:= ReadBool(PlatForms[i] + 'Debug', 'PostBuildEnabled', False);

             PlatformConfigBuildOptions.PostBuildOption := TPostBuildOption(ReadInteger(
                PlatForms[i] + 'Debug', 'BuildEvent', 0));

             PlatformConfigBuildOptions.PreBuildEvents.AddRange(TmpPreBuildEvents);
             PlatformConfigBuildOptions.PostBuildEvents.AddRange(TmpPostBuildEvents);

             FPlatformConfigBuildOptions.Add(PlatformConfigBuildOptions);

             PlatformConfigBuildOptions := TPlatformConfigBuildOptions.Create;
             PlatformConfigBuildOptions.FPlatformConfig := PlatForms[i] + 'Release';
             ConvertIniFormatStringToBuildEvent(Trim(ReadString(
                PlatForms[i] + 'Release', 'PreBuild', '')), TmpPreBuildEvents);
             ConvertIniFormatStringToBuildEvent(Trim(ReadString(
                PlatForms[i] + 'Release', 'PostBuild', '')), TmpPostBuildEvents);

             PlatformConfigBuildOptions.PreBuildEnabled := ReadBool(PlatForms[i] + 'Release', 'PreBuildEnabled', False);
             PlatformConfigBuildOptions.PostBuildEnabled:= ReadBool(PlatForms[i] + 'Release', 'PostBuildEnabled', False);

             PlatformConfigBuildOptions.PostBuildOption := TPostBuildOption(ReadInteger(
                PlatForms[i] + 'Release', 'BuildEvent', 0));

             PlatformConfigBuildOptions.PreBuildEvents.AddRange(TmpPreBuildEvents);
             PlatformConfigBuildOptions.PostBuildEvents.AddRange(TmpPostBuildEvents);

             FPlatformConfigBuildOptions.Add(PlatformConfigBuildOptions);

          end;

        TmpPreBuildEvents.DisposeOf;
        TmpPostBuildEvents.DisposeOf;

        LogText('%s - Loaded', [ASourceFile]);

      finally
        Free;
      end;

   end;

  LogText('TBuildOptions.CopyProjectEvents(ASourceFile: %s)', [ASourceFile]);

end;

procedure TBuildOptions.LoadProjectEvents(const NewFileName: string);
begin
  ClearEvents;
  LogText('TBuildOptions.LoadProjectEvents(FileName: %s, NewFileName: %s)',
    [ProjOptions.FileName, NewFileName]);
  ProjOptions.FileName := NewFileName;
  CopyProjectEvents(ProjOptions.FileName);
  LogText('TBuildOptions.LoadProjectEvents(NewFileName: %s)', [ProjOptions.FileName]);
end;

procedure TBuildOptions.SaveProjectEvents(const FileCheck: Boolean);

var
   i: Integer;

begin

  LogText('TBuildOptionExpert.SaveProjectEvents (FileCheck: %s)',
    [BoolToStr(FileCheck, True)]);

   if ProjOptions.FileName <> ''
   then
      begin

         if FileCheck
         then
            if not FileExists(ProjOptions.FileName) then
            begin
               LogText('%s - File Not Found!', [ProjOptions.FileName]);
               Exit;
            end;

         with TIniFile.Create(ProjOptions.FileName) do
         try

            for i := 0 to FPlatformConfigBuildOptions.Count - 1 do
               begin

                  WriteString(FPlatformConfigBuildOptions[i].FPlatformConfig, 'PreBuild',
                     ConvertBuildEventStringToIniFormat(FPlatformConfigBuildOptions[i].PreBuildEvents));
                  WriteString(FPlatformConfigBuildOptions[i].FPlatformConfig, 'PostBuild',
                    ConvertBuildEventStringToIniFormat(FPlatformConfigBuildOptions[i].PostBuildEvents));
                  WriteInteger(FPlatformConfigBuildOptions[i].FPlatformConfig, 'BuildEvent', Integer(FPlatformConfigBuildOptions[i].PostBuildOption));
                  WriteBool(FPlatformConfigBuildOptions[i].FPlatformConfig, 'PreBuildEnabled', FPlatformConfigBuildOptions[i].PreBuildEnabled);
                  WriteBool(FPlatformConfigBuildOptions[i].FPlatformConfig, 'PostBuildEnabled', FPlatformConfigBuildOptions[i].PostBuildEnabled);

               end;

            LogText('%s - File Saved', [ProjOptions.FileName]);

         finally
            Free;
         end;

      end;

   LogText('TBuildOptionExpert.SaveProjectEvents (FileCheck: %s)',
    [BoolToStr(FileCheck, True)]);

end;

function TBuildOptions.ShowDialog(AFileName: String): Boolean;
begin
   LoadProjectEvents(AFileName);
   Result := BuildOptionsForm.Execute(Self);
end;

procedure TProjOptions.SetFileName(const Value: string);
var
  FileExt: string;
begin
  LogText('In - TBuildOptions.SetFileName: Value=%s, FileName=%s',
    [FFileName, Value]);
  if FFileName <> Value then
  begin

    if Value <> ''
    then
       begin

          FileExt := LowerCase(ExtractFileExt(Value));
          if FileExt <> '.ini' then
            FFileName := ChangeFileExt(Value, '.ini')
          else
            FFileName := Value;

       end
    else
       FFileName := '';

  end;
  LogText('Out - TBuildOptions.SetFileName: Value=%s, FileName=%s',
    [FFileName, Value]);
end;

procedure TBuildOptions.SaveAll;
begin
  LogText('In - TBuildOptions.SaveAll');
  SaveProjectEvents;
  LogText('Out - TBuildOptions.SaveAll');
end;

procedure TBuildOptions.ClearEvents;

var
   i: Integer;

begin

  ProjOptions.FileName := '';

  LogText('In - TBuildOptions.ClearEvents');

  for i := FPlatformConfigBuildOptions.Count - 1 downto 0 do
     begin
        FPlatformConfigBuildOptions[i].FPreBuildEvents.DisposeOf;
        FPlatformConfigBuildOptions[i].FPostBuildEvents.DisposeOf;
        FPlatformConfigBuildOptions.Delete(i);
     end;

  FPlatformConfigBuildOptions.Clear;

  LogText('Out - TBuildOptions.ClearEvents');

end;

constructor TProjOptions.Create;
begin
   FParams := TList<TParam>.Create;
end;

destructor TProjOptions.Destroy;
begin
  FParams.DisposeOf;
  inherited;
end;

function TProjOptions.GetFileName: String;
begin
  Result := EmptyStr;
  if (FFileName = '') then
    FFileName := GetCurrentProjectFileName;
  if (FFileName <> '') then
  begin
    FFileName := ChangeFileExt(FFileName, '.ini');
    Result := FFileName;
  end;
  LogText('TBuildOptions.GetFileName(Result: %s)', [Result]);
end;

function TProjOptions.GetParam(Name: String): TParam;

var
   i: Integer;

begin

   for i := 0 to FParams.Count - 1 do
      if FParams[i].Name = Name
      then
         Result := FParams[i];

end;

procedure TBuildOptions.Reset;
begin
  LogText('In - TBuildOptions.Reset(FileName: %s)', [ProjOptions.FileName]);
  ProjOptions.FileName := '';
  ClearEvents;
  LogText('Out - TBuildOptions.Reset(FileName: %s)', [ProjOptions.FileName]);
end;

constructor TPlatformConfigBuildOptions.Create;
begin

   FPreBuildEvents := TList<TBuildCommand>.Create;
   FPostBuildEvents :=  TList<TBuildCommand>.Create;

end;

//procedure TPlatformConfigBuildOptions.SetPostBuildEvents(AValue: TStringList);
//begin
//  FPostBuildEvents.Assign(AValue);
//end;
//
//procedure TPlatformConfigBuildOptions.SetPreBuildEvents(AValue: TStringList);
//begin
//  FPreBuildEvents.Assign(AValue);
//end;

end.
