{ ********************************************************************** }
{ ******** Custom Delphi IDE Build Notifier for Build Options ********** }
{ ******* Written by Kiran Kurapaty (kuraki@morganstanley.com) ********* }
{ ********************************************************************** }
unit uBuildNotifier;
interface
{$I BuildEvents.inc}
uses
  Windows, SysUtils, Controls, Graphics, Classes, Menus, ActnList, ToolsAPI,
  Dialogs, Forms;
type
  TProjectCompileNotifier = class(TInterfacedObject, IOTAProjectCompileNotifier)
  protected
    procedure AfterCompile(var CompileInfo: TOTAProjectCompileInfo);
    procedure BeforeCompile(var CompileInfo: TOTAProjectCompileInfo);
    procedure Destroyed;
  end;

  TCompileNotifier = class(TInterfacedObject, IOTACompileNotifier)
  protected
    procedure ProjectCompileStarted(const Project: IOTAProject; Mode: TOTACompileMode);
    procedure ProjectCompileFinished(const Project: IOTAProject; Result: TOTACompileResult);
    procedure ProjectGroupCompileStarted(Mode: TOTACompileMode);
    procedure ProjectGroupCompileFinished(Result: TOTACompileResult);
  end;
implementation
uses
  uBuildEngine,
  uBuildOptionExpert,
  uBuildMisc;
const
  C_OTA_FILE_NOTIFICATION_STR : array [TOTAFileNotification] of String = (
    'ofnFileOpening', 'ofnFileOpened', 'ofnFileClosing',
    'ofnDefaultDesktopLoad', 'ofnDefaultDesktopSave', 'ofnProjectDesktopLoad',
    'ofnProjectDesktopSave', 'ofnPackageInstalled', 'ofnPackageUninstalled',
    'ofnActiveProjectChanged', 'ofnProjectOpenedFromTemplate',
    'ofnBeginProjectGroupOpen', 'ofnEndProjectGroupOpen', 'ofnBeginProjectGroupClose',
    'ofnEndProjectGroupClose');

{ TBuildNotifier }
var
   ProjCompNot: integer;
   Intf: IOTAProjectCompileNotifier;

{ TProjectCompileNotifier }

procedure TCompileNotifier.ProjectCompileFinished(const Project: IOTAProject;
  Result: TOTACompileResult);
begin
//   Project.ProjectBuilder.RemoveCompileNotifier(ProjCompNot);
   BuildOptionExpert.FBuildSuccess := Result = crOTASucceeded;
   BuildOptionExpert.FBuildSpan := (Now - BuildOptionExpert.FBuildSpan);

  try
    case (BuildOptionExpert.Options.GetPlatformConfigBuildOptions(GetCurrentProject.CurrentPlatform + GetCurrentProject.CurrentConfiguration).PostBuildOption) of
      boSuccess:
        if (BuildOptionExpert.FBuildSuccess) then
          BuildOptionExpert.ExecutePostBuildEvent('Build Success');
//      boFailed:
//        if (not BuildOptionExpert.FBuildSuccess) then
//          BuildOptionExpert.ExecutePostBuildEvent('Build Failed');
      boAlways:
        BuildOptionExpert.ExecutePostBuildEvent('After Build');
      boNone:
        BuildOptionExpert.LogLine(mtDebug, '%s Compiled in %s',
          [BuildOptionExpert.ProjectName, GetDoneTimeStr(BuildOptionExpert.FBuildSpan)]);
    end;
  finally
    BuildOptionExpert.FBuildSuccess := False;
  end;

end;

procedure TCompileNotifier.ProjectCompileStarted(const Project: IOTAProject;
  Mode: TOTACompileMode);
begin

//   Intf := TProjectCompileNotifier.Create;
//   ProjCompNot := Project.ProjectBuilder.AddCompileNotifier(Intf);

   BuildOptionExpert.ExecutePreBuildEvent;
end;

procedure TCompileNotifier.ProjectGroupCompileFinished(
  Result: TOTACompileResult);
begin

end;

procedure TCompileNotifier.ProjectGroupCompileStarted(Mode: TOTACompileMode);
begin

end;

procedure TProjectCompileNotifier.AfterCompile(
  var CompileInfo: TOTAProjectCompileInfo);
begin

end;

procedure TProjectCompileNotifier.BeforeCompile(
  var CompileInfo: TOTAProjectCompileInfo);
begin
end;

procedure TProjectCompileNotifier.Destroyed;
begin

end;

end.
